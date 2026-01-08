# .gitignore 使用指南

## 什么是 .gitignore？

`.gitignore` 是 Git 版本控制系统的配置文件，用于指定哪些文件或目录不需要被 Git 跟踪和提交到仓库中。

## 为什么需要 .gitignore？

1. **避免提交不必要的文件**：如编译产物、临时文件、IDE 配置等
2. **保护敏感信息**：如配置文件中的密码、密钥等
3. **减小仓库体积**：排除大文件和不必要的文件
4. **避免冲突**：排除个人 IDE 配置，避免团队协作时的冲突

## 使用方法

### 1. 基本语法

```
# 注释 - 以 # 开头的是注释

# 忽略单个文件
filename.txt

# 忽略整个目录
directory/

# 忽略所有匹配的文件
*.log
*.class

# 忽略特定路径的文件
src/main/resources/application-local.yml

# 使用通配符
*.tmp
test*.txt

# 排除某个文件（使用 !）
*.log
!important.log  # 不忽略 important.log

# 忽略目录但不忽略其中的某些文件
target/
!target/important.jar
```

### 2. 匹配规则

- `*` - 匹配任意字符（除了 `/`）
- `**` - 匹配任意目录层级
- `?` - 匹配单个字符
- `[abc]` - 匹配括号中的任意字符
- `[0-9]` - 匹配数字范围
- `/` - 目录分隔符，如果放在开头表示根目录

### 3. 常见示例

```gitignore
# 忽略所有 .log 文件
*.log

# 忽略 logs 目录下的所有文件
logs/

# 忽略根目录下的 logs 目录
/logs

# 忽略所有目录下的 logs 目录
**/logs

# 忽略所有 .class 文件，但保留 important.class
*.class
!important.class

# 忽略 target 目录，但保留其中的某个文件
target/
!target/important.jar

# 忽略包含 test 的文件名
*test*

# 忽略 .tmp 或 .temp 文件
*.{tmp,temp}

# 忽略特定目录下的所有文件
src/main/resources/private/
```

## 本项目 .gitignore 说明

### 已配置的忽略项

1. **Maven 相关**
   - `target/` - Maven 编译输出目录
   - `.mvn/` - Maven Wrapper 相关文件

2. **IDE 配置**
   - `.idea/` - IntelliJ IDEA 配置
   - `*.iml` - IntelliJ 模块文件
   - `.classpath`, `.project` - Eclipse 配置
   - `.vscode/` - VS Code 配置

3. **日志文件**
   - `*.log` - 所有日志文件
   - `logs/` - 日志目录

4. **操作系统文件**
   - `.DS_Store` - macOS 系统文件
   - `Thumbs.db` - Windows 缩略图缓存

5. **配置文件**
   - `application-local.yml` - 本地配置文件（可能包含敏感信息）
   - `application-dev.yml` - 开发环境配置
   - `application-prod.yml` - 生产环境配置（可能包含敏感信息）

6. **编译文件**
   - `*.class` - Java 编译后的 class 文件
   - `*.jar`, `*.war`, `*.ear` - 打包文件

## 如何添加新的忽略规则

### 方法1：直接编辑 .gitignore 文件

在 `.gitignore` 文件中添加新的规则：

```gitignore
# 忽略自定义目录
my-custom-dir/

# 忽略特定文件
my-secret-config.properties
```

### 方法2：使用 Git 命令（临时忽略已跟踪的文件）

如果文件已经被 Git 跟踪，需要先移除跟踪：

```bash
# 从 Git 索引中移除文件（但保留本地文件）
git rm --cached filename

# 然后添加到 .gitignore
echo "filename" >> .gitignore

# 提交更改
git add .gitignore
git commit -m "Add filename to .gitignore"
```

## 常见问题

### Q1: 我已经提交了不应该提交的文件，怎么办？

```bash
# 1. 从 Git 索引中移除文件（保留本地文件）
git rm --cached filename

# 2. 添加到 .gitignore
echo "filename" >> .gitignore

# 3. 提交更改
git add .gitignore
git commit -m "Remove filename from tracking"
```

### Q2: 如何忽略已经被跟踪的目录？

```bash
# 移除目录跟踪（保留本地文件）
git rm -r --cached directory/

# 添加到 .gitignore
echo "directory/" >> .gitignore

# 提交
git add .gitignore
git commit -m "Ignore directory"
```

### Q3: 如何查看哪些文件被忽略了？

```bash
# 查看被忽略的文件
git status --ignored

# 或者使用
git clean -nX  # 预览会被清理的忽略文件
```

### Q4: .gitignore 不生效怎么办？

1. 检查文件是否已经被 Git 跟踪（已跟踪的文件不会被忽略）
2. 检查 .gitignore 文件语法是否正确
3. 检查文件路径是否正确（相对于仓库根目录）
4. 清除 Git 缓存：`git rm -r --cached .` 然后重新添加

## 最佳实践

1. **项目开始时就配置好 .gitignore**：避免提交不必要的文件

2. **团队统一 .gitignore**：所有团队成员使用相同的忽略规则

3. **敏感信息必须忽略**：
   - 密码、密钥
   - API Key
   - 数据库连接信息
   - 证书文件

4. **编译产物必须忽略**：
   - `.class` 文件
   - `target/`, `build/` 目录
   - 打包文件 `.jar`, `.war`

5. **IDE 配置建议忽略**：
   - 个人 IDE 配置
   - 工作区设置
   - 但可以考虑提交共享的代码风格配置

6. **使用注释**：在 .gitignore 中添加注释说明为什么要忽略某些文件

## 相关命令

```bash
# 查看 Git 状态（包括忽略的文件）
git status --ignored

# 强制添加被忽略的文件
git add -f filename

# 检查文件是否被忽略
git check-ignore -v filename

# 清理未跟踪的文件（谨慎使用）
git clean -fd  # -f: force, -d: directories
```

