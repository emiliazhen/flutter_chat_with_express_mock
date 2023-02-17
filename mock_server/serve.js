const express = require('express')
const path = require('path')
const cors = require('cors')
const bodyParser = require('body-parser')
// const { expressjwt: jwt } = require('express-jwt')
const expressWs = require('express-ws')
const websocketRoutes = require('./routers/websocket.js')
const fileUpload = require('express-fileupload')

const uploadRoutes = require('./routers/upload.js')
const downloadRoutes = require('./routers/download.js')
const userRoutes = require('./routers/user.js')
const systemRoutes = require('./routers/system.js')
const membersRoutes = require('./routers/members.js')
const logRoutes = require('./routers/log.js')

const PORT = 8019

// const SECRET_KEY = 'kite1874'
const app = express()

// 解决CORS
app.use(cors())

app.use(bodyParser.json())
// 解决POST拿前端传值
app.use(bodyParser.urlencoded({ extended: false }))

// 静态资源暴露
app.use(express.static(path.join(__dirname, './uploads/')))

// 启用ws
expressWs(app)

// websocket
app.use('/ws', websocketRoutes)

// ! 暂时关闭token校验
// // token校验
// app.use(
//   jwt({
//     secret: SECRET_KEY,
//     algorithms: ['HS256'],
//     getToken: function fromHeaderOrQuerystring(req) {
//       if (req.headers.authorization && req.headers.authorization.split(' ')[0] === 'Bearer') {
//         return req.headers.authorization.split(' ')[1]
//       } else if (req.query && req.query.token) {
//         return req.query.token
//       }
//       return null
//     },
//   }).unless({ path: ['/user/login', '/user/logout', '/user/chartData', /^\/images\/.*/] })
// )
// // token过期捕获
// app.use(function (err, req, res, next) {
//   if (err.name === 'UnauthorizedError') {
//     res.status(401).send({ code: 401, message: '重新登录！' })
//   }
// })

// 启用文件上传
app.use(
  fileUpload({
    createParentPath: true,
  })
)

// 上传路由
app.use('/upload', uploadRoutes)

// 下载路由
app.use('/download', downloadRoutes)

// user路由
app.use('/user', userRoutes)

// system路由
app.use('/system', systemRoutes)

// members路由
app.use('/members', membersRoutes)

// log路由
app.use('/log', logRoutes)

app.listen(PORT, () => {
  console.log(`---- Listen ${PORT} ----`)
})
