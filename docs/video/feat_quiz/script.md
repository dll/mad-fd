# 测验教学视频脚本 v6

## 技术特性

- **edge_tts** (zh-CN-XiaoxiaoNeural) 高质量中文语音
- **moviepy** 精确帧级同步：每句独立帧，一次性编码，彻底消除漂移
- 字幕逐句烧录到画面；SRT 时间戳来自真实 MP3 时长

## 成片结构

1. **功能导入** — 测验功能 — 章节测验、错题管理与学习进度统计
2. **四大功能模块全景** — QuizPage / WrongAnswersPage / ProgressPage / DAO 层
3. **章节选择界面** — _chapters 列表 · _loadChapters() · _quizStarted 状态控制
4. **QuizDao.getChapters()** — SELECT DISTINCT source · WHERE 过滤空值 · ORDER BY 排序
5. **开始测验 _startQuiz()** — 加载题目 · 重置状态机 · _quizStarted=true 切换视图
6. **题目界面布局** — LinearProgressIndicator · 题目文字 · 4 选项 · 操作按钮
7. **选项颜色状态反馈** — isSelected / isCorrect / _answered — 三状态颜色机
8. **提交答案 _submitAnswer()** — 前置检查 · 判断正误 · 错题记录 · setState 触发重建
9. **错题记录 WrongAnswerDao.addWrongAnswer()** — 重复检测 · INSERT or UPDATE · times 错误计数累加
10. **QuestionModel 题目数据模型** — source · optionA~D · answerIndex · options / correctAnswer getter
11. **QuizResultModel 成绩数据模型** — userId · score · numCorrect · numTotal · chapter · 双时间戳
12. **测验完成 _finishQuiz()** — 构造结果 · saveQuizResult · AlertDialog · barrierDismissible=false
13. **QuizDao — 保存与查询成绩** — saveQuizResult · getQuizResults · getQuizSummary 聚合
14. **错题本 WrongAnswersPage** — ExpansionTile 可折叠 · 答案对比 · 移除 / 清空操作
15. **ProgressPage — 测验成绩 Tab** — 三统计卡片 · fl_chart 折线图 · 历史记录列表
16. **fl_chart LineChart 成绩趋势** — FlSpot · isCurved · barWidth · belowBarData 半透明填充
17. **ProgressPage — 学习记录 Tab** — LearningRecordDao.getStatistics() · 三卡片 · 四条学习建议
18. **功能总结与数据流** — 五环节闭环 · DAO 层解耦 · 可视化学习成果

## 讲解稿

### 1. 功能导入
> 测验功能 — 章节测验、错题管理与学习进度统计

**旁白：** 欢迎进入测验功能教学视频。测验功能是知识图谱 App 的核心学习闭环模块，涵盖章节选择、题目作答、错题记录、成绩保存和进度统计五个核心环节。用户通过测验可以巩固所学知识，利用错题本反复练习薄弱点，并在进度页看到可视化的学习成果。本视频将带你完整梳理每个环节的实现原理和数据流转。

### 2. 四大功能模块全景
> QuizPage / WrongAnswersPage / ProgressPage / DAO 层

**旁白：** 测验功能由三个页面和三个 DAO 类协同工作。QuizPage 是核心主页，负责章节选择和题目作答的全部交互逻辑。WrongAnswersPage 是独立页面，展示用户历史答错的题目并支持移除和清空。ProgressPage 以 TabView 形式呈现测验成绩和学习记录两组统计数据。底层由 QuizDao、WrongAnswerDao、LearningRecordDao 三个 DAO 类封装 SQLite 数据库操作，UI 层通过调用 DAO 方法获取数据，实现了良好的关注点分离。

### 3. 章节选择界面
> _chapters 列表 · _loadChapters() · _quizStarted 状态控制

**旁白：** 章节选择界面是 QuizPage 的初始状态，由状态变量 _quizStarted 控制显示，默认值为 false，因此进入页面首先看到的是章节列表。页面初始化时 initState 调用 _loadChapters 方法，从 QuizDao 异步获取所有可用章节。加载期间显示进度圈，加载完成后以 ListView 形式展示各章节，每个章节是一个可点击的 Card。列表末尾有一个带红色背景的「错题本」Card，点击后导航至 WrongAnswersPage 进行错题复习。

### 4. QuizDao.getChapters()
> SELECT DISTINCT source · WHERE 过滤空值 · ORDER BY 排序

**旁白：** getChapters 方法通过 rawQuery 执行 SQL 查询，利用 DISTINCT 关键字对 source 字段去重，确保每个章节只出现一次。WHERE 子句过滤掉 source 为空或空字符串的题目，避免出现空白章节项。ORDER BY source 保证章节按字母顺序稳定排列，每次加载结果一致。source 字段是 questions 表中标识题目所属章节的核心字段，题目导入时按章节分组填写，getChapters 和 getQuestionsByChapter 都依赖这个字段工作。

