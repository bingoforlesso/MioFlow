# 秒订 Flutter Application

## 产品简介
秒订 是一个基于 Flutter 3.24+ 开发的跨平台应用程序，提供现代化的用户界面和流畅的用户体验。应用采用了最新的 Flutter 技术栈和最佳实践，支持多平台部署。

## 功能特点
- 现代化的 Material Design 3 界面设计
- 完整的用户认证系统（登录/注册）
- 响应式界面设计，支持多种屏幕尺寸
- 深色模式支持
- 多语言支持（中文/英文）
- 状态管理使用 BLoC 模式
- 依赖注入实现

## 主要功能说明
1. 用户认证
   - 用户注册
   - 用户登录
   - 密码重置
   - 会话管理

2. 主页功能
   - 用户信息显示
   - 导航菜单
   - 主题切换

## 技术栈
- Flutter 3.24+
- Dart 语言（支持空安全）
- BLoC 状态管理
- Provider 状态管理
- GoRouter 路由管理
- GetIt 依赖注入
- Flutter Localizations 国际化
- Material 3 设计系统

## 依赖版本说明
1. 核心依赖
   ```yaml
   environment:
     sdk: '>=3.1.0 <4.0.0'
   
   dependencies:
     flutter:
       sdk: flutter
     # UI 相关
     cupertino_icons: ^1.0.2
     google_fonts: ^6.1.0
     
     # 网络和数据处理
     dio: ^5.0.0
     mysql1: ^0.20.0
     
     # 状态管理
     flutter_bloc: ^8.1.3
     provider: ^6.0.5
     
     # 依赖注入
     get_it: ^7.2.0
     injectable: ^2.1.2
     
     # 路由管理
     go_router: ^13.0.0
     
     # 数据模型
     freezed_annotation: ^2.4.1
     json_annotation: ^4.8.1
     equatable: ^2.0.5
     
     # 多媒体处理
     image_picker: ^1.0.4
     speech_to_text: ^6.3.0
     cached_network_image: ^3.2.3
     
     # 工具类
     flutter_dotenv: ^5.1.0
     shared_preferences: ^2.2.2
     intl: ^0.19.0
     uuid: ^4.3.3

   dev_dependencies:
     flutter_test:
       sdk: flutter
     flutter_lints: ^2.0.0
     build_runner: ^2.4.7
     json_serializable: ^6.7.1
     freezed: ^2.4.5
     injectable_generator: ^2.1.6
     mockito: ^5.4.4
     analyzer: ^5.13.0
   ```

2. 依赖说明
   - dio: HTTP 客户端，用于网络请求
   - flutter_bloc: 状态管理库，处理应用状态
   - get_it: 依赖注入容器，管理服务实例
   - go_router: 声明式路由管理
   - freezed_annotation: 数据类生成器注解
   - injectable: 依赖注入注解
   - image_picker: 图片选择器
   - speech_to_text: 语音识别
   - flutter_dotenv: 环境变量管理
   - uuid: 生成唯一标识符
   - cached_network_image: 图片缓存
   - shared_preferences: 本地数据存储
   - intl: 国际化支持

3. 开发依赖说明
   - build_runner: 代码生成器
   - json_serializable: JSON 序列化
   - freezed: 不可变对象生成器
   - injectable_generator: 依赖注入代码生成
   - mockito: 测试模拟
   - analyzer: 代码分析

4. 版本兼容性注意事项
   - Flutter SDK: 确保使用 3.24.0 或更高版本
   - Dart SDK: 确保使用 3.1.0 或更高版本
   - 依赖冲突解决：
     ```bash
     # 检查依赖冲突
     flutter pub outdated
     
     # 升级依赖
     flutter pub upgrade
     
     # 指定版本升级
     flutter pub upgrade --major-versions
     ```

5. 依赖配置验证
   ```bash
   # 验证依赖配置
   flutter pub get
   
   # 生成必要的代码
   flutter pub run build_runner build --delete-conflicting-outputs
   
   # 清理并重新构建
   flutter clean
   flutter pub get
   flutter pub run build_runner build
   ```

