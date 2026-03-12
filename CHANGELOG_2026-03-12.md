# 2026-03-12 更新 - 阅读器安全区和模式切换

## 修改内容

### 1. 顶部安全区功能
- **新增**: `safeAreaTop` 设置项，可调节顶部安全区高度（0-100px）
- **用途**: 避免阅读时顶部文字被前置摄像头遮挡
- **文件修改**:
  - `lib/pages/reader/controller.dart` - 添加 `safeAreaTop` 字段和 `changeSafeAreaTop()` 方法
  - `lib/service/local_storage_service.dart` - 添加存储键 `kReaderSafeAreaTop` 和读写方法
  - `lib/pages/reader/view.dart` - 在 `padding` 中将 `safeAreaTop` 加到 `topMargin`
  - `lib/pages/reader/widgets/reader_setting.dart` - 在"边距"标签页添加安全区调节滑块

### 2. 阅读模式快速切换
- **新增**: 在设置页"边距"标签页底部添加阅读方向快速切换入口
- **功能**: 点击后弹出单选对话框，可在滚动/左到右/右到左之间切换
- **文件修改**:
  - `lib/pages/reader/widgets/reader_setting.dart` - 添加 NormalTile 显示当前模式并支持切换
  - `lib/common/app_translations.dart` - 添加翻译文本

## 翻译文本

### 简体中文
- `safe_area`: "安全区域"
- `top_safe_area`: "顶部安全区"
- `top_safe_area_subtitle`: "避免文字被摄像头遮挡"
- `reading_mode`: "阅读模式"
- `scroll_read_mode`: "滚动阅读"
- `horizontal_read_mode`: "横向翻页"

### 繁体中文
- `safe_area`: "安全區域"
- `top_safe_area`: "頂部安全區"
- `top_safe_area_subtitle`: "避免文字被攝像頭遮擋"
- `reading_mode`: "閱讀模式"
- `scroll_read_mode`: "滾動閱讀"
- `horizontal_read_mode`: "橫向翻頁"

## 使用方法

1. **调节安全区**:
   - 打开阅读设置 → 边距标签页
   - 在"安全区域"部分拖动"顶部安全区"滑块
   - 根据摄像头位置调整合适的高度

2. **切换阅读模式**:
   - 打开阅读设置 → 边距标签页
   - 点击"阅读方向"选项
   - 选择滚动、左到右或右到左模式

## 技术细节

- 安全区高度存储在 Hive 的 `_reader` box 中，键名为 `readerSafeAreaTop`
- 默认值为 `0.0`（无安全区）
- 调节范围：0-100px，步长 1px
- 安全区高度会立即应用到阅读界面的 padding 中

## 代码分析

✅ 所有文件通过 `dart analyze` 检查，无错误无警告
