import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/exhibit.dart';
import '../services/data_service.dart';
import 'ar_view.dart';

/// QR scanner screen with medieval-style frame overlay.
/// Permission-first: blocks until camera is granted.
class ScannerView extends StatefulWidget {
  const ScannerView({
    super.key,
    required this.dataService,
  });

  final DataService dataService;

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _hasPermission = false;
  bool _isProcessing = false;
  String lastScanned = 'Nic naskenováno';

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final result = await Permission.camera.request();
    if (mounted) {
      setState(() => _hasPermission = result.isGranted);
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String code = barcodes.first.rawValue ?? '';
    if (code.isEmpty) return;

    final String? exhibitId = _resolveExhibitId(code);
    if (exhibitId == null) return;

    final Exhibit? exhibit = widget.dataService.getExhibitById(exhibitId);
    if (exhibit == null || !mounted) return;

    _isProcessing = true;
    HapticFeedback.lightImpact();
    debugPrint('--- DETEKCE: $code -> exponát $exhibitId ---');

    _handleScanAndNavigate(exhibit);
  }

  Future<void> _handleScanAndNavigate(Exhibit exhibit) async {
    await _controller.pause();
    if (!mounted) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => ARView(
          exhibit: exhibit,
          dataService: widget.dataService,
        ),
      ),
    );

    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    await _controller.start();
    if (mounted) setState(() => _isProcessing = false);
  }

  /// Mapuje QR obsah na ID exponátu.
  String? _resolveExhibitId(String code) {
    if (code.contains('extensia.cz')) return 'kostel_01';
    if (code == 'kostel_01' || code.endsWith('kostel_01')) return 'kostel_01';
    return null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('--- UI: Scanner View se vykresluje ---');

    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5E6CA),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 80,
                  color: Color(0xFF3E2723),
                ),
                const SizedBox(height: 32),
                Text(
                  'Aplikace potřebuje přístup ke kameře pro skenování QR kódů.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ebGaramond(
                    fontSize: 20,
                    color: const Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => openAppSettings(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B0000),
                      foregroundColor: const Color(0xFFF5E6CA),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Povolit kameru v nastavení',
                      style: GoogleFonts.ebGaramond(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) => _buildErrorView(error),
            overlayBuilder: _buildMedievalOverlay,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: Colors.black.withValues(alpha: 0.6),
                child: Text(
                  'Stav: $lastScanned',
                  style: GoogleFonts.ebGaramond(
                    fontSize: 16,
                    color: const Color(0xFFF5E6CA),
                  ),
                ),
              ),
            ),
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
                      color: const Color(0xFFF5E6CA).withValues(alpha: 0.9),
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

  Widget _buildMedievalOverlay(
      BuildContext context, BoxConstraints constraints) {
    final Size size = Size(constraints.maxWidth, constraints.maxHeight);
    return CustomPaint(
      painter: MedievalFramePainter(size: size),
      size: size,
    );
  }

  Widget _buildErrorView(MobileScannerException error) {
    String message = 'Kamera není k dispozici';
    if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
      message = 'Aplikace vyžaduje přístup ke kameře pro fungování AR.';
    } else if (error.errorCode == MobileScannerErrorCode.unsupported) {
      message = 'Toto zařízení nepodporuje skenování.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Color(0xFF8B0000),
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
      ..color = Colors.black.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final Path outerPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path innerPath = Path()..addRect(scanRect);
    final Path framePath =
        Path.combine(PathOperation.difference, outerPath, innerPath);
    canvas.drawPath(framePath, fillPaint);

    canvas.drawRect(scanRect.deflate(frameWidth / 2), framePaint);

    final Paint accentPaint = Paint()
      ..color = _accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    const double cornerLen = cornerSize;
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
