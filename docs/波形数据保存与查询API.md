



## 波形数据保存

保存
POST /usrSwingWaveFormConfig/save/default/swing
POST /usrSwingWaveFormConfig/save/default/vibration

查询
GET /usrSwingWaveFormConfig/info/default/swing
GET /usrSwingWaveFormConfig/info/default/vibration



### 一、保存接口

~~~
POST http://106.14.99.175/api/usrSwingWaveFormConfig/save/default/swing
POST http://106.14.99.175/api/usrSwingWaveFormConfig/save/default/vibration
~~~



### 逻辑说明

可以重复保存，按照用户、设备（默认default）、执行的数据类型（swing、vibration）进行保存或更新。



### 请求体参数结构说明

~~~
数据库存储数据有压缩，
接口参数数据结构必须满足如下逻辑：

waveform+序号：对应名称
optionalWaveformsData元素如下：
waveformName是名称
sliderValue元素key是value: + 序号， 值是对应的整数数据
~~~



### 请求体实例

~~~json
{
    "waveform1": "羽毛轻扫",
    "waveform2": "深海呼吸",
    "waveform3": "午后清风",
    "waveform4": "晨露微光",
    "waveform5": "溪流潺潺",
    "waveform6": "丝绒摩挲",
    "waveform7": "深海潜流",
    "waveform8": "耳鬓厮磨",
    "waveform9": "钟摆催眠",
    "waveform10": "琴弦共鸣",
    "waveform11": "惊涛骇浪",
    "waveform12": "陨石坠落",
    "optionalWaveformsData": [
        {
            "waveformName": "羽毛轻扫",
            "sliderValue": [
                {
                    "value1": 26,
                    "value2": 26,
                    "value3": 28,
                    "value4": 30,
                    "value5": 32,
                    "value6": 34,
                    "value7": 36,
                    "value8": 38
                },
                {
                    "value1": 40,
                    "value2": 38,
                    "value3": 36,
                    "value4": 34,
                    "value5": 32,
                    "value6": 30,
                    "value7": 28,
                    "value8": 26
                },
                {
                    "value1": 26,
                    "value2": 28,
                    "value3": 30,
                    "value4": 32,
                    "value5": 30,
                    "value6": 28,
                    "value7": 26,
                    "value8": 26
                },
                {
                    "value1": 26,
                    "value2": 0,
                    "value3": 0,
                    "value4": 0,
                    "value5": 0,
                    "value6": 0,
                    "value7": 0,
                    "value8": 0
                }
            ]
        },
        {
            "waveformName": "深海呼吸",
            "sliderValue": [
                {
                    "value1": 26,
                    "value2": 28,
                    "value3": 30,
                    "value4": 32,
                    "value5": 34,
                    "value6": 36,
                    "value7": 38,
                    "value8": 40
                },
                {
                    "value1": 42,
                    "value2": 44,
                    "value3": 46,
                    "value4": 46,
                    "value5": 44,
                    "value6": 42,
                    "value7": 40,
                    "value8": 38
                },
                {
                    "value1": 36,
                    "value2": 34,
                    "value3": 32,
                    "value4": 30,
                    "value5": 28,
                    "value6": 26,
                    "value7": 26,
                    "value8": 0
                }
            ]
        },
        {
            "waveformName": "午后清风",
            "sliderValue": [
                {
                    "value1": 26,
                    "value2": 29,
                    "value3": 28,
                    "value4": 31,
                    "value5": 30,
                    "value6": 33,
                    "value7": 32,
                    "value8": 35
                },
                {
                    "value1": 34,
                    "value2": 37,
                    "value3": 36,
                    "value4": 34,
                    "value5": 32,
                    "value6": 33,
                    "value7": 30,
                    "value8": 31
                },
                {
                    "value1": 28,
                    "value2": 29,
                    "value3": 26,
                    "value4": 26,
                    "value5": 0,
                    "value6": 0,
                    "value7": 0,
                    "value8": 0
                }
            ]
        },
        {
            "waveformName": "晨露微光",
            "sliderValue": [
                {
                    "value1": 26,
                    "value2": 26,
                    "value3": 28,
                    "value4": 28,
                    "value5": 30,
                    "value6": 30,
                    "value7": 32,
                    "value8": 34
                },
                {
                    "value1": 36,
                    "value2": 38,
                    "value3": 40,
                    "value4": 42,
                    "value5": 42,
                    "value6": 40,
                    "value7": 38,
                    "value8": 36
                },
                {
                    "value1": 34,
                    "value2": 32,
                    "value3": 30,
                    "value4": 30,
                    "value5": 28,
                    "value6": 28,
                    "value7": 26,
                    "value8": 26
                }
            ]
        },
        {
            "waveformName": "溪流潺潺",
            "sliderValue": [
                {
                    "value1": 26,
                    "value2": 28,
                    "value3": 30,
                    "value4": 32,
                    "value5": 34,
                    "value6": 36,
                    "value7": 38,
                    "value8": 36
                },
                {
                    "value1": 38,
                    "value2": 40,
                    "value3": 38,
                    "value4": 36,
                    "value5": 34,
                    "value6": 32,
                    "value7": 30,
                    "value8": 28
                },
                {
                    "value1": 26,
                    "value2": 26,
                    "value3": 26,
                    "value4": 0,
                    "value5": 0,
                    "value6": 0,
                    "value7": 0,
                    "value8": 0
                }
            ]
        },
        {
            "waveformName": "丝绒摩挲",
            "sliderValue": [
                {
                    "value1": 26,
                    "value2": 28,
                    "value3": 30,
                    "value4": 32,
                    "value5": 34,
                    "value6": 36,
                    "value7": 38,
                    "value8": 40
                },
                {
                    "value1": 40,
                    "value2": 38,
                    "value3": 36,
                    "value4": 34,
                    "value5": 32,
                    "value6": 30,
                    "value7": 28,
                    "value8": 26
                },
                {
                    "value1": 26,
                    "value2": 26,
                    "value3": 0,
                    "value4": 0,
                    "value5": 0,
                    "value6": 0,
                    "value7": 0,
                    "value8": 0
                }
            ]
        },
        {
            "waveformName": "深海潜流",
            "sliderValue": [
                {
                    "value1": 26,
                    "value2": 28,
                    "value3": 30,
                    "value4": 32,
                    "value5": 34,
                    "value6": 36,
                    "value7": 38,
                    "value8": 40
                },
                {
                    "value1": 42,
                    "value2": 40,
                    "value3": 38,
                    "value4": 36,
                    "value5": 34,
                    "value6": 32,
                    "value7": 30,
                    "value8": 28
                }
            ]
        },
        {
            "waveformName": "耳鬓厮磨",
            "sliderValue": [
                {
                    "value1": 26,
                    "value2": 28,
                    "value3": 30,
                    "value4": 34,
                    "value5": 38,
                    "value6": 40,
                    "value7": 42,
                    "value8": 42
                },
                {
                    "value1": 40,
                    "value2": 38,
                    "value3": 34,
                    "value4": 30,
                    "value5": 28,
                    "value6": 26,
                    "value7": 26,
                    "value8": 0
                }
            ]
        },
        {
            "waveformName": "钟摆催眠",
            "sliderValue": [
                {
                    "value1": 26,
                    "value2": 30,
                    "value3": 34,
                    "value4": 38,
                    "value5": 40,
                    "value6": 42,
                    "value7": 40,
                    "value8": 38
                },
                {
                    "value1": 34,
                    "value2": 30,
                    "value3": 26,
                    "value4": 26,
                    "value5": 26,
                    "value6": 26,
                    "value7": 0,
                    "value8": 0
                }
            ]
        },
        {
            "waveformName": "琴弦共鸣",
            "sliderValue": [
                {
                    "value1": 26,
                    "value2": 32,
                    "value3": 38,
                    "value4": 42,
                    "value5": 40,
                    "value6": 36,
                    "value7": 30,
                    "value8": 28
                },
                {
                    "value1": 30,
                    "value2": 36,
                    "value3": 40,
                    "value4": 38,
                    "value5": 32,
                    "value6": 0,
                    "value7": 0,
                    "value8": 0
                }
            ]
        },
        {
            "waveformName": "惊涛骇浪",
            "sliderValue": [
                {
                    "value1": 26,
                    "value2": 30,
                    "value3": 40,
                    "value4": 50,
                    "value5": 46,
                    "value6": 36,
                    "value7": 30,
                    "value8": 40
                },
                {
                    "value1": 55,
                    "value2": 46,
                    "value3": 36,
                    "value4": 26,
                    "value5": 0,
                    "value6": 0,
                    "value7": 0,
                    "value8": 0
                }
            ]
        },
        {
            "waveformName": "陨石坠落",
            "sliderValue": [
                {
                    "value1": 26,
                    "value2": 30,
                    "value3": 34,
                    "value4": 40,
                    "value5": 46,
                    "value6": 52,
                    "value7": 46,
                    "value8": 34
                },
                {
                    "value1": 26,
                    "value2": 26,
                    "value3": 0,
                    "value4": 0,
                    "value5": 0,
                    "value6": 0,
                    "value7": 0,
                    "value8": 0
                }
            ]
        },
        {
            "waveformName": "测试摇摆",
            "sliderValue": [
                {
                    "value1": 1,
                    "value2": 1,
                    "value3": 1,
                    "value4": 1,
                    "value5": 1,
                    "value6": 1,
                    "value7": 1,
                    "value8": 1
                },
                {
                    "value1": 2,
                    "value2": 2,
                    "value3": 2,
                    "value4": 2,
                    "value5": 2,
                    "value6": 2,
                    "value7": 2,
                    "value8": 2
                }
            ]
        },
        {
            "waveformName": "摇摆测试",
            "sliderValue": [
                {
                    "value1": 0,
                    "value2": 0,
                    "value3": 0,
                    "value4": 0,
                    "value5": 0,
                    "value6": 0,
                    "value7": 0,
                    "value8": 0
                }
            ]
        }
    ]
}
~~~

