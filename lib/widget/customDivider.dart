import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double opacity;
  final double thickness;
  final double verticalPadding;

  const CustomDivider({
    super.key,
    this.opacity = 0.4,
    this.thickness = 1.0,
    this.verticalPadding = 8
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Container(
        height: thickness,
        width: double.infinity,
        color: Colors.black.withOpacity(opacity),
      ),
    );
  }
}