import 'package:flutter/material.dart';

import 'animated_plain_icon.dart';

class PriceTab extends StatefulWidget {
  final double height;

  const PriceTab({Key key, this.height}) : super(key: key);

  @override
  _PriceTabState createState() => _PriceTabState();
}

class _PriceTabState extends State<PriceTab> with TickerProviderStateMixin {
  final double _initialPlanePaddingBottom = 16.0;
  final double _minPlanePaddingTop = 16.0;

  AnimationController _planeSizeAnimationController;
  AnimationController _planeTravelController;
  Animation _planeSizeAnimation;
  Animation _planeTravelAnimation;

  double get _planeTopPadding =>
      widget.height - _initialPlanePaddingBottom - _planeSize;

   double get _maxPlaneTopPadding =>
      widget.height - _initialPlanePaddingBottom - _planeSize - _minPlanePaddingTop;

  double get _planeSize => _planeSizeAnimation.value;

  @override
  void initState() {
    super.initState();
    _initSizeAnimations();
    _initPlaneTravelAnimations();
    _planeSizeAnimationController.forward();
  }
  @override
  void dispose() {
    _planeSizeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[_buildPlane()],
      ),
    );
  }

  Widget _buildPlane() {
    return AnimatedBuilder(
      animation: _planeTravelAnimation,
      child: Column(
        children: <Widget>[
          AnimatedPlaneIcon(animation: _planeSizeAnimation),
          Container(
          width: 2.0,
          height: 240.0,
          color: Color.fromARGB(255, 200, 200, 200),
        ),
        ],
      ),
      builder: (context, child) => Positioned(
            top: _planeTravelAnimation.value,
            child: child,
          ),
    );
  }

  _initSizeAnimations() {
    _planeSizeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 340),
      vsync: this,
    )
    ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(Duration(milliseconds: 500),
              () => _planeTravelController.forward());
        }
      });
    _planeSizeAnimation =
        Tween<double>(begin: 60.0, end: 36.0).animate(CurvedAnimation(
      parent: _planeSizeAnimationController,
      curve: Curves.easeOut,
    ));
  }

  _initPlaneTravelAnimations() {
    _planeTravelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _planeTravelAnimation = Tween<double>(begin: _maxPlaneTopPadding, end: _minPlanePaddingTop).animate(CurvedAnimation(
      parent: _planeTravelController,
      curve: Curves.easeInOut,
    ));
  }
}
