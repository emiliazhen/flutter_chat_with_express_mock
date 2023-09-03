// 是否状态;
Map yNStatusEnum = {
  'Yes': 3,
  'No': 1,
  'Types': {
    3: '是',
    1: '否',
  },
  'TypeArray': [
    {'KeyId': 3, 'Value': '是'},
    {'KeyId': 1, 'Value': '否'}
  ]
};

// 聊天消息状态;
Map chatLogStatusEnum = {
  'Unsent': 1,
  'Failed': 3,
  'Sending': 5,
  'Send': 7,
  'Success': 10,
  'Types': {
    1: '未发送',
    3: '发送失败',
    5: '发送中',
    7: '已发送',
    10: '发送成功',
  },
  'TypeArray': [
    {'KeyId': 1, 'Value': '未发送'},
    {'KeyId': 3, 'Value': '发送失败'},
    {'KeyId': 5, 'Value': '发送中'},
    {'KeyId': 7, 'Value': '已发送'},
    {'KeyId': 10, 'Value': '发送成功'}
  ]
};
// 聊天消息类型;
Map messageTypeEnum = {
  'Text': 1,
  'Image': 3,
  'File': 9,
  'Audio': 11,
  'Video': 13,
  'OnlineOrOffline': 100,
  'RepeatLogin': 101,
  'Ack': 102,
  'Types': {
    1: '文本',
    3: '图片',
    9: '文件',
    11: '音频',
    13: '视频',
    100: '在线/离线',
    101: '重复登录',
    102: '确认消息',
  },
  'TypeArray': [
    {'KeyId': 1, 'Value': '文本'},
    {'KeyId': 3, 'Value': '图片'},
    {'KeyId': 9, 'Value': '文件'},
    {'KeyId': 11, 'Value': '音频'},
    {'KeyId': 13, 'Value': '视频'},
    {'KeyId': 100, 'Value': '在线/离线'},
    {'KeyId': 101, 'Value': '重复登录'},
    {'KeyId': 102, 'Value': '确认消息'}
  ]
};

// Websocket链接状态(前端用);
Map websocketLinkStatusEnum = {
  'Linking': 1,
  'LinKFail': 3,
  'LinkComplete': 5,
  'Types': {
    1: '正在连接',
    3: '连接失败',
    5: '连接完成',
  },
  'TypeArray': [
    {'KeyId': 1, 'Value': '正在连接'},
    {'KeyId': 3, 'Value': '连接失败'},
    {'KeyId': 5, 'Value': '连接完成'}
  ]
};
// App端Command类型;
Map appCommandTypesEnum = {
  'LinkSuccess': 1,
  'Error': 3,
  'System': 5,
  'SendSuccess': 11,
  'SendFail': 13,
  'CommandUnread': 14,
  'CommandMessage': 15,
  'ReceiveMessage': 17,
  'OnlineOrOffline': 21,
  'RePush': 23,
  'Ack': 25,
  'Types': {
    1: '连接成功',
    3: 'session/参数序列化等各种异常',
    5: '系统消息(比如:单点登录提示等消息提醒)',
    11: '发送成功',
    13: '发送失败',
    14: '指令未读数量',
    15: '指令消息',
    17: '接收信息',
    21: '在线/离线',
    23: '重新推送',
    25: '客户端确认收到',
  },
  'TypeArray': [
    {'KeyId': 1, 'Value': '连接成功'},
    {'KeyId': 3, 'Value': 'session/参数序列化等各种异常'},
    {'KeyId': 5, 'Value': '系统消息(比如:单点登录提示等消息提醒)'},
    {'KeyId': 11, 'Value': '发送成功'},
    {'KeyId': 13, 'Value': '发送失败'},
    {'KeyId': 15, 'Value': '指令未读数量'},
    {'KeyId': 15, 'Value': '指令消息'},
    {'KeyId': 17, 'Value': '接收信息'},
    {'KeyId': 21, 'Value': '在线/离线'},
    {'KeyId': 23, 'Value': '重新推送'},
    {'KeyId': 25, 'Value': '客户端确认收到'},
  ]
};
Map eventEnum = {
  'event1': 1,
  'event2': 3,
  'event3': 5,
  'event4': 7,
  'event5': 9,
  'Types': {
    1: '事件1 ',
    3: '事件2',
    5: '事件3',
    7: '事件4',
    9: '事件5',
  },
  'TypeArray': [
    {'KeyId': 1, 'Value': '事件1'},
    {'KeyId': 3, 'Value': '事件2'},
    {'KeyId': 5, 'Value': '事件3'},
    {'KeyId': 7, 'Value': '事件4'},
    {'KeyId': 9, 'Value': '事件5'},
  ]
};

Map deviceEnum = {
  'deviceA': 1,
  'deviceB': 3,
  'deviceC': 5,
  'deviceD': 7,
  'deviceE': 9,
  'Types': {
    1: '设备A ',
    3: '设备B',
    5: '设备C',
    7: '设备D',
    9: '设备E',
  },
  'TypeArray': [
    {'KeyId': 1, 'Value': '设备A'},
    {'KeyId': 3, 'Value': '设备B'},
    {'KeyId': 5, 'Value': '设备C'},
    {'KeyId': 7, 'Value': '设备D'},
    {'KeyId': 9, 'Value': '设备E'},
  ]
};
Map floorEnum = {
  'floor1': 1,
  'floor2': 3,
  'floor3': 5,
  'Types': {
    1: '段-上',
    3: '段-中',
    5: '段-下',
  },
  'TypeArray': [
    {'KeyId': 1, 'Value': '段-上'},
    {'KeyId': 3, 'Value': '段-中'},
    {'KeyId': 5, 'Value': '段-下'},
  ]
};
Map roomEnum = {
  'room1': 1,
  'room2': 3,
  'room3': 5,
  'Types': {
    1: '室1 ',
    3: '室2',
    5: '室3',
  },
  'TypeArray': [
    {'KeyId': 1, 'Value': '室1'},
    {'KeyId': 3, 'Value': '室2'},
    {'KeyId': 5, 'Value': '室3'},
  ]
};
Map departmentEnum = {
  'departmentA': 1,
  'departmentB': 3,
  'departmentC': 5,
  'departmentD': 7,
  'departmentE': 9,
  'Types': {
    1: '部门A ',
    3: '部门B',
    5: '部门C',
    7: '部门D',
    9: '部门E',
  },
  'TypeArray': [
    {'KeyId': 1, 'Value': '部门A'},
    {'KeyId': 3, 'Value': '部门B'},
    {'KeyId': 5, 'Value': '部门C'},
    {'KeyId': 7, 'Value': '部门D'},
    {'KeyId': 9, 'Value': '部门E'},
  ]
};
Map commandStateEnum = {
  'unread': 0,
  'read': 1,
  'complete': 2,
  'Types': {
    0: '未读 ',
    1: '已读',
    2: '已完成',
  },
  'TypeArray': [
    {'KeyId': 0, 'Value': '未读'},
    {'KeyId': 1, 'Value': '已读'},
    {'KeyId': 2, 'Value': '已完成'},
  ]
};
