# Tổng quan và chức năng

## Mục đích

Ứng dụng chat AI đa chức năng trên React Native:

- Chat văn bản theo **topic/category** (trợ lý).
- Chat theo **nhân vật (character)**.
- Tab **Image**: tạo ảnh từ text (text-to-image) với chọn style.
- **Lịch sử** hội thoại lưu cục bộ (Realm).
- **Onboarding / Welcome**, đa ngôn ngữ (`i18n`), cấu hình persist (AsyncStorage qua Zustand).

## Stack chính

- React Native + React Navigation (`Stack` + `BottomTab`).
- **HTTP:** Axios (base URL gắn trong `index.js` interceptor).
- **Realtime:** `react-native-sse` (`EventSource`) tới `/sse`.
- **Local DB:** Realm (`Conversation`, `MessageChat`).
- **State:** Zustand (`session-store`, `realm-store`, `categories-store`, …).

## Năm tab dưới cùng (BottomTab)

Thứ tự **trái → phải** trùng với `bottom-tab.tsx` và icon trong `assets/tab/index.ts` (`imgTabs`). Nhãn chữ tab đang bị comment trong `custom-tabbar.tsx`; dưới đây dùng **tên route** trong code làm khóa chính.

| # | Route (React Navigation) | File màn | Icon (ý nghĩa) | Nội dung / chức năng |
|---|---------------------------|----------|------------------|------------------------|
| 1 | `Home` | `src/screen/home/home.tsx` | `ic_chatai` | Hub: gradient nền, **HeaderHome** (nhập nhanh → Chat), **CharacterHome**, **CategoryView** (category → Assistants), **ImageGeneratorHome** → tab Image Generator, **TrendingView** (prompt trending → Chat). **API:** không gọi thêm trong màn; dùng `categories` đã fetch khi vào BottomTab (GET `/categories`). |
| 2 | `Assistants` | `src/screen/assistants/assistants.tsx` | `ic_assistant` | Category ngang + gợi ý per category; tap gợi ý → **Chat** với `inputText`. **API:** chỉ đọc `categories` trong store (cùng nguồn GET `/categories`). Params vào tab: `categoryIndex`. |
| 3 | `ImageGenerator` | `src/screen/image-generator/image-generators.tsx` | `ic_image` | Danh sách preset image generator; chọn preset → **Chat** với `inputText = prompt`, `tabIndex = 1` (tab Image). **API:** GET `/image-generators` (`fetchImageGenerators`). |
| 4 | `Characters` | `src/screen/character/characters.tsx` | `ic_character` | Danh sách nhân vật → **Chat** với `character`, `tabIndex = 0` (Ask). **API:** GET `/characters` (`fetchCharacters`). |
| 5 | `History` | `src/screen/history/history.tsx` | `ic_history` | Lịch sử hội thoại (Realm): search, xóa từng cuộc / xóa hết; mở lại cuộc → **Chat** với `conversationId`. **API:** không. |

**Màn Chat** không nằm trong tab: Push lên Stack (`router.tsx`, `screen: Chat`). **Settings / Languages / Report** cũng ngoài tab, thường từ header Home/Image/Assistants.

---

## Luồng điều hướng

1. **Splash** — sau khi hydrate config: `OnboardingScreen` → `WelcomeScreen` → `BottomTab` tùy cờ `isRunOnboarding` / `isRunWelcome` (`config-store`).
2. **BottomTab:** 5 tab như bảng trên (`bottom-tab.tsx`); vào BottomTab có thể gọi `fetchCategories()` nếu danh mục rỗng.
3. **Stack phụ:** Languages, Settings, Report, **Chat** (fullscreen ngoài tab).

## Nơi chức năng lõi được triển khai

| Chức năng | Vị trí chính |
|-----------|----------------|
| Gửi tin & dừng generate | `src/actions/chatActions.ts`, `src/services/call-api.ts` |
| Stream phản hồi | `src/services/sse-service.ts`, `src/store/session-store.ts`, `src/hooks/useChat.ts` |
| UI Chat | `src/screen/chat/*`, `src/hooks/useChat.ts` |
| Dữ liệu catalog (categories, characters, …) | `src/store/*-store.ts` + `call-api.ts` |
| Persist hội thoại | `src/store/realm-store.ts`, `src/database/*` |

## Ghi chú hành vi (từ mã hiện tại)

- `category` trong `route.params` của **Chat** được `useChat` đọc, nhưng **không có** `navigation.navigate('Chat', { category: … })` trong codebase hiện tại — chỉ có `inputText`, `character`, `conversationId`, `tabIndex`. Gợi ý/category trên tab Ask phụ thuộc vào việc truyền `category` sau này.
- Aspect ratio được chọn trên UI (`SelectRatioBottomSheet`) nhưng **không thấy** được gửi trong `MessageRequest` tại `ChatActions.sendMessage`; nếu backend hỗ trợ ratio, cần bổ sung field và mapping.
