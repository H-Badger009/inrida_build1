import 'package:flutter/material.dart';

enum AnimationStep { step1, step2, step3, step4, step5, step6 }

class IntroAnimation extends StatefulWidget {
  const IntroAnimation({super.key});

  @override
  State<IntroAnimation> createState() => _IntroAnimationState();
}

class _IntroAnimationState extends State<IntroAnimation> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _asset6Controller;
  late Animation<Offset> _asset6SlideAnimation;
  AnimationStep currentStep = AnimationStep.step1;

  @override
  void initState() {
    super.initState();

    // Controller for the initial slide-in (step 1)
    _slideController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _slideAnimation = Tween<Offset>(begin: const Offset(-1, 0), end: const Offset(0, 0))
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeInOut));

    // Controller for the final slide-in (step 6)
    _asset6Controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _asset6SlideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0))
        .animate(CurvedAnimation(parent: _asset6Controller, curve: Curves.easeInOut));

    // Start the animation sequence
    _slideController.forward().then((_) {
      setState(() => currentStep = AnimationStep.step2);
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() => currentStep = AnimationStep.step3);
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        setState(() => currentStep = AnimationStep.step4);
      });
      Future.delayed(const Duration(milliseconds: 900), () {
        setState(() => currentStep = AnimationStep.step5);
      });
      Future.delayed(const Duration(milliseconds: 1200), () {
        setState(() => currentStep = AnimationStep.step6);
        _asset6Controller.forward().then((_) {
          Navigator.pushReplacementNamed(context, '/splash');
        });
      });
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _asset6Controller.dispose();
    super.dispose();
  }

  // Widget for "logo anim" with configurable rings
  Widget logoAnim(int rings) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (rings >= 1)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        if (rings >= 2)
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        Image.asset('assets/logo_anim.png', width: 100, height: 100), // Adjust size as needed
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const double carLeft = 50.0; // Position for "Car" and "Asset 6"
    final double carTop = (MediaQuery.of(context).size.height - 100) / 2; // Center vertically, adjust for image height

    // Define all screens as widgets
    Widget screen0 = Container(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            left: carLeft,
            top: carTop,
            child: Image.asset('assets/car.png', width: 100, height: 100), // Second image: "Car"
          ),
        ],
      ),
    );

    Widget screen1 = Container(
      color: const Color(0xFF26A69A), // Teal background
      child: Stack(
        children: [
          Positioned(
            left: carLeft,
            top: carTop,
            child: Image.asset('assets/asset6.png', width: 100, height: 100), // First image: "Asset 6"
          ),
          const Center(
            child: Opacity(opacity: 0, child: SizedBox.shrink()), // "logo anim" hidden initially
          ),
        ],
      ),
    );

    Widget screen3 = Container(
      color: const Color(0xFF26A69A),
      child: Center(child: logoAnim(0)), // Third image: "logo anim" with no rings
    );

    Widget screen4 = Container(
      color: const Color(0xFF26A69A),
      child: Center(child: logoAnim(1)), // Fourth image: "logo anim" with one ring
    );

    Widget screen5 = Container(
      color: const Color(0xFF26A69A),
      child: Center(child: logoAnim(2)), // Fifth image: "logo anim" with two rings
    );

    Widget screen6 = Container(
      color: const Color(0xFF26A69A),
      child: Align(
        alignment: const Alignment(0, 0.8), // Sixth image: "logo anim" near bottom
        child: logoAnim(0),
      ),
    );

    // Build the UI based on the current step
    switch (currentStep) {
      case AnimationStep.step1:
        return Stack(
          children: [
            Positioned.fill(child: screen0),
            SlideTransition(position: _slideAnimation, child: screen1),
            Positioned(
              left: carLeft,
              top: carTop,
              child: FadeTransition(
                opacity: Tween<double>(begin: 1, end: 0).animate(_slideController),
                child: Image.asset('assets/car.png', width: 100, height: 100),
              ),
            ),
          ],
        );
      case AnimationStep.step2:
        return screen3;
      case AnimationStep.step3:
        return screen4;
      case AnimationStep.step4:
        return screen5;
      case AnimationStep.step5:
        return screen6;
      case AnimationStep.step6:
        return Stack(
          children: [
            screen6,
            SlideTransition(
              position: _asset6SlideAnimation,
              child: Center(
                child: Image.asset('assets/asset6.png', width: 100, height: 100), // Seventh image: "Asset 6"
              ),
            ),
          ],
        );
    }
  }
}