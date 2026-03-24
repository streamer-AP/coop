# Unity-Flutter 剧情桥接接口文档

## 1. 架构概述

重构后 Unity 作为 library 嵌入 Flutter APP。剧情模块（Live2D 动画 + 检查点字幕）仍在 Unity 内运行，但 **网络请求、蓝牙控制、用户进度存储、权限判断** 全部移交 Flutter 管理。

两端通过 JSON 消息通信：

```
Flutter ──MethodChannel──> Android/iOS 原生层 ──UnitySendMessage──> Unity (FlutterBridge.cs)
Unity (FlutterBridge.cs) ──原生层 onUnityMessage──> MethodChannel ──> Flutter (UnityBridge.dart)
```

**消息统一格式：**

```json
{
  "type": "消息类型字符串",
  "data": { ... }
}
```

---

## 2. 文件清单

| 文件 | 位置 | 说明 |
|------|------|------|
| `FlutterBridge.cs` | `Assets/_Code/Module/FlutterBridge/` | **Unity 侧消息中心**（已写好，直接用） |
| `unity_bridge.dart` | Flutter `lib/core/platform/` | Flutter 侧 MethodChannel 收发（已有） |
| `unity_message.dart` | Flutter `lib/core/platform/` | 消息类型常量（需更新） |
| `story_bridge_service.dart` | Flutter `lib/features/story/application/services/` | Flutter 侧业务逻辑调度（需更新） |

---

## 3. Flutter → Unity 接口（9 个）

### 3.1 `enterScene` — 进入剧情场景

**时机**：用户在剧情列表页点击某个剧情，Flutter 准备好数据后发送。

```json
{
  "type": "enterScene",
  "data": {
    "characterId": "doctorOrven",
    "sceneId": "BattleScene",
    "storyId": "ch01_v0_stage_sec01",
    "permissions": ["PAGE_STORY_ORVEN_1_1", "PAGE_STORY_ORVEN_1_2"],
    "checkpoints": [
      {
        "checkpointCode": "ch01_v0_stage_sec01_checkpoint00",
        "checkpointId": 4,
        "checkpointName": "检查点00",
        "checkpointOrder": 1,
        "description": "检查点00-空",
        "isEnd": 0,
        "isStart": 1,
        "roleCode": "doctorOrven",
        "status": 1,
        "storyCode": "ch01_v0_stage_sec01",
        "userIsFinished": "0"
      }
    ]
  }
}
```

**Unity 侧处理（`FlutterBridge.cs` 已实现）：**
- 将 `permissions` 存入 `FlutterBridge.CurrentPermissions`
- 将 `checkpoints` 数据解析为 `List<CheckpointData>`
- 触发 `OnEnterScene` 事件

**Unity 侧改造点（`BattleState.cs`）：**

```csharp
// 原来的代码：
private async UniTask GetStoryData()
{
    var StoryProcess = new StoryProcessApi();
    // ... 网络请求 ...
    data = StoryProcess.response.data;
}

// 改为：
// BattleState 订阅 FlutterBridge.OnEnterScene 事件，
// 直接使用传入的 checkpoints 数据，不再调网络
internal override async UniTask OnEnter()
{
    await base.OnEnter();
    FlutterBridge.Instance.OnEnterScene += HandleEnterScene;
    // ... 其余初始化 ...
}

private void HandleEnterScene(EnterSceneData sceneData)
{
    // 将 CheckpointData 转换为原来的 StoryProcessApi.CheckPoint[]
    data = ConvertCheckpoints(sceneData.checkpoints);
    curStoryCode = sceneData.storyId;
    // 然后继续原来的流程：ShowStoryPawn() 等
}
```

---

### 3.2 `exitScene` — 退出剧情场景

```json
{
  "type": "exitScene",
  "data": {}
}
```

**Unity 侧处理**：停止剧情，清理资源，等同于原来的 `C2C_SkipStory` + 退出流程。

---

### 3.3 `userProgress` — 同步已完成章节

```json
{
  "type": "userProgress",
  "data": {
    "storyId": "ch01_v0_stage_sec01",
    "completedSections": ["ch01_v0_stage_sec01_checkpoint00", "ch01_v0_stage_sec01_checkpoint01"]
  }
}
```

**Unity 侧处理**：更新本地 `_sortedCheckpoints` 中对应检查点的 `userIsFinished = "1"`。

