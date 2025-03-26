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
- 智能搜索匹配功能

## 主要功能说明

### 智能搜索功能
产品搜索功能提供了多种智能匹配方式，大大提升了搜索的灵活性和准确性：

1. **同音字匹配**
   - 自动识别并匹配同音汉字，如搜索"连塑"能匹配到"联塑"品牌产品
   - 基于优化的文本规范化算法，优先处理同音字映射
   - 支持常见多音字智能匹配

2. **拼音匹配**
   - 支持使用拼音进行搜索，如"shuiguan"可匹配到"水管"
   - 结合中文分词技术，提高拼音匹配准确度
   - 支持不完整拼音和拼音首字母搜索

3. **分词匹配**
   - 智能分析复合查询词，如"不锈钢水管"会被分解为多个关键词进行匹配
   - 自动识别产品类别、材质、品牌等关键信息
   - 根据分词权重进行智能排序

4. **数字单位匹配**
   - 支持中英文单位互换，如"1.5寸"可匹配"1.5inch"相关产品
   - 自动转换常见计量单位（如厘米、米、英寸等）
   - 支持小数点和分数形式的数值匹配

5. **品牌匹配**
   - 智能识别品牌名称，如"ppr管"能识别为PPR材质的管道产品
   - 品牌别名和缩写支持
   - 自动纠正常见品牌名称拼写错误

搜索匹配功能通过优化的normalize_text函数实现，该函数按照以下顺序处理文本：
- 首先处理同音字映射
- 转换为小写以便不区分大小写匹配
- 处理别名和缩写映射
- 处理单位换算和标准化

### 产品筛选功能
产品列表页面提供了强大的筛选功能，可以根据以下属性进行筛选：

- 规格（Specification）
- 度数（Degree）
- 材质（Material）
- 品牌（Brand）
- 型号（Model）
- 产品类型（Product Type）
- 名称（Name）
- 颜色（Color）
- 长度（Length）
- 压力（Pressure）
- 重量（Weight）
- 输出品牌（Output Brand）
- 功率（Wattage）
- 使用类型（Usage Type）
- 子类型（Sub Type）

筛选面板位于产品列表的左侧，用户可以：
1. 展开/折叠各个筛选组
2. 选择/取消选择筛选选项
3. 查看每个选项的产品数量
4. 一键清除所有筛选条件

筛选结果会实时更新，显示符合所有选中条件的产品。

1. 用户认证
   - 用户注册
   - 用户登录
   - 密码重置
   - 会话管理

2. 主页功能
   - 用户信息显示
   - 导航菜单
   - 主题切换

### API接口列表

#### 产品管理接口
1. **获取产品列表**
   - 方法: `GET`
   - 路径: `/api/v1/products`
   - 功能: 获取产品列表，支持分页和多种过滤条件
   - 参数:
     * `page`: 页码，默认1
     * `page_size`: 每页数量，默认20
     * `filters`: 筛选条件，如品牌、材质等

2. **搜索产品**
   - 方法: `POST`
   - 路径: `/api/v1/products/search`
   - 功能: 通过关键词搜索产品
   - 参数:
     * `query`: 搜索关键词
     * `page`: 页码，默认1
     * `page_size`: 每页数量，默认20
     * `filters`: 筛选条件，如品牌、材质等

3. **获取产品属性值列表**
   - 方法: `GET`
   - 路径: `/api/v1/products/attributes/{attribute}`
   - 功能: 获取指定属性的所有可能值
   - 参数:
     * `attribute`: 属性名称，如brand（品牌）、material（材质）等

4. **获取产品详情**
   - 方法: `GET`
   - 路径: `/api/v1/products/{id}`
   - 功能: 获取指定ID的产品详细信息
   - 参数:
     * `id`: 产品ID

5. **按类别查询产品**
   - 方法: `GET`
   - 路径: `/api/v1/products/category/{type}`
   - 功能: 根据产品类型获取商品列表
   - 参数:
     * `type`: 产品类型
     * `page`: 页码，默认1
     * `page_size`: 每页数量，默认20

6. **按品牌查询产品**
   - 方法: `GET`
   - 路径: `/api/v1/products/brand/{brand}`
   - 功能: 根据品牌获取产品列表
   - 参数:
     * `brand`: 品牌名称
     * `page`: 页码，默认1
     * `page_size`: 每页数量，默认20

7. **查找相似产品**
   - 方法: `GET`
   - 路径: `/api/v1/products/similar/{id}`
   - 功能: 查找与指定产品相似的商品
   - 参数:
     * `id`: 产品ID
     * `limit`: 返回结果数量限制，默认5

#### 订单管理接口
1. **创建订单**
   - 方法: `POST`
   - 路径: `/api/v1/orders`
   - 功能: 创建新订单

