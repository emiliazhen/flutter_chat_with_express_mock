import { NestFactory } from '@nestjs/core'
import { AppModule } from './app.module'
import { WsAdapter } from './websocket/websocket.adapter'
import * as path from 'path'
import * as express from 'express'

async function bootstrap() {
  const app = await NestFactory.create(AppModule)
  app.useWebSocketAdapter(new WsAdapter(app))
  app.use(express.static(path.join(__dirname, '..', 'public')))
  await app.listen(3000)
}
bootstrap()