---

### 3.4 `bluetoothState` — 同步蓝牙连接状态

```json
{
  "type": "bluetoothState",
  "data": {
    "connected": true,
    "deviceModel": "OMAO-001"
  }
}
```

**Unity 侧处理（`FlutterBridge.cs` 已实现）：**
- 更新 `FlutterBridge.IsBluetoothConnected`
- 更新 `FlutterBridge.DeviceModel`

**Unity 侧改造点**：所有 `UserDataManager.GetCurDeviceIsConnected()` 替换为 `FlutterBridge.Instance.IsBluetoothConnected`

---

### 3.5 `bluetoothToggle` — 开关蓝牙控制

```json
{
  "type": "bluetoothToggle",
  "data": {
    "enabled": false
  }
}
```

**Unity 侧处理**：当 `enabled=false` 时，蓝牙信号发送暂停。更新 `FlutterBridge.IsBluetoothEnabled`。

---

### 3.6 `pauseStory` — 暂停/恢复剧情

```json
{
  "type": "pauseStory",
  "data": {
    "isPause": true
  }
}
```

**Unity 侧处理**：等同于原来的 `C2C_StorySetPause`，控制动画速度 + TimeScale + BGM 暂停。

**Unity 侧改造点（`BattlePawn.cs`）：**

```csharp
// 在 EventAddListener() 中添加：
FlutterBridge.Instance.OnPauseStory += (isPause) =>
{
    OnC2C_StorySetPauseEvent(new MSG_State.C2C_StorySetPause { isPause = isPause });
};
```

---

### 3.7 `skipStory` — 全局跳过剧情

```json
{
  "type": "skipStory",
  "data": {}
}
```

**Unity 侧处理**：等同于原来的 `C2C_SkipStory`，终止所有动画和检查点播放。

---

### 3.8 `skipCheckpoint` — 跳过当前字幕段落

```json
{
  "type": "skipCheckpoint",
  "data": {}
}
```

**Unity 侧处理**：等同于原来的 `C2C_SkipCheckpointEvent`，逐段跳过当前检查点的字幕。

---

### 3.9 `skipToNextCheckpoint` — 跳到下一个检查点

```json
{
  "type": "skipToNextCheckpoint",
  "data": {}
}
```

**Unity 侧处理**：等同于原来的 `C2C_SkipCheckpointNewEvent`，跳过当前检查点 + 动画，直接进入下一段。

---

## 4. Unity → Flutter 接口（11 个）

### 4.1 `bluetoothSignal` — 蓝牙控制信号

**时机**：剧情动画播放过程中，根据 `.bluetooth.json` 配置或实时计算发送。

```json
{
  "type": "bluetoothSignal",
  "data": {
    "swing": 50,
    "vibration": 70,
    "durationMs": 200,
    "delayMs": 0
  }
}
```

**字段说明**：
- `swing`：摇摆强度 0-100
- `vibration`：震动强度 0-100
- `durationMs`：持续时间（毫秒）
- `delayMs`：延迟时间（毫秒）

**Unity 侧改造点（`NewBattleUIUIDesigner.cs`）：**

```csharp
// 原来的代码：
if (UserDataManager.GetCurDeviceIsConnected())
{
    SDKManager.Instance.SendToBluetoothParameter(result.swingLevel, result.vibrationLevel, result.duration, result.delay);
}

// 改为：
if (FlutterBridge.Instance.IsBluetoothConnected && FlutterBridge.Instance.IsBluetoothEnabled)
{
    FlutterBridge.Instance.SendBluetoothSignal(result.swingLevel, result.vibrationLevel, result.duration, result.delay);
}
```

**Flutter 侧处理（`StoryBridgeService` 已实现）**：收到后通过 `BleSignalArbitrator` 仲裁，以 story 优先级发送给蓝牙设备。

---

### 4.2 `checkpointProgress` — 请求上报检查点进度

**时机**：每个检查点播放完成后，在进入下一个检查点之前发送。

```json
{
  "type": "checkpointProgress",
  "data": {
    "storyCode": "ch01_v0_stage_sec01",
    "checkpointCode": "ch01_v0_stage_sec01_checkpoint00",
    "checkpointOrder": 1,
    "roleCode": "doctorOrven"
  }
}
```

