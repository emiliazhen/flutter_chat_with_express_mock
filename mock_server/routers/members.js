const express = require('express')
const Mock = require('mockjs')
const apiRoutes = express.Router()

const random = Math.random() * 500 + 500

// 获取通讯录列表
apiRoutes.get('/getUserList', function (req, res) {
  setTimeout(() => {
    res.json({
      code: 200,
      msg: '操作成功',
      data: [
        { userId: 1635, name: '董秀兰' },
        { userId: 1153, name: '郝静' },
        { userId: 1465, name: '孔涛' },
        { userId: 1807, name: '杜静' },
        { userId: 1753, name: '蔡明' },
        { userId: 1927, name: '乔磊' },
        { userId: 1988, name: '唐刚' },
        { userId: 1752, name: '任娜' },
        { userId: 1503, name: '乔强' },
        { userId: 1226, name: '沈明' },
        { userId: 1436, name: '曹伟' },
        { userId: 1444, name: '侯超' },
        { userId: 1173, name: '赵秀兰' },
        { userId: 1097, name: '熊磊' },
        { userId: 1879, name: '范秀英' },
        { userId: 1972, name: '徐秀兰' },
        { userId: 1703, name: '江勇' },
        { userId: 1534, name: '黄洋' },
        { userId: 1471, name: '朱秀兰' },
        { userId: 1747, name: '许平' },
      ],
    })
  }, random)
})

// 获取用户信息
apiRoutes.get('/getUserInfo', function (req, res) {
  setTimeout(() => {
    res.json({
      code: 200,
      msg: '操作成功',
      data: Mock.mock({
        MemberId: req.query.id,
        paragraph: '@cparagraph',
        'follower|10-1999': 1,
        'project|10-1000': 1,
        'points|500-300000': 1,
      }),
    })
  }, random)
})

module.exports = apiRoutes
