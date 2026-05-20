# SSE (Server-Sent Events)

## URL

`https://chatdi.vynix.org/sse` — hằng `API_SSE` trong `src/common/constants.ts`.

## Client

- **Implementation:** `src/services/sse-service.ts` — `react-native-sse` `EventSource`.
- **Wrapper:** `startSSEClient(url, { connection, message })`.
- **Lưu session:** `src/store/session-store.ts` (`zustand`).

## Lifecycle

- **Mở:** `useChat` mount → `startClient()` (`useEffect` trong `hooks/useChat.ts`).
- **Đóng:** unmount Chat → `stopClient()` (đóng `EventSource`, reset `sessionID`, streaming state).

Nếu user không vào Chat, **SSE không được start** trong luồng hiện tại (session chỉ cấp sau khi mở màn Chat).

## Sự kiện phía server (custom event names)

Parsing trong code:

| Listener EventSource | Payload JSON | Xử lý |
|---------------------|--------------|--------|
| `connection` | `{ session_id: string }` | Lưu `sessionID`, `isConnected: true` |
| `message` | Xem `SSEMessageEvent` bên dưới | Cập nhật streaming text/image |

Kiểu `SSEMessageEvent` (`sse-service.ts`):

- `id: string`
- `type`: `"start" | "delta" | "stop" | "delta-text-to-image"`
- `content: string`
- `role`: `"assistant" | "user"`
- `metaData?`: `{ character_id, user_language }`

### Mapping trong `session-store`

| `type` | Hành vi |
|--------|---------|
| `start` | `currentMessageId = data.id`, xóa nội dung stream |
| `delta` | `streamingText += data.content` |
| `delta-text-to-image` | `streamingImage = data.content` (URL/base64 tùy server) |
| `stop` | `currentMessageId = null` |
| khác | `console.warn` |

## Retry khi lỗi

Trong handler `error` của `EventSource`:

- `es.close` (thiếu `()` trong mã hiện tại — chỉ là reference, có thể không đóng thực sự).
- `setTimeout(..., CHAT_CONSTANTS.TIME_OUT)` (1000ms) gọi lại `startSSEClient(url, onEvent)` — **tạo client mới** nhưng **không** gán lại vào store; reconnect có thể không đồng bộ với `session-store.client`.

Đây là điểm nên chỉnh khi refactor (một luồng reconnect duy nhất, cập nhật reference `client` trong store).

## Ràng buộc UI gửi tin

`InputView` disable khi **thiếu** `isConnected` hoặc `deviceID` hoặc `sessionID` (`chat.tsx`), tức là phụ thuộc SSE nhận `connection` và device id hợp lệ.