2. **获取订单列表**
   - 方法: `GET`
   - 路径: `/api/v1/orders`
   - 功能: 获取订单列表
   - 参数:
     * `page`: 页码，默认1
     * `page_size`: 每页数量，默认20

3. **获取订单详情**
   - 方法: `GET`
   - 路径: `/api/v1/orders/{id}`
   - 功能: 获取指定ID的订单详细信息
   - 参数:
     * `id`: 订单ID

4. **更新订单状态**
   - 方法: `PATCH`
   - 路径: `/api/v1/orders/{id}/status`
   - 功能: 更新订单状态
   - 参数:
     * `id`: 订单ID
     * `status`: 新状态

#### 购物车接口
1. **添加商品到购物车**
   - 方法: `POST`
   - 路径: `/api/v1/cart/items`
   - 功能: 添加商品到购物车

2. **获取购物车商品**
   - 方法: `GET`
   - 路径: `/api/v1/cart/items`
   - 功能: 获取购物车中的所有商品

3. **更新购物车商品数量**
   - 方法: `PATCH`
   - 路径: `/api/v1/cart/items/{id}`
   - 功能: 更新购物车中特定商品的数量
   - 参数:
     * `id`: 购物车项ID

4. **删除购物车商品**
   - 方法: `DELETE`
   - 路径: `/api/v1/cart/items/{id}`
   - 功能: 从购物车中删除特定商品
   - 参数:
     * `id`: 购物车项ID

#### 经销商管理接口
1. **获取经销商列表**
   - 方法: `GET`
   - 路径: `/api/v1/dealers`
   - 功能: 获取经销商列表
   - 参数:
     * `page`: 页码，默认1
     * `page_size`: 每页数量，默认20

2. **获取经销商详情**
   - 方法: `GET`
   - 路径: `/api/v1/dealers/{id}`
   - 功能: 获取指定ID的经销商详细信息
   - 参数:
     * `id`: 经销商ID

#### 地址管理接口
1. **创建地址**
   - 方法: `POST`
   - 路径: `/api/v1/addresses`
   - 功能: 创建新地址

2. **获取地址列表**
   - 方法: `GET`
   - 路径: `/api/v1/addresses`
   - 功能: 获取地址列表

3. **获取地址详情**
   - 方法: `GET`
   - 路径: `/api/v1/addresses/{id}`
   - 功能: 获取指定ID的地址详细信息
   - 参数:
     * `id`: 地址ID

4. **更新地址**
   - 方法: `PUT`
   - 路径: `/api/v1/addresses/{id}`
   - 功能: 更新指定地址
   - 参数:
     * `id`: 地址ID

5. **删除地址**
   - 方法: `DELETE`
   - 路径: `/api/v1/addresses/{id}`
   - 功能: 删除指定地址
   - 参数:
     * `id`: 地址ID

### API文档
API文档使用Swagger生成，可通过以下地址访问：
- 本地开发环境: http://localhost:3000/docs
- 测试环境: http://test-api.example.com/docs
- 生产环境: https://api.example.com/docs

API文档提供了所有接口的详细信息，包括请求参数、响应格式和示例。开发人员可以通过文档页面直接测试API功能。

## 技术栈
- Flutter 3.24+
- Dart 语言（支持空安全）
- BLoC 状态管理
- Provider 状态管理
- GoRouter 路由管理
- GetIt 依赖注入
- Flutter Localizations 国际化
- Material 3 设计系统
- Python FastAPI 后端
- MySQL 9.2.0 数据库

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

4. 数据库表使用问题
   - 问题现象：代码中错误使用 `products` 表而不是 `product_info` 表
   - 问题原因：
     * 未仔细阅读数据库设计文档
     * 使用了默认的表名假设
     * 缺乏与后端的沟通确认
   - 正确做法：
     * 使用 `product_info` 表作为商品信息主表
     * 表结构包含更丰富的字段：
       - 基本信息：id, code, name, brand
       - 规格参数：specification, material, color, length
       - 性能参数：pressure, degree, wattage
       - 分类信息：product_type, usage_type, sub_type
     * 在代码中明确注释表的用途和关系
   - 改进措施：
     * 添加数据库表映射文档
     * 在代码中统一使用正确的表名
     * 添加表名常量定义
     * 定期同步数据库设计变更