**Unity 侧改造点（`BattlePawn.cs`）：**

```csharp
// 原来的代码：
private async UniTask SendCheckpointIsFinishedToServer(string _storyCode, string _checkpointCode, long checkpointOrder, string _roleCode)
{
    var UserProgressesCreate = new UserProgressesCreateAPI();
    // ... 直接调网络接口 ...
}

// 改为：
private void SendCheckpointIsFinishedToServer(string _storyCode, string _checkpointCode, long checkpointOrder, string _roleCode)
{
    FlutterBridge.Instance.SendCheckpointProgress(_storyCode, _checkpointCode, checkpointOrder, _roleCode);
    
    // 同时更新本地状态（乐观更新）
    for (int i = 0; i < _sortedCheckpoints.Count; i++)
    {
        if (_sortedCheckpoints[i].checkpointCode == _checkpointCode)
        {
            _sortedCheckpoints[i].userIsFinished = "1";
            break;
        }
    }
}
```

**Flutter 侧处理**：收到后调用 `/userProgresses/create` 接口上报给服务器，然后通过 `userProgress` 消息反馈已完成列表给 Unity。

---

### 4.3 `storyStateChanged` — 剧情状态变化

```json
{
  "type": "storyStateChanged",
  "data": {
    "state": "playLive2DAnimation"
  }
}
```

**state 取值**：
- `"none"` — 空闲
- `"playLive2DAnimation"` — 正在播放 Live2D 动画
- `"playCheckpointDialogue"` — 正在播放检查点字幕

**Unity 侧改造点（`BattlePawn.cs`）：**

```csharp
// 原来的代码（通过 MessageBus 内部广播）：
private StoryState curStoryState
{
    set
    {
        _curStoryState = value;
        m_MessageBus?.Publish<MSG_State.C2C_StoryState>(...);
    }
}

// 额外添加：同时通知 Flutter
private StoryState curStoryState
{
    set
    {
        _curStoryState = value;
        m_MessageBus?.Publish<MSG_State.C2C_StoryState>(...);
        // 新增：通知 Flutter
        FlutterBridge.Instance?.SendStoryStateChanged((StoryStateEnum)(int)value);
    }
}
```

---

### 4.4 `playCheckpoint` — 推送检查点字幕

```json
{
  "type": "playCheckpoint",
  "data": {
    "text": "在那遥远的星球...",
    "currentIndex": 2,
    "lastPlayableIndex": 4,
    "userIsFinished": "0"
  }
}
```

**Unity 侧改造点（`BattlePawn.cs` 的 `PlayTypewriterEffect` 方法）：**

```csharp
// 原来通过 MessageBus 内部广播 C2C_PlayCheckpointEvent
// 额外添加：同时通知 Flutter
FlutterBridge.Instance?.SendPlayCheckpoint(segment.ShowText, _curCheckpointIndex, _lastPlayableCheckpointIndex, userIsFinished);
```

---

### 4.5 `stopCheckpoint` — 停止字幕显示

```json
{
  "type": "stopCheckpoint",
  "data": {}
}
```

**Unity 侧**：在 `ResetUI()` 方法中，发布 `C2C_StopCheckpointEvent` 时同时调用 `FlutterBridge.Instance?.SendStopCheckpoint()`。

---

### 4.6 `playDialogue` — 对白显示

```json
{
  "type": "playDialogue",
  "data": {
    "dialogueId": 1001
  }
}
```

**Unity 侧**：在动画事件触发 `C2C_PlayDialogueEvent` 时同时调用 `FlutterBridge.Instance?.SendPlayDialogue(id)`。

---

### 4.7 `stopDialogue` — 停止对白

```json
{
  "type": "stopDialogue",
  "data": {
    "dialogueId": 1001
  }
}
```

---

### 4.8 `playMotionSubtitle` — 动画开始播放，通知加载字幕

```json
{
  "type": "playMotionSubtitle",
  "data": {
    "clipName": "ch01_v0_stage_sec01_m01",
    "checkpointIndex": 0
  }
}
```

**Unity 侧**：在 `ShowOneAnimationClip()` 方法中，发布 `C2C_PlayMotionSubtitleFile` 时同时调用 `FlutterBridge.Instance?.SendPlayMotionSubtitle(clipName, checkpointIndex)`。

---

