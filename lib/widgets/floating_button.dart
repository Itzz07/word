import 'package:flutter/material.dart';

class ScrollToTopButton extends StatelessWidget {
  final ScrollController scrollController;

  const ScrollToTopButton({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        scrollController.animateTo(
          0.0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      child: Icon(
        Icons.keyboard_arrow_up,
        size: 60,
        color: Colors.grey,
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
    );
  }
}
