import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/exhibit.dart';
import '../services/exhibit_service.dart';
import 'detail_view.dart';

/// QR scanner screen with medieval-style frame overlay.
class ScannerView extends StatefulWidget {
  const ScannerView({
    super.key,
    required this.exhibitService,
  });

  final ExhibitService exhibitService;

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? raw = barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    final String id = raw.trim();
    final Exhibit? exhibit = widget.exhibitService.getExhibitById(id);
    if (exhibit == null) return;

    _isProcessing = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _isProcessing = false;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DetailView(
            exhibit: exhibit,
            exhibitService: widget.exhibitService,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => _buildErrorView(error),
            overlayBuilder: _buildMedievalOverlay,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    'Hledání exponátu...',
                    style: GoogleFonts.ebGaramond(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF5E6CA),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Namiřte kameru na QR kód exponátu',
                    style: GoogleFonts.ebGaramond(
                      fontSize: 16,
                      color: const Color(0xFFF5E6CA).withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedievalOverlay(BuildContext context, BoxConstraints constraints) {
    final Size size = Size(constraints.maxWidth, constraints.maxHeight);
    return CustomPaint(
      painter: MedievalFramePainter(size: size),
      size: size,
    );
  }

  Widget _buildErrorView(MobileScannerException error) {
    String message = 'Kamera není k dispozici';
    if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
      message = 'Přístup ke kameře byl odepřen. Povolte kameru v nastavení.';
    } else if (error.errorCode == MobileScannerErrorCode.unsupported) {
      message = 'Toto zařízení nepodporuje skenování.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: const Color(0xFF8B0000),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.ebGaramond(
                fontSize: 18,
                color: const Color(0xFFF5E6CA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints a medieval-style frame around the scan area.
class MedievalFramePainter extends CustomPainter {
  MedievalFramePainter({required this.size});

  final Size size;

  static const Color _frameColor = Color(0xFF3E2723);
  static const Color _accentColor = Color(0xFF8B0000);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    const double padding = 48.0;
    const double frameWidth = 12.0;
    const double cornerSize = 40.0;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double halfSize = (size.shortestSide * 0.5) - padding;

    final Rect scanRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: halfSize * 2,
      height: halfSize * 2,
    );

    final Paint framePaint = Paint()
      ..color = _frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = frameWidth;

    final Paint fillPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final Path outerPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path innerPath = Path()..addRect(scanRect);
    final Path framePath = Path.combine(PathOperation.difference, outerPath, innerPath);
    canvas.drawPath(framePath, fillPaint);

    canvas.drawRect(scanRect.deflate(frameWidth / 2), framePaint);

    final Paint accentPaint = Paint()
      ..color = _accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final double cornerLen = cornerSize;
    final double left = scanRect.left;
    final double right = scanRect.right;
    final double top = scanRect.top;
    final double bottom = scanRect.bottom;

    void drawCorner(double x, double y, bool flipX, bool flipY) {
      final double dx = flipX ? -1 : 1;
      final double dy = flipY ? -1 : 1;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + dx * cornerLen, y),
        accentPaint,
      );
      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + dy * cornerLen),
        accentPaint,
      );
    }

    drawCorner(left, top, false, false);
    drawCorner(right, top, true, false);
    drawCorner(left, bottom, false, true);
    drawCorner(right, bottom, true, true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
