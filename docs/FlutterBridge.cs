using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using UnityEngine;

namespace Unity.FlutterBridge
{
    /// <summary>
    /// Flutter ↔ Unity 消息桥接中心。
    /// 
    /// 【使用方式】
    /// 1. 在场景中创建一个空 GameObject，命名为 "FlutterBridge"（必须与 Flutter 侧 UnitySendMessage 的目标一致）
    /// 2. 将此脚本挂载到该 GameObject 上
    /// 3. 其他模块通过 FlutterBridge.Instance 访问
    /// 
    /// 【通信协议】
    /// 所有消息格式统一为 JSON：
    /// {
    ///   "type": "消息类型字符串",
    ///   "data": { ... }
    /// }
    /// 
    /// 【接收消息】Flutter → Unity
    /// Flutter 通过 MethodChannel 调用 Android/iOS 原生层，
    /// 原生层再通过 UnitySendMessage("FlutterBridge", "OnFlutterMessage", jsonString) 转发给 Unity。
    /// 
    /// 【发送消息】Unity → Flutter
    /// Unity 调用 SendToFlutter()，内部通过 Android/iOS 原生层的反向通道转发给 Flutter。
    /// Android: UnityPlayer.currentActivity.Call("onUnityMessage", json)
    /// iOS: 通过 DllImport 调用原生方法
    /// </summary>
    public class FlutterBridge : MonoBehaviour
    {
        public static FlutterBridge Instance { get; private set; }

        // ==================== Flutter → Unity 事件 ====================
        
        /// <summary>进入剧情场景</summary>
        public event Action<EnterSceneData> OnEnterScene;
        /// <summary>退出剧情场景</summary>
        public event Action OnExitScene;
        /// <summary>同步用户进度</summary>
        public event Action<UserProgressData> OnUserProgress;
        /// <summary>同步蓝牙连接状态</summary>
        public event Action<BluetoothStateData> OnBluetoothState;
        /// <summary>蓝牙开关</summary>
        public event Action<bool> OnBluetoothToggle;
        /// <summary>暂停/恢复剧情</summary>
        public event Action<bool> OnPauseStory;
        /// <summary>全局跳过剧情</summary>
        public event Action OnSkipStory;
        /// <summary>跳过当前检查点字幕段落</summary>
        public event Action OnSkipCheckpoint;
        /// <summary>跳到下一个检查点</summary>
        public event Action OnSkipToNextCheckpoint;

        // ==================== 内部状态 ====================
        
        /// <summary>Flutter 传入的权限列表，替代原来的 SysRolePermissionCache</summary>
        public List<string> CurrentPermissions { get; private set; } = new List<string>();
        
        /// <summary>Flutter 传入的蓝牙连接状态，替代原来的 UserDataManager.GetCurDeviceIsConnected()</summary>
        public bool IsBluetoothConnected { get; private set; }
        
        /// <summary>Flutter 传入的蓝牙开关状态</summary>
        public bool IsBluetoothEnabled { get; private set; } = true;

        /// <summary>Flutter 传入的设备型号</summary>
        public string DeviceModel { get; private set; }

#if UNITY_IOS && !UNITY_EDITOR
        [System.Runtime.InteropServices.DllImport("__Internal")]
        private static extern void onUnityMessage(string json);
#endif

        private void Awake()
        {
            if (Instance == null)
            {
                Instance = this;
                DontDestroyOnLoad(gameObject);
            }
            else
            {
                Destroy(gameObject);
            }
        }

        private void OnDestroy()
        {
            if (Instance == this) Instance = null;
        }

        // ==================== 接收 Flutter 消息的入口 ====================

        /// <summary>
        /// Flutter 通过 UnitySendMessage("FlutterBridge", "OnFlutterMessage", json) 调用此方法。
        /// json 格式: { "type": "enterScene", "data": { ... } }
        /// </summary>
        public void OnFlutterMessage(string json)
        {
            try
            {
                var msg = JsonConvert.DeserializeObject<BridgeMessage>(json);
                if (msg == null) return;
                DispatchMessage(msg.type, msg.data);
            }
            catch (Exception e)
            {
                Debug.LogError($"[FlutterBridge] 解析消息失败: {e.Message}\nJSON: {json}");
            }
        }

