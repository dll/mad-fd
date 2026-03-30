# 学习路径教学视频脚本 v6

## 技术特性

- **edge_tts** (zh-CN-XiaoxiaoNeural) 高质量中文语音
- **moviepy** 精确帧级同步：每句独立帧，一次性编码，彻底消除漂移
- 字幕逐句烧录到画面；SRT 时间戳来自真实 MP3 时长

## 成片结构

1. **课程导入** — 学习路径功能 — 帮助用户规划和追踪学习进度
2. **功能模块总览** — LearningPlanPage 的六大核心模块
3. **页面在项目中的位置** — lib/presentation/pages/learning/learning_plan_page.dart
4. **数据模型** — _plans — 硬编码在 State 内的学习计划列表
5. **页面骨架** — Scaffold + AppBar + ListView.builder + FloatingActionButton
6. **总体进度卡片** — _buildHeader() — 所有计划的平均进度汇总
7. **计划卡片组件** — _buildPlanCard() — 单个计划的完整信息展示
8. **进度追踪逻辑** — LinearProgressIndicator 双层应用 — 全局 + 单计划
9. **章节详情底部弹窗** — _showPlanDetail() — showModalBottomSheet + DraggableScrollableSheet
10. **章节完成状态渲染** — isCompleted = index < completedDays — 双态 UI 设计
11. **创建计划对话框** — _showCreatePlanDialog() — AlertDialog + 两个 TextField
12. **删除计划操作** — PopupMenuButton → _deletePlan() → setState → SnackBar
13. **状态管理** — StatefulWidget + _LearningPlanPageState — 单一数据源模式
14. **扩展方向** — 从原型到生产级功能的演进路径
15. **功能总结** — LearningPlanPage — 完整的学习计划管理闭环

## 讲解稿

### 1. 课程导入
> 学习路径功能 — 帮助用户规划和追踪学习进度

**旁白：** 欢迎进入学习路径功能教学视频。学习路径页面是知识图谱 App 的学习管理中心，帮助用户创建个人学习计划，追踪每个计划的完成进度，并以章节列表的形式展示具体学习内容。本视频将带你深入了解页面架构、数据模型、核心组件和交互流程。

### 2. 功能模块总览
> LearningPlanPage 的六大核心模块

**旁白：** 学习路径页面包含六个核心模块。第一是顶部的总体进度卡片，汇总显示所有计划的平均完成百分比。第二是使用 ListView.builder 渲染的计划卡片列表，每张卡片展示一个计划的进度信息。第三是点击卡片后弹出的章节详情底部面板，采用 DraggableScrollableSheet 实现可拖拽效果。第四是通过右上角悬浮按钮触发的创建计划对话框。第五是通过卡片右侧弹出菜单触发的删除操作。第六是贯穿全页的 State 状态管理，_plans 列表是唯一数据源。

### 3. 页面在项目中的位置
> lib/presentation/pages/learning/learning_plan_page.dart

**旁白：** 在项目目录中，LearningPlanPage 位于 lib/presentation/pages/learning/ 目录下，属于表现层的页面模块。它继承自 StatefulWidget，配合私有的 State 类管理页面内部状态。页面导入了 AuthService，为后续关联用户身份预留接口。整体脚手架由 Scaffold 构成，顶部有渐变色 AppBar，右下角有一个悬浮的添加按钮，底部内容区域由 ListView 填充。

### 4. 数据模型
> _plans — 硬编码在 State 内的学习计划列表

**旁白：** 当前版本的数据模型采用 List<Map<String, dynamic>> 格式，直接硬编码在 _LearningPlanPageState 中。每个计划包含八个字段：title 是计划名称，description 是目标描述，progress 是当前完成百分比，days 是计划总天数，completedDays 是已完成的天数，chapters 是章节名称列表，color 决定卡片的主题颜色。三个示例计划分别是 Flutter 入门、Android 进阶和跨平台实战，进度分别为 60%、30% 和 10%。

### 5. 页面骨架
> Scaffold + AppBar + ListView.builder + FloatingActionButton

**旁白：** 页面骨架由 Scaffold 搭建。AppBar 使用 #667eea 蓝紫渐变色作为背景，前景文字和图标为白色。body 是一个 ListView.builder，padding 为 16 像素，itemCount 设置为 _plans.length + 1，其中索引 0 渲染总体进度卡片，后续索引依次渲染各个计划卡片。右下角的 FloatingActionButton 采用同款蓝紫色，点击后触发创建计划对话框。

### 6. 总体进度卡片
> _buildHeader() — 所有计划的平均进度汇总

**旁白：** 总体进度卡片由 _buildHeader 方法构建，作为 ListView 的第 0 项渲染。totalProgress 通过 map 取出所有计划的 progress 字段后求和再除以计划数量，得到一个浮点数平均值。LinearProgressIndicator 的 value 参数接收 totalProgress 除以 100 的小数形式。外层用 ClipRRect 裁剪成圆角，minHeight 设为 10 像素使进度条更粗。右侧显示取整后的百分比数字，底部一行文字动态显示当前参与的计划数量。

### 7. 计划卡片组件
> _buildPlanCard() — 单个计划的完整信息展示

**旁白：** 每个计划对应一个 _buildPlanCard 卡片。Card 内部包裹 InkWell，点击整张卡片触发章节详情弹窗。顶部一行分为三个部分：左侧是带背景色的图标容器，颜色取自计划的 color 字段并调低透明度；中间是标题和描述的列；右侧是带有删除选项的三点弹出菜单。中部是与计划 color 一致的彩色进度条，右侧显示当前百分比。底部两端分别显示已完成天数和章节总数，文字颜色置灰处理。

