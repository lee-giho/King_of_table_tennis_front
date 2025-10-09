import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/util/appColors.dart';

class BorderedThumbShape extends RoundSliderThumbShape {
  final double borderWidth;
  final Color borderColor;

  const BorderedThumbShape({
    this.borderWidth = 2,
    this.borderColor = Colors.black,
    double enabledThumbRadius = 12
  }) : super(enabledThumbRadius: enabledThumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
      required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter? labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow
    }
  ) {
    final Canvas canvas = context.canvas;

    // 내부 원
    final Paint fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 테두리
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    // 그리기
    canvas.drawCircle(center, enabledThumbRadius, fillPaint);
    canvas.drawCircle(center, enabledThumbRadius, borderPaint);
  }
}

class ScoreSlider extends StatefulWidget {
  final String label;
  final Function(int) onChanged;
  final int initialValue;

  const ScoreSlider({
    super.key,
    required this.label,
    required this.onChanged,
    this.initialValue = 3
  });

  @override
  State<ScoreSlider> createState() => _ScoreSliderState();
}

class _ScoreSliderState extends State<ScoreSlider> {
  late double value;

  @override
  void initState() {
    super.initState();

    value = widget.initialValue.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold
          )
        ),
        const SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              5,
              (index) => Text(
                "${index+1}",
                style: const TextStyle(
                  fontSize: 14
                )
              )
            )
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -6),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: AppColors.tableBlue,
              inactiveTrackColor: Colors.grey[300],
              overlayColor: Colors.blue.withOpacity(.2),

              // Thumb
              thumbShape: const BorderedThumbShape(
                enabledThumbRadius: 12,
                borderWidth: 2,
                borderColor: Colors.black
              ),

              // value Indicator
              valueIndicatorColor: AppColors.racketRed,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),
              
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 1.5),
              activeTickMarkColor: Colors.white,
              inactiveTickMarkColor: Colors.white,
              trackShape: const RoundedRectSliderTrackShape()
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 5,
              divisions: 4,
              label: value.round().toString(),
              onChanged: (val) {
                setState(() {
                  value = val;
                });
                widget.onChanged(val.round());
              }
            ),
          ),
        )
      ],
    );
  }
}