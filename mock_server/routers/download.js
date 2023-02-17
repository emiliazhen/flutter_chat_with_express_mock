const express = require('express')
const apiRoutes = express.Router()
const random = Math.random() * 500 + 500

const fileList = [
  { fileId: 1635, fileName: 'Living in the Light', description: 'A guide to personal and planetary transformation' },
  { fileId: 1153, fileName: 'Javascript 半知半解', description: 'JavaScript诞生于1995年，它的主要目的是处理以前由服务器端语言负责的一些输入验证操作。' },
  {
    fileId: 1465,
    fileName: 'Jquery 1.2.6 源码分析',
    description:
      'jQuery 是一个非常优秀的 JS 库，与 Prototype,YUI,Mootools 等众多的 Js 类库相比，它剑走偏锋，从 web 开发的实用角度出发，抛除了其它 Lib 中一些中看但不实用的东西，为开发者提供了优美短小而精悍的类库。',
  },
  {
    fileId: 1245,
    fileName: 'Javascript 语言精粹',
    description:
      'avaScript曾是“世界上最被误解的语言”，因为它担负太多的特性，包括糟糕的交互和失败的设计，但随着Ajax的到来，JavaScript“从最受误解的编程语言演变为最流行的语言”，这除了幸运之外，也证明了它其实是一门优秀的语言。',
  },
]

const fileMap = {
  1635: 'Living in the Light',
  1153: 'Javascript 半知半解',
  1465: 'Jquery 1.2.6 源码分析',
  1245: 'Javascript 语言精粹',
}

// 下载
apiRoutes.get('/getFileList', function (req, res) {
  setTimeout(() => {
    res.json({
      code: 200,
      msg: '操作成功',
      data: fileList,
    })
  }, random)
})

// 下载
apiRoutes.get('/file', function (req, res) {
  console.log(req.query.fileId)
  console.log(req)
  console.log(fileMap[req.query.fileId])
  setTimeout(() => {
    res.download(`./assets/${fileMap[req.query.fileId]}.pdf`)
  }, random)
})
module.exports = apiRoutes
