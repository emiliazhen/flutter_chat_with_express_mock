import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

// 图片查看器
class PhotoViewSimple extends StatelessWidget {
  const PhotoViewSimple({
    Key? key,
    required this.imageProvider, //图片
    this.backgroundDecoration, //背景修饰
    this.minScale, //最大缩放倍数
    this.maxScale, //最小缩放倍数
  }) : super(key: key);
  final ImageProvider imageProvider;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoView(
        imageProvider: imageProvider,
        backgroundDecoration: backgroundDecoration,
        minScale: minScale,
        maxScale: maxScale,
        enableRotation: true,
        onTapUp: (_, __, ___) {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
