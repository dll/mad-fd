# 视频播放教学视频脚本 v6

## 技术特性

- **edge_tts** (zh-CN-XiaoxiaoNeural) 高质量中文语音
- **moviepy** 精确帧级同步：每句独立帧，一次性编码，彻底消除漂移
- 字幕逐句烧录到画面；SRT 时间戳来自真实 MP3 时长

## 成片结构

1. **课程导入** — 视频播放功能 — 按章节组织的课程视频资源管理
2. **VideoListPage 页面结构** — AppBar + ListView.builder + refresh 按钮构成完整视频列表页
3. **视频资源列表展示** — ListView 逐条渲染 · 红色圆形图标标识视频类型
4. **课程章节组织总览** — 6 章 15 个视频 · 章节粒度对应 resource_files 记录
5. **第一至三章视频资源详情** — 移动应用开发技术体系 · 原生开发基础 · 混合开发技术
6. **第四至六章视频资源详情** — 小程序开发 · 华为多端应用开发 · 综合开发实践
7. **SQLite resource_files 表结构** — 视频与文档资源共用同一张表 · file_type 字段区分类型
8. **首次启动自动初始化流程** — 数据库为空时自动写入 15 条视频记录 · 用户无感知
9. **视频资源自动插入逻辑** — _initVideoData() 构建 Map 列表 · 逐条 insert 写入 SQLite
10. **视频播放交互** — 点击 ListTile → _playVideo(filePath) → SnackBar 提示
11. **_playVideo() 方法实现** — 极简实现 · SnackBar 反馈 · 便于后续扩展平台播放器
12. **AppBar 刷新按钮功能** — IconButton(Icons.refresh) → 重新执行 _loadVideos()
13. **DatabaseHelper 统一管理** — 单例模式 · 全局共享数据库连接 · 避免重复打开
14. **视频播放与课程进度联动** — chapter 字段桥接视频资源与学习记录 · 推动进度更新
15. **功能总结** — VideoListPage 核心要点回顾 · 下一步学习方向

## 讲解稿

### 1. 课程导入
> 视频播放功能 — 按章节组织的课程视频资源管理

**旁白：** 欢迎进入视频播放功能教学视频。本节围绕 VideoListPage 的实现展开，讲解系统如何管理按章节组织的课程视频资源。共 6 章 15 个视频，数据存储在 SQLite 数据库的 resource_files 表中。支持首次启动自动初始化和点击播放交互，由 DatabaseHelper 单例统一管理数据库连接。

### 2. VideoListPage 页面结构
> AppBar + ListView.builder + refresh 按钮构成完整视频列表页

**旁白：** VideoListPage 由三个核心部分构成。顶部 AppBar 承载页面标题与刷新按钮，点击刷新会重新从数据库加载视频列表。中间主体是 ListView.builder，根据视频列表动态生成每一条 ListTile。每条 ListTile 左侧有一个红色圆形图标，右侧显示章节名称，点击可触发播放操作。页面状态的刷新通过 setState 驱动，保证数据库读取完成后界面立即更新。

### 3. 视频资源列表展示
> ListView 逐条渲染 · 红色圆形图标标识视频类型

**旁白：** 列表的视觉设计非常简洁。每条视频记录用一个红色圆形图标标识视频类型，主标题显示章节名称，副标题显示资产路径。用户点击任意一条，页面就调用 _playVideo 方法，并通过 SnackBar 显示当前视频的文件路径。当数据库记录为空时，ListView 区域会显示暂无视频资源的提示文字，告知用户当前状态。

### 4. 课程章节组织总览
> 6 章 15 个视频 · 章节粒度对应 resource_files 记录

**旁白：** 课程视频按照六章组织，总计十五个视频资源。第一章移动应用开发技术体系有两个视频，第二章原生开发基础有两个视频。第三章混合开发技术有三个视频，第四章小程序开发有两个视频。第五章华为多端应用开发和第六章综合开发实践各有三个视频。每个视频对应 resource_files 表中的一条记录，file_type 字段值为 video。

### 5. 第一至三章视频资源详情
> 移动应用开发技术体系 · 原生开发基础 · 混合开发技术

**旁白：** 前三章共七个视频资源，路径都以 assets 开头。第一章移动应用开发技术体系对应两个 MP4 文件，分别是技术体系1和技术体系2。第二章原生开发基础同样包含两个视频，分别是原生开发基础1和原生开发基础2。第三章混合开发技术包含三个视频，文件名后缀数字依次为1、2、3。这些路径字段存储在 resource_files 的 file_path 列中，作为平台播放器的输入参数。

### 6. 第四至六章视频资源详情
> 小程序开发 · 华为多端应用开发 · 综合开发实践

**旁白：** 后三章共八个视频资源。第四章小程序开发有两个视频，第五章华为多端应用开发有三个视频，第六章综合开发实践有三个视频。加上前三章的七个视频，总计恰好十五条 resource_files 记录。这十五条记录在数据库为空时会被 _initVideoData 方法一次性批量写入，保证应用第一次启动就有完整的视频列表可以显示。

### 7. SQLite resource_files 表结构
> 视频与文档资源共用同一张表 · file_type 字段区分类型

