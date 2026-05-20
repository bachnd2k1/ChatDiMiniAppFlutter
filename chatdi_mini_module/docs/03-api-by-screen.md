# API REST — spec và ví dụ `curl`

## Base URL và header chung

Trong **`index.js`** mọi request axios được prefix URL:

| Môi trường | Base URL (`src/common/constants.ts`) |
|------------|--------------------------------------|
| **Production** (`!__DEV__`) | `https://chatdi.vynix.org` |
| **Staging** (`__DEV__`) | `https://chatdi-staging.vynix.org` |

**Header interceptor (đặt global):**

- `Content-Type: application/json`
- `Accept: application/json, application/problem+json`
- `Accept-Language: <mã ngôn ngữ>`, ví dụ `vi`, `en` (không để giá trị rỗng)

### Luồng `x-device-id` và `x-session-id` (SSE / “sse id”)

- **`x-device-id`:** định danh thiết bị (app lấy từ ví dụ `react-native-device-info` và truyền vào các API chat).
- **`x-session-id`:** định danh phiên kết nối **Server-Sent Events** — nhận từ payload event `connection` (field `session_id`) khi client đã kết nối `${BASE_URL}/sse`. **Gửi message** không thể bỏ qua hai header này nếu backend yêu cầu đồng bộ stream trả lời.
- **`x-premium`** (tuỳ sản phẩm backend): ví dụ flag gói premium; có thể bỏ nếu server không đọc.

**Catalog GET** (`/categories`, `/characters`, …) thường chỉ cần bộ interceptor; **`GET /dynamic/grouped-styles`** và **POST `/message/*`** cần **`x-device-id`** + **`x-session-id`** (xem mục Dynamic styles và message).

---

## Bảng endpoint chính (`src/services/call-api.ts`)

| Hàm | Method | Path (relative sau base URL) |
|-----|--------|--------------------------------|
| `getCategories` | GET | `/categories` |
| `getImageStyle` | GET | `/image-style` |
| `getImageStyles` | GET | `/image-styles` |
| `getImageGenerators` | GET | `/image-generators` |
| `getCharacters` | GET | `/characters` |
| `sendMsg` | POST | **`/message/message`** — chat Ask |
| `sendMsgToImage` | POST | `/message/text-to-image` |
| `sendMsgCharacter` | POST | `/message/character` |
| `stopGenerateMessage` | POST | `/message/stop` |
| `getImageToImagePresigned` | GET | `/message/image-to-image/presigned` |
| `sendImage` (image-to-image) | POST | `/message/image-to-image` |
| `getDynamicStyle` | GET | `/dynamic/grouped-styles` — cần device + **`#sym:sessionID`** (xem § Dynamic) |
| `getDynamicStylePresigned` | GET | `/dynamic/presigned/:styleId` |
| `generateDynamicStyle` | POST | `/dynamic/generate` |

---

## Biến môi trường cho `curl`

```bash
export BASE_URL='https://chatdi.vynix.org'
# export BASE_URL='https://chatdi-staging.vynix.org'  # khi staging

export LANG='vi'
export DEVICE_ID='1232'                          # ví dụ; thay bằng id thực tế
export SESSION_ID='<session_id từ SSE connection>' 
# export PREMIUM='true'   # không bắt buộc — tuỳ backend
```

**Header tái dùng cho POST message:**

```text
-H "Content-Type: application/json"
-H "Accept: application/json, application/problem+json"
-H "Accept-Language: ${LANG:-en}"
-H "x-device-id: ${DEVICE_ID}"
-H "x-session-id: ${SESSION_ID}"
# -H "x-premium: ${PREMIUM}"   # bỏ comment nếu backend dùng
```

---

## `curl` GET (catalog — chỉ interceptor, không device/session trong ví dụ tối thiểu)

```bash
curl -sS "${BASE_URL}/categories" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, application/problem+json" \
  -H "Accept-Language: ${LANG:-en}"

# GET /image-style, /image-styles, /image-generators, /characters — cùng bộ header
```

---

## POST `/message/message` — body đầy đủ + header bắt buộc

Một phần tử trong **`conversation`** có thể kèm tối đa **`file_1` … `file_5`** (object gồm `file_data`, `file_id`, `file_name`); chỉ gửi khi có đính kèm — có thể bỏ hết các key `file_*` cho hội thoại chỉ chữ.

Ví dụ tương đương **`curl --location`** (đã chỉnh cú pháp header đúng, không có dấu `;` sót sau tên header):

