# 课程资料教学视频脚本 v6

## 技术特性

- **edge_tts** (zh-CN-XiaoxiaoNeural) 高质量中文语音
- **moviepy** 精确帧级同步：每句独立帧，一次性编码，彻底消除漂移
- 字幕逐句烧录到画面；SRT 时间戳来自真实 MP3 时长

## 成片结构

1. **课程导入** — 课程资料功能 — PDF 与 PPT 课件统一管理与浏览
2. **功能架构总览** — DocumentListPage 在整体系统中的位置与职责
3. **Tab 设计** — PDF文档 / PPT课件 双 Tab · DefaultTabController · TabBarView
4. **resource_files 数据表结构** — SQLite 本地表 · 统一存储 PDF 与 PPT 资源记录
5. **PDF 文档列表** — 清言智谱生成 · file_type='pdf' · 每章对应多节 PDF
6. **PPT 课件列表** — 秒出PPT生成 · file_type='ppt' · 与 PDF 章节一一对应
7. **章节组织方式** — 六章课程 · 每章多节 · chapter 字段分组显示
8. **数据初始化流程** — App 首次启动 · _onCreate 建表 · 预置数据插入
9. **DatabaseHelper 单例模式** — 全局唯一数据库连接 · instance 静态访问 · 懒初始化
10. **文件打开机制** — _openDocument() · SnackBar 路径提示 · 平台文件处理
11. **AppBar Refresh 刷新按钮** — 重新从 SQLite 加载 · setState 驱动视图更新
12. **完整数据流总览** — 从 initState 到 ListView 渲染的全链路
13. **功能测试要点** — Tab 切换 · 数据加载 · SnackBar 验证 · refresh 验证
14. **总结与回顾** — 课程资料功能设计要点 · 最佳实践 · 后续扩展方向

## 讲解稿

### 1. 课程导入
> 课程资料功能 — PDF 与 PPT 课件统一管理与浏览

**旁白：** 欢迎进入课程资料功能教学视频。课程资料功能为用户提供 PDF 文档和 PPT 课件的统一管理与浏览入口。所有课件资源按章节组织，存储在本地 SQLite 数据库中，通过 Tab 切换轻松在 PDF 和 PPT 之间导航。本视频将依次介绍 Tab 设计、数据库表结构、章节组织方式、数据初始化流程以及文件打开机制。

### 2. 功能架构总览
> DocumentListPage 在整体系统中的位置与职责

**旁白：** 在整个知识图谱系统中，课程资料功能由 DocumentListPage 承载。它通过 TabBar 将 PDF 文档与 PPT 课件分开展示，背后的数据来自 SQLite 的 resource_files 表。DatabaseHelper 单例负责统一管理数据库连接和数据查询。从架构角度看，DocumentListPage 属于学习资料子系统，与视频、测验等页面共同构成完整的学习资源中心。

### 3. Tab 设计
> PDF文档 / PPT课件 双 Tab · DefaultTabController · TabBarView

**旁白：** DocumentListPage 使用 Flutter 的 DefaultTabController 实现双 Tab 切换。AppBar 底部放置 TabBar，包含『PDF文档』和『PPT课件』两个 Tab。页面初始化时同时加载两份数据，分别存入 _pdfList 和 _pptList。TabBarView 负责在两个 Tab 之间切换内容区域，用户切换 Tab 时无需再次查询数据库，体验流畅。

### 4. resource_files 数据表结构
> SQLite 本地表 · 统一存储 PDF 与 PPT 资源记录

**旁白：** 课程资料的核心数据存储在 SQLite 的 resource_files 表中。该表包含六个关键字段：file_name 存储文件的显示名称，file_path 存储 assets 目录下的完整相对路径，file_type 用字符串 'pdf' 或 'ppt' 区分资源类型，chapter 存储所属章节名称用于分组，description 存储课件的摘要说明。页面通过 file_type 字段过滤，分别查询 PDF 列表和 PPT 列表。

### 5. PDF 文档列表
> 清言智谱生成 · file_type='pdf' · 每章对应多节 PDF

**旁白：** PDF 文档列表展示所有 file_type 为 'pdf' 的资源记录。这些课件由清言智谱 AI 生成，存放在 assets 目录下的『清言智谱』子文件夹中。文件命名遵循『第X章课件名称.pdf』的格式，共约 15 个 PDF 文件，覆盖全部六章内容。列表使用 ListView 展示，每一项显示文件名和章节信息，用户点击即可触发打开操作。

### 6. PPT 课件列表
> 秒出PPT生成 · file_type='ppt' · 与 PDF 章节一一对应

**旁白：** PPT 课件列表展示所有 file_type 为 'ppt' 的资源记录。这些课件由秒出 PPT 工具生成，存放在 assets 目录下的『秒出PPT』子文件夹中，格式为 pptx。每章的 PDF 课件都对应一套 PPT 课件，形成一一对应的双线资料体系。用户在 PDF 文档 Tab 中浏览后，切换到 PPT 课件 Tab 即可查看对应的演示文稿。

