# Models và cấu trúc dữ liệu

## TypeScript — request/response và UI (`src/types/`)

### `message-request.ts`

- **`MessageRequest`:** payload POST message  
  - `chat_id?`, `conversation`, `content`, `topics?`, `style?`, `character_id?`
- **`ConversationItem`:** một bubble trên UI (`id`, `content`, `role`, `image?`)
- **`MessageItem`:** phần tử trong history gửi lên API (`content`, `role`)

### `category.ts` — `Category`

`id`, `name`, `icon`, `description`, `suggestion` (chuỗi gợi ý có thể nhiều dòng).

### `character.ts` — `Character`

`id`, `name`, `topics[]`, `question`, `description`, `picture`.

### `image-style.ts` — `ImageStyle`

`id`, `name`, `description`, `logo`.

### `image-generator.ts` — `ImageGenerator`

`id`, `name`, `picture`, `prompt`.

### `style-image-option.ts` — `StyleImageOption`

`icon`, `name` (dùng cho chip Style/Ratio local).

### `language.ts` — `Language`

`code`, `name`, `country`, `flag`, `tagColor`.

### `rating-state.ts` — `RatingState`

Rating UI (popup) — local model.

---

## Realm — persistence (`src/database/`)

### `Conversation` (`ConversationSchema.ts`)

| Field | Type |
|-------|------|
| `id` | string (PK) |
| `title` | string? |
| `topic` | string? |
| `character` | string? |
| `lastMessage` | string? |
| `lastMessageTime` | date? |
| `messageCount` | int |
| `createdAt` / `updatedAt` | date |

Type TS: **`IConversation`**.

### `MessageChat` (`MessageChatSchema.ts`)

| Field | Type |
|-------|------|
| `id` | string (PK) |
| `conversationId` | string |
| `message` | string |
| `type` | string (`text`, `image`, …) |
| `imageUrl` | string? |
| `isUser` | bool |
| `createdAt` / `updatedAt` | date |

Type TS: **`IMessageChat`**.

**Lưu ý:** `MessageChatService` có `getMessagesByCharacter` filter `characterName`, nhưng schema **không** có property `characterName` — đoạn này không khớp schema (dead code hoặc lỗi).

---

## Zustand / persist

- **`config-store`:** AsyncStorage (`language`, `isDarkMode`, `isRunOnboarding`, `isRunWelcome`).
- **`session-store`:** SSE client, `sessionID`, streaming fields (không persist).
- **`realm-store`:** instance Realm + mirror `conversations[]` + CRUD facade.

---

## Đặt tên / typo

Project dùng `reamlStore` / `initialize` trong một số file — typo của "realm"; chỉ là tên export, không ảnh hưởng hành vi nhưng dễ gây nhầm khi tìm kiếm.
