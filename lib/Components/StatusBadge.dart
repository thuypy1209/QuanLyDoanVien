import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  // Constructor tiện ích cho xếp loại
  factory StatusBadge.fromXepLoai(String xepLoai) {
    Color badgeColor;
    switch (xepLoai.toLowerCase()) {
      case "xuất sắc":
        badgeColor = const Color(0xFF2E7D32); // Green
        break;
      case "tốt":
        badgeColor = const Color(0xFF43A047);
        break;
      case "khá":
        badgeColor = const Color(0xFFFB8C00); // Orange
        break;
      case "trung bình":
        badgeColor = const Color(0xFFE53935); // Red
        break;
      default:
        badgeColor = Colors.grey;
    }
    return StatusBadge(label: xepLoai, color: badgeColor);
  }

  // Constructor tiện ích cho điểm danh
  factory StatusBadge.checkInStatus({required bool isCheckedIn, int? diem}) {
    if (isCheckedIn) {
      return StatusBadge(
        label: diem != null ? "Đã tham gia (+$diem)" : "Đã check-in",
        color: const Color(0xFF2E7D32),
        icon: Icons.check_circle,
      );
    } else {
      return const StatusBadge(
        label: "Chưa check-in",
        color: Color(0xFF1976D2),
        icon: Icons.access_time,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