### 7. 章节组织方式
> 六章课程 · 每章多节 · chapter 字段分组显示

**旁白：** 课程资料按照六章内容组织。第一章介绍移动应用开发技术体系全景；第二章讲解 Android 与 iOS 原生开发基础；第三章对比 Flutter、React Native 等混合开发技术；第四章深入微信小程序开发流程；第五章聚焦华为 HarmonyOS 多端应用开发；第六章通过综合开发实践将前五章知识融会贯通。resource_files 表的 chapter 字段记录每个文件所属章节，供页面分组显示使用。

### 8. 数据初始化流程
> App 首次启动 · _onCreate 建表 · 预置数据插入

**旁白：** App 首次安装运行时，DatabaseHelper 调用 openDatabase 打开 SQLite 数据库。数据库不存在时触发 _onCreate 回调，在此处创建 resource_files 表并插入预置的课件数据。预置数据包含约 15 条 PDF 记录和 15 条 PPT 记录，对应六章所有课件。之后每次启动 App，数据库已存在，直接复用数据，不会重复插入，保证数据一致性。

### 9. DatabaseHelper 单例模式
> 全局唯一数据库连接 · instance 静态访问 · 懒初始化

**旁白：** DatabaseHelper 采用 Dart 单例模式，确保整个 App 只有一个 SQLite 数据库连接。通过私有构造函数 _internal 和静态 instance 字段实现单例访问。database getter 采用懒初始化策略，第一次访问时才真正打开数据库。对外暴露的 getResourceFiles 方法接收 type 参数，按 file_type 字段查询并返回对应列表。DocumentListPage 和其他所有页面都通过 DatabaseHelper.instance 统一访问数据层。

### 10. 文件打开机制
> _openDocument() · SnackBar 路径提示 · 平台文件处理

**旁白：** 当用户点击课件列表中的任意一项时，页面调用 _openDocument 方法。该方法首先通过 ScaffoldMessenger 弹出 SnackBar，将文件的完整 assets 路径显示给用户，作为即时反馈。实际的文件打开操作由底层平台处理，可以调用 open_file 等插件将文件交给系统默认程序打开。这种设计将 UI 反馈与平台能力解耦，便于后续扩展真实的文件打开逻辑。

### 11. AppBar Refresh 刷新按钮
> 重新从 SQLite 加载 · setState 驱动视图更新

**旁白：** AppBar 右侧提供一个刷新图标按钮，让用户可以手动重新加载课件数据。点击刷新按钮会再次调用 _loadResources 方法，重新向 DatabaseHelper 发起查询。查询完成后通过 setState 更新 _pdfList 和 _pptList，Flutter 框架自动触发页面重建，列表即时刷新。刷新功能与页面初始化复用同一套查询逻辑，代码简洁且易于维护。

### 12. 完整数据流总览
> 从 initState 到 ListView 渲染的全链路

**旁白：** 整个课程资料功能的数据流可以分为五个环节。第一步，页面初始化时 initState 调用 _loadResources；第二步，_loadResources 通过 DatabaseHelper.instance 发起数据库查询；第三步，SQLite 按 file_type 过滤 resource_files 表并返回结果；第四步，查询结果通过 setState 写入 _pdfList 和 _pptList；第五步，Flutter 重建 TabBarView 下的 ListView，每条记录渲染为一个 ListTile。整条链路清晰简洁，各层职责边界分明。

### 13. 功能测试要点
> Tab 切换 · 数据加载 · SnackBar 验证 · refresh 验证

**旁白：** 对课程资料功能进行测试时，需要关注以下几个核心场景。首先验证 PDF Tab 能正确显示约 15 条 PDF 记录，PPT Tab 能正确显示约 15 条 PPT 记录。其次测试 Tab 切换时两份数据均保持完整，不发生混淆或丢失。然后点击任意文件，确认 SnackBar 弹出并显示正确的 assets 路径。最后验证 AppBar 的 refresh 按钮点击后能正确触发重新加载，数据不重复不丢失。

### 14. 总结与回顾
> 课程资料功能设计要点 · 最佳实践 · 后续扩展方向

**旁白：** 本视频完整介绍了课程资料功能的实现原理。设计亮点在于用 TabBar 清晰分离 PDF 和 PPT 两类资源，用 resource_files 表统一管理所有课件记录。DatabaseHelper 单例保证数据库访问的唯一性和一致性，file_type 字段让页面查询和渲染逻辑极为简洁。chapter 字段为未来按章节分组显示留下了扩展空间。后续可以进一步集成 open_file 插件，实现真实的文件打开能力。感谢收看，欢迎继续学习其他功能模块。
