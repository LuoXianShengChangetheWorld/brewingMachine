# 数据库部署指南

## 📋 数据库架构概览

本项目采用MySQL 5.7+作为主数据库，支持完整的智能酿酒机平台业务。

## 🚀 快速部署

### 1. 环境要求
- MySQL 5.7+ 或 MariaDB 10.3+
- 至少 1GB 可用存储空间
- 字符集：utf8mb4

### 2. 执行数据库脚本

```bash
# 1. 连接MySQL
mysql -u root -p

# 2. 执行创建脚本
source /path/to/database_schema.sql;

# 或者直接执行
mysql -u root -p < database_schema.sql
```

### 3. 验证安装

```sql
USE brewing_machine;
SHOW TABLES;
```

## 📊 数据库结构

### 核心业务表（10张）

| 表名 | 用途 | 记录量预估 |
|------|------|------------|
| `user` | 用户信息 | 10万+ |
| `store` | 店铺信息 | 1000+ |
| `device` | 设备信息 | 5000+ |
| `device_slot` | 设备槽位 | 50000+ |
| `goods` | 商品信息 | 1000+ |
| `goods_price` | 商品价格 | 5000+ |
| `category` | 商品分类 | 50+ |
| `order` | 订单信息 | 100万+ |
| `coupon` | 优惠券 | 100+ |
| `user_coupon` | 用户优惠券 | 100万+ |

### 辅助表（4张）

| 表名 | 用途 |
|------|------|
| `user_auth` | 用户第三方认证 |
| `user_account_record` | 用户账户流水 |
| `activity` | 营销活动 |
| `activity` | 活动配置 |

## 🔧 配置说明

### 连接配置

在 `application.yml` 中配置数据库连接：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/brewing_machine?useUnicode=true&characterEncoding=utf8mb4&useSSL=false&serverTimezone=Asia/Shanghai
    username: your_username
    password: your_password
    driver-class-name: com.mysql.cj.jdbc.Driver
    hikari:
      minimum-idle: 5
      maximum-pool-size: 20
      idle-timeout: 300000
      max-lifetime: 900000
      connection-timeout: 30000
```

### 分库分表策略

当数据量达到以下规模时，建议考虑分库分表：

| 表名 | 分库分表阈值 | 建议策略 |
|------|-------------|----------|
| `order` | 1000万记录 | 按月分表 |
| `user_account_record` | 1000万记录 | 按用户ID分表 |
| `user_coupon` | 1000万记录 | 按时间分表 |
| `device_slot` | 10万记录 | 分库 |

## 📈 性能优化

### 1. 索引策略

已创建的关键索引：
- 主键索引：所有表
- 唯一索引：用户名、手机号、设备序列号、订单号等
- 复合索引：用户状态+创建时间、设备店铺+在线状态等

### 2. 查询优化

```sql
-- 常用查询示例

-- 1. 获取用户订单列表（分页）
SELECT o.*, g.name as goods_name 
FROM `order` o 
LEFT JOIN goods g ON o.goods_id = g.id 
WHERE o.user_id = ? 
ORDER BY o.create_time DESC 
LIMIT ?, ?;

-- 2. 设备库存状态查询
SELECT ds.*, d.name as device_name, g.name as goods_name
FROM device_slot ds
JOIN device d ON ds.device_id = d.id
LEFT JOIN goods g ON ds.goods_id = g.id
WHERE ds.device_id = ?;

-- 3. 店铺设备统计
SELECT s.*, 
       COUNT(d.id) as device_count,
       SUM(CASE WHEN d.online = 1 THEN 1 ELSE 0 END) as online_count
FROM store s
LEFT JOIN device d ON s.id = d.store_id
WHERE s.owner_id = ?
GROUP BY s.id;
```

### 3. 缓存策略

建议使用Redis缓存以下数据：
- 用户登录状态
- 商品信息（热点数据）
- 设备在线状态
- 店铺信息

## 🛡️ 安全考虑

### 1. 数据备份

```bash
# 全量备份
mysqldump -u root -p --single-transaction --routines --triggers brewing_machine > backup_$(date +%Y%m%d).sql

# 增量备份（基于二进制日志）
mysqlbinlog --start-datetime="2025-01-01 00:00:00" --stop-datetime="2025-01-01 23:59:59" mysql-bin.000001 > increment_backup.sql
```

### 2. 数据清理

```sql
-- 清理30天前的账户流水记录
DELETE FROM user_account_record 
WHERE create_time < DATE_SUB(NOW(), INTERVAL 30 DAY);

-- 清理已取消的过期订单
DELETE FROM `order` 
WHERE status = 'CANCELLED' 
AND create_time < DATE_SUB(NOW(), INTERVAL 7 DAY);
```

### 3. 敏感数据处理

- 密码使用BCrypt加密
- 手机号、身份证等敏感信息建议加密存储
- 定期清理过期token

## 🔍 监控指标

### 1. 数据库性能指标

```sql
-- 查看当前连接数
SHOW STATUS LIKE 'Threads_connected';

-- 查看慢查询
SHOW VARIABLES LIKE 'slow_query_log';
SELECT * FROM mysql.slow_log ORDER BY start_time DESC LIMIT 10;

-- 查看表大小
SELECT 
    table_name AS '表名',
    table_rows AS '记录数',
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS '大小(MB)'
FROM information_schema.tables 
WHERE table_schema = 'brewing_machine'
ORDER BY (data_length + index_length) DESC;
```

### 2. 业务监控

建议监控以下业务指标：
- 日新增用户数
- 日订单量
- 设备在线率
- 支付成功率
- 优惠券使用率

## 🚨 常见问题

### Q1: 连接池耗尽
**解决方案**: 调整HikariCP配置，增加最大连接数

### Q2: 慢查询问题
**解决方案**: 
1. 检查索引使用情况
2. 优化SQL语句
3. 考虑分库分表

### Q3: 数据一致性问题
**解决方案**: 使用事务和分布式锁

### Q4: 高并发订单处理
**解决方案**: 
1. 使用消息队列
2. 乐观锁控制库存
3. 异步处理非关键业务

## 📞 技术支持

如遇到数据库相关问题，请检查：
1. 连接配置是否正确
2. 索引是否生效
3. 查询是否优化
4. 是否需要扩容

---

**创建时间**: 2025-12-31  
**数据库版本**: MySQL 5.7+  
**字符集**: utf8mb4  
**排序规则**: utf8mb4_unicode_ci