# 智能售酒机平台 - 二维码登录系统

## 技术栈

- **后端框架**: Spring Boot 2.7.18
- **Java版本**: JDK 1.8
- **数据库**: MySQL 5.7+
- **ORM框架**: MyBatis
- **二维码生成**: Google ZXing
- **构建工具**: Maven

## 项目结构

```
brewing-machine/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/
│       │       └── brewingmachine/
│       │           ├── BrewingMachineApplication.java    # 启动类
│       │           ├── controller/
│       │           │   └── QrCodeLoginController.java   # 二维码登录控制器
│       │           ├── service/
│       │           │   ├── QrCodeService.java           # 二维码生成服务
│       │           │   └── QrCodeLoginService.java      # 二维码登录服务
│       │           ├── entity/
│       │           │   └── QrCodeLogin.java             # 二维码登录实体
│       │           └── mapper/
│       │               └── QrCodeLoginMapper.java       # MyBatis Mapper接口
│       └── resources/
│           ├── application.yml                          # 配置文件
│           ├── mapper/
│           │   └── QrCodeLoginMapper.xml                # MyBatis SQL映射文件
│           └── static/
│               └── index.html                           # 前端登录页面
├── database/
│   └── init.sql                                         # 数据库初始化脚本
├── pom.xml                                              # Maven依赖配置
└── README.md                                            # 项目说明文档
```

## 快速开始

### 1. 环境要求

- JDK 1.8
- Maven 3.6+
- MySQL 5.7+
- IDE (IntelliJ IDEA / Eclipse)

### 2. 数据库配置

```sql
-- 执行数据库初始化脚本
source database/init.sql
```

或者手动创建数据库和表（参考 `database/init.sql` 文件）。

### 3. 配置文件

修改 `src/main/resources/application.yml` 中的数据库配置：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/brewing_machine?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: your_password  # 修改为你的数据库密码
  
  # MyBatis配置
  mybatis:
    mapper-locations: classpath:mapper/*.xml
    type-aliases-package: com.brewingmachine.entity
```

### 4. 运行项目

```bash
# 使用Maven运行
mvn spring-boot:run

# 或者打包后运行
mvn clean package
java -jar target/brewing-machine-1.0.0.jar
```

### 5. 访问页面

浏览器访问：http://localhost:8080/api/index.html

## API接口说明

### 1. 生成二维码

**请求**
```
POST /api/qr/login/generate
```

**响应**
```json
{
    "qrToken": "生成的token",
    "qrCodeImage": "data:image/png;base64,...",
    "expireTime": "2024-01-01T12:00:00"
}
```

### 2. 查询二维码状态

**请求**
```
GET /api/qr/login/status/{qrToken}
```

**响应**
```json
{
    "status": 0,  // 0-未扫描，1-已扫描未确认，2-已确认登录，3-已过期
    "message": "等待扫描",
    "userInfo": {},  // 登录成功后返回用户信息
    "userId": 123    // 登录成功后返回用户ID
}
```

### 3. 扫描二维码（移动端）

**请求**
```
POST /api/qr/login/scan
Content-Type: application/x-www-form-urlencoded

qrToken=xxx
```

**响应**
```json
{
    "success": true,
    "message": "扫描成功"
}
```

### 4. 确认登录（移动端）

**请求**
```
POST /api/qr/login/confirm
Content-Type: application/json

{
    "qrToken": "xxx",
    "userId": 123,
    "userInfo": {
        "userId": 123,
        "username": "test"
    }
}
```

**响应**
```json
{
    "success": true,
    "message": "登录成功"
}
```

## 二维码登录流程

1. **PC端**：访问登录页面，调用生成二维码接口，显示二维码
2. **PC端**：前端每2秒轮询查询二维码状态
3. **移动端**：用户使用APP扫描二维码，调用扫描接口
4. **移动端**：用户在APP上确认登录，调用确认登录接口
5. **PC端**：轮询检测到状态变为"已确认登录"，获取用户信息，完成登录

## 状态说明

- **0**: 未扫描 - 二维码已生成，等待用户扫描
- **1**: 已扫描未确认 - 用户已扫描，等待用户在手机上确认
- **2**: 已确认登录 - 用户已确认，登录成功
- **3**: 已过期 - 二维码超过有效期（默认5分钟）

## 配置说明

在 `application.yml` 中可以配置：

```yaml
qr:
  code:
    expire-seconds: 300  # 二维码过期时间（秒），默认5分钟
    width: 300           # 二维码宽度（像素）
    height: 300          # 二维码高度（像素）

# MyBatis配置
mybatis:
  mapper-locations: classpath:mapper/*.xml  # Mapper XML文件位置
  type-aliases-package: com.brewingmachine.entity  # 实体类包路径
  configuration:
    map-underscore-to-camel-case: true  # 开启驼峰命名转换
```

## 注意事项

1. 二维码默认有效期为5分钟，过期后需要刷新
2. 前端会自动轮询查询二维码状态，无需手动刷新
3. 移动端需要实现扫码功能，扫描后解析出token，然后调用相应的API
4. 生产环境建议使用Redis存储二维码临时数据，提高性能
5. 需要根据实际业务需求完善用户信息管理和认证逻辑
6. **MyBatis配置**：确保 `mapper-locations` 路径正确，Mapper接口需要使用 `@Mapper` 注解或在启动类上使用 `@MapperScan` 扫描

## 开发计划

- [ ] 集成Redis缓存二维码数据
- [ ] 添加JWT token生成和验证
- [ ] 完善用户管理模块
- [ ] 添加日志记录
- [ ] 添加异常处理
- [ ] 单元测试

## 许可证

MIT License
