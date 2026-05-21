# 🏗️ Flutter Chat App Architecture (Provider)

## Overview
App sử dụng:
- Provider để quản lý state
- Repository pattern để tách data layer
- SSE để nhận message realtime
- Local DB để cache (offline)

---

## Layers

### 1. Presentation
- Screens
- Widgets
- Providers (ChangeNotifier)

### 2. Domain (simple)
- Models (Message, Channel)
- Business logic nằm trong Provider

### 3. Data
- API Service (REST)
- SSE Service
- Local Database (Hive / Drift)

---