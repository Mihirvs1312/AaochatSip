import 'package:flutter/material.dart';

class ActionButton extends StatefulWidget {
  final String? title;
  final String subTitle;
  final IconData? icon;
  final bool checked;
  final bool number;
  final Color? fillColor;
  final Function()? onPressed;
  final Function()? onLongPress;

  const ActionButton({
    Key? key,
    this.title,
    this.subTitle = '',
    this.icon,
    this.onPressed,
    this.onLongPress,
    this.checked = false,
    this.number = false,
    this.fillColor,
  }) : super(key: key);

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  @override
  Widget build(BuildContext context) {
    Color? background =
        Theme.of(context).buttonTheme.colorScheme?.surfaceContainerLow;
    Color splashColor = Theme.of(context).splashColor;
    Color? textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestureDetector(
          onLongPress: widget.onLongPress,
          onTap: widget.onPressed,
          child: RawMaterialButton(
            onPressed: widget.onPressed,
            splashColor:
                widget.fillColor ??
                (widget.checked ? splashColor : Colors.blue),
            fillColor:
                widget.fillColor ?? (widget.checked ? Colors.blue : background),
            elevation: 10.0,
            shape: CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child:
                  widget.number
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${widget.title}',
                            style: TextStyle(
                              fontSize: 20,
                              color: widget.fillColor ?? textColor,
                            ),
                          ),
                          Text(
                            widget.subTitle.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: widget.fillColor ?? textColor,
                            ),
                          ),
                        ],
                      )
                      : Icon(
                        widget.icon,
                        size: 30.0,
                        color:
                            widget.fillColor != null
                                ? Colors.white
                                : (widget.checked ? Colors.white : Colors.blue),
                      ),
            ),
          ),
        ),
        widget.number
            ? Container(
              margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
            )
            : Container(
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              child:
                  (widget.number || widget.title == null)
                      ? null
                      : Text(
                        widget.title!,
                        style: TextStyle(
                          fontSize: 15.0,
                          color: widget.fillColor ?? textColor,
                        ),
                      ),
            ),
      ],
    );
  }
}