6. 常见依赖问题解决
   - 版本不兼容：检查 pubspec.yaml 中的版本约束
   - 代码生成失败：清理缓存后重新生成
   - 依赖冲突：使用 `dependency_overrides` 解决
   - 示例：
     ```yaml
     dependency_overrides:
       package_name: ^x.y.z
     ```

## 常见问题说明

1. 输入文字无响应问题
   - 问题现象：在输入框输入文字（如"水龙头"）后，点击发送按钮没有响应
   - 问题原因：
     * 消息处理逻辑不完整
     * 输入框内容未清除
     * 状态更新不及时
   - 解决方案：
     * 修复了 `ChatWidget` 中的 `_handleTextSubmitted` 方法
     * 确保发送消息后清除输入框
     * 添加加载状态处理
     * 使用正确的 `messageSent` 事件
   - 验证方法：
     ```dart
     // 在 _handleTextSubmitted 方法中添加调试输出
     debugPrint('发送消息: $text');
     ```

2. .env 文件加载失败问题
   - 问题现象：
     ```dart
     // lib/main.dart 中的代码会在 .env 加载失败时使用默认配置
     try {
       await dotenv.load(fileName: '.env');
     } catch (e) {
       debugPrint('Error loading .env: $e');
       dotenv.testLoad(fileInput: '''
       API_BASE_URL=http://localhost:8000
       ...
       ''');
     }
     ```
   - 可能原因：
     1. 文件路径问题：确保 `.env` 文件在项目根目录
     2. 文件权限问题：确保文件有正确的读取权限
     3. 文件编码问题：确保文件使用 UTF-8 编码，无 BOM 头
     4. Flutter 资源配置：确保在 `pubspec.yaml` 中正确配置
   - 解决步骤：
     1. 检查文件位置：
       ```bash
       ls -la .env  # 确认文件存在且在正确位置
       ```
     2. 检查文件权限：
       ```bash
       chmod 644 .env  # 设置正确的文件权限
       ```
     3. 检查文件编码：
       ```bash
       file -I .env  # 检查文件编码
       ```
     4. 更新 pubspec.yaml：
       ```yaml
       flutter:
         assets:
           - .env
           - .env.development
           - .env.production
       ```
     5. 清理并重新构建：
       ```bash
       flutter clean
       flutter pub get
       flutter pub run build_runner build --delete-conflicting-outputs
       ```
   - 验证方法：
     ```dart
     // 在 main.dart 中添加调试输出
     debugPrint('API_BASE_URL: ${dotenv.env['API_BASE_URL']}');
     ```
   - 已知问题：
     - 项目中发现 pubspec.yaml 未正确配置 .env 文件，导致加载失败
     - 解决方案：已更新 pubspec.yaml，添加了 .env 到 assets 配置中

3. 依赖相关问题
   - 问题现象：依赖版本冲突或不兼容
   - 解决方案：
     * 使用 `flutter pub outdated` 检查过期依赖
     * 使用 `flutter pub upgrade` 更新依赖
     * 在 pubspec.yaml 中指定兼容版本
     * 必要时使用 `dependency_overrides`
   - 关键依赖版本要求：
     ```yaml
     flutter_bloc: ^8.1.3  # 状态管理
     dio: ^5.0.0          # 网络请求
     get_it: ^7.2.0       # 依赖注入
     flutter_dotenv: ^5.1.0  # 环境变量
     ```

