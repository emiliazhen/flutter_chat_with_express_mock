import { Controller, Get, Post, UseInterceptors, UploadedFile, UploadedFiles, Body } from '@nestjs/common'
import { AppService } from './app.service'
import { FileInterceptor, FileFieldsInterceptor } from '@nestjs/platform-express'
import * as dayjs from 'dayjs'
import { createWriteStream } from 'fs'
import { join } from 'path'
import { mock } from 'mockjs'

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello()
  }

  @Get('res/person/app/getUserList')
  getUserList() {
    return {
      code: 200,
      msg: '操作成功',
      data: [
        { personId: 1635, personName: '董秀兰' },
        { personId: 1153, personName: '郝静' },
        { personId: 1465, personName: '孔涛' },
        { personId: 1807, personName: '杜静' },
        { personId: 1753, personName: '蔡明' },
        { personId: 1927, personName: '乔磊' },
        { personId: 1988, personName: '唐刚' },
        { personId: 1752, personName: '任娜' },
        { personId: 1503, personName: '乔强' },
        { personId: 1226, personName: '沈明' },
        { personId: 1436, personName: '曹伟' },
        { personId: 1444, personName: '侯超' },
        { personId: 1173, personName: '赵秀兰' },
        { personId: 1097, personName: '熊磊' },
        { personId: 1879, personName: '范秀英' },
        { personId: 1972, personName: '徐秀兰' },
        { personId: 1703, personName: '江勇' },
        { personId: 1534, personName: '黄洋' },
        { personId: 1471, personName: '朱秀兰' },
        { personId: 1747, personName: '许平' },
      ],
    }
  }

  @Post('msg/command/app/getUnreadCount')
  getUnreadCount() {
    return {
      code: 200,
      msg: '操作成功',
      data: 20,
    }
  }

  @Get('msg/command/app/list')
  getCommandList() {
    const { rows } = mock({
      'rows|20': [
        {
          'id|+1': 1,
          content: '@cparagraph',
          'type|0-1': 1,
          'msgState|0-2': 1,
          'tagValue|1': ['普通', '非密'],
          inTime: '@date(yyyy-MM-dd hh:mm:ss)',
        },
      ],
    })
    return {
      code: 200,
      rows,
      message: '',
    }
  }

  @Post('app/uploadFile')
  @UseInterceptors(FileInterceptor('file'))
  postUploadFile(@UploadedFile() file, @Body() body) {
    const toPath = `/${dayjs().format('YYYY-MM-DD-HH-mm-ss-SSS')}-${Math.random().toString(36).substring(2)}${file.originalname.substring(file.originalname.lastIndexOf('.'))}`
    const writeStream = createWriteStream(join(__dirname, '../public', toPath))
    writeStream.write(file.buffer)
    return {
      code: 200,
      msg: '上传成功',
      data: toPath,
    }
  }

  @Post('app/stateUpload')
  @UseInterceptors(FileFieldsInterceptor([{ name: 'audioFile' }, { name: 'videoFile' }, { name: 'pictureFile' }]))
  postStateUpload(@UploadedFiles() files, @Body() body) {
    console.log(files)
    for (const key in files) {
      if (Object.prototype.hasOwnProperty.call(files, key)) {
        const currentFileList = files[key]
        for (let index = 0; index < currentFileList.length; index++) {
          const file = currentFileList[index]
          const toPath = `/${dayjs().format('YYYY-MM-DD-HH-mm-ss-SSS')}-${Math.random().toString(36).substring(2)}${file.originalname.substring(
            file.originalname.lastIndexOf('.')
          )}`
          const writeStream = createWriteStream(join(__dirname, '../public', toPath))
          writeStream.write(file.buffer)
        }
      }
    }
    return {
      code: 200,
      msg: '上传成功',
      data: '',
    }
  }
}
