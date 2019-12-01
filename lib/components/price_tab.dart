import '../helpers/fade_route.dart';

import '../pages/tickets_page.dart';

import '../models/flight_stop.dart';
import 'package:flutter/material.dart';

import 'animated_dot.dart';
import 'animated_plain_icon.dart';
import 'flight_stop_card.dart';

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

  final double _cardHeight = 80.0;

  AnimationController _dotsAnimationController;
  List<Animation<double>> _dotPositions = [];

  double get _planeTopPadding =>
      widget.height - _initialPlanePaddingBottom - _planeSize;

  double get _maxPlaneTopPadding =>
      widget.height -
      _initialPlanePaddingBottom -
      _planeSize -
      _minPlanePaddingTop;

  double get _planeSize => _planeSizeAnimation.value;

  final List<FlightStop> _flightStops = [
    FlightStop("JFK", "ORY", "JUN 05", "6h 25m", "\$851", "9:26 am - 3:43 pm"),
    FlightStop("MRG", "FTB", "JUN 20", "6h 25m", "\$532", "9:26 am - 3:43 pm"),
    FlightStop("ERT", "TVS", "JUN 20", "6h 25m", "\$718", "9:26 am - 3:43 pm"),
    FlightStop("KKR", "RTY", "JUN 20", "6h 25m", "\$663", "9:26 am - 3:43 pm"),
  ];

  final List<GlobalKey<FlightStopCardState>> _stopKeys = []; //<--- Add keys

  AnimationController _fabAnimationController;
  Animation _fabAnimation;

  @override
  void initState() {
    super.initState();
    _initSizeAnimations();
    _initPlaneTravelAnimations();
    _initDotAnimationController();
    _initDotAnimations();
    _initFabAnimationController(); //<--- init fab controller
    _flightStops.forEach((stop) => _stopKeys
        .add(new GlobalKey<FlightStopCardState>())); //<-- init card keys
    _planeSizeAnimationController.forward();
  }

  @override
  void dispose() {
    _planeSizeAnimationController.dispose();
    _planeTravelController.dispose();
    _dotsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[_buildPlane()]
          ..addAll(_flightStops.map(_buildStopCard))
          ..addAll(_flightStops.map(_mapFlightStopToDot))
          ..add(_buildFab())
      ),
    );
  }

  Widget _mapFlightStopToDot(stop) {
    int index = _flightStops.indexOf(stop);
    bool isStartOrEnd = index == 0 || index == _flightStops.length - 1;
    Color color = isStartOrEnd ? Colors.red : Colors.green;
    return AnimatedDot(
      animation: _dotPositions[index],
      color: color,
    );
  }

  Widget _buildStopCard(FlightStop stop) {
    int index = _flightStops.indexOf(stop);
    double topMargin = _dotPositions[index].value -
        0.5 * (FlightStopCard.height - AnimatedDot.size);
    bool isLeft = index.isOdd;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: topMargin),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            isLeft ? Container() : Expanded(child: Container()),
            Expanded(
              child: FlightStopCard(
                key: _stopKeys[index],
                flightStop: stop,
                isLeft: isLeft,
              ),
            ),
            !isLeft ? Container() : Expanded(child: Container()),
          ],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return Positioned(
      bottom: 16.0,
      child: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
        onPressed: () => Navigator
            .of(context)
            .push(FadeRoute(builder: (context) => TicketsPage())), //<-- Navigation
        child: Icon(Icons.check, size: 36.0),
      ),
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
            height: _flightStops.length *
                _cardHeight *
                0.8, // <--- changed length of trail
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
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(Duration(milliseconds: 500), () {
            // widget?.onPlaneFlightStart();
            _planeTravelController.forward();
          });
          Future.delayed(Duration(milliseconds: 700), () {
            // <--- dots animation start
            _dotsAnimationController.forward();
          });
        }
      });
    _planeSizeAnimation =
        Tween<double>(begin: 60.0, end: 36.0).animate(CurvedAnimation(
      parent: _planeSizeAnimationController,
      curve: Curves.easeOut,
    ));
  }

  void _initDotAnimations() {
    //what part of whole animation takes one dot travel
    final double slideDurationInterval = 0.4;
    //what are delays between dot animations
    final double slideDelayInterval = 0.2;
    //at the bottom of the screen
    double startingMarginTop = widget.height;
    //minimal margin from the top (where first dot will be placed)
    double minMarginTop =
        _minPlanePaddingTop + _planeSize + 0.5 * (0.8 * _cardHeight);

    for (int i = 0; i < _flightStops.length; i++) {
      final start = slideDelayInterval * i;
      final end = start + slideDurationInterval;

      double finalMarginTop = minMarginTop + i * (0.8 * _cardHeight);
      Animation<double> animation = new Tween(
        begin: startingMarginTop,
        end: finalMarginTop,
      ).animate(
        new CurvedAnimation(
          parent: _dotsAnimationController,
          curve: new Interval(start, end, curve: Curves.easeOut),
        ),
      )
       ..addStatusListener((status) {   //<--- Add a listener to start card animations
        if (status == AnimationStatus.completed) {
          _animateFlightStopCards().then((_) => _animateFab());
        }
      });
      _dotPositions.add(animation);
    }
  }

  Future _animateFlightStopCards() async {
    return Future.forEach(_stopKeys, (GlobalKey<FlightStopCardState> stopKey) {
      return new Future.delayed(Duration(milliseconds: 250), () {
        stopKey.currentState.runAnimation();
      });
    });
  }

   _animateFab() {
    _fabAnimationController.forward();
  }

  void _initDotAnimationController() {
    _dotsAnimationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 500));
  }

  _initPlaneTravelAnimations() {
    _planeTravelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _planeTravelAnimation =
        Tween<double>(begin: _maxPlaneTopPadding, end: _minPlanePaddingTop)
            .animate(CurvedAnimation(
      parent: _planeTravelController,
      curve: Curves.easeInOut,
    ));
  }

  void _initFabAnimationController() {
    _fabAnimationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 300));
    _fabAnimation = new CurvedAnimation(
        parent: _fabAnimationController, curve: Curves.easeOut);
  }
}
