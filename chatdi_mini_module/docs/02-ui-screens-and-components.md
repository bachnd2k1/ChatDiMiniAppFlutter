# UI theo màn hình và component

## Navigator

- **`src/router/router.tsx`:** Stack: Splash → Onboarding, Welcome, BottomTab, Languages, Settings, Report, Chat.
- **`src/router/bottom-tab.tsx`:** 5 tab + `CustomTabBar`; vào BottomTab prefetch **GET `/categories`** nếu store rỗng.

### Bảng 5 tab ↔ phần UI / màn

| Route | Screen | Khối UI chính trên tab |
|-------|--------|-------------------------|
| `Home` | `home.tsx` | `LinearGradient`; `HeaderHome`; `CharacterHome`; `CategoryView`; `ImageGeneratorHome`; `TrendingView` |
| `Assistants` | `assistants.tsx` | `HeaderView`; `FlatList` category (`CategoryItem`); `FlatList` gợi ý (`SuggestItem`) |
| `ImageGenerator` | `image-generators.tsx` | `HeaderView`; danh sách preset (`image-gen-*`) |
| `Characters` | `characters.tsx` | `HeaderView`; danh sách (`character-item`) |
| `History` | `history.tsx` | Search + `FlatList` `HistoryItem` |

Chi tiết API/dữ liệu từng tab: xem [01-overview-and-features.md § Năm tab](./01-overview-and-features.md#năm-tab-dưới-cùng-bottomtab).

---

## Splash (`screen/welcome/splash.tsx`)

- **UI:** Logo full màn.
- **Logic:** Đọc hydrate `useConfigStore`, điều hướng theo onboarding/welcome đã hoàn thành hay chưa.

---

## Onboarding (`screen/onboarding/`)

- **UI:** Các slide onboarding (`onboarding-item`, `data`).
- **Điều hướng:** Kết thúc → `WelcomeScreen`.

---

## Welcome (`screen/welcome/`)

- **UI:** Giới thiệu checklist (`welcome-item`), dữ liệu static/ghi trong `constants` / assets.
- **Điều hướng:** Vào `BottomTab`.

---

## Bottom tab — Home (`screen/home/home.tsx`)

- **UI:**
  - Nền `LinearGradient`.
  - **HeaderHome** (`header-home.tsx`): ô nhập prompt nhanh, nút Settings, gửi `Chat` với `inputText`.
  - **SectionList** các khối: Characters (`CharacterHome` / `character-view`), Assistants (**CategoryView**), Image Generator (**ImageGeneratorHome**), Trending (**TrendingView**).
- **Điều hướng:** `Assistants` (See All hoặc từ category), `Characters`, `ImageGenerator`, `Chat` (từ trending / character item).

---

## Assistants (`screen/assistants/assistants.tsx`)

- **UI:** `HeaderView`, list category ngang (`CategoryItem`), list gợi ý (`SuggestItem`).
- **Params:** `categoryIndex` để scroll/highlight category.
- **Điều hướng:** `Chat` với `{ inputText }` — **không** truyền object category.

---

## Image Generator (`screen/image-generator/`)

- **UI:** Header, grid/list preset (`ImageGenItem`, modal chi tiết nếu có).
- **Điều hướng:** `Chat` với `{ inputText: prompt, tabIndex: 1 }` để mở tab Image.

---

## Characters (`screen/character/characters.tsx`)

- **UI:** Danh sách character (`character-item`).
- **Điều hướng:** `Chat` với `{ character, tabIndex: 0 }`.

---

## History (`screen/history/history.tsx`)

- **UI:** Ô search, danh sách `HistoryItem`, xóa 1 / xóa all (popup `showPopup`).
- **Nguồn dữ liệu:** Realm qua hook `useHistory` (không gọi API).

---

## Chat (`screen/chat/chat.tsx`)

Khối UI chính:

| Thành phần | File | Vai trò |
|------------|------|--------|
| Header + tab Ask/Image | `HeaderView`, `TabHeaderView` | Back, xóa hội thoại, đổi tab |
| Nội dung tin | `ChatContentView` | FlatList bubble, loading, copy/share/tải ảnh |
| Gợi ý (chỉ khi có) | `SuggestionView`, `SuggestionItemView` | Chip gợi ý nhập vào ô input |
| Image tab — style bar | `PickStyleView` | Mở bottom sheet Style / Ratio |
| Bottom sheet style | `SelectStyleBottomSheet` | Chọn `ImageStyle` từ store |
| Bottom sheet ratio | `SelectRatioBottomSheet` | Chọn tỷ lệ khung hình |
| Composer | `InputView` | Nhập, gửi, stop generate, mic/photo placeholder |

Logic tập trung ở **`useChat`** (`src/hooks/useChat.ts`).

---

## Settings (`screen/setting/settings.tsx`)

- **UI:** Các row: Languages, Report, …
- **Điều hướng:** `Languages`, `Report`.

---

## Languages (`screen/language/languages.tsx`)

- **UI:** Chọn ngôn ngữ (`language-item`).
- **Lưu:** `language-store` / `config-store` + `i18n`.

---

## Report (`screen/report/report.tsx`)

- **UI:** Hình minh họa, mô tả, `TextInput`, nút gradient gửi.
- **API:** Nút Send hiện `onPress={() => {}}` — **chưa** gọi backend.

---

## Component dùng chung (một phần)

- `components/header-view.tsx`, `button-gradient.tsx`, `rating-bottom-sheet.tsx`, `tab-header-view.tsx`, v.v.
- Assets theo domain: `src/assets/chat`, `welcome`, `setting`, …