### 4.9 `orientationRequest` — 请求切换屏幕方向

```json
{
  "type": "orientationRequest",
  "data": {
    "orientation": "landscape"
  }
}
```

**取值**：`"portrait"` 竖屏 / `"landscape"` 横屏

**Unity 侧改造点（`BattleState.cs`）：**

```csharp
// 原来的代码：
ScreenOrientationManager.Instance.SwitchToLandscape();

// 改为：
FlutterBridge.Instance?.SendOrientationRequest(true); // true = landscape
```

**注意**：Unity 作为 library 嵌入后，不应再直接调用 `Screen.orientation`，必须让 Flutter 宿主 APP 来控制。

---

### 4.10 `requestExit` — 请求返回 Flutter

```json
{
  "type": "requestExit",
  "data": {}
}
```

**时机**：剧情播放完毕或用户手动退出时发送。

**Flutter 侧处理（已实现）**：收到后调用 `exitScene(notifyUnity: false)` 释放蓝牙信号源，切换回 Flutter 视图。

---

### 4.11 `storyComplete` — 整个剧情完成

```json
{
  "type": "storyComplete",
  "data": {
    "storyId": "ch01_v0_stage_sec01"
  }
}
```

**时机**：所有检查点播放完毕后发送。

**Unity 侧改造点（`BattlePawn.cs` 的 `StartStory` 方法末尾）：**

```csharp
// 原来的代码：
m_MessageBus?.Publish(new MSG_State.C2C_SkipStory() {});

// 在此之前添加：
FlutterBridge.Instance?.SendStoryComplete(curStoryCode);
```

**Flutter 侧处理（已实现）**：收到后将该剧情标记为 `isCompleted = true`，更新本地数据库。

---

## 5. 需要改造的 Unity 文件清单

| 文件 | 改造内容 | 优先级 |
|------|----------|--------|
| **`BattleState.cs`** | 1. 接收 `enterScene` 中的 checkpoints 数据，不再调 `StoryProcessApi`<br>2. 屏幕方向切换改为 `FlutterBridge.SendOrientationRequest()`<br>3. 订阅 `OnExitScene`、`OnSkipStory` 事件 | P0 |
| **`BattlePawn.cs`** | 1. `SendCheckpointIsFinishedToServer` 改为 `FlutterBridge.SendCheckpointProgress()`<br>2. `curStoryState` setter 中添加 `FlutterBridge.SendStoryStateChanged()`<br>3. 广播检查点/对白/字幕时同步调 FlutterBridge<br>4. 订阅 `OnPauseStory`、`OnSkipStory`、`OnSkipCheckpoint`、`OnSkipToNextCheckpoint`<br>5. 剧情播完时调 `FlutterBridge.SendStoryComplete()` | P0 |
| **`NewBattleUIUIDesigner.cs`** | 1. `SendToBluetoothParameter` 替换为 `FlutterBridge.SendBluetoothSignal()`<br>2. `UserDataManager.GetCurDeviceIsConnected()` 替换为 `FlutterBridge.Instance.IsBluetoothConnected`<br>3. 蓝牙 Toggle 状态联动 `FlutterBridge.IsBluetoothEnabled` | P0 |
| **`NewBattleUIUILogic.cs`** | 订阅 FlutterBridge 事件，转发给 Designer（如果 UI 逻辑保持 MessageBus 方式则不用改） | P1 |
| **`NewMainStorylineUILogic.cs`** | 剧情列表数据改为从 Flutter 传入（不再调 `StoryresourceApi`、`SysRolePermissionCurrectApi`） | P1 |
| **`ScreenOrientationManager.cs`** | 所有 `SwitchToPortrait()`/`SwitchToLandscape()` 调用点改为通过 FlutterBridge | P0 |

---

## 6. 不需要改的部分

以下逻辑保留在 Unity 内部，不需要桥接：

- **Live2D 动画播放**：AnimancerComponent、AnimationClip 加载、动画事件转发
- **剧情音效/BGM**：`m_AudioComponent.PlayBGM()` / `StopBGM()` 仍由 Unity 自己管理
- **检查点配置读取**：`MotionCheckpointsReader`、`PlayDialogueAudioConfigReader` 等从 StreamingAssets 读取
- **蓝牙信号编排数据**：`MotionFileProcessor` 从 `Resources/bluetooth/` 读取 `.bluetooth.json`
- **Unity 内部事件总线**：`AsyncMessageBus` 的 `C2C_*` 消息仍然在 Unity 内部正常流转，FlutterBridge 只是**额外**将关键事件同步给 Flutter