        private void DispatchMessage(string type, Dictionary<string, object> data)
        {
            switch (type)
            {
                case FlutterToUnity.EnterScene:
                    HandleEnterScene(data);
                    break;

                case FlutterToUnity.ExitScene:
                    OnExitScene?.Invoke();
                    break;

                case FlutterToUnity.UserProgress:
                    HandleUserProgress(data);
                    break;

                case FlutterToUnity.BluetoothState:
                    HandleBluetoothState(data);
                    break;

                case FlutterToUnity.BluetoothToggle:
                    HandleBluetoothToggle(data);
                    break;

                case FlutterToUnity.PauseStory:
                    HandlePauseStory(data);
                    break;

                case FlutterToUnity.SkipStory:
                    OnSkipStory?.Invoke();
                    break;

                case FlutterToUnity.SkipCheckpoint:
                    OnSkipCheckpoint?.Invoke();
                    break;

                case FlutterToUnity.SkipToNextCheckpoint:
                    OnSkipToNextCheckpoint?.Invoke();
                    break;

                default:
                    Debug.LogWarning($"[FlutterBridge] 未知消息类型: {type}");
                    break;
            }
        }

        // ==================== 发送消息给 Flutter ====================

        /// <summary>
        /// 向 Flutter 发送消息。
        /// </summary>
        public void SendToFlutter(string type, Dictionary<string, object> data = null)
        {
            var msg = new BridgeMessage { type = type, data = data ?? new Dictionary<string, object>() };
            string json = JsonConvert.SerializeObject(msg);

            try
            {
#if UNITY_ANDROID && !UNITY_EDITOR
                using (var unityPlayer = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                using (var activity = unityPlayer.GetStatic<AndroidJavaObject>("currentActivity"))
                {
                    // 调用 Flutter 侧注册的 MethodChannel 回调
                    // 原生 Activity 需要实现 onUnityMessage(String json) 方法
                    activity.Call("onUnityMessage", json);
                }
#elif UNITY_IOS && !UNITY_EDITOR
                onUnityMessage(json);
#else
                Debug.Log($"[FlutterBridge] SendToFlutter: {json}");
#endif
            }
            catch (Exception e)
            {
                Debug.LogError($"[FlutterBridge] 发送消息失败: {e.Message}");
            }
        }

        // ==================== 便捷发送方法（Unity → Flutter） ====================

        /// <summary>
        /// 发送蓝牙控制信号。替代原来的 SDKManager.Instance.SendToBluetoothParameter()
        /// </summary>
        public void SendBluetoothSignal(int swing, int vibration, int durationMs = 0, int delayMs = 0)
        {
            SendToFlutter(UnityToFlutter.BluetoothSignal, new Dictionary<string, object>
            {
                { "swing", Mathf.Clamp(swing, 0, 100) },
                { "vibration", Mathf.Clamp(vibration, 0, 100) },
                { "durationMs", durationMs },
                { "delayMs", delayMs }
            });
        }

        /// <summary>
        /// 请求 Flutter 上报检查点进度。替代原来的 UserProgressesCreateAPI
        /// </summary>
        public void SendCheckpointProgress(string storyCode, string checkpointCode, long checkpointOrder, string roleCode)
        {
            SendToFlutter(UnityToFlutter.CheckpointProgress, new Dictionary<string, object>
            {
                { "storyCode", storyCode },
                { "checkpointCode", checkpointCode },
                { "checkpointOrder", checkpointOrder },
                { "roleCode", roleCode }
            });
        }

        /// <summary>
        /// 广播剧情状态变化
        /// </summary>
        public void SendStoryStateChanged(StoryStateEnum state)
        {
            string stateStr = state switch
            {
                StoryStateEnum.None => "none",
                StoryStateEnum.PlayLive2DAnimation => "playLive2DAnimation",
                StoryStateEnum.PlayCheckpointDialogue => "playCheckpointDialogue",
                _ => "none"
            };
            SendToFlutter(UnityToFlutter.StoryStateChanged, new Dictionary<string, object>
            {
                { "state", stateStr }
            });
        }

        /// <summary>
        /// 推送检查点字幕文本
        /// </summary>
        public void SendPlayCheckpoint(string text, int currentIndex, int lastPlayableIndex, string userIsFinished)
        {
            SendToFlutter(UnityToFlutter.PlayCheckpoint, new Dictionary<string, object>
            {
                { "text", text },
                { "currentIndex", currentIndex },
                { "lastPlayableIndex", lastPlayableIndex },
                { "userIsFinished", userIsFinished }
            });
        }

        /// <summary>
        /// 停止检查点字幕
        /// </summary>
        public void SendStopCheckpoint()
        {
            SendToFlutter(UnityToFlutter.StopCheckpoint);
        }

        /// <summary>
        /// 推送对白显示
        /// </summary>
        public void SendPlayDialogue(int dialogueId)
        {
            SendToFlutter(UnityToFlutter.PlayDialogue, new Dictionary<string, object>
            {
                { "dialogueId", dialogueId }
            });
        }

        /// <summary>
        /// 停止对白显示
        /// </summary>
        public void SendStopDialogue(int dialogueId)
        {
            SendToFlutter(UnityToFlutter.StopDialogue, new Dictionary<string, object>
            {
                { "dialogueId", dialogueId }
            });
        }

        /// <summary>
        /// 通知 Flutter 动画开始播放，加载字幕
        /// </summary>
        public void SendPlayMotionSubtitle(string clipName, int checkpointIndex)
        {
            SendToFlutter(UnityToFlutter.PlayMotionSubtitle, new Dictionary<string, object>
            {
                { "clipName", clipName },
                { "checkpointIndex", checkpointIndex }
            });
        }

        /// <summary>
        /// 请求切换屏幕方向
        /// </summary>
        public void SendOrientationRequest(bool landscape)
        {
            SendToFlutter(UnityToFlutter.OrientationRequest, new Dictionary<string, object>
            {
                { "orientation", landscape ? "landscape" : "portrait" }
            });
        }

        /// <summary>
        /// 请求返回 Flutter
        /// </summary>
        public void SendRequestExit()
        {
            SendToFlutter(UnityToFlutter.RequestExit);
        }

        /// <summary>
        /// 整个剧情完成
        /// </summary>
        public void SendStoryComplete(string storyId)
        {
            SendToFlutter(UnityToFlutter.StoryComplete, new Dictionary<string, object>
            {
                { "storyId", storyId }
            });
        }

        // ==================== 私有解析方法 ====================

        private void HandleEnterScene(Dictionary<string, object> data)
        {
            var parsed = new EnterSceneData();
            if (data.TryGetValue("characterId", out var cid)) parsed.characterId = cid?.ToString();
            if (data.TryGetValue("sceneId", out var sid)) parsed.sceneId = sid?.ToString();
            if (data.TryGetValue("storyId", out var stid)) parsed.storyId = stid?.ToString();

            if (data.TryGetValue("permissions", out var perms) && perms != null)
            {
                parsed.permissions = JsonConvert.DeserializeObject<List<string>>(perms.ToString()) ?? new List<string>();
                CurrentPermissions = parsed.permissions;
            }

            if (data.TryGetValue("checkpoints", out var cps) && cps != null)
            {
                parsed.checkpoints = JsonConvert.DeserializeObject<List<CheckpointData>>(cps.ToString()) ?? new List<CheckpointData>();
            }

            OnEnterScene?.Invoke(parsed);
        }

        private void HandleUserProgress(Dictionary<string, object> data)
        {
            var parsed = new UserProgressData();
            if (data.TryGetValue("storyId", out var sid)) parsed.storyId = sid?.ToString();
            if (data.TryGetValue("completedSections", out var cs) && cs != null)
            {
                parsed.completedSections = JsonConvert.DeserializeObject<List<string>>(cs.ToString()) ?? new List<string>();
            }
            OnUserProgress?.Invoke(parsed);
        }

        private void HandleBluetoothState(Dictionary<string, object> data)
        {
            var parsed = new BluetoothStateData();
            if (data.TryGetValue("connected", out var conn))
            {
                parsed.connected = Convert.ToBoolean(conn);
                IsBluetoothConnected = parsed.connected;
            }
            if (data.TryGetValue("deviceModel", out var dm))
            {
                parsed.deviceModel = dm?.ToString();
                DeviceModel = parsed.deviceModel;
            }
            OnBluetoothState?.Invoke(parsed);
        }

        private void HandleBluetoothToggle(Dictionary<string, object> data)
        {
            bool enabled = true;
            if (data.TryGetValue("enabled", out var e))
            {
                enabled = Convert.ToBoolean(e);
            }
            IsBluetoothEnabled = enabled;
            OnBluetoothToggle?.Invoke(enabled);
        }

        private void HandlePauseStory(Dictionary<string, object> data)
        {
            bool isPause = false;
            if (data.TryGetValue("isPause", out var p))
            {
                isPause = Convert.ToBoolean(p);
            }
            OnPauseStory?.Invoke(isPause);
        }

        /// <summary>
        /// 检查是否拥有指定权限。替代原来的 SysRolePermissionCache.HasPermissionCode()
        /// </summary>
        public bool HasPermission(string permissionCode)
        {
            return CurrentPermissions.Contains(permissionCode);
        }
    }

