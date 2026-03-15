import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/exhibit.dart';
import '../services/data_service.dart';
import 'ar_view.dart';

/// Parchment-themed exhibit detail screen.
class DetailView extends StatelessWidget {
  const DetailView({
    super.key,
    required this.exhibit,
    required this.dataService,
  });

  final Exhibit exhibit;
  final DataService dataService;

  static const Color _parchment = Color(0xFFF5E6CA);
  static const Color _inkBlack = Color(0xFF1A1A1A);
  static const Color _heraldicRed = Color(0xFF8B0000);
  static const Color _darkWood = Color(0xFF3E2723);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8EDE0),
              Color(0xFFF5E6CA),
              Color(0xFFEFDFC0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exhibit.title,
                      style: GoogleFonts.ebGaramond(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: _inkBlack,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Image.asset(
                      exhibit.imagePath,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    exhibit.description,
                    style: GoogleFonts.ebGaramond(
                      fontSize: 18,
                      height: 1.6,
                      color: _inkBlack,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildArButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            debugPrint('--- NAVIGACE: Přecházím na AR obrazovku ---');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ARView(
                  exhibit: exhibit,
                  dataService: dataService,
                ),
              ),
            );
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _darkWood,
              border: Border.all(color: _heraldicRed, width: 2),
            ),
            child: Text(
              'Zobrazit v AR',
              style: GoogleFonts.ebGaramond(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _parchment,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