```bash
curl --location "${BASE_URL}/message/message" \
  --header 'Accept: application/json, application/problem+json' \
  --header "Accept-Language: ${LANG:-en}" \
  --header 'Content-Type: application/json' \
  --header "x-device-id: ${DEVICE_ID}" \
  --header "x-session-id: ${SESSION_ID}" \
  --data '{
  "chat_id": "string",
  "content": "string",
  "conversation": [
    {
      "content": "string",
      "file_1": {
        "file_data": "string",
        "file_id": "string",
        "file_name": "string"
      },
      "file_2": {
        "file_data": "string",
        "file_id": "string",
        "file_name": "string"
      },
      "file_3": {
        "file_data": "string",
        "file_id": "string",
        "file_name": "string"
      },
      "file_4": {
        "file_data": "string",
        "file_id": "string",
        "file_name": "string"
      },
      "file_5": {
        "file_data": "string",
        "file_id": "string",
        "file_name": "string"
      },
      "role": "user"
    }
  ],
  "topics": "string"
}'
```

Nếu backend hỗ trợ **`x-premium`**:

```bash
  --header "x-premium: true" \
```

(đặt sau các header khác hoặc thay giá trị theo OpenAPI của server.)

---

## Các POST `/message/*` khác (cùng header device + session như ví dụ trên)

Áp dụng chung các header: `Content-Type`, `Accept`, `Accept-Language`, **`x-device-id`**, **`x-session-id`**, và tùy chọn **`x-premium`**.

### POST `/message/text-to-image`

```bash
curl -sS "${BASE_URL}/message/text-to-image" \
  -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, application/problem+json" \
  -H "Accept-Language: ${LANG:-en}" \
  -H "x-device-id: ${DEVICE_ID}" \
  -H "x-session-id: ${SESSION_ID}" \
  -d '{
    "chat_id": "550e8400-e29b-41d4-a716-446655440001",
    "conversation": [
      { "content": "Một chú mèo", "role": "user" }
    ],
    "content": "Một chú mèo",
    "style": "optional-style-id"
  }'
```

### POST `/message/character` (**không** field `chat_id`)

```bash
curl -sS "${BASE_URL}/message/character" \
  -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, application/problem+json" \
  -H "Accept-Language: ${LANG:-en}" \
  -H "x-device-id: ${DEVICE_ID}" \
  -H "x-session-id: ${SESSION_ID}" \
  -d '{
    "conversation": [
      { "content": "Mở đầu...", "role": "assistant" },
      { "content": "Câu mới của user", "role": "user" }
    ],
    "content": "Câu mới của user",
    "character_id": "character-id-from-/characters"
  }'
```

### POST `/message/stop`

```bash
curl -sS "${BASE_URL}/message/stop" \
  -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, application/problem+json" \
  -H "Accept-Language: ${LANG:-en}" \
  -H "x-device-id: ${DEVICE_ID}" \
  -H "x-session-id: ${SESSION_ID}" \
  -d '{"message_id": "SSE-message-id-từ-event-start"}'
```

### POST `/message/image-to-image`

```bash
curl -sS "${BASE_URL}/message/image-to-image" \
  -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, application/problem+json" \
  -H "Accept-Language: ${LANG:-en}" \
  -H "x-device-id: ${DEVICE_ID}" \
  -H "x-session-id: ${SESSION_ID}" \
  -d '{
    "chat_id": "optional-chat-uuid",
    "content": "Mô tả chỉnh sửa",
    "image_url": "đường-dẫn-sau-presigned-trên-Object-Storage"
  }'
```

---

## GET `/dynamic/grouped-styles` — `getDynamicStyle`

Hàm trong app: `getDynamicStyle(deviceID, sessionID)` — **`src/services/call-api.ts`**.

### Contract

| | |
|--|--|
| **Method** | `GET` |
| **URL** | `${BASE_URL}/dynamic/grouped-styles` |
| **Query** | Không (theo code hiện tại) |

**Headers (khớp axios interceptor + yêu cầu API dynamic):**

| Header | Giá trị |
|--------|---------|
| `Content-Type` | `application/json` |
| `Accept` | `application/json, application/problem+json` |
| `Accept-Language` | Ví dụ `vi`, `en` |
| `x-device-id` | Định danh thiết bị (string, ví dụ từ `DeviceInfo`) |
| `x-session-id` | **`#sym:sessionID`** — phiên **SSE**, **không** được copy từ `deviceID` |

### Ký hiệu `#sym:sessionID`