**旁白：** resource_files 表是视频与文档资源的统一存储位置。表结构包含 id 主键、file_type 类型字段、chapter 章节名、file_path 文件路径以及 title 标题。VideoListPage 在查询时只获取 file_type 等于 video 的记录，从而将视频资源与文档资源分离。chapter 字段的值直接作为列表每一项的主标题展示，file_path 字段的值作为播放器输入传入 _playVideo 方法。

### 8. 首次启动自动初始化流程
> 数据库为空时自动写入 15 条视频记录 · 用户无感知

**旁白：** VideoListPage 的初始化流程设计得非常健壮。页面挂载时 initState 调用 _loadVideos 异步方法。方法内先查询 resource_files 表中 file_type 为 video 的记录数量。如果数量为零，说明是首次启动，立即调用 _initVideoData 批量插入十五条记录。插入完成后再次查询，把结果存入状态变量，最后通过 setState 触发 ListView 重新渲染。整个过程对用户完全透明，首次启动即可看到完整的视频列表。

### 9. 视频资源自动插入逻辑
> _initVideoData() 构建 Map 列表 · 逐条 insert 写入 SQLite

**旁白：** _initVideoData 方法的职责非常单一：构造数据并写入数据库。方法内部先定义一个包含十五个 Map 的列表，每个 Map 包含 file_type、chapter 和 file_path 字段。然后通过 for 循环，每次调用 DatabaseHelper.instance 的 insert 方法将一条记录写入 resource_files 表。因为使用了 await，每次 insert 都是顺序执行的，不会出现并发冲突。插入完成后，_loadVideos 的后续查询可以立刻获取到这十五条记录。

### 10. 视频播放交互
> 点击 ListTile → _playVideo(filePath) → SnackBar 提示

**旁白：** 视频播放的交互流程分为三个层次。第一层是用户层：用户在 ListView 中点击某条视频，触发 ListTile 的 onTap 回调。第二层是 Flutter 层：onTap 调用 _playVideo 方法，传入该条记录的 file_path 字符串。_playVideo 方法通过 ScaffoldMessenger 显示一个 SnackBar，内容为正在播放加上文件路径。第三层是平台扩展层：实际的视频播放可以通过 video_player 插件或原生 Intent 来实现，当前版本以 SnackBar 作为占位反馈。

### 11. _playVideo() 方法实现
> 极简实现 · SnackBar 反馈 · 便于后续扩展平台播放器

**旁白：** _playVideo 方法的实现非常简洁，只有几行代码。方法接收一个字符串类型的文件路径参数。首先调用 ScaffoldMessenger 的 hideCurrentSnackBar 方法，防止多次点击时 SnackBar 叠加显示。然后调用 showSnackBar，显示包含文件路径的提示文字。这种低耦合设计的好处是：当需要接入真实播放器时，只需把 SnackBar 替换成 Navigator.push 或插件调用，其他代码无需修改。

### 12. AppBar 刷新按钮功能
> IconButton(Icons.refresh) → 重新执行 _loadVideos()

**旁白：** AppBar 右侧的刷新按钮是一个实用的辅助功能。按钮通过 AppBar 的 actions 属性添加，使用 Icons.refresh 图标。点击后直接调用 _loadVideos 方法，重新从数据库读取视频列表并更新界面。这个设计在实际使用中非常有价值：当用户通过其他途径导入了新的视频资源，或者数据库内容发生变化时，可以立刻手动刷新，而不需要退出重进页面。

### 13. DatabaseHelper 统一管理
> 单例模式 · 全局共享数据库连接 · 避免重复打开

**旁白：** DatabaseHelper 是整个应用的数据库访问核心。它采用单例模式，通过 DatabaseHelper.instance 提供全局唯一的数据库连接对象。这意味着无论 VideoListPage、DocumentPage 还是 ProgressPage，都通过同一个 DatabaseHelper 实例访问数据库。单例懒初始化的设计保证了数据库只被打开一次，避免了多次打开带来的性能开销和潜在的并发冲突。resource_files、learning_records 等多张表都由 DatabaseHelper 统一创建和管理。

### 14. 视频播放与课程进度联动
> chapter 字段桥接视频资源与学习记录 · 推动进度更新

**旁白：** 视频播放功能不是一个孤立的模块，它通过 chapter 字段与课程进度产生联动。resource_files 表中的 chapter 字段与 learning_records 表使用相同的章节标识。当用户播放视频时，可以在 _playVideo 方法中同时调用 LearningRecordDao.insert，把播放行为记录到 learning_records 表中。ProgressPage 再通过查询 learning_records，统计各章节的学习进度并展示进度条。这样一来，视频播放与知识图谱学习等多种行为都能共同推动课程进度，形成完整的学习闭环。

### 15. 功能总结
> VideoListPage 核心要点回顾 · 下一步学习方向

**旁白：** 本节内容到这里结束，我们来回顾一下视频播放功能的核心要点。视频元数据存储在 SQLite 的 resource_files 表中，file_type 字段值为 video。首次启动时，系统自动插入六章共十五条记录，保证列表立刻可用。ListView 通过红色圆形图标和章节名称清晰展示视频资源，点击触发 _playVideo 方法。_playVideo 以 SnackBar 作为当前反馈，后续可替换为真实的平台播放器。DatabaseHelper 单例确保数据一致性，chapter 字段将视频播放与课程进度联动，形成完整的学习体验。
