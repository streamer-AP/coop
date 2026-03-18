import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

class PinCodeInput extends StatefulWidget {
  const PinCodeInput({super.key, required this.onCompleted, this.length = 6});

  final ValueChanged<String> onCompleted;
  final int length;

  @override
  State<PinCodeInput> createState() => _PinCodeInputState();
}

class _PinCodeInputState extends State<PinCodeInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.length, (index) {
              final hasValue = index < _controller.text.length;
              final char = hasValue ? _controller.text[index] : '';
              return SizedBox(
                width: 42,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 42,
                      child: Center(
                        child: Text(
                          char,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            color:
                                hasValue
                                    ? const Color(0xFF2D2A36)
                                    : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 1.8,
                      color:
                          hasValue
                              ? const Color(0xFF65606F)
                              : const Color(0xFF8E889E),
                    ),
                  ],
                ),
              );
            }),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                showCursor: false,
                enableInteractiveSelection: false,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
                onChanged: (value) {
                  setState(() {});
                  if (value.length == widget.length) {
                    widget.onCompleted(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