## 使用说明
1. 环境配置

   ### Android SDK 配置
   ```bash
   # macOS 配置 Android SDK 环境变量
   echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
   echo 'export PATH=$PATH:$ANDROID_HOME/tools' >> ~/.zshrc
   echo 'export PATH=$PATH:$ANDROID_HOME/tools/bin' >> ~/.zshrc
   echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
   source ~/.zshrc

   # Windows 配置 Android SDK 环境变量
   # 1. 打开系统环境变量设置
   # 2. 新建系统变量 ANDROID_HOME，值为 Android SDK 安装路径
   # 例如：C:\Users\YourUsername\AppData\Local\Android\Sdk
   # 3. 在 Path 变量中添加以下路径：
   # %ANDROID_HOME%\tools
   # %ANDROID_HOME%\tools\bin
   # %ANDROID_HOME%\platform-tools

   # Linux 配置 Android SDK 环境变量
   echo 'export ANDROID_HOME=$HOME/Android/Sdk' >> ~/.bashrc
   echo 'export PATH=$PATH:$ANDROID_HOME/tools' >> ~/.bashrc
   echo 'export PATH=$PATH:$ANDROID_HOME/tools/bin' >> ~/.bashrc
   echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.bashrc
   source ~/.bashrc

   # 验证配置
   echo $ANDROID_HOME
   adb --version
   ```

   ### Flutter 环境检查
   ```bash
   # 检查 Flutter 环境
   flutter doctor
   
   # 获取依赖
   flutter pub get
   
   # 生成必要的代码
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. 运行应用
   ```bash
   # 调试模式运行
   flutter run
   
   # 发布模式运行
   flutter run --release
   ```

3. Android 编译打包
   ```bash
   # 生成 Android APK
   flutter build apk --release

   # 生成 Android App Bundle
   flutter build appbundle --release

   # 指定环境变量打包
   flutter build apk --release --dart-define=ENVIRONMENT=prod

   # 查看签名信息
   keytool -list -v -keystore <keystore_path> -alias <alias_name>
   ```

4. iOS 编译打包
   ```bash
   # 生成 iOS 发布包
   flutter build ios --release

   # 生成 iOS Archive
   xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release -archivePath build/Runner.xcarchive archive

   # 导出 IPA
   xcodebuild -exportArchive -archivePath build/Runner.xcarchive -exportOptionsPlist exportOptions.plist -exportPath build/ios

   # 指定环境变量打包
   flutter build ios --release --dart-define=ENVIRONMENT=prod
   ```

5. 多平台构建
   ```bash
   # 同时构建所有支持的平台
   flutter build all

   # 查看支持的目标平台
   flutter devices
   ```

## 服务器配置和维护

### 端口配置说明
1. 后端服务器端口
   - 默认端口：8000
   - 配置位置：
     - `.env` 文件：`API_BASE_URL=http://localhost:8000`
     - `lib/core/config/env.dart`：默认返回 `http://localhost:8000`
     - `lib/main.dart`：环境变量加载失败时的默认配置
     - `server/.env.example`：允许的前端域名配置 `ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080`

2. 数据库端口
   - MySQL 默认端口：3306
   - 数据库连接信息：
     ```
     Host: 127.0.0.1
     Port: 3306
     User: root
     Password: Ac661978
     Database: mioflow
     ```

3. 其他服务端口配置
   - 地址服务：
     - `lib/features/address/domain/services/address_service.dart`：默认端口 3000
   - 经销商服务：
     - `lib/features/dealer/domain/services/dealer_service.dart`：默认端口 3000
   - 前端开发服务器：
     - `vite.config.ts`：默认端口 3000
   - Python 后端服务器：
     - `src/server/main.py`：CORS 配置允许端口 3000

4. 端口配置检查清单
   - [ ] 确保 `.env` 文件中的 `API_BASE_URL` 设置为 `http://localhost:8000`
   - [ ] 确保后端服务器运行在 8000 端口
   - [ ] 确保 MySQL 数据库运行在 3306 端口
   - [ ] 如果需要修改端口，请同时更新以下文件：
     * `.env`
     * `lib/main.dart` 中的默认配置
     * `lib/features/address/domain/services/address_service.dart`
     * `lib/features/dealer/domain/services/dealer_service.dart`
     * `server/.env.example`
     * `src/server/main.py`
     * `vite.config.ts`
     * 后端服务器配置

3. 常见端口问题排查
   - 如果遇到 `Connection refused` 错误，请检查：
     * 后端服务器是否正在运行
     * 端口号是否配置正确（8000）
     * 是否有其他服务占用了该端口