### 5. 开始测验 _startQuiz()
> 加载题目 · 重置状态机 · _quizStarted=true 切换视图

**旁白：** 用户选择章节后，_startQuiz 方法首先将加载状态置为 true，然后调用 QuizDao 的 getQuestionsByChapter 方法，通过 source 字段过滤该章节的所有题目并以列表形式返回。加载成功后，方法在 setState 中集中重置所有状态变量：当前题目索引归零、正确计数归零、选中答案清空、答题标志清空。最关键的一步是将 _quizStarted 设为 true，这会触发 build 方法中的条件判断，从章节选择视图切换到题目作答视图。

### 6. 题目界面布局
> LinearProgressIndicator · 题目文字 · 4 选项 · 操作按钮

**旁白：** 题目界面使用 Column 布局，从上到下分为三个区域。顶部是 LinearProgressIndicator，显示当前题目在整个测验中的进度比例，value 等于当前索引加一除以总题数，随答题实时更新。中间是 Expanded 包裹的 SingleChildScrollView，内含题目文字和四个选项按钮，支持题目内容超长时滚动查看。底部是固定高度四十八像素的 ElevatedButton，在未选择时禁用、选择后可提交、提交后切换为下一题或完成测验，三种状态由 _answered 和 _selectedAnswer 共同驱动。

### 7. 选项颜色状态反馈
> isSelected / isCorrect / _answered — 三状态颜色机

**旁白：** 选项按钮的颜色由三个变量共同决定：isSelected 表示该选项是否被选中，isCorrect 表示该选项是否是正确答案，_answered 表示是否已提交。提交前，选中项显示蓝紫色高亮，其余保持灰色边框。提交后，无论用户选对还是选错，正确选项都会高亮为绿色，用户答错的选项变为红色，正确答案始终可见，帮助用户即时学习和记忆。这种设计模式常见于教育类 App，即时反馈显著优于延迟反馈的学习效果。

### 8. 提交答案 _submitAnswer()
> 前置检查 · 判断正误 · 错题记录 · setState 触发重建

**旁白：** _submitAnswer 是提交答案的核心方法。首先检查是否已选择选项，未选择则直接返回，这与按钮的 onPressed 为 null 的禁用逻辑配合。然后取出当前题目，将用户选择的索引与题目的 answerIndex 比对，判断是否正确。如果答错，立即调用 _recordWrongAnswer 方法异步记录错题，由于错题记录是异步且有 try-catch 保护，不会阻塞或影响当前界面响应。最后通过 setState 将 _answered 设为 true 并更新正确计数，触发 UI 重建使颜色反馈立即生效，按钮文字也同步切换为「下一题」。

### 9. 错题记录 WrongAnswerDao.addWrongAnswer()
> 重复检测 · INSERT or UPDATE · times 错误计数累加

**旁白：** _recordWrongAnswer 方法调用 WrongAnswerDao 的 addWrongAnswer 方法记录错题。该方法首先查询 wrong_answers 表，检查该用户对该题目是否已有错误记录。若已存在，执行 UPDATE 将 times 加一并更新 last_wrong_time；若不存在，执行 INSERT 写入完整记录，times 初始为一。这个设计使得错题本能够追踪每道题的错误频率，错误次数越多，CircleAvatar 中显示的数字越大，帮助用户快速定位高频错题。整个操作在 try-catch 中执行，任何数据库异常都被静默处理。

### 10. QuestionModel 题目数据模型
> source · optionA~D · answerIndex · options / correctAnswer getter

**旁白：** QuestionModel 是题目的数据模型，对应数据库 questions 表的字段结构。source 字段标识题目所属章节，是章节分组查询的核心依据。四个选项分别以 optionA 至 optionD 存储，answerIndex 记录正确答案的序号，从零开始。模型提供两个便捷 getter：options 返回选项字符串列表，用于 List.generate 中按索引取对应选项文字；correctAnswer 通过 switch 将 answerIndex 转换为对应的选项文字，直接用于写入错题记录的 correctAnswer 字段，避免在 UI 层重复转换逻辑。

### 11. QuizResultModel 成绩数据模型
> userId · score · numCorrect · numTotal · chapter · 双时间戳

**旁白：** QuizResultModel 是保存测验成绩的数据模型，对应 quiz_results 表。score 字段存储百分制得分，在 _finishQuiz 方法中计算，公式为答对题数除以总题数乘以一百后取整。chapter 字段可以为空，为空时 ProgressPage 的历史记录列表显示「综合测验」。时间戳字段使用 ISO 8601 格式的字符串存储，quizTimestamp 记录测验开始时间，completedAt 记录完成时间，两者均在 _finishQuiz 中赋值。accuracy getter 提供一个便捷的正确率计算属性，防止除以零的边界情况。

### 12. 测验完成 _finishQuiz()
> 构造结果 · saveQuizResult · AlertDialog · barrierDismissible=false

