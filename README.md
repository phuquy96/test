# 0xjz1 iOS App

## Cấu Trúc Project
```
0xjz1-ios/
├── project.yml                    ← XcodeGen config
├── Sources/
│   └── App/
│       ├── AppDelegate.swift
│       └── ViewController.swift
├── Resources/
│   └── web/
│       └── index.html             ← UI chính (iOS 26 glass)
└── .github/
    └── workflows/
        └── build.yml              ← Tự build IPA trên GitHub
```

## Cách Đưa Lên GitHub & Lấy IPA

### Bước 1: Tạo repo GitHub mới
1. Vào https://github.com/new
2. Đặt tên repo (ví dụ: `0xjz1-app`)
3. **Không** tích "Add README" (để trống)
4. Nhấn **Create repository**

### Bước 2: Push code lên GitHub
Mở Terminal / PowerShell trong thư mục `0xjz1-ios`:
```bash
git init
git add .
git commit -m "Initial 0xjz1 iOS app"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/0xjz1-app.git
git push -u origin main
```

### Bước 3: Lấy IPA
1. Vào tab **Actions** của repo
2. Chọn workflow **"Build 0xjz1 IPA"** đang chạy
3. Chờ build xong (~5-10 phút)
4. Kéo xuống mục **Artifacts**
5. Nhấn **aloalo-ipa-X** để tải về → file `aloalo.ipa`

### Bước 4: Ký & Cài IPA
Dùng **ESign** / **AltStore** / **Sideloadly**:
- Mở app ký, chọn `aloalo.ipa`
- Ký xong → cài vào máy

## API Key Info
- **API URL:** `https://severphuquy.sbs/api/server_key.php`
- **API Token:** `PQ-LIVE-2-D4BAFBDF9058F4FE`
- **Format:** `?api_key=TOKEN&key=USER_KEY&hwid=DEVICE_HWID`

## Tính Năng
- ✅ Giao diện iOS 26 Glassmorphism
- ✅ Kết nối realtime server key PhuQuy
- ✅ HWID tự động lấy từ thiết bị
- ✅ Khóa thiết bị sau khi nhập key thành công
- ✅ Hiển thị: Key / Thời Hạn / Ngày Hết Hạn
- ✅ Đếm ngược 6s vào menu sau khi xác thực
- ✅ Polling 30s đồng bộ với server
- ✅ Tự kick về màn nhập key khi hết hạn (4s)
- ✅ Thông báo lỗi: Bị Khóa / Bị Xóa / Hết Hạn / Không Tồn Tại
- ✅ 3 Tab: Trang Chủ / Ứng Dụng / Cài Đặt
- ✅ Đếm ngược realtime ở tab Cài Đặt