4. 环境配置文件问题排查
   - `.env` 文件加载失败问题：
     * 问题现象：
       ```dart
       // lib/main.dart 中的代码会在 .env 加载失败时使用默认配置
       try {
         await dotenv.load(fileName: '.env');
       } catch (e) {
         debugPrint('Error loading .env: $e');
         dotenv.testLoad(fileInput: '''
         API_BASE_URL=http://localhost:8000
         ...
         ''');
       }
       ```
     * 可能原因：
       1. 文件路径问题：确保 `.env` 文件在项目根目录
       2. 文件权限问题：确保文件有正确的读取权限
       3. 文件编码问题：确保文件使用 UTF-8 编码，无 BOM 头
       4. Flutter 资源配置：确保在 `pubspec.yaml` 中正确配置
     * 解决步骤：
       1. 检查文件位置：
          ```bash
          ls -la .env  # 确认文件存在且在正确位置
          ```
       2. 检查文件权限：
          ```bash
          chmod 644 .env  # 设置正确的文件权限
          ```
       3. 检查文件编码：
          ```bash
          file -I .env  # 检查文件编码
          ```
       4. 更新 pubspec.yaml：
          ```yaml
          flutter:
            assets:
              - .env
              - .env.development
              - .env.production
          ```
       5. 清理并重新构建：
          ```bash
          flutter clean
          flutter pub get
          flutter pub run build_runner build --delete-conflicting-outputs
          ```
     * 验证方法：
       ```dart
       // 在 main.dart 中添加调试输出
       debugPrint('API_BASE_URL: ${dotenv.env['API_BASE_URL']}');
       ```
     * 已知问题：
       - 项目中发现 pubspec.yaml 未正确配置 .env 文件，导致加载失败
       - 解决方案：已更新 pubspec.yaml，添加了 .env 到 assets 配置中

5. 端口修改步骤
   ```bash
   # 1. 修改 .env 文件
   API_BASE_URL=http://localhost:新端口号

   # 2. 修改 lib/main.dart 中的默认配置
   # 找到 dotenv.testLoad 部分并更新
   ```

6. 需要修改的3000端口清单（按调用链排序）
   - [ ] API 调用链相关：
     * `lib/features/chat/presentation/widgets/chat_widget.dart`
     * `lib/features/product/domain/services/product_matcher_service.dart`
     * `lib/features/product/data/repositories/product_repository_impl.dart`
     * `lib/features/product/data/datasources/product_remote_data_source.dart`
     * `lib/core/services/api_service.dart`

   - [ ] 服务配置相关：
     * `lib/features/address/domain/services/address_service.dart`
       ```dart
       AddressService() : baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
       ```
     * `lib/features/dealer/domain/services/dealer_service.dart`
       ```dart
       DealerService() : baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
       ```

   - [ ] 环境配置相关：
     * `.env`
     * `lib/main.dart` 中的默认配置
     * `lib/core/config/env.dart`

   - [ ] 服务器配置相关：
     * `vite.config.ts`
       ```typescript
       target: 'http://localhost:3000'
       ```
     * `src/server/main.py`
       ```python
       allow_origins=["http://localhost:3000"]
       ```
     * `server/.env.example`
       ```
       ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
       ```

   - [ ] 其他可能的位置：
     * 所有使用 `ApiService` 的服务类
     * 所有使用 `baseUrl` 或 `API_URL` 的文件
     * 所有包含 `localhost` 的配置文件
     * 检查 `build.yaml`、`pubspec.yaml` 等构建配置文件
     * 检查 `android/app/src/main/AndroidManifest.xml` 中的网络配置
     * 检查 `ios/Runner/Info.plist` 中的网络配置

   修改步骤：
   1. 使用以下命令查找所有包含端口的文件：
      ```bash
      grep -r "localhost:[0-9]\+" .
      ```
   2. 将所有发现的 3000 端口改为 8000
   3. 执行清理和重新构建：
      ```bash
      flutter clean
      flutter pub get
      flutter run
      ```