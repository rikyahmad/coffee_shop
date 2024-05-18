import 'package:flutter/material.dart';

class MultipleAnimation {
  final TickerProvider vsync;
  final Duration duration;
  final Duration reverseDuration;
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> animations = [];

  MultipleAnimation(
      {required this.vsync,
      required this.duration,
      required this.reverseDuration});

  int get length => _controllers.length;

  void animate({double from = 0, required AnimationCallback callback}) {
    final controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: vsync,
    );

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    );

    callback.call(start: () {
      _controllers.add(controller);
      animations.add(animation);
    });

    controller.forward(from: from).then((_) {
      callback.call(end: () {
        int index = _controllers.indexOf(controller);
        if (index != -1) {
          _controllers.removeAt(index);
          animations.removeAt(index);
        }
      });
    });
  }

  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
  }
}

typedef AnimationCallback = void Function({Function? start, Function? end});
