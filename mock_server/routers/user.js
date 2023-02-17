const express = require('express')
const Mock = require('mockjs')
// const jsonWebToken = require('jsonwebtoken')
const apiRoutes = express.Router()

const random = Math.random() * 500 + 500
// const SECRET_KEY = 'kite1874'

// 登录
// apiRoutes.post('/login', function (req, res) {
//   const token = jsonWebToken.sign(
//     {
//       //exp 的值是一个时间戳，这里表示 1h 后 token 失效
//       exp: Math.floor(Date.now() / 1000) + 60 * 60,
//       userId: Math.floor(Math.random() * 1000),
//       role: Math.floor(Math.random() * 10),
//     },
//     SECRET_KEY
//   )
//   setTimeout(() => {
//     res.json({
//       code: 200,
//       msg: '操作成功',
//       data: token,
//     })
//   }, random)
// })

// 退出
apiRoutes.get('/logout', function (req, res) {
  setTimeout(() => {
    res.json({
      code: 200,
      msg: '操作成功',
      data: '',
    })
  }, random)
})

// 获取用户信息
apiRoutes.get('/info', function (req, res) {
  setTimeout(() => {
    res.json({
      code: 200,
      msg: '操作成功',
      data: Mock.mock({
        id: '@id',
        name: '@cname',
        address: '@city(true)',
      }),
    })
  }, random)
})

// 获取用户图表数据
apiRoutes.get('/chartData', function (req, res) {
  setTimeout(() => {
    const { data } = Mock.mock({
      'data|40': [
        {
          'id|+1': 0,
          name: '@cname',
          'value|0-9999': 1,
        },
      ],
    })
    res.json({
      code: 200,
      msg: '操作成功',
      data,
    })
  }, random)
})
module.exports = apiRoutes
