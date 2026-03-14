import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'screens/scanner_view.dart';
import 'services/exhibit_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const PresanitzARApp());
}

class PresanitzARApp extends StatelessWidget {
  const PresanitzARApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureProvider<ExhibitService>(
      create: (_) async {
        final service = ExhibitService();
        await service.loadExhibits();
        return service;
      },
      initialData: null,
      child: MaterialApp(
        title: 'Příbram 1420 AR',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B0000),
            brightness: Brightness.light,
            primary: const Color(0xFF3E2723),
            secondary: const Color(0xFF8B0000),
          ),
          fontFamily: GoogleFonts.ebGaramond().fontFamily,
        ),
        home: Consumer<ExhibitService>(
          builder: (context, exhibitService, _) {
            if (exhibitService == null) {
              return const _LoadingScreen();
            }
            return ScannerView(exhibitService: exhibitService);
          },
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6CA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF3E2723),
            ),
            const SizedBox(height: 24),
            Text(
              'Načítání...',
              style: GoogleFonts.ebGaramond(
                fontSize: 20,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
