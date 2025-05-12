import 'package:flutter/cupertino.dart'
    show CupertinoActionSheet, CupertinoActionSheetAction;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:flutter_quill/internal.dart';

class ImageRatioResizer extends StatefulWidget {
  const ImageRatioResizer({
    required this.imageWidth,
    required this.imageHeight,
    required this.onImageResize,
    super.key,
  });

  final double imageWidth;
  final double imageHeight;

  final Function(double width, double height) onImageResize;

  @override
  ImageRatioResizerState createState() => ImageRatioResizerState();
}

class ImageRatioResizerState extends State<ImageRatioResizer> {
  late double _sizeRatio = 1;

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).isCupertino) {
      return _showCupertinoMenu();
    }
    return _showMaterialMenu();
  }

  Widget _showMaterialMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _widthSlider(),
      ],
    );
  }

  Widget _showCupertinoMenu() {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {},
          child: _widthSlider(),
        ),
      ],
    );
  }

  Widget _slider({
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        child: Slider.adaptive(
          value: _getRatioToSliderValue(_sizeRatio),
          max: 100,
          divisions: 1000,
          // Might need to be changed
          label: context.loc.resize,
          onChanged: (val) {
            setState(() {
              onChanged(_getSizeRatioFromSliderValue(val));
              _resizeImage();
            });
          },
        ),
      ),
    );
  }

  double _getRatioToSliderValue(double ratio) {
    switch (ratio) {
      case > 1:
        return ratio * 20;
      default:
        return ratio * 50;
    }
  }

  double _getSizeRatioFromSliderValue(double value) {
    switch (value) {
      case > 50:
        return value / 20.0;
      default:
        return value / 50.0;
    }
  }

  Widget _widthSlider() {
    return _slider(
      onChanged: (value) {
        _sizeRatio = value;
      },
    );
  }

  bool _scheduled = false;

  void _resizeImage() {
    if (_scheduled) {
      return;
    }

    _scheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.onImageResize(
          widget.imageWidth * _sizeRatio, widget.imageHeight * _sizeRatio);
      _scheduled = false;
    });
  }
}
