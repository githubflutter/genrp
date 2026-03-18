**AIBook**

- **Purpose:** Concise documentation for the `AIBook` example app implemented in `lib/client/aibook.dart`.
- **Location:** [lib/client/aibook.dart](lib/client/aibook.dart)

**Overview**

`AIBook` is a minimal Flutter entry that exposes the `AIBookApp` widget. It builds a `MaterialApp` with the debug banner disabled (`debugShowCheckedModeBanner: false`) and a simple `Scaffold` as the `home` screen.

**Key symbols**

- `AIBookApp`: `StatelessWidget` that returns the `MaterialApp` used for the example.

**How to run**

Run the example directly with Flutter by targeting the file:

```bash
flutter run -t lib/client/aibook.dart
```

**What it shows**

- App title: "AIBook"
- AppBar title: "AIBook"
- Body: centered text "AIBook Home"

**Customization notes**

- Change the app title in the `MaterialApp` `title` parameter.
- Replace the `home` `Scaffold` with your own screens or `Navigator`/`routes`.
- `debugShowCheckedModeBanner` is already set to `false` to disable the debug banner in debug builds.

**Suggested next steps**

- Wire `AIBookApp` into the main entry (`lib/main.dart`) if you want it to be the default app.
- Expand documentation with API examples or screenshots if desired.
