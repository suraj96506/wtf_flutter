# Knowledge Transfer (Guru & Trainer apps)

## High-level
- Two Flutter apps share a common `shared/` package for models, services, and widgets.
- Local chat server powers messaging (`token_server/chat_server.dart`).
- Firestore powers call requests/approvals (`callRequests` collection).
- 100ms handles video calls via a local token server (`token_server/hms_token_server.dart`).

## Guru app (member role)
- Entry: `guru_app/lib/main.dart` → `AuthWrapper`.
- Onboarding/login creates/uses mock user DK (`dk_member_id`) and lands on Home.
- Chat:
  - `chat_list_screen.dart` lists peers.
  - `conversation_screen.dart` handles chat, typing indicator, quick replies, and video invite cards.
  - Chat uses `HttpChatService` → local chat server (default `http://10.0.2.2:8081`).
- Schedule call:
  - `schedule_call_screen.dart` (styled picker) creates a `CallRequest` in Firestore with trainer Aarav.
  - `my_sessions_screen.dart` shows approved sessions with tabs (scheduled/video calls).
- Video call:
  - In chat, tap video icon to send an invite; Accept/Join opens `SimpleCallScreen` (HMS SDK join).

## Trainer app (trainer role)
- Entry: `trainer_app/lib/main.dart` → `AuthWrapper`.
- Mock user: Aarav (`aarav_trainer_id`).
- Home: `trainer_home_screen.dart` tiles link to Chats, Requests, Sessions.
- Requests:
  - `trainer_requests_screen.dart` streams pending Firestore `callRequests`, approve/decline actions update status.
- Sessions:
  - `trainer_sessions_screen.dart` shows approved requests in tabs (scheduled/video).
- Chat:
  - Same flow as Guru; video invite cards can Accept/Reject/Join.

## Shared folder highlights (`shared/`)
- `models/`: `user`, `message`, `call_request`, `scheduled_meeting`, `room_meta`.
- `services/`:
  - `mock_auth_service.dart` seeds DK/Aarav and handles simple persistence.
  - `http_chat_service.dart` talks to local chat server for messages/typing.
  - `firestore_call_service.dart` manages call requests in Firestore + 100ms join/leave (token fetch, HMS join).
  - `meeting_service` + `firestore_meeting_service.dart` (if needed) for meeting-style flows.
  - `service_providers.dart` wires Riverpod providers for auth/chat/call/meeting.
- `widgets/`: `simple_call_screen.dart` minimal in-call UI (joins HMS, renders tracks, mic/cam/leave).

### Core models (fields)
- `User`: `id`, `role`, `name`, `email`, `avatarUrl?`, `assignedTrainerId?`
- `Message`: `id`, `chatId`, `senderId`, `receiverId`, `text`, `createdAt`, `status`
- `CallRequest`: `id`, `memberId`, `trainerId`, `trainerName`, `memberName`, `requestedAt`, `scheduledFor`, `note`, `status`
- `ScheduledMeeting`: `id`, `trainerId`, `memberId`, `trainerName`, `memberName`, `scheduledFor`, `createdAt`, `topic`, `description?`, `durationMinutes`, `status`, `declineReason?`
- `RoomMeta`: `id`, `callRequestId`, `hmsRoomId`, `hmsRoleMember`, `hmsRoleTrainer`

## Servers
- Chat server: `dart run token_server/chat_server.dart`
  - Emulator base: `http://10.0.2.2:8081`, real device: use LAN IP.
- HMS token server: `dart run token_server/hms_token_server.dart`
  - Requires `.env` with `HMS_ACCESS_KEY`, `HMS_SECRET`, `HMS_ROOM_ID`.
  - Emulator token URL: `http://10.0.2.2:3000/token?userId=&role=&roomId=...`; real device: use LAN IP.

## Video call roles/IDs
- Room ID comes from `.env` or invite message payload.
- Role mapping in conversation screens: trainer → `host`, member → `guest` (update if your 100ms template uses different roles).

## Data flow & workflows
- Chat:
  - Guru/Trainer chat uses `HttpChatService` → local chat server. `getMessages(chatId)` streams messages; typing status polled via `/typing`.
  - Status ticks sent/read; read receipts set when screen open.
- Video invite via chat:
  - Send message `VIDEO_INVITE|<roomId>|pending`.
  - Receiver Accept → sends `...|accepted` and navigates to `SimpleCallScreen` (joins HMS).
  - Reject → sends `...|rejected`; buttons disabled, shows “Call rejected”.
- Call scheduling:
  - Guru `schedule_call_screen.dart` creates `CallRequest` in Firestore with Aarav as trainer; status `pending`.
  - Trainer `trainer_requests_screen.dart` streams `callRequests` for trainer, Approve/Decline updates status.
  - Sessions: Guru `my_sessions_screen.dart` and Trainer `trainer_sessions_screen.dart` show approved requests (tabs for scheduled/video).
- Video call:
  - Token from local token server → HMS join in `SimpleCallScreen`.
  - HMS listener populates video tracks; controls for mic/cam/leave.

## Dependencies
- Riverpod for DI/state wiring.
- HMS SDK (`hmssdk_flutter`) for video calls.
- Firestore for call requests.
- `permission_handler` for runtime camera/mic requests.
- Local chat server via `http_chat_service` for messaging.

## How chat/video invite works
- Video invite is a chat message `VIDEO_INVITE|<roomId>|pending`.
- Accept → sends `VIDEO_INVITE|<roomId>|accepted` and navigates to `SimpleCallScreen`.
- Reject → sends `VIDEO_INVITE|<roomId>|rejected`.
- `SimpleCallScreen` joins HMS with token from the token server and shows tracks.

## How to run
- See `RUN.md` for commands and base URLs (start chat server + HMS token server, then run each app).
