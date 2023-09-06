# Hajj App

The Hajj Assistance App is a mobile application that provides emergency support and a map feature for Hajj pilgrims. It enables quick assistance requests during emergencies and utilizes advanced algorithms to connect users with nearby officers. Enhance your Hajj journey with this app's safety and convenience.

## Getting Started

> Update dependencies

```
flutter pub get
```

> Run application

```
flutter run
```

> Build `.apk`

```
flutter build apk --target-platform android-arm,android-arm64 --no-tree-shake-icons
```

> Mapbox Command

The access token is passed via the command line arguments when either building

```
flutter build <platform> --dart-define ACCESS_TOKEN=YOUR_TOKEN_HERE
```

or running the application

```
flutter run --dart-define ACCESS_TOKEN=YOUR_TOKEN_HERE
```