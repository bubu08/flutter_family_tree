import 'package:flutter/material.dart';

class FabCircularMenuButtom extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const FabCircularMenuButtom({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const widthAndSize = 75.0;
    return InkWell(
      child: Ink(
        width: widthAndSize,
        height: widthAndSize,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.all(5), child: Icon(icon)),
          Text(label, textAlign: TextAlign.center)
        ]),
      ),
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
    );
  }
}
