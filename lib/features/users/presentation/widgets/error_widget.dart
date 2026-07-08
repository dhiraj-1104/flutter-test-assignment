import 'package:flutter/widgets.dart';

class ErrorWidget extends StatelessWidget {
  final String msg;
  const ErrorWidget({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: Text(msg)),
          ),
        );
      },
    );
  }
}
