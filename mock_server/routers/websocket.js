const express = require('express')
const expressWs = require('express-ws')
const Mock = require('mockjs')
const apiRoutes = express.Router()
const dayjs = require('dayjs')
expressWs(apiRoutes)

// ws
apiRoutes.ws('/', function (ws, req) {
  // 使用 ws 的 send 方法向连接另一端的客户端发送数据
  ws.send(
    JSON.stringify({
      command: 1,
      code: 'CORRECT',
      reqData: '连接成功',
    })
  )

  // 使用 on 方法监听事件
  //   message 事件表示从另一段（服务端）传入的数据
  ws.on('message', function (msg) {
    console.log(`receive message ${msg}`)
    const { messageType } = JSON.parse(msg)
    switch (messageType) {
      case 999:
        openTest()
        break
      case -999:
        closeTest()
        break
      case 1:
        ws.send(
          JSON.stringify({
            command: 11,
            code: 'CORRECT',
            reqData: msg,
          })
        )
        break
      case 3:
        ws.send(
          JSON.stringify({
            command: 11,
            code: 'CORRECT',
            reqData: msg,
          })
        )
        break
      case 11:
        ws.send(
          JSON.stringify({
            command: 11,
            code: 'CORRECT',
            reqData: msg,
          })
        )
        break
      case 13:
        ws.send(
          JSON.stringify({
            command: 11,
            code: 'CORRECT',
            reqData: msg,
          })
        )
        break
      default:
        break
    }
  })
  let timer = null

  // 测试
  function openTest() {
    timer = setInterval(() => {
      ws.send(
        JSON.stringify({
          command: 17,
          code: 'CORRECT',
          reqData: Mock.mock({
            messageId: '@string',
            messageType: 1,
            createTime: dayjs().format('YYYY-MM-DD HH:mm:ss.SSS'),
            'sourceId|1': [
              '1635',
              '1153',
              '1465',
              '1807',
              '1753',
              '1927',
              '1988',
              '1752',
              '1503',
              '1226',
              '1436',
              '1444',
              '1173',
              '1097',
              '1879',
              '1972',
              '1703',
              '1534',
              '1471',
              '1747',
            ],
            content: '@csentence',
          }),
        })
      )
    }, 500)
  }
  // 关闭测试
  function closeTest() {
    clearInterval(timer)
    timer = null
  }
  // close 事件表示客户端断开连接时执行的回调函数
  ws.on('close', function (e) {
    closeTest()
  })
})

module.exports = apiRoutes
