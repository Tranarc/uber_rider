class SpringEffect extends StatefulWidget {
  @override
  SpringState createState() => SpringState();
}

class SpringState extends State<SpringEffect> with TickerProviderStateMixin {
  AnimationController? controller;
  AnimationController? controller2;
  Animation<double>? animation;
  SpringSimulation? simulation;
  double _position = 0;

  @override
  void initState() {
    super.initState();
    simulation = SpringSimulation(
      SpringDescription(
        mass: 1.0,
        stiffness: 100.0,
        damping: 5.0,
      ),
      200.0,
      100.0,
      -2000.0,
    );

    controller2 =
        AnimationController(vsync: this, duration: Duration(milliseconds: 70));
    animation = Tween(begin: 100.0, end: 200.0).animate(controller2!)
      ..addListener(() {
        if (controller2!.status == AnimationStatus.completed) {
          controller!.forward(from: 0);
        }
        setState(() {
          _position = animation!.value;
        });
      });

    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2))
          ..forward()
          ..addListener(() {
            if (controller!.status == AnimationStatus.completed) {
              controller2!.forward(from: 0);
            }
            setState(() {
              _position = simulation!.x(controller!.value);
            });
          });
  }

  @override
  void dispose() {
    controller!.dispose();
    controller2!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Align(
            alignment: Alignment(0, _position / 1000),
            child: Image.asset(
              "images/pickupIcon.png",
              width: 50,
            ),
          ),
        ],
      ),
    ));
  }
}