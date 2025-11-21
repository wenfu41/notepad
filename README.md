# 记账助手

一个美观实用的Flutter记账应用，具备数据备份和统计分析功能。

## 📱 应用介绍

记账助手是一个专为个人理财设计的现代化记账应用，具有简洁的用户界面和强大的功能。采用Material Design 3设计语言，支持深色模式，提供出色的用户体验。

### ✨ 核心功能

- **💰 记账管理**: 支持收入和支出记录，多种分类选择
- **📊 数据统计**: 月度、年度收支统计，图表可视化分析
- **🏷️ 分类管理**: 预设分类和自定义分类，支持图标和颜色自定义
- **💾 数据备份**: 支持导出Excel文件，自动数据备份到外部存储
- **🔄 数据恢复**: 应用卸载重装后自动读取保留的数据
- **📈 预算管理**: 设置月度预算，实时预算提醒和统计
- **🎨 现代设计**: Material Design 3设计，美观大气的用户界面

### 🔧 技术特点

- **跨平台**: 支持Android和iOS平台
- **数据持久化**: 使用SQLite数据库，支持外部存储
- **状态管理**: 采用Riverpod进行状态管理
- **响应式UI**: 适配不同屏幕尺寸的设备
- **高性能**: 60fps流畅动画，优秀的用户体验
- **数据安全**: 支持数据备份和恢复，防止数据丢失

## 🏗️ 技术架构

### 技术栈
- **开发语言**: Dart 3.9.2+
- **框架**: Flutter SDK
- **状态管理**: Riverpod 2.5.1
- **数据库**: SQLite (sqflite 2.3.3)
- **本地存储**: SharedPreferences
- **UI组件**: Material Design 3
- **图表**: fl_chart
- **字体**: Google Fonts
- **文件处理**: Excel导出、文件选择

### 架构模式
- **MVVM架构**: Model-View-ViewModel设计模式
- **Clean Architecture**: 分层架构设计
- **Repository模式**: 数据访问层抽象
- **依赖注入**: GetIt服务定位

### 项目结构
```
lib/
├── app/                     # 应用入口
│   ├── app.dart            # 主应用组件
│   └── router/             # 路由配置
├── core/                   # 核心功能
│   ├── constants/          # 常量定义
│   ├── themes/            # 主题配置
│   ├── database/          # 数据库相关
│   └── utils/             # 工具函数
├── data/                   # 数据层
│   ├── models/            # 数据模型
│   ├── services/          # 业务服务
│   └── providers/         # 状态提供者
├── features/              # 功能模块
│   ├── home/              # 首页
│   ├── add_transaction/   # 添加记录
│   ├── categories/        # 分类管理
│   ├── statistics/        # 统计分析
│   └── settings/          # 设置页面
└── shared/                 # 共享组件
    ├── widgets/           # 通用组件
    ├── extensions/        # 扩展函数
    └── exceptions/        # 异常处理
```

## 📦 安装和使用

### 环境要求
- Flutter SDK 3.9.2+
- Dart 3.9.2+
- Android Studio 或 VS Code
- Android SDK (Android开发)
- Xcode (iOS开发)

### 安装步骤

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd expense_tracker
   ```

2. **获取依赖**
   ```bash
   flutter pub get
   ```

3. **运行应用**
   ```bash
   flutter run
   ```

### 构建发布版

**Android APK**
```bash
flutter build apk --release
```

**iOS IPA**
```bash
flutter build ios --release
```

## 💾 数据备份说明

### 自动备份
- 应用数据存储在外部存储空间
- 应用卸载后数据仍然保留
- 重装应用后自动读取历史数据

### 手动备份
1. 在设置页面点击"备份数据"
2. 选择导出格式（Excel）
3. 文件保存到Download/ExpenseTracker_Backup文件夹

### 数据恢复
1. 在设置页面点击"恢复数据"
2. 选择备份文件
3. 确认恢复操作

### 权限要求
- **Android**: 需要存储权限用于数据备份和恢复
- **iOS**: 自动处理文件访问权限

## 🎨 界面设计

### 设计原则
- **简洁直观**: 遵循Material Design 3设计规范
- **一致性**: 统一的组件库和设计语言
- **可访问性**: 支持无障碍访问
- **响应式**: 适配不同屏幕尺寸

### 主题系统
- **浅色主题**: 默认主题，适合白天使用
- **深色主题**: 护眼模式，适合夜间使用
- **动态主题**: 跟随系统设置自动切换

### 颜色规范
- **主色调**: Material Blue (#1976D2)
- **辅助色**: Material Teal (#03DAC6)
- **功能色**: 绿色(收入)、红色(支出)、蓝色(预算)

## 📊 数据模型

### Transaction (交易记录)
- `id`: 唯一标识符
- `amount`: 金额
- `type`: 类型(收入/支出)
- `categoryId`: 分类ID
- `description`: 备注描述
- `date`: 交易日期
- `createdAt/updatedAt`: 时间戳

### Category (分类)
- `id`: 唯一标识符
- `name`: 分类名称
- `icon`: 图标
- `color`: 颜色
- `sortOrder`: 排序顺序
- `isDefault`: 是否为默认分类

### Budget (预算)
- `id`: 唯一标识符
- `categoryId`: 分类ID
- `amount`: 预算金额
- `year/month`: 预算周期
- `spent`: 已消费金额

## 🔧 开发指南

### 代码规范
- 遵循Dart官方代码规范
- 使用flutter_lints进行代码检查
- 组件和函数命名遵循驼峰命名法

### 状态管理
- 使用Riverpod进行状态管理
- 遵循单一数据源原则
- 合理使用Provider家族

### 数据库操作
- 使用事务处理复杂操作
- 合理使用索引提高查询性能
- 及时关闭数据库连接

### 错误处理
- 使用try-catch处理异常
- 提供用户友好的错误提示
- 记录日志便于调试

## 🚀 版本历史

### v1.0.0 (2024-01-XX)
- ✅ 基础记账功能
- ✅ 分类管理系统
- ✅ 数据统计功能
- ✅ 数据备份恢复
- ✅ Material Design 3界面

### 计划功能
- 📅 预算提醒功能
- 🔔 账单提醒
- 📊 更多图表类型
- 🌐 多语言支持
- ☁️ 云端同步

## 🤝 贡献指南

欢迎提交Issue和Pull Request来改进这个项目！

### 开发流程
1. Fork项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建Pull Request

### 代码提交规范
- `feat`: 新功能
- `fix`: 修复bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动

## 📄 许可证

本项目采用MIT许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系方式

- **项目维护者**: [Your Name]
- **邮箱**: [your.email@example.com]
- **项目地址**: [https://github.com/your-username/expense_tracker]

## 🙏 致谢

感谢以下开源项目的支持：
- [Flutter](https://flutter.dev/)
- [Riverpod](https://riverpod.dev/)
- [sqflite](https://pub.dev/packages/sqflite)
- [fl_chart](https://pub.dev/packages/fl_chart)
- [Google Fonts](https://pub.dev/packages/google_fonts)

---

如果这个项目对你有帮助，请给个⭐️支持一下！