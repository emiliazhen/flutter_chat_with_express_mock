const express = require('express')
const apiRoutes = express.Router()

const random = Math.random() * 500 + 500

// app 日志
apiRoutes.post('/app', function (req, res) {
  console.log(req.body)
  setTimeout(() => {
    res.json({
      code: 200,
      msg: '操作成功',
    })
  }, random)
})

module.exports = apiRoutes