### 数据库信息

~~~json
usr_swing_wave_form_config

id	user_id	omao_id	device_model	waveform_names	waveform_datas	created_at	updated_at
101	2	OM1763224205518010	default	["羽毛轻扫", "深海呼吸", "午后清风", "晨露微光", "溪流潺潺", "丝绒摩挲", "深海潜流", "耳鬓厮磨", "钟摆催眠", "琴弦共鸣", "惊涛骇浪", "陨石坠落"]	[{"k": "羽毛轻扫", "v": [[26, 26, 28, 30, 32, 34, 36, 38], [40, 38, 36, 34, 32, 30, 28, 26], [26, 28, 30, 32, 30, 28, 26, 26], [26, 0, 0, 0, 0, 0, 0, 0]]}, {"k": "深海呼吸", "v": [[26, 28, 30, 32, 34, 36, 38, 40], [42, 44, 46, 46, 44, 42, 40, 38], [36, 34, 32, 30, 28, 26, 26, 0]]}, {"k": "午后清风", "v": [[26, 29, 28, 31, 30, 33, 32, 35], [34, 37, 36, 34, 32, 33, 30, 31], [28, 29, 26, 26, 0, 0, 0, 0]]}, {"k": "晨露微光", "v": [[26, 26, 28, 28, 30, 30, 32, 34], [36, 38, 40, 42, 42, 40, 38, 36], [34, 32, 30, 30, 28, 28, 26, 26]]}, {"k": "溪流潺潺", "v": [[26, 28, 30, 32, 34, 36, 38, 36], [38, 40, 38, 36, 34, 32, 30, 28], [26, 26, 26, 0, 0, 0, 0, 0]]}, {"k": "丝绒摩挲", "v": [[26, 28, 30, 32, 34, 36, 38, 40], [40, 38, 36, 34, 32, 30, 28, 26], [26, 26, 0, 0, 0, 0, 0, 0]]}, {"k": "深海潜流", "v": [[26, 28, 30, 32, 34, 36, 38, 40], [42, 40, 38, 36, 34, 32, 30, 28]]}, {"k": "耳鬓厮磨", "v": [[26, 28, 30, 34, 38, 40, 42, 42], [40, 38, 34, 30, 28, 26, 26, 0]]}, {"k": "钟摆催眠", "v": [[26, 30, 34, 38, 40, 42, 40, 38], [34, 30, 26, 26, 26, 26, 0, 0]]}, {"k": "琴弦共鸣", "v": [[26, 32, 38, 42, 40, 36, 30, 28], [30, 36, 40, 38, 32, 0, 0, 0]]}, {"k": "惊涛骇浪", "v": [[26, 30, 40, 50, 46, 36, 30, 40], [55, 46, 36, 26, 0, 0, 0, 0]]}, {"k": "陨石坠落", "v": [[26, 30, 34, 40, 46, 52, 46, 34], [26, 26, 0, 0, 0, 0, 0, 0]]}, {"k": "测试摇摆", "v": [[1, 1, 1, 1, 1, 1, 1, 1], [2, 2, 2, 2, 2, 2, 2, 2]]}, {"k": "摇摆测试", "v": [[0, 0, 0, 0, 0, 0, 0, 0]]}]	2026-03-06 21:03:56	2026-03-06 21:09:54
~~~



