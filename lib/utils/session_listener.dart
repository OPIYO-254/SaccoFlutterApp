import 'dart:async';

import 'package:flutter/material.dart';

class SessionListener extends StatefulWidget {
  Widget child;
  Duration duration;
  VoidCallback onTimeout;


  SessionListener({
    super.key,
    required this.child,
    required this.onTimeout,
    required this.duration
  });

  @override
  State<SessionListener> createState() => _SessionListenerState();
}

class _SessionListenerState extends State<SessionListener> {
  Timer? _timer;

  _startTimer(){
    // print('timer resert');
    if(_timer!=null){
      _timer?.cancel();
      _timer==null;
    }

    _timer = Timer(widget.duration, (){
      // print('timer elapsed');
      widget.onTimeout();
    });
  }

  @override
  void dispose(){
    if(_timer!=null){
      _timer?.cancel();
      _timer==null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e){
        _startTimer();
      },
      child: widget.child,
    );
  }
}