### 8. 进度追踪逻辑
> LinearProgressIndicator 双层应用 — 全局 + 单计划

**旁白：** 进度追踪在两个层面同时进行。全局层面，_buildHeader 对所有计划的 progress 字段求平均值，渲染在顶部汇总进度条中。单计划层面，_buildPlanCard 直接读取当前计划的 progress 整数，除以 100 后传入 LinearProgressIndicator 的 value 参数。目前 progress 是硬编码的静态值，未来可以根据 completedDays 除以 days 动态计算。三个示例计划使用不同颜色——蓝色代表 Flutter 入门，绿色代表 Android 进阶，橙色代表跨平台实战——通过颜色编码帮助用户快速区分。

### 9. 章节详情底部弹窗
> _showPlanDetail() — showModalBottomSheet + DraggableScrollableSheet

**旁白：** 点击任意计划卡片触发 _showPlanDetail 方法，调用 showModalBottomSheet 弹出底部面板。isScrollControlled 设为 true 允许面板占据更大屏幕空间。面板顶部使用 RoundedRectangleBorder 裁出 20 像素圆角。内部是一个 DraggableScrollableSheet，初始高度为屏幕的 60%，最小可收缩到 40%，最大可展开到 90%，支持手势拖拽。面板顶部有一条灰色拖动指示条，下方是计划标题和关闭图标，分隔线以下是章节条目的 ListView。

### 10. 章节完成状态渲染
> isCompleted = index < completedDays — 双态 UI 设计

**旁白：** 章节列表的每个条目根据 isCompleted 布尔值呈现两种不同状态。判断逻辑简洁直接：若章节索引小于 completedDays，则视为已完成。已完成章节：左侧头像背景为绿色并显示对勾图标，标题文字加上删除线并置灰，右侧尾部图标为绿色实心圆形对勾。未完成章节：左侧头像背景为浅灰并显示序号数字，标题文字保持正常样式，右侧尾部图标为灰色空心圆形。这种双态设计让用户一眼便能区分学习进度。

### 11. 创建计划对话框
> _showCreatePlanDialog() — AlertDialog + 两个 TextField

**旁白：** 点击右下角悬浮按钮触发 _showCreatePlanDialog 方法。内部调用 showDialog 弹出 AlertDialog，标题栏显示「创建学习计划」，内容区包含两个输入框。第一个 TextField 用于填写计划名称，带有占位提示文字。第二个 TextField 支持多行输入（maxLines 为 2），用于填写计划描述。底部操作区有两个按钮：取消按钮关闭对话框，创建按钮目前仅弹出一条「功能开发中」的 SnackBar 提示，正式提交逻辑留待后续开发。

### 12. 删除计划操作
> PopupMenuButton → _deletePlan() → setState → SnackBar

**旁白：** 删除操作从卡片右侧的 PopupMenuButton 触发。点击三点图标后弹出包含「删除计划」的下拉菜单。选择后 onSelected 回调判断 value 为 delete，调用 _deletePlan。_deletePlan 在 setState 回调中直接调用 _plans.remove 传入计划 Map 对象，利用对象引用相等性精准定位并移除目标计划。remove 后 setState 驱动 ListView 重建，列表立即缩短一项。操作完成后 ScaffoldMessenger 弹出底部提示，告知用户哪个计划被删除。需要注意的是，showSnackBar 在异步环境下应检查 context.mounted。

### 13. 状态管理
> StatefulWidget + _LearningPlanPageState — 单一数据源模式

**旁白：** 当前版本采用最基础的 StatefulWidget 状态管理方案。_LearningPlanPageState 持有 _plans 列表，这是整个页面的唯一数据源。任何对 _plans 的修改都必须包裹在 setState 中，以通知 Flutter 框架在下一帧重新执行 build 方法。这种方案的优点是代码简洁、易于理解，适合功能原型开发。缺点是数据仅存在于内存，页面销毁后丢失，且无法跨页面共享学习计划数据。后续可引入 Provider 或 Riverpod 实现全局状态管理。

### 14. 扩展方向
> 从原型到生产级功能的演进路径

**旁白：** 当前实现是功能完整的原型版本，后续可从六个方向进行生产化演进。第一，数据持久化：使用 SharedPreferences 存储简单数据，或 SQLite、Hive 处理复杂结构。第二，后端同步：通过 REST API 与服务器交互，支持多设备同步。第三，动态进度：将静态 progress 字段改为 completedDays / days 的实时计算。第四，章节交互：允许用户点击章节条目切换完成状态，同步更新进度。第五，全局状态管理：引入 Provider 或 Riverpod，使其他页面也能感知学习计划变化。第六，推送提醒：结合本地通知插件，每天定时提醒用户继续学习。

### 15. 功能总结
> LearningPlanPage — 完整的学习计划管理闭环

**旁白：** 本视频完整讲解了 LearningPlanPage 的学习路径功能。页面通过 ListView.builder 高效渲染计划列表，顶部进度卡片动态汇总所有计划的平均完成度。DraggableScrollableSheet 提供流畅的底部章节详情面板，双态 UI 设计让已完成与未完成章节一目了然。AlertDialog 实现快速创建计划的入口，PopupMenuButton 配合 setState 提供简洁的删除体验。整个功能构成了一个完整的学习计划管理闭环，为用户提供清晰的学习路径引导和进度追踪能力。感谢观看，如有问题欢迎留言交流。
