import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/message.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({super.key, required this.message, required this.onTap});

  final Message message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRead = message.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 4, 20, 6),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color:
                isRead
                    ? Colors.white.withValues(alpha: 0.0)
                    : Colors.white.withValues(alpha: 0.82),
          ),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors:
                isRead
                    ? [
                      const Color(0xFFCDCDF0).withValues(alpha: 0.46),
                      Colors.white.withValues(alpha: 0.66),
                    ]
                    : [
                      const Color(0xFFCDCDF0).withValues(alpha: 0.50),
                      Colors.white.withValues(alpha: 0.84),
                    ],
            stops: const [0.0, 1.0],
          ),
          boxShadow: AppShadows.soft(color: Colors.white),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.title,
              style: TextStyle(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                color: isRead ? const Color(0xFF797979) : Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              message.body,
              style: TextStyle(
                fontSize: 13,
                height: 20 / 13,
                fontWeight: FontWeight.w400,
                color: const Color(
                  0xFF797979,
                ).withValues(alpha: isRead ? 0.88 : 1.0),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(message.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    height: 18 / 12,
                    color: Color(0xFF979797),
                  ),
                ),
                Text(
                  '查看详情',
                  style: TextStyle(
                    fontSize: 12,
                    height: 18 / 12,
                    color:
                        isRead
                            ? const Color(0xFF7E7E80)
                            : const Color(0xFF6A53A7),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