    // ==================== 消息常量 ====================

    public static class FlutterToUnity
    {
        public const string EnterScene = "enterScene";
        public const string ExitScene = "exitScene";
        public const string UserProgress = "userProgress";
        public const string BluetoothState = "bluetoothState";
        public const string BluetoothToggle = "bluetoothToggle";
        public const string PauseStory = "pauseStory";
        public const string SkipStory = "skipStory";
        public const string SkipCheckpoint = "skipCheckpoint";
        public const string SkipToNextCheckpoint = "skipToNextCheckpoint";
    }

    public static class UnityToFlutter
    {
        public const string BluetoothSignal = "bluetoothSignal";
        public const string CheckpointProgress = "checkpointProgress";
        public const string StoryStateChanged = "storyStateChanged";
        public const string PlayCheckpoint = "playCheckpoint";
        public const string StopCheckpoint = "stopCheckpoint";
        public const string PlayDialogue = "playDialogue";
        public const string StopDialogue = "stopDialogue";
        public const string PlayMotionSubtitle = "playMotionSubtitle";
        public const string OrientationRequest = "orientationRequest";
        public const string RequestExit = "requestExit";
        public const string StoryComplete = "storyComplete";
    }

    // ==================== 数据结构 ====================

    [Serializable]
    public class BridgeMessage
    {
        public string type;
        public Dictionary<string, object> data = new Dictionary<string, object>();
    }

    public enum StoryStateEnum
    {
        None,
        PlayLive2DAnimation,
        PlayCheckpointDialogue
    }

    [Serializable]
    public class EnterSceneData
    {
        public string characterId;
        public string sceneId;
        public string storyId;
        public List<string> permissions = new List<string>();
        public List<CheckpointData> checkpoints = new List<CheckpointData>();
    }

    /// <summary>
    /// 与服务端 StoryProcessApi.CheckPoint 结构对齐
    /// </summary>
    [Serializable]
    public class CheckpointData
    {
        public string checkpointCode;
        public long? checkpointId;
        public string checkpointName;
        public long checkpointOrder;
        public string description;
        public long? isEnd;
        public long? isStart;
        public string roleCode;
        public long? status;
        public string storyCode;
        public string userIsFinished;
    }

    [Serializable]
    public class UserProgressData
    {
        public string storyId;
        public List<string> completedSections = new List<string>();
    }

    [Serializable]
    public class BluetoothStateData
    {
        public bool connected;
        public string deviceModel;
    }
}
