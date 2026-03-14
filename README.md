# Příbram 1420 AR – Muzejní průvodce

Muzejní průvodce s AR pro Bitvu u Příbrami 1420. Aplikace umožňuje skenovat QR kódy exponátů, zobrazit historické informace a prohlížet 3D modely v rozšířené realitě.

## Požadavky

- Flutter (nejnovější stabilní verze)
- Android 7.0+ (API 24+)
- Zařízení s podporou ARCore

## Instalace

1. Naklonujte nebo zkopírujte projekt
2. Spusťte `flutter pub get`
3. Spusťte `flutter run` na připojeném Android zařízení

## Struktura projektu

- `lib/models/exhibit.dart` – datový model exponátu
- `lib/screens/scanner_view.dart` – QR skener s gotickým rámem
- `lib/screens/detail_view.dart` – detailní stránka s pergamenovým motivem
- `lib/screens/ar_view.dart` – AR zobrazení s image trackingem
- `lib/services/exhibit_service.dart` – služba pro načítání dat
- `assets/data/exhibits.json` – lokální data exponátů
- `assets/models/kostel.glb` – 3D model kostela
- `assets/images/marker_kostel_01.png` – QR kód pro AR tracking (musí odpovídat tištěnému markeru)

## Použití

1. **Skenování** – Namiřte kameru na QR kód exponátu (obsah: `kostel_01`)
2. **Detail** – Po rozpoznání se zobrazí stránka s informacemi
3. **AR** – Stiskněte „Zobrazit v AR“ a namiřte kameru na stejný QR kód pro zobrazení 3D modelu

## Přidání nových exponátů

1. Přidejte záznam do `assets/data/exhibits.json`
2. Přidejte 3D model do `assets/models/`
3. Vygenerujte QR kód s ID exponátu a uložte jako `assets/images/marker_{marker_id}.png`
4. Zaregistrujte asset v `pubspec.yaml`

## Poznámky

- Pro hladké AR tracking na některých zařízeních může být potřeba sestavit s `debuggable false` (viz [ARCore issue](https://github.com/google-ar/arcore-android-sdk/issues/1750))
- Tištěný QR kód musí odpovídat obrázku v `assets/images/marker_*.png`
