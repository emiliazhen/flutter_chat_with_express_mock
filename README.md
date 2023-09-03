# 沙漠鹧鸪哨

## 介绍

此 APP 为各个摸金校尉在沙漠中执行任务时使用的 APP，主要功能为

- 首页：
  - 查看未读指令：显示总部发来的指令列表
  - 上报所在位置: 上报当前位置
  - 上报携带设备：上报指南针、八卦等设备
  - 上报资源：上报所带的水、电、油资源
  - 上报现场情况：现场出现事故需要救援或重大奇迹发现时，上报请求总部支援
- 文档
  - 摸金校尉指南：本地下载 PDF 并本机观看
- 消息
  - 各个摸金校尉之间通讯（文字、表情、图片、语音、视频文件）
  - 摸金校尉与总部通讯
- 我的
  - 账号管理
- 登录
  - 账号登录

使用`flutter 3.x` 搭建的`app`项目，已与后台对接过实际数据，现将数据使用`node.js`的`express + mock`做本地服务端，方便项目本地`run`

### 实现

- [x] 用户
  - [x] 通讯录管理
  - [x] 用户切换登录
- [x] 聊天通信
  - [x] 文字消息
  - [x] 图片消息
  - [x] 语音消息
  - [x] 视频消息
  - [ ] 消息推送
- [x] 文件
  - [x] 文件列表
  - [x] 文件下载
  - [x] 文件已下载调用原生打开 pdf
- [x] 表单
  - [x] 表单组件完成

## 使用

- 进入`./im_nest_server`，装包并开启服务

```sh
npm i
npm run start
```

- 进入`flutter_application`，装包后在本地`android`模拟器或真机上运行

```sh
flutter pub get
flutter run
```

## 打包

```sh
# android
flutter build apk
```

## app 消息规则

### 发送

#### 文本消息

|     key     |        type        |      content      |
| :---------: | :----------------: | :---------------: |
| MessageType |        枚举        |     消息类型      |
|  MessageId  |       string       |      消息 ID      |
|   Content   |       string       |       内容        |
|  TargetId   | string 或 int 都行 | 消息发送给谁的 ID |

```json
{
  "MessageType": 1,
  "Content": "志许选级同素果议管给越次飞军任整路。",
  "MessageId": "2f39a463-0a44-44e5-9f8d-6140cd799b0d",
  "TargetId": "8888"
}
```

#### 图片消息

|     key     |        type        |      content      |
| :---------: | :----------------: | :---------------: |
| MessageType |        枚举        |     消息类型      |
|  MessageId  |       string       |      消息 ID      |
|  TargetId   | string 或 int 都行 | 消息发送给谁的 ID |
|  ImageUrl   |       string       |     图片地址      |

```json
{ "MessageType": 3, "ImageUrl": "/2023-01-09-14-20-16-396-7im87aeyozv.jpg", "MessageId": "114fde34-1185-4346-8829-867b801354e8", "TargetId": "1316" }
```

#### 语音/视频消息

|     key     |        type        |          content          |
| :---------: | :----------------: | :-----------------------: |
| MessageType |        枚举        |         消息类型          |
|  MessageId  |       string       |          消息 ID          |
|   Content   |       string       | 视频/音频文件的时长（秒） |
|  TargetId   | string 或 int 都行 |     消息发送给谁的 ID     |
|   LinkUrl   |       string       |         音频地址          |

```json
{ "MessageType": 3, "Content": "19", "LinkUrl": "/2023-01-06-17-26-00-219-vi21n0vagpt.mp4", "MessageId": "114fde34-1185-4346-8829-867b801354e8", "TargetId": "1316" }
```

### 接收

#### 发送后返回成功

|   key   |      type       |                        content                        |
| :-----: | :-------------: | :---------------------------------------------------: |
| Command |      枚举       |                    返回的消息类型                     |
|  Code   | int/string 都行 |                        状态码                         |
|  Data   |   json 字符串   | 发送给服务端时的消息，用来确定是哪条 message 发送成功 |

```json
{ "Command": 11, "Code": "CORRECT", "Data": "{...}" }
```

### 枚举

暂定的枚举，Key 和 value 只做参考，可后端修改；

#### messageTypeEnum 聊天消息类型

|       key       | value |  content  |
| :-------------: | :---: | :-------: |
|      Text       |   1   |   文本    |
|      Image      |   3   |   图片    |
|      File       |   9   |   文件    |
|      Audio      |  11   |   音频    |
|      Video      |  13   |   视频    |
| OnlineOrOffline |  100  | 在线/离线 |
|   RepeatLogin   |  101  | 重复登录  |
|       Ack       |  102  | 确认消息  |

#### Command 类型

|       key       | value |                content                |
| :-------------: | :---: | :-----------------------------------: |
|   LinkSuccess   |   1   |               连接成功                |
|      Error      |   3   |     session/参数序列化等各种异常      |
|     System      |   5   | 系统消息(比如:单点登录提示等消息提醒) |
|   SendSuccess   |  11   |               发送成功                |
|    SendFail     |  13   |               发送失败                |
|   PushMessage   |  15   |             平台推送消息              |
| ReceiveMessage  |  17   |               接收信息                |
| OnlineOrOffline |  21   |               在线/离线               |
|     RePush      |  23   |               重新推送                |
|       Ack       |  25   |            客户端确认收到             |
