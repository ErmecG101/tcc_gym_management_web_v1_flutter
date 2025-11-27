import 'package:flutter/material.dart';

class PageUtils {
  static void navigateTo(BuildContext ctx, Widget page) {
    Navigator.pop(ctx);
    Navigator.push(ctx, MaterialPageRoute(builder: (builder) => page));
  }
}
