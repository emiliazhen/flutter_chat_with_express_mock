import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter_app/utils/config.dart';
import 'package:flutter_app/components/base_loading.dart';

/// 拥有状态的Image
class StatusImage extends StatelessWidget {
  /// 宽度
  final double width;

  /// 高度
  final double? height;

  /// 图片链接
  final String imageSrc;

  /// 填充方式
  final BoxFit fit;

  /// 报错图片
  final Widget? error;

  /// imageBuilder
  final Function? imageBuilder;

  const StatusImage(
      {Key? key,
      required this.imageSrc,
      required this.width,
      this.height,
      this.imageBuilder,
      this.fit = BoxFit.cover,
      this.error})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      alignment: Alignment.center,
      width: width,
      height: height,
      fit: fit,
      imageUrl: imageSrc,
      imageBuilder: imageBuilder != null
          ? (context, imageProvider) {
              return imageBuilder!(context, imageProvider);
            }
          : null,
      placeholder: (BuildContext context, String url) {
        return BaseLoading();
      },
      errorWidget: (BuildContext context, String url, dynamic curError) {
        return error ?? Image.asset('images/failed_image.png');
      },
    );
  }
}