---

## 7. 迁移步骤（建议顺序）

### 第一步：部署 FlutterBridge

1. 在 Unity 场景中创建 `GameObject` 命名为 `"FlutterBridge"`
2. 挂载 `FlutterBridge.cs` 脚本
3. 确保 `DontDestroyOnLoad` 生效（脚本已处理）

### 第二步：改造蓝牙信号发送

在 `NewBattleUIUIDesigner.cs` 中搜索所有 `SDKManager.Instance.SendToBluetoothParameter`，替换为：

```csharp
if (FlutterBridge.Instance != null && FlutterBridge.Instance.IsBluetoothConnected && FlutterBridge.Instance.IsBluetoothEnabled)
{
    FlutterBridge.Instance.SendBluetoothSignal(swingLevel, vibrationLevel, duration, delay);
}
```

### 第三步：改造检查点进度上报

在 `BattlePawn.cs` 的 `SendCheckpointIsFinishedToServer` 中，删掉 `UserProgressesCreateAPI` 调用，改为：

```csharp
FlutterBridge.Instance?.SendCheckpointProgress(_storyCode, _checkpointCode, checkpointOrder, _roleCode);
```

### 第四步：改造数据源

在 `BattleState.cs` 中：
- 删掉 `GetStoryData()` 的网络请求
- 从 `FlutterBridge.OnEnterScene` 事件获取 checkpoints 数据

### 第五步：改造屏幕方向

搜索所有 `ScreenOrientationManager.Instance.SwitchToLandscape()` 和 `SwitchToPortrait()`，替换为 `FlutterBridge.Instance?.SendOrientationRequest(true/false)`。

### 第六步：订阅 Flutter 控制命令

在 `BattlePawn.cs` 的 `EventAddListener()` 中添加 FlutterBridge 事件订阅：

```csharp
protected override void EventAddListener()
{
    compositeDisposable = new();
    // ... 原来的 MessageBus 订阅保留 ...
    
    // 新增：订阅 Flutter 控制命令
    if (FlutterBridge.Instance != null)
    {
        FlutterBridge.Instance.OnPauseStory += HandleFlutterPause;
        FlutterBridge.Instance.OnSkipStory += HandleFlutterSkip;
        FlutterBridge.Instance.OnSkipCheckpoint += HandleFlutterSkipCheckpoint;
        FlutterBridge.Instance.OnSkipToNextCheckpoint += HandleFlutterSkipToNext;
    }
}

private void HandleFlutterPause(bool isPause)
{
    OnC2C_StorySetPauseEvent(new MSG_State.C2C_StorySetPause { isPause = isPause });
}

private void HandleFlutterSkip()
{
    OnC2C_SkipStory(new MSG_State.C2C_SkipStory());
}

private void HandleFlutterSkipCheckpoint()
{
    SkipCurrentDialogueSegment();
}

private UniTask HandleFlutterSkipToNext()
{
    return PlayNextAnimation();
}
```

记得在 `EventRemoveListener()` 中取消订阅。

### 第七步：添加 Flutter 通知

在关键节点额外调用 FlutterBridge 发送方法（详见第 4 章各接口的 "Unity 侧改造点"）。

---

## 8. Flutter 侧需要更新的代码

### 8.1 `unity_message.dart` — 补充消息类型

```dart
class FlutterToUnityMessages {
  FlutterToUnityMessages._();
  static const enterScene = 'enterScene';
  static const exitScene = 'exitScene';
  static const skipToCheckpoint = 'skipToCheckpoint';
  static const userProgress = 'userProgress';
  static const bluetoothState = 'bluetoothState';
  static const bluetoothToggle = 'bluetoothToggle';
  // 新增：
  static const pauseStory = 'pauseStory';
  static const skipStory = 'skipStory';
  static const skipCheckpoint = 'skipCheckpoint';
  static const skipToNextCheckpoint = 'skipToNextCheckpoint';
}

class UnityToFlutterMessages {
  UnityToFlutterMessages._();
  static const bluetoothSignal = 'bluetoothSignal';
  static const sectionComplete = 'sectionComplete';
  static const checkpointReached = 'checkpointReached';
  static const animationState = 'animationState';
  static const requestExit = 'requestExit';
  static const storyComplete = 'storyComplete';
  // 新增：
  static const storyStateChanged = 'storyStateChanged';
  static const playCheckpoint = 'playCheckpoint';
  static const stopCheckpoint = 'stopCheckpoint';
  static const playDialogue = 'playDialogue';
  static const stopDialogue = 'stopDialogue';
  static const playMotionSubtitle = 'playMotionSubtitle';
  static const checkpointProgress = 'checkpointProgress';
  static const orientationRequest = 'orientationRequest';
}
```