**旁白：** _finishQuiz 在最后一题点击「完成测验」后执行。首先从 AuthService 获取当前用户，如果未登录则直接返回，避免空指针。然后构造完整的 QuizResultModel 并调用 saveQuizResult 写入数据库。成绩保存完毕后，通过 showDialog 弹出结果对话框，barrierDismissible 设为 false 强制用户主动点击「确定」，而不能通过点击外部关闭。对话框根据得分显示不同图标和颜色，超过一半题目正确显示庆祝图标和绿色，否则中性橙色。用户点击「确定」后页面回到章节选择，等待下一次测验。

### 13. QuizDao — 保存与查询成绩
> saveQuizResult · getQuizResults · getQuizSummary 聚合

**旁白：** QuizDao 提供三个成绩相关方法，层次清晰。saveQuizResult 最简单，直接调用 db.insert 将 toMap 的结果写入 quiz_results 表。getQuizResults 按时间倒序返回用户的历史成绩列表，用于 ProgressPage 的历史记录区域。最强大的是 getQuizSummary，它执行包含四个聚合函数的 SQL 语句，一次查询同时返回测验次数、总答对题数、总题数和平均分，ProgressPage 的三张统计卡片直接使用这个 Map 的值，不需要在 Dart 代码中做额外统计运算。

### 14. 错题本 WrongAnswersPage
> ExpansionTile 可折叠 · 答案对比 · 移除 / 清空操作

**旁白：** WrongAnswersPage 通过 WrongAnswerDao 的 getWrongAnswers 方法加载当前用户的所有错题。列表使用 ExpansionTile 实现可折叠效果，折叠时显示题目摘要和错误次数，展开后显示完整内容。圆形 Avatar 显示 wrong_answers 表的 times 字段，红色背景直观反映该题的薄弱程度，数字越大说明这道题错了越多次，需要重点复习。展开后可以清晰对比你的答案和正确答案，红色和绿色的对比帮助加强记忆。AppBar 右侧的扫帚图标触发确认对话框，确认后清空当前用户全部错题记录。

### 15. ProgressPage — 测验成绩 Tab
> 三统计卡片 · fl_chart 折线图 · 历史记录列表

**旁白：** ProgressPage 使用 TabController 管理两个 Tab，两个 Tab 共用同一份 _loadData 加载的数据。测验成绩 Tab 顶部是三张并排统计卡片，分别显示测验次数、平均分和正确率，数据来自 getQuizSummary 的聚合查询结果，蓝绿橙三色区分。若存在历史成绩，卡片下方显示 fl_chart 折线图，高度固定两百像素，展示成绩变化趋势。最下方历史记录列表最多显示最近十条，每条以圆形 Avatar 展示分数，六十分及以上为绿色，否则为红色，一眼区分成绩优劣。

### 16. fl_chart LineChart 成绩趋势
> FlSpot · isCurved · barWidth · belowBarData 半透明填充

**旁白：** _buildChart 方法构建 fl_chart 的折线图，数据转换是理解这段代码的关键。首先对历史成绩列表调用 reversed 倒序，使图表从左到右按时间顺序排列，再用 asMap 获取数值索引，将每条记录的 index 作为 X 轴坐标，score 作为 Y 轴坐标构造 FlSpot。图表的 Y 轴固定在零到一百，清晰反映百分制得分变化。折线启用 isCurved 使曲线平滑，配合蓝紫色主题色和 alpha 值仅 0.1 的半透明下方填充，在保持专业感的同时视觉上突出成绩趋势。

### 17. ProgressPage — 学习记录 Tab
> LearningRecordDao.getStatistics() · 三卡片 · 四条学习建议

**旁白：** 学习记录 Tab 同样使用三张统计卡片，数据来自 LearningRecordDao 的 getStatistics 方法。该方法执行三条独立 SQL 查询：总记录数统计用户全部的学习行为，独立节点数通过 COUNT DISTINCT 去重统计已覆盖的知识节点数量，反映学习的广度；本周学习数通过日期条件过滤最近七天的活跃度。卡片下方是学习建议卡片，包含四条具体可操作的建议。这四条建议呼应了整个 App 的学习闭环设计：学图谱、做测验、查错题、重复练，形成记忆巩固的正向循环。

### 18. 功能总结与数据流
> 五环节闭环 · DAO 层解耦 · 可视化学习成果

**旁白：** 测验功能通过五个环节形成完整的学习闭环。章节选择利用 SQL DISTINCT 查询，将题库按 source 字段自动分组，无需手动维护章节列表。题目加载通过 WHERE source 过滤，精准获取当前章节所有题目。答题过程中三状态颜色机制提供即时反馈，isSelected、isCorrect、_answered 三个变量协同驱动 UI。答错的题目自动写入错题本并支持重复计次，错误频率可视化帮助用户定位薄弱点。每次测验完成后成绩以结构化模型写入数据库，ProgressPage 通过 SQL 聚合和 fl_chart 将进度可视化展示。感谢观看测验功能教学视频！