| Ký hiệu | Ý nghĩa |
|---------|---------|
| **`#sym:sessionID`** | Giá trị trường **`session_id`** trong payload JSON của event SSE **`connection`** (sau khi client kết nối `${BASE_URL}/sse`). Cùng nguồn với header `x-session-id` khi gửi `/message/message`, v.v. |

**Sai lệch đã sửa trong code:** trước đây client gửi `x-session-id: deviceID`; theo contract đúng phải gửi **`#sym:sessionID`**.

### Response (ứng dụng)

Store đọc `response.data`; dữ liệu nhóm style thường nằm trong `data` (kiểu `GroupStyle[]` trong `src/types/dynamic-style`). Chi tiết field tùy backend.

### Code call API (Home tab)

Ví dụ gọi khi vào Home tab (đã có `deviceID` + `#sym:sessionID` từ SSE `connection`):

```ts
import { useEffect } from 'react';
import { getDynamicStyle } from 'src/services/call-api';

function useLoadDynamicStylesOnHome({
  isHomeTabFocused,
  deviceID,
  sessionID, // session_id từ SSE connection
  setDynamicStyles,
}: {
  isHomeTabFocused: boolean;
  deviceID: string;
  sessionID?: string;
  setDynamicStyles: (styles: unknown[]) => void;
}) {
  useEffect(() => {
    if (!isHomeTabFocused) return;
    if (!deviceID || !sessionID) return;

    const run = async () => {
      try {
        const response = await getDynamicStyle(deviceID, sessionID);
        setDynamicStyles(response?.data?.data ?? []);
      } catch (error) {
        console.error('getDynamicStyle failed', error);
      }
    };

    void run();
  }, [isHomeTabFocused, deviceID, sessionID, setDynamicStyles]);
}
```

Lưu ý:
- Không gọi API này trước khi nhận được `session_id` từ event SSE `connection`.
- `x-session-id` phải là `sessionID` thực tế, không dùng `deviceID`.

### `curl` — test

```bash
export BASE_URL='https://chatdi.vynix.org'
export LANG='vi'
export DEVICE_ID='your-device-id'
# SESSION_ID = session_id từ event SSE connection (#sym:sessionID)
export SESSION_ID='your-sse-session-id'

curl -sS "${BASE_URL}/dynamic/grouped-styles" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, application/problem+json" \
  -H "Accept-Language: ${LANG:-en}" \
  -H "x-device-id: ${DEVICE_ID}" \
  -H "x-session-id: ${SESSION_ID}"
```

---

## POST `/dynamic/generate` và GET `/dynamic/presigned/:styleId`

Luồng generate trong `call-api.ts` cũng dùng **`x-device-id`** + **`x-session-id`** (giá trị session là **`#sym:sessionID`**, không dùng `deviceID`). Ví dụ generate:

```bash
curl -sS "${BASE_URL}/dynamic/generate" \
  -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, application/problem+json" \
  -H "Accept-Language: ${LANG:-en}" \
  -H "x-device-id: ${DEVICE_ID}" \
  -H "x-session-id: ${SESSION_ID}" \
  -d '{
    "audio_inputs": [],
    "image_inputs": [],
    "style_id": "style-id",
    "text_input": "prompt",
    "video_inputs": []
  }'
```

GET presigned — thay `STYLE_ID` bằng id style thực tế:

```bash
export STYLE_ID='your-style-uuid'

curl -sS "${BASE_URL}/dynamic/presigned/${STYLE_ID}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, application/problem+json" \
  -H "Accept-Language: ${LANG:-en}" \
  -H "x-device-id: ${DEVICE_ID}" \
  -H "x-session-id: ${SESSION_ID}"
```

---

## SSE — lấy `session_id` cho `x-session-id`

Không có `session_id` hợp lệ chỉ bằng REST; client phải mở **Server-Sent Events** tới `${BASE_URL}/sse` và đọc event `connection`. Chi tiết payload: [04-sse.md](./04-sse.md).

---

## Theo màn hình / luồng (app)

| Nơi | API chính |
|-----|-----------|
| BottomTab (categories rỗng) | GET `/categories` |
| Image Generator tab | GET `/image-generators` |
| Characters tab | GET `/characters` |
| Assistants | Dùng cache categories |
| Chat (mount styles) | GET `/image-styles` |
| Home tab (dynamic styles, khi đã có session SSE) | GET `/dynamic/grouped-styles` + **`#sym:sessionID`** |
| Chat gửi tin | POST `/message/message` \| `/message/text-to-image` \| `/message/character` (kèm **device + session**) |
| Stop | POST `/message/stop` |

Response shape có thể bọc trong `data` tùy backend; store trong app thường đọc `response.data`.
