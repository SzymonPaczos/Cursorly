# Cursorly - iOS App

Aplikacja iOS w SwiftUI, która pozwala zamienić iPhone'a w bezprzewodową myszkę dla komputera Mac.

## 📱 Funkcjonalności (Wersja 1.0 - UI Only)

### Ekran startowy (WelcomeView)
- Tytuł: "Cursorly – połącz z komputerem"
- Opis: "Zamień iPhone'a w bezprzewodową myszkę"
- Trzy przyciski wyboru sposobu połączenia:
  - 🔵 Połącz automatycznie (Bluetooth/Wi-Fi)
  - 🌐 Połącz przez IP ręcznie
  - 🚀 Połącz przez Internet (premium)

### Nawigacja
- Używa `NavigationStack` (iOS 16+)
- Trzy osobne widoki dla każdego trybu połączenia
- Każdy widok zawiera placeholder "Jeszcze w budowie"

## 🎨 Design
- Layout responsywny i przyjazny użytkownikowi
- Elementy wycentrowane pionowo i poziomo
- Ikony SF Symbols
- Kolory systemowe zgodne z Human Interface Guidelines
- Czysty, nowoczesny design

## 📁 Struktura projektu

```
Cursorly/
├── CursorlyApp.swift              # Punkt wejścia aplikacji
├── Views/
│   ├── WelcomeView.swift          # Główny ekran powitalny
│   ├── ConnectionAutoView.swift   # Tryb automatyczny
│   ├── ConnectionManualView.swift # Tryb ręczny (IP)
│   └── ConnectionPremiumView.swift # Tryb premium
├── Assets.xcassets/               # Zasoby aplikacji
└── Preview Content/               # Zasoby dla podglądu
```

## 🚀 Instrukcje uruchomienia

1. Otwórz projekt w Xcode 15.0+
2. Wybierz symulator iPhone lub podłącz fizyczne urządzenie
3. Naciśnij Cmd+R aby uruchomić aplikację

## 📋 Wymagania
- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## 🔮 Przyszłe funkcjonalności
- Rzeczywista komunikacja Bluetooth/Wi-Fi
- Implementacja protokołu połączenia
- Obsługa gestów myszy
- Synchronizacja z aplikacją desktopową

## 📝 Uwagi
Ta wersja zawiera tylko interfejs użytkownika bez żadnej faktycznej funkcjonalności połączeniowej. Aplikacja jest gotowa do uruchomienia jako prototyp interfejsu. 