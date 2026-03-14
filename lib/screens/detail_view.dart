import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/exhibit.dart';
import '../services/exhibit_service.dart';
import 'ar_view.dart';

/// Parchment-themed exhibit detail screen.
class DetailView extends StatelessWidget {
  const DetailView({
    super.key,
    required this.exhibit,
    required this.exhibitService,
  });

  final Exhibit exhibit;
  final ExhibitService exhibitService;

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
                child: Text(
                  exhibit.title,
                  style: GoogleFonts.ebGaramond(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: _inkBlack,
                  ),
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
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ARView(
                exhibit: exhibit,
                exhibitService: exhibitService,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkWood,
          foregroundColor: _parchment,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: const BorderSide(color: _heraldicRed, width: 2),
          ),
        ),
        child: Text(
          'Zobrazit v AR',
          style: GoogleFonts.ebGaramond(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
