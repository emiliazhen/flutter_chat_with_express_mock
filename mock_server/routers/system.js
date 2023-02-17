const express = require('express')
const Mock = require('mockjs')
const apiRoutes = express.Router()

const random = Math.random() * 500 + 500

// 获取日志
apiRoutes.get('/log/list', function (req, res) {
  const size = req.query.pageSize
  const index = req.query.pageIndex
  if (!index || !size) {
    res.json({
      code: 500,
      msg: '请传入正确的页码！',
    })
    return
  }
  setTimeout(() => {
    const nameStr = `rows|${size}`
    res.json({
      code: 200,
      msg: '',
      data: Mock.mock({
        [nameStr]: [
          {
            'id|+1': 1,
            userName: '@cname',
            ip: '@ip',
            'status|0-2': 1,
            email: '@email',
            date: '@date(MM-dd hh:mm:ss)',
            note: '@csentence',
          },
        ],
        total: 210,
      }),
    })
  }, random)
})

// 获取日志
apiRoutes.get('/log/item', function (req, res) {
  setTimeout(() => {
    if (req.query.id) {
      const { data } = Mock.mock({
        data: {
          userName: '@cname',
          ip: '@ip',
          email: '@email',
          description: '@cparagraph',
        },
      })
      res.json({
        code: 200,
        msg: '',
        data,
      })
    } else {
      res.json({
        code: 500,
        msg: '请求参数需要id！',
      })
    }
  }, random)
})

// 编辑
apiRoutes.post('/log/update', function (req, res) {
  setTimeout(() => {
    res.json({
      code: 200,
      msg: '操作成功！',
    })
  }, random)
})

// 删除
apiRoutes.post('/log/delete', function (req, res) {
  console
  setTimeout(() => {
    if (req.body.id) {
      res.json({
        code: 200,
        msg: '操作成功！',
      })
    } else {
      res.json({
        code: 500,
        msg: ' 请求参数需要id！',
      })
    }
  }, random)
})
module.exports = apiRoutes