## 二、查询接口

~~~
GET http://106.14.99.175/api/usrSwingWaveFormConfig/info/default/swing
GET http://106.14.99.175/api/usrSwingWaveFormConfig/info/default/vibration


查询
GET /usrSwingWaveFormConfig/info/default/swing
GET /usrSwingWaveFormConfig/info/default/vibration
~~~

逻辑与保存类似

### 响应体结构

.data获取原始数据

~~~json
{
    "code": 200,
    "message": "Success",
    "data": {
        "waveform1": "羽毛轻扫",
        "waveform2": "深海呼吸",
        "waveform3": "午后清风",
        "waveform4": "晨露微光",
        "waveform5": "溪流潺潺",
        "waveform6": "丝绒摩挲",
        "waveform7": "深海潜流",
        "waveform8": "耳鬓厮磨",
        "waveform9": "钟摆催眠",
        "waveform10": "琴弦共鸣",
        "waveform11": "惊涛骇浪",
        "waveform12": "陨石坠落",
        "optionalWaveformsData": [
            {
                "waveformName": "羽毛轻扫",
                "sliderValue": [
                    {
                        "value1": 26,
                        "value2": 26,
                        "value3": 28,
                        "value4": 30,
                        "value5": 32,
                        "value6": 34,
                        "value7": 36,
                        "value8": 38
                    },
                    {
                        "value1": 40,
                        "value2": 38,
                        "value3": 36,
                        "value4": 34,
                        "value5": 32,
                        "value6": 30,
                        "value7": 28,
                        "value8": 26
                    },
                    {
                        "value1": 26,
                        "value2": 28,
                        "value3": 30,
                        "value4": 32,
                        "value5": 30,
                        "value6": 28,
                        "value7": 26,
                        "value8": 26
                    },
                    {
                        "value1": 26,
                        "value2": 0,
                        "value3": 0,
                        "value4": 0,
                        "value5": 0,
                        "value6": 0,
                        "value7": 0,
                        "value8": 0
                    }
                ]
            },
            {
                "waveformName": "深海呼吸",
                "sliderValue": [
                    {
                        "value1": 26,
                        "value2": 28,
                        "value3": 30,
                        "value4": 32,
                        "value5": 34,
                        "value6": 36,
                        "value7": 38,
                        "value8": 40
                    },
                    {
                        "value1": 42,
                        "value2": 44,
                        "value3": 46,
                        "value4": 46,
                        "value5": 44,
                        "value6": 42,
                        "value7": 40,
                        "value8": 38
                    },
                    {
                        "value1": 36,
                        "value2": 34,
                        "value3": 32,
                        "value4": 30,
                        "value5": 28,
                        "value6": 26,
                        "value7": 26,
                        "value8": 0
                    }
                ]
            },
            {
                "waveformName": "午后清风",
                "sliderValue": [
                    {
                        "value1": 26,
                        "value2": 29,
                        "value3": 28,
                        "value4": 31,
                        "value5": 30,
                        "value6": 33,
                        "value7": 32,
                        "value8": 35
                    },
                    {
                        "value1": 34,
                        "value2": 37,
                        "value3": 36,
                        "value4": 34,
                        "value5": 32,
                        "value6": 33,
                        "value7": 30,
                        "value8": 31
                    },
                    {
                        "value1": 28,
                        "value2": 29,
                        "value3": 26,
                        "value4": 26,
                        "value5": 0,
                        "value6": 0,
                        "value7": 0,
                        "value8": 0
                    }
                ]
            },
            {
                "waveformName": "晨露微光",
                "sliderValue": [
                    {
                        "value1": 26,
                        "value2": 26,
                        "value3": 28,
                        "value4": 28,
                        "value5": 30,
                        "value6": 30,
                        "value7": 32,
                        "value8": 34
                    },
                    {
                        "value1": 36,
                        "value2": 38,
                        "value3": 40,
                        "value4": 42,
                        "value5": 42,
                        "value6": 40,
                        "value7": 38,
                        "value8": 36
                    },
                    {
                        "value1": 34,
                        "value2": 32,
                        "value3": 30,
                        "value4": 30,
                        "value5": 28,
                        "value6": 28,
                        "value7": 26,
                        "value8": 26
                    }
                ]
            },
            {
                "waveformName": "溪流潺潺",
                "sliderValue": [
                    {
                        "value1": 26,
                        "value2": 28,
                        "value3": 30,
                        "value4": 32,
                        "value5": 34,
                        "value6": 36,
                        "value7": 38,
                        "value8": 36
                    },
                    {
                        "value1": 38,
                        "value2": 40,
                        "value3": 38,
                        "value4": 36,
                        "value5": 34,
                        "value6": 32,
                        "value7": 30,
                        "value8": 28
                    },
                    {
                        "value1": 26,
                        "value2": 26,
                        "value3": 26,
                        "value4": 0,
                        "value5": 0,
                        "value6": 0,
                        "value7": 0,
                        "value8": 0
                    }
                ]
            },
            {
                "waveformName": "丝绒摩挲",
                "sliderValue": [
                    {
                        "value1": 26,
                        "value2": 28,
                        "value3": 30,
                        "value4": 32,
                        "value5": 34,
                        "value6": 36,
                        "value7": 38,
                        "value8": 40
                    },
                    {
                        "value1": 40,
                        "value2": 38,
                        "value3": 36,
                        "value4": 34,
                        "value5": 32,
                        "value6": 30,
                        "value7": 28,
                        "value8": 26
                    },
                    {
                        "value1": 26,
                        "value2": 26,
                        "value3": 0,
                        "value4": 0,
                        "value5": 0,
                        "value6": 0,
                        "value7": 0,
                        "value8": 0
                    }
                ]
            },
            {
                "waveformName": "深海潜流",
                "sliderValue": [
                    {
                        "value1": 26,
                        "value2": 28,
                        "value3": 30,
                        "value4": 32,
                        "value5": 34,
                        "value6": 36,
                        "value7": 38,
                        "value8": 40
                    },
                    {
                        "value1": 42,
                        "value2": 40,
                        "value3": 38,
                        "value4": 36,
                        "value5": 34,
                        "value6": 32,
                        "value7": 30,
                        "value8": 28
                    }
                ]
            },
            {
                "waveformName": "耳鬓厮磨",
                "sliderValue": [
                    {
                        "value1": 26,
                        "value2": 28,
                        "value3": 30,
                        "value4": 34,
                        "value5": 38,
                        "value6": 40,
                        "value7": 42,
                        "value8": 42
                    },
                    {
                        "value1": 40,
                        "value2": 38,
                        "value3": 34,
                        "value4": 30,
                        "value5": 28,
                        "value6": 26,
                        "value7": 26,
                        "value8": 0
                    }
                ]
            },
            {
                "waveformName": "钟摆催眠",
                "sliderValue": [
                    {
                        "value1": 26,
                        "value2": 30,
                        "value3": 34,
                        "value4": 38,
                        "value5": 40,
                        "value6": 42,
                        "value7": 40,
                        "value8": 38
                    },
                    {
                        "value1": 34,
                        "value2": 30,
                        "value3": 26,
                        "value4": 26,
                        "value5": 26,
                        "value6": 26,
                        "value7": 0,
                        "value8": 0
                    }
                ]
            },
            {
                "waveformName": "琴弦共鸣",
                "sliderValue": [
                    {
                        "value1": 26,
                        "value2": 32,
                        "value3": 38,
                        "value4": 42,
                        "value5": 40,
                        "value6": 36,
                        "value7": 30,
                        "value8": 28
                    },
                    {
                        "value1": 30,
                        "value2": 36,
                        "value3": 40,
                        "value4": 38,
                        "value5": 32,
                        "value6": 0,
                        "value7": 0,
                        "value8": 0
                    }
                ]
            },
            {
                "waveformName": "惊涛骇浪",
                "sliderValue": [
                    {
                        "value1": 26,
                        "value2": 30,
                        "value3": 40,
                        "value4": 50,
                        "value5": 46,
                        "value6": 36,
                        "value7": 30,
                        "value8": 40
                    },
                    {
                        "value1": 55,
                        "value2": 46,
                        "value3": 36,
                        "value4": 26,
                        "value5": 0,
                        "value6": 0,
                        "value7": 0,
                        "value8": 0
                    }
                ]
            },
            {
                "waveformName": "陨石坠落",
                "sliderValue": [
                    {
                        "value1": 26,
                        "value2": 30,
                        "value3": 34,
                        "value4": 40,
                        "value5": 46,
                        "value6": 52,
                        "value7": 46,
                        "value8": 34
                    },
                    {
                        "value1": 26,
                        "value2": 26,
                        "value3": 0,
                        "value4": 0,
                        "value5": 0,
                        "value6": 0,
                        "value7": 0,
                        "value8": 0
                    }
                ]
            },
            {
                "waveformName": "测试摇摆",
                "sliderValue": [
                    {
                        "value1": 1,
                        "value2": 1,
                        "value3": 1,
                        "value4": 1,
                        "value5": 1,
                        "value6": 1,
                        "value7": 1,
                        "value8": 1
                    },
                    {
                        "value1": 2,
                        "value2": 2,
                        "value3": 2,
                        "value4": 2,
                        "value5": 2,
                        "value6": 2,
                        "value7": 2,
                        "value8": 2
                    }
                ]
            },
            {
                "waveformName": "摇摆测试",
                "sliderValue": [
                    {
                        "value1": 0,
                        "value2": 0,
                        "value3": 0,
                        "value4": 0,
                        "value5": 0,
                        "value6": 0,
                        "value7": 0,
                        "value8": 0
                    }
                ]
            }
        ]
    },
    "timestamp": 1772802857793
}
~~~

