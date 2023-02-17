const express = require('express')
const apiRoutes = express.Router()
const dayjs = require('dayjs')
const _ = require('lodash')

const random = Math.random() * 500 + 500

// 文件上传
apiRoutes.post('/file', async (req, res) => {
  try {
    if (!req.files) {
      res.send({
        status: false,
        message: '请上传文件',
      })
    } else {
      const curFile = req.files.file
      // 将文件移动到服务器上其他位置
      const toPath = `/${dayjs().format('YYYY-MM-DD-HH-mm-ss-SSS')}-${Math.random().toString(36).substring(2)}${curFile.name.substring(curFile.name.lastIndexOf('.'))}`
      curFile.mv(`./uploads${toPath}`)
      setTimeout(() => {
        res.send({
          code: 200,
          msg: '上传成功',
          data: toPath,
        })
      }, random)
    }
  } catch (err) {
    res.status(500).send(err)
  }
})

// 文件上传-多文件
apiRoutes.post('/files', async (req, res) => {
  if (!req.files) {
    res.send({
      status: false,
      message: '请上传文件',
    })
  } else {
    const dataList = []
    console.log(req.files.files)
    _.forEach(_.keysIn(req.files.files), (key) => {
      const curFile = req.files.files[key]
      console.log(curFile)
      const toPath = `./uploads/${dayjs().format('YYYY-MM-DD-HH-mm-ss-SSS')}-${Math.random().toString(36).substring(2)}${curFile.name.substring(curFile.name.lastIndexOf('.'))}`
      console.log(toPath)
      curFile.mv(toPath)
      dataList.push(toPath)
    })
    // 将文件移动到服务器上其他位置
    setTimeout(() => {
      res.send({
        code: 200,
        msg: '上传成功',
        data: dataList,
      })
    }, random)
  }
})

module.exports = apiRoutes
