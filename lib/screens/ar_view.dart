import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/exhibit.dart';

/// Statický detail exponátu – styl středověkého rukopisu.
/// Bez AR, kamery a WebView.
class ARView extends StatelessWidget {
  const ARView({
    super.key,
    required this.exhibit,
    this.dataService,
  });

  final Exhibit exhibit;
  final dynamic dataService;

  static const Color _parchment = Color(0xFFFCDA8B);
  static const Color _darkBrown = Color(0xFF3E2723);
  static const Color _buttonBrown = Color(0xFF5D4037);
  static const Color _frameBrown = Color(0xFF4E342E);

  String _exhibitNumber() {
    final match = RegExp(r'\d+').firstMatch(exhibit.id);
    return match != null ? match.group(0)!.padLeft(2, '0') : '01';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _parchment,
      appBar: AppBar(
        backgroundColor: _frameBrown,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Zavřít',
        ),
        title: Text(
          'Detail exponátu',
          style: GoogleFonts.ebGaramond(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildImage(context),
              const SizedBox(height: 24),
              Text(
                exhibit.title,
                style: GoogleFonts.cinzel(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: _darkBrown,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'XIII — XV STOLETÍ',
                style: GoogleFonts.ebGaramond(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: _darkBrown.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                exhibit.description,
                style: GoogleFonts.ebGaramond(
                  fontSize: 17,
                  height: 1.7,
                  color: _darkBrown,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 32),
              _buildScanButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EXPONÁT Č. ${_exhibitNumber()}',
          style: GoogleFonts.cinzel(
            fontSize: 14,
            letterSpacing: 2,
            color: _darkBrown.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 1,
          color: _darkBrown.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _frameBrown,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _frameBrown, width: 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Image.asset(
            exhibit.imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: _parchment.withValues(alpha: 0.5),
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                  color: _darkBrown.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: _buttonBrown,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          'SKENOVAT DALŠÍ EXPONÁT',
          style: GoogleFonts.ebGaramond(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
