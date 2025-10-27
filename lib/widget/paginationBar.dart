import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int window;
  final ValueChanged<int> onPageChanged;

  final Size buttonSize;
  final EdgeInsetsGeometry buttonPadding;
  final Color? activeBgColor;
  final Color? activeFgColor;
  final Color? inactiveFgColor;
  final Color? borderActiveColor;
  final Color? borderInactiveColor;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.window = 5,
    this.buttonSize = const Size(34, 28),
    this.buttonPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    this.activeBgColor = const Color.fromARGB(50, 30, 77, 135),
    this.activeFgColor,
    this.inactiveFgColor,
    this.borderActiveColor = Colors.black,
    this.borderInactiveColor = Colors.grey
  });

  List<int> pageWindow({
    required int current,
    required int total,
    required int window
  }) {
    if (total <= 0) return const [];

    int start = (current + 1) - (window ~/ 2);
    int maxStart = total - window + 1;
    if (maxStart < 1) maxStart = 1;

    if (start < 1) start = 1;
    if (start > maxStart) start = maxStart;

    int end = start + window - 1;
    if (end > total) end = total;

    return [for (int p = start; p <= end; p++) p];
  }

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final pages = pageWindow(
      current: currentPage,
      total: totalPages,
      window: window
    );

    Widget arrow(String label, {required VoidCallback onTap, bool enabled = true}) {
      return IconButton(
        onPressed: enabled ? onTap : null,
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        padding: EdgeInsets.zero,
        icon: Icon(
          label == "<" ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
          size: 18
        )
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (currentPage > 0)
          arrow("<", onTap: () => onPageChanged(currentPage - 1)),
        ...pages.map((p1) {
          final isActive = (p1 - 1) == currentPage;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: OutlinedButton(
              onPressed: isActive ? null : () => onPageChanged(p1 - 1),
              style: OutlinedButton.styleFrom(
                minimumSize: buttonSize,
                padding: buttonPadding,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(
                  color: isActive 
                    ? (borderActiveColor ?? Colors.black)
                    : (borderInactiveColor ?? Colors.grey),
                ),
                backgroundColor: isActive ? activeBgColor : null,
                foregroundColor: isActive
                  ? (activeFgColor ?? Colors.white)
                  : (inactiveFgColor ?? Colors.black)
              ),
              child: Text(
                "$p1",
                style: TextStyle(
                  fontWeight: isActive
                    ? FontWeight.bold
                    : FontWeight.normal
                ),
              )
            ),
          );
        }),
        if (currentPage < totalPages - 1)
          arrow(">", onTap: () => onPageChanged(currentPage + 1))
      ]
    );
  }
}