5. 搜索功能问题解决
   - 问题现象：搜索同音字产品时无法返回正确结果
   - 问题原因：
     * `normalize_text`函数处理顺序不正确
     * 同音字映射未优先处理
     * 文本转换为小写过早，影响了同音字处理
   - 解决方案：
     * 重新调整了文本处理顺序，优先处理同音字映射
     * 将处理同音字的逻辑移到函数开头
     * 确保在所有映射处理后才进行其他文本转换
     * 添加更多详细的同音字映射对
   - 优化效果：
     * 同音字搜索：如"连塑"成功匹配到"联塑"品牌产品
     * 拼音搜索：如"shuiguan"成功匹配到"水管"相关产品
     * 分词匹配：如"不锈钢水管"成功匹配到相关产品
     * 数字单位匹配：如"1.5寸"成功匹配到"1.5inch"相关规格产品
     * 品牌匹配：如"ppr管"成功识别PPR材质管道产品

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

## 搜索结果筛选功能实现

### 第一阶段：基础筛选功能

#### 功能亮点
1. 智能筛选面板
   - 左侧固定宽度(280dp)的筛选面板，采用 Material Design 3 设计规范
   - 支持 15 种核心产品属性的精确筛选
   - 实时显示每个筛选选项对应的产品数量
   - 支持筛选条件的展开/折叠管理
   - 一键清除所有筛选条件

2. 用户友好的交互设计
   - 筛选选项支持多选操作
   - 已选条件在顶部横向滚动展示
   - 每个筛选条件支持单独删除
   - 空结果时提供智能建议
   - 支持通过点击产品卡片上的属性标签快速筛选

3. 高性能实现
   - 使用 ListView.builder 实现长列表的高效渲染
   - 筛选操作采用防抖处理，优化性能
   - 预计算筛选选项数量，避免重复计算
   - 采用 BLoC 模式管理状态，确保响应性能

4. 数据结构设计
   ```dart
   // 筛选选项定义
   class FilterOption {
     final String attribute;    // 属性名称
     final String value;        // 选项值
     final int count;          // 符合该选项的产品数量
     final bool selected;      // 是否被选中
   }

   // 筛选组定义
   class FilterGroup {
     final String attribute;    // 属性名称
     final String displayName;  // 显示名称
     final List<FilterOption> options;  // 选项列表
     final bool isExpanded;    // 是否展开
   }

   // 筛选状态定义
   class FilterState {
     final Map<String, Set<String>> selectedFilters;  // 已选筛选条件
     final List<FilterGroup> filterGroups;            // 所有筛选组
   }
   ```

5. 核心筛选属性
   - 规格（Specification）
   - 度数（Degree）
   - 材质（Material）
   - 品牌（Brand）
   - 型号（Model）
   - 产品类型（Product Type）
   - 名称（Name）
   - 颜色（Color）
   - 长度（Length）
   - 压力（Pressure）
   - 重量（Weight）
   - 输出品牌（Output Brand）
   - 功率（Wattage）
   - 使用类型（Usage Type）
   - 子类型（Sub Type）

6. 性能优化策略
   - 采用懒加载方式显示筛选选项
   - 使用缓存优化筛选结果
   - 实现筛选条件的本地存储
   - 优化筛选算法复杂度
   - 减少不必要的重建

7. 用户体验优化
   - 提供清晰的视觉反馈
   - 支持键盘快捷操作
   - 适配不同屏幕尺寸
   - 实现平滑的动画效果
   - 提供友好的错误提示

8. 技术实现亮点
   - 使用 BLoC 模式实现状态管理
   - 采用 Repository 模式处理数据
   - 实现依赖注入优化代码结构
   - 使用 Freezed 生成不可变对象
   - 支持单元测试和集成测试

9. 开发步骤
   ```bash
   # 1. 创建筛选相关的数据模型
   lib/features/product/domain/models/filter_option.dart
   lib/features/product/domain/models/filter_group.dart
   lib/features/product/domain/models/filter_state.dart

   # 2. 创建筛选服务
   lib/features/product/domain/services/filter_service.dart

   # 3. 创建筛选相关的 UI 组件
   lib/features/product/presentation/widgets/filter_panel.dart
   lib/features/product/presentation/widgets/filter_group.dart
   lib/features/product/presentation/widgets/selected_filters.dart
   lib/features/product/presentation/widgets/filter_option_item.dart

   # 4. 创建筛选状态管理
   lib/features/product/presentation/bloc/filter_bloc.dart
   lib/features/product/presentation/bloc/filter_event.dart
   lib/features/product/presentation/bloc/filter_state.dart
   ```

10. 测试用例
    ```dart
    void main() {
      group('Filter Service Tests', () {
        test('应该正确过滤单个属性', () {
          // 测试代码
        });

        test('应该支持多属性组合筛选', () {
          // 测试代码
        });

        test('应该正确计算筛选选项数量', () {
          // 测试代码
        });
      });
    }
    ```

11. 注意事项
    - 确保筛选逻辑的性能优化
    - 处理空结果的用户体验
    - 保持筛选状态的一致性
    - 支持筛选条件的持久化
    - 考虑移动端的触摸友好性

## Cursor 历史下载链接