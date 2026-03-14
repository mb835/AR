import 'package:ar_flutter_plugin_flash/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_flash/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flash/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flash/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flash/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flash/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flash/models/ar_node.dart';
import 'package:ar_flutter_plugin_flash/widgets/ar_view.dart' as ar;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/exhibit.dart';
import '../services/exhibit_service.dart';

/// AR view that anchors the exhibit 3D model to the detected marker image.
class ARView extends StatefulWidget {
  const ARView({
    super.key,
    required this.exhibit,
    required this.exhibitService,
  });

  final Exhibit exhibit;
  final ExhibitService exhibitService;

  @override
  State<ARView> createState() => _ARViewState();
}

class _ARViewState extends State<ARView> {
  ARSessionManager? _arSessionManager;
  ARObjectManager? _arObjectManager;
  ARAnchorManager? _arAnchorManager;
  ARLocationManager? _arLocationManager;

  ARNode? _placedNode;
  bool _isInitializing = true;
  String? _statusMessage;

  Future<void> _onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) async {
    _arSessionManager = arSessionManager;
    _arObjectManager = arObjectManager;
    _arAnchorManager = arAnchorManager;
    _arLocationManager = arLocationManager;

    _arSessionManager!.onImageTrackingConfigured = (success) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _statusMessage = success
              ? 'Namiřte kameru na QR kód exponátu'
              : 'Inicializace AR selhala';
        });
      }
    };

    final String trackingImagePath =
        widget.exhibitService.getTrackingImagePath(widget.exhibit.markerId);

    await _arSessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: false,
      showWorldOrigin: false,
      handleTaps: false,
      trackingImagePaths: [trackingImagePath],
      continuousImageTracking: true,
      imageTrackingUpdateIntervalMs: 500,
    );

    _arObjectManager!.onInitialize();
    _arSessionManager!.onImageDetected = _onImageDetected;
  }

  void _onImageDetected(
    String imageName,
    Matrix4 transformation,
    double width,
    double height,
  ) {
    if (mounted) {
      setState(() => _statusMessage = 'Exponát nalezen');
    }
    _placeObjectOnImage(transformation);
  }

  Future<void> _placeObjectOnImage(Matrix4 transformation) async {
    if (_arObjectManager == null) return;

    try {
      const double scale = 0.15;
      final Matrix4 modelTransform = Matrix4.copy(transformation);
      modelTransform.scale(scale, scale, scale);

      if (_placedNode == null) {
        final ARNode imageNode = ARNode(
          type: NodeType.localGLB,
          uri: widget.exhibit.modelPath,
          transformation: modelTransform,
        );

        final bool? didAdd = await _arObjectManager!.addNode(imageNode);
        if (didAdd == true && mounted) {
          setState(() => _placedNode = imageNode);
        }
      } else {
        _placedNode!.transform = modelTransform;
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = 'Model nenalezen');
      }
    }
  }

  @override
  void dispose() {
    if (_placedNode != null && _arObjectManager != null) {
      _arObjectManager!.removeNode(_placedNode!);
      _placedNode = null;
    }
    _arSessionManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          ar.ARView(
            onARViewCreated: _onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.none,
            permissionPromptDescription: 'Přístup ke kameře je potřeba pro zobrazení AR.',
            permissionPromptButtonText: 'Povolit',
          ),
          if (_isInitializing)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFF5E6CA),
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3E2723).withOpacity(0.9),
                    border: Border.all(color: const Color(0xFF8B0000), width: 2),
                  ),
                  child: Text(
                    _statusMessage ?? 'Hledání markeru...',
                    style: GoogleFonts.ebGaramond(
                      fontSize: 16,
                      color: const Color(0xFFF5E6CA),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
