# 100ms Token Server

This is a simple Dart-based server to generate dummy tokens for the 100ms video call integration.

## How to Run

1.  **Navigate to the `token_server` directory:**
    ```
    cd token_server
    ```

2.  **Get dependencies:**
    ```
    dart pub get
    ```

3.  **Run the server:**
    ```
    dart bin/server.dart
    ```

The server will start on `localhost:8080` by default.

## API

### `GET /token`

Generates a dummy token for a user.

**Query Parameters:**

*   `userId` (required): The ID of the user.
*   `role` (required): The role of the user (e.g., 'trainer', 'member').

**Example Request:**

```
GET http://localhost:8080/token?userId=dk_member_id&role=member
```

**Example Response:**

```
dummy_token_for_dk_member_id_as_member
```