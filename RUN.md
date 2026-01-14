# How to run everything locally

## 1) Start the chat server (for messaging)
In a terminal from the repo root:
```
dart run token_server/chat_server.dart
```
Defaults:
- Emulator base URL: http://10.0.2.2:8081
- Real device: use your LAN IP, e.g., http://192.168.x.x:8081

## 2) Start the 100ms token server (for video calls)
Create `token_server/.env` with:
```
HMS_ACCESS_KEY=your_access_key
HMS_SECRET=your_app_secret
HMS_ROOM_ID=your_room_id   # use the room id from the 100ms dashboard
```
Then run:
```
dart run token_server/hms_token_server.dart
```
- Emulator default: `http://10.0.2.2:3000/token`
- Real device: use your LAN IP, e.g., `http://192.168.x.x:3000/token`
- If your 100ms roles differ, set them in the app code (join uses the role mapping in the conversation screens).

## 3) Run the Guru app
From repo root:
```
flutter run -t guru_app/lib/main.dart
```

## 4) Run the Trainer app
From repo root:
```
flutter run -t trainer_app/lib/main.dart
```

## Notes
- Ensure Android manifests have camera/mic permissions (added), and grant at runtime.
- Chat and call both rely on the servers above; start them before testing.
- If using a real device, update `CHAT_BASE_URL`/`TOKEN_SERVER_BASE` to your LAN IP (`--dart-define` or code). 
