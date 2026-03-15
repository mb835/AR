import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'screens/ar_view.dart';
import 'screens/scanner_view.dart';
import 'services/data_service.dart';

void main() async {
  debugPrint('--- APLIKACE NASTARTOVALA ---');
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
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
    return FutureProvider<DataService?>(
      create: (_) async {
        final service = DataService();
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
        home: Consumer<DataService?>(
          builder: (context, dataService, _) {
            if (dataService == null) {
              return const _LoadingScreen();
            }
            return ScannerView(dataService: dataService);
          },
        ),
        // Route /detail handled here (needs Provider context for DataService)
        onGenerateRoute: (settings) {
          if (settings.name == '/detail') {
            debugPrint('--- NAVIGACE: Přecházím na detail obrazovku ---');
            final code = settings.arguments as String?;
            return MaterialPageRoute<void>(
              builder: (context) {
                final dataService = Provider.of<DataService?>(context);
                if (dataService == null || code == null) {
                  return const _LoadingScreen();
                }
                final exhibit = dataService.getExhibitById(code);
                if (exhibit == null) {
                  return Scaffold(
                    body: Center(
                      child: Text(
                        'Exponát nenalezen',
                        style: GoogleFonts.ebGaramond(
                          fontSize: 18,
                          color: const Color(0xFF3E2723),
                        ),
                      ),
                    ),
                  );
                }
                return ARView(exhibit: exhibit, dataService: dataService);
              },
            );
          }
          return null;
        },
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