### 8.2 `story_bridge_service.dart` — 补充 handleUnityMessage

```dart
Future<void> handleUnityMessage(UnityMessage message) async {
  switch (message.type) {
    // ... 已有的 case ...
    
    case UnityToFlutterMessages.checkpointProgress:
      await _handleCheckpointProgressReport(message.data);
      break;
    case UnityToFlutterMessages.storyStateChanged:
      // 可选：存储当前状态用于 UI 展示
      break;
    case UnityToFlutterMessages.playCheckpoint:
      // 可选：如果 Flutter 侧要展示字幕 UI
      break;
    case UnityToFlutterMessages.orientationRequest:
      _handleOrientationRequest(message.data);
      break;
  }
}

Future<void> _handleCheckpointProgressReport(Map<String, dynamic> data) async {
  // 调用后端 API 上报进度
  final storyCode = data['storyCode'] as String?;
  final checkpointCode = data['checkpointCode'] as String?;
  final checkpointOrder = data['checkpointOrder'] as int?;
  final roleCode = data['roleCode'] as String?;
  if (storyCode == null || checkpointCode == null) return;
  
  // TODO: 调用 Dio 请求 POST /userProgresses/create
  // 成功后 syncUserProgress() 反馈给 Unity
}

void _handleOrientationRequest(Map<String, dynamic> data) {
  final orientation = data['orientation'] as String?;
  if (orientation == 'landscape') {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  } else {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
}
```

### 8.3 `enterScene` 方法补充 checkpoints 数据

```dart
Future<void> enterScene({
  required String characterId,
  required String sceneId,
  String? storyId,
  List<String> permissions = const [],
  List<Map<String, dynamic>> checkpoints = const [], // 新增
}) async {
  await _initUnityEngine();
  _activeSession = _StorySession(characterId: characterId, storyId: storyId);

  await _sendToUnity(
    UnityMessage(
      type: FlutterToUnityMessages.enterScene,
      data: {
        'characterId': characterId,
        'sceneId': sceneId,
        'storyId': storyId,
        'permissions': permissions,
        'checkpoints': checkpoints, // 新增
      },
    ),
  );
  // ...
}
```

---

## 9. 消息流程时序图

```
用户点击剧情
    │
    ▼
Flutter: 请求 /checkPoints/storyProcess/{storyCode} 获取检查点数据
Flutter: 请求 /userPermissions 获取权限
    │
    ▼
Flutter ──enterScene──> Unity
    │  (含 checkpoints + permissions)
    ▼
Unity: 加载场景、Live2D 演员
Unity ──orientationRequest(landscape)──> Flutter
    │
    ▼
Unity: 播放检查点字幕
Unity ──playCheckpoint──> Flutter
Unity ──storyStateChanged(playCheckpointDialogue)──> Flutter
    │
    ▼
Unity: 字幕播完，切 Live2D 动画
Unity ──storyStateChanged(playLive2DAnimation)──> Flutter
Unity ──playMotionSubtitle──> Flutter
Unity ──bluetoothSignal(每帧)──> Flutter ──BLE──> 设备
    │
    ▼
Unity: 检查点播完
Unity ──checkpointProgress──> Flutter ──POST /userProgresses/create──> 服务器
Flutter ──userProgress──> Unity (更新已完成列表)
    │
    ▼
(重复上述 检查点→动画 循环)
    │
    ▼
Unity: 所有检查点播完
Unity ──storyComplete──> Flutter
Unity ──requestExit──> Flutter
Unity ──orientationRequest(portrait)──> Flutter
    │
    ▼
Flutter: 切换回 Flutter 视图，释放蓝牙信号源
```
