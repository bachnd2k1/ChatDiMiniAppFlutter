# Đề xuất tối ưu DB local (Realm)

Tóm tắt vấn đề từ mã hiện tại và hướng cải thiện. Model local đang **lệch** một phần với kiểu API/UI và có chỗ **chưa cascade / đặt tên sai**.

## 1. Tách vai trò: “UI message” vs “DB row”

Hiện tại UI dùng `ConversationItem` (content + role + image) trong khi DB dùng `message` + `type` + `imageUrl` + `isUser`. Việc chuyển đổi nằm rải rác trong `useChat` và `realmStore.updateMessage` (ép `message`/`imageUrl` khi đổi type).

**Đề xuất:**

- Chuẩn hóa **một lớp mapper** (`toUIMessage(im: IMessageChat): ConversationItem` / `fromSendPayload`) trong một file duy nhất để khỏi phân nhánh lặp.
- Hoặc lưu thêm **`role`** enum (`user` | `assistant`) đồng bộ API thay vì chỉ `isUser`.

## 2. Tránh trùng lặp và mơ hồ cho ảnh

Với `type === 'image'`, có lúc dữ liệu nằm ở `imageUrl`, có lúc `updateMessage` chép sang `imageUrl` từ `message`.

**Đề xuất:**

- Với tin ảnh: **`imageUrl`** là canonical; `message` để caption tùy chọn hoặc rỗng.
- Migration nhỏ: script một lần chuẩn hóa bản ghi cũ.

## 3. User message và `type`

Trong `handleSendPress`, user message dùng `messageType = isImageTab ? 'image' : 'text'` trong khi nội dung vẫn là **text**.

**Đề xuất:**

- User nhập luôn là **`text`**; chỉ assistant stream ra **`image`** khi có `delta-text-to-image`.
- Tránh làm sai thống kê / hiển thị list nếu sau này filter theo `type`.

## 4. Cascade delete và tính nhất quán History

`ConversationService.deleteConversation` **không xóa** `MessageChat` — có thể để rác hoặc lỗi nếu sau này query theo conversation.

**Đề xuất:**

- Trong một `realm.write`: xóa mọi `MessageChat` với `conversationId` rồi xóa `Conversation`.
- Hoặc dùng quan hệ Realm `conversationId` inverse (nếu nâng lên linking objects).

## 5. Đặt tên API `realm-store`

- `deleteMessage(id)` hiện gọi `deleteMessagesByConversation(id)` — tên sai mục đích.

**Đề xuất:** đổi thành `deleteMessagesForConversation(conversationId)` hoặc tách hai hàm: xóa 1 tin theo PK vs xóa cả cuộc hội thoại.

## 6. Conversation metadata

Khi chat với character, `createConversation` chỉ set `title`/`topic` — **thiếu** `character` id/name.

**Đề xuất:** set `character` (id hoặc name) và/hoặc `title` có ý nghĩa để History và search dễ đọc.

Topic đang có thể là `category?.id`; khi không có category, `topic` có thể rỗng — OK nếu cố ý.

## 7. Index và query performance

Conversation sort theo `updatedAt`; message theo `createdAt`.

**Đề xuất:**

- Thêm **index Realm** cho `MessageChat.conversationId` + `createdAt` (nếu dataset lớn).
- Pagination: không load full message một lần cho hội thoại dài (slice trong service + “load older”).

## 8. Sửa lệch schema / dead code trong service

- `ConversationService.searchConversations`: filter có `characterName` nhưng schema là **`character`** — query có thể lỗi runtime hoặc luôn rỗng.
- `MessageChatService.getMessagesByCharacter`: dùng `characterName` không tồn tại trong schema.

**Đề xuất:** bổ sung field vào schema nếu cần, hoặc sửa predicate cho đúng tên property.

## 9. Phiên bản schema và migration

`schemaVersion: 1`; `onMigration` trống.

**Đề xuất:**

- Khi đổi field (thêm `role`, sửa `type` enum…), bump version và migration có kiểm thử đơn vị nhỏ.

## 10. Optional: SQLite / MMKV chỉ cho metadata

Realm phù hợp tin nhắn blob lớn. Nếu sau này chỉ cache nhẹ và cần ít footprint:

- Có thể cân nhắc SQLite (WatermelonDB) hoặc tách meta conversation ra MMKV và message list sang SQLite — **chỉ** khi profiler chỉ ra bottleneck; không cần đổi nếu chưa đau.

## Ưu tiên thực hiện nhanh (impact cao)

1. Cascade delete message khi xóa conversation.  
2. Sửa `searchConversations` / `getMessagesByCharacter` cho khớp schema.  
3. Đặt `type` nhất quán cho user message (`text`).  
4. Mapper layer + đổi tên `deleteMessage` trong store.
