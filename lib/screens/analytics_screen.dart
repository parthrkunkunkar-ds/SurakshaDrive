import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text(context),
                ),
              ),
              Text(
                'Your driving safety insights',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.subText(context),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  _statCard(context,
                    icon: Icons.timer_outlined,
                    label: 'Total Drive Time',
                    value: '24.5h',
                    sub: '+12% this week',
                    subColor: AppColors.green,
                    iconColor: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  _statCard(context,
                    icon: Icons.warning_amber_outlined,
                    label: 'Total Alerts',
                    value: '9',
                    sub: 'Last 7 days',
                    subColor: AppColors.subText(context),
                    iconColor: AppColors.red,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _statCard(context,
                    icon: Icons.remove_red_eye_outlined,
                    label: 'Avg EAR Value',
                    value: '0.31',
                    sub: 'Within safe range',
                    subColor: AppColors.green,
                    iconColor: AppColors.green,
                  ),
                  const SizedBox(width: 12),
                  _statCard(context,
                    icon: Icons.calendar_today_outlined,
                    label: 'Sessions',
                    value: '18',
                    sub: 'This month',
                    subColor: AppColors.subText(context),
                    iconColor: AppColors.primary,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                'Recent Sessions',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text(context),
                ),
              ),

              const SizedBox(height: 12),

              _sessionCard(context, date: 'May 28, 2026', duration: '2h 15m', alerts: 3, avgEar: 0.31),
              _sessionCard(context, date: 'May 27, 2026', duration: '1h 45m', alerts: 1, avgEar: 0.33),
              _sessionCard(context, date: 'May 26, 2026', duration: '3h 10m', alerts: 5, avgEar: 0.29),
              _sessionCard(context, date: 'May 25, 2026', duration: '0h 55m', alerts: 0, avgEar: 0.35),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String sub,
    required Color subColor,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 10),
            Text(label,
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.subText(context))),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text(context))),
            const SizedBox(height: 4),
            Text(sub,
                style: GoogleFonts.inter(fontSize: 11, color: subColor, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _sessionCard(BuildContext context, {
    required String date,
    required String duration,
    required int alerts,
    required double avgEar,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date,
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text(context))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Completed',
                    style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.green)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(duration,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.subText(context))),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: AppColors.primary, size: 16),
              const SizedBox(width: 4),
              Text('Alerts  $alerts',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.text(context), fontWeight: FontWeight.w500)),
              const SizedBox(width: 20),
              Icon(Icons.remove_red_eye_outlined, color: AppColors.green, size: 16),
              const SizedBox(width: 4),
              Text('Avg EAR  ${avgEar.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.text(context), fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}