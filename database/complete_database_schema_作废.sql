-- ============================================
-- 售玖机小程序完整数据库设计
-- ============================================

-- 用户表
CREATE TABLE IF NOT EXISTS `user` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    `username` VARCHAR(50) NOT NULL COMMENT '用户名',
    `password` VARCHAR(255) NOT NULL COMMENT '密码(MD5)',
    `nickname` VARCHAR(100) COMMENT '昵称',
    `avatar` VARCHAR(500) COMMENT '头像URL',
    `phone` VARCHAR(20) COMMENT '手机号',
    `email` VARCHAR(100) COMMENT '邮箱',
    `gender` TINYINT DEFAULT 0 COMMENT '性别：0-未知，1-男，2-女',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-正常',
    `role` VARCHAR(20) DEFAULT 'member' COMMENT '角色：member-会员，agent-代理商，merchant-商家',
    `parent_user_id` BIGINT COMMENT '上级用户ID',
    `balance` DECIMAL(10,2) DEFAULT 0.00 COMMENT '余额',
    `frozen` DECIMAL(10,2) DEFAULT 0.00 COMMENT '冻结金额',
    `points` INT DEFAULT 0 COMMENT '积分',
    `total_recharge` DECIMAL(10,2) DEFAULT 0.00 COMMENT '累计充值',
    `total_withdraw` DECIMAL(10,2) DEFAULT 0.00 COMMENT '累计提现',
    `token` VARCHAR(255) COMMENT '登录token',
    `token_expire_time` DATETIME COMMENT 'token过期时间',
    `last_login_time` DATETIME COMMENT '最后登录时间',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_username` (`username`),
    UNIQUE KEY `uk_phone` (`phone`),
    INDEX `idx_parent_user_id` (`parent_user_id`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 用户登录方式表
CREATE TABLE IF NOT EXISTS `user_auth` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `type` VARCHAR(20) NOT NULL COMMENT '登录类型：wechat-微信，phone-手机号',
    `access_key` VARCHAR(100) COMMENT '登录标识(微信openid或手机号)',
    `secret_key` VARCHAR(255) COMMENT '登录密钥(微信unionid或手机验证码)',
    `bind_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '绑定时间',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_user_type` (`user_id`, `type`),
    INDEX `idx_access_key` (`access_key`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户登录方式表';

-- 用户账户记录表
CREATE TABLE IF NOT EXISTS `user_account_record` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `type` VARCHAR(20) NOT NULL COMMENT '记录类型：recharge-充值，withdraw-提现，consume-消费，refund-退款',
    `amount` DECIMAL(10,2) NOT NULL COMMENT '金额',
    `balance` DECIMAL(10,2) NOT NULL COMMENT '变动后余额',
    `remark` VARCHAR(200) COMMENT '备注',
    `order_id` VARCHAR(50) COMMENT '关联订单ID',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_type` (`type`),
    INDEX `idx_create_time` (`create_time`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户账户记录表';

-- 店铺表
CREATE TABLE IF NOT EXISTS `store` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '店铺ID',
    `name` VARCHAR(100) NOT NULL COMMENT '店铺名称',
    `address` VARCHAR(200) COMMENT '地址',
    `latitude` DECIMAL(10,7) COMMENT '纬度',
    `longitude` DECIMAL(10,7) COMMENT '经度',
    `cover` VARCHAR(500) COMMENT '封面图片',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-正常',
    `owner_id` BIGINT COMMENT '店铺拥有者ID',
    `agent_id` BIGINT COMMENT '代理商ID',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_owner_id` (`owner_id`),
    INDEX `idx_agent_id` (`agent_id`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='店铺表';

-- 设备表
CREATE TABLE IF NOT EXISTS `device` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '设备ID',
    `sn` VARCHAR(50) NOT NULL COMMENT '设备编号',
    `name` VARCHAR(100) COMMENT '设备名称',
    `store_id` BIGINT COMMENT '绑定店铺ID',
    `online` TINYINT DEFAULT 0 COMMENT '在线状态：0-离线，1-在线',
    `battery` TINYINT DEFAULT 100 COMMENT '电量百分比',
    `status` VARCHAR(20) DEFAULT 'normal' COMMENT '设备状态：online-在线，offline-离线，fault-故障，lack-缺液，lack_el-缺电',
    `last_heartbeat` DATETIME COMMENT '最后心跳时间',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_sn` (`sn`),
    INDEX `idx_store_id` (`store_id`),
    INDEX `idx_status` (`status`),
    FOREIGN KEY (`store_id`) REFERENCES `store` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备表';

-- 商品表
CREATE TABLE IF NOT EXISTS `goods` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '商品ID',
    `name` VARCHAR(100) NOT NULL COMMENT '商品名称',
    `cover` VARCHAR(500) COMMENT '商品封面',
    `description` TEXT COMMENT '商品描述',
    `category_id` BIGINT COMMENT '分类ID',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-下架，1-上架',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_category_id` (`category_id`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品表';

-- 商品规格价格表
CREATE TABLE IF NOT EXISTS `goods_price` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '价格ID',
    `goods_id` BIGINT NOT NULL COMMENT '商品ID',
    `capacity` INT NOT NULL COMMENT '容量(ml)',
    `price` DECIMAL(8,2) NOT NULL COMMENT '价格',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_goods_capacity` (`goods_id`, `capacity`),
    INDEX `idx_goods_id` (`goods_id`),
    FOREIGN KEY (`goods_id`) REFERENCES `goods` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品规格价格表';

-- 设备槽位表
CREATE TABLE IF NOT EXISTS `device_slot` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '槽位ID',
    `device_id` BIGINT NOT NULL COMMENT '设备ID',
    `slot_id` VARCHAR(20) NOT NULL COMMENT '槽位编号',
    `goods_id` BIGINT COMMENT '商品ID',
    `price_id` BIGINT COMMENT '价格ID',
    `capacity` INT COMMENT '容量(ml)',
    `price` DECIMAL(8,2) COMMENT '当前价格',
    `stock` INT DEFAULT 0 COMMENT '库存数量',
    `locked` TINYINT DEFAULT 0 COMMENT '锁定状态：0-未锁定，1-已锁定',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_device_slot` (`device_id`, `slot_id`),
    INDEX `idx_device_id` (`device_id`),
    INDEX `idx_goods_id` (`goods_id`),
    INDEX `idx_locked` (`locked`),
    FOREIGN KEY (`device_id`) REFERENCES `device` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`goods_id`) REFERENCES `goods` (`id`) ON DELETE SET NULL,
    FOREIGN KEY (`price_id`) REFERENCES `goods_price` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备槽位表';

-- 订单表
CREATE TABLE IF NOT EXISTS `order` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '订单ID',
    `order_id` VARCHAR(50) NOT NULL COMMENT '订单编号',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `device_id` BIGINT NOT NULL COMMENT '设备ID',
    `slot_id` BIGINT NOT NULL COMMENT '槽位ID',
    `goods_id` BIGINT COMMENT '商品ID',
    `goods_name` VARCHAR(100) COMMENT '商品名称',
    `capacity` INT COMMENT '容量(ml)',
    `price` DECIMAL(8,2) NOT NULL COMMENT '单价',
    `quantity` INT DEFAULT 1 COMMENT '数量',
    `total_amount` DECIMAL(8,2) NOT NULL COMMENT '总金额',
    `coupon_id` BIGINT COMMENT '优惠券ID',
    `coupon_amount` DECIMAL(8,2) DEFAULT 0.00 COMMENT '优惠券减免金额',
    `pay_amount` DECIMAL(8,2) NOT NULL COMMENT '实际支付金额',
    `pay_type` VARCHAR(20) COMMENT '支付方式：wechat-微信，alipay-支付宝，balance-余额',
    `status` VARCHAR(20) DEFAULT 'pending' COMMENT '订单状态：pending-待支付，paid-已支付，completed-已完成，cancelled-已取消',
    `pay_time` DATETIME COMMENT '支付时间',
    `complete_time` DATETIME COMMENT '完成时间',
    `refund_time` DATETIME COMMENT '退款时间',
    `remark` VARCHAR(200) COMMENT '备注',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_order_id` (`order_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_device_id` (`device_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_create_time` (`create_time`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT,
    FOREIGN KEY (`device_id`) REFERENCES `device` (`id`) ON DELETE RESTRICT,
    FOREIGN KEY (`slot_id`) REFERENCES `device_slot` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- 商品分类表
CREATE TABLE IF NOT EXISTS `category` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '分类ID',
    `name` VARCHAR(50) NOT NULL COMMENT '分类名称',
    `sort` INT DEFAULT 0 COMMENT '排序',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_sort` (`sort`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品分类表';

-- 优惠券表
CREATE TABLE IF NOT EXISTS `coupon` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '优惠券ID',
    `name` VARCHAR(100) NOT NULL COMMENT '优惠券名称',
    `type` VARCHAR(20) NOT NULL COMMENT '类型：fixed-固定金额，percent-百分比',
    `value` DECIMAL(8,2) NOT NULL COMMENT '优惠值',
    `min_amount` DECIMAL(8,2) DEFAULT 0.00 COMMENT '最低使用金额',
    `total_quantity` INT NOT NULL COMMENT '总发放量',
    `used_quantity` INT DEFAULT 0 COMMENT '已使用量',
    `valid_start` DATETIME NOT NULL COMMENT '有效期开始',
    `valid_end` DATETIME NOT NULL COMMENT '有效期结束',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_status` (`status`),
    INDEX `idx_valid_start` (`valid_start`),
    INDEX `idx_valid_end` (`valid_end`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='优惠券表';

-- 用户优惠券表
CREATE TABLE IF NOT EXISTS `user_coupon` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户优惠券ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `coupon_id` BIGINT NOT NULL COMMENT '优惠券ID',
    `order_id` BIGINT COMMENT '使用订单ID',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-未使用，1-已使用，2-已过期',
    `use_time` DATETIME COMMENT '使用时间',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_user_coupon` (`user_id`, `coupon_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_coupon_id` (`coupon_id`),
    INDEX `idx_status` (`status`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`coupon_id`) REFERENCES `coupon` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户优惠券表';

-- 活动表
CREATE TABLE IF NOT EXISTS `activity` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '活动ID',
    `name` VARCHAR(100) NOT NULL COMMENT '活动名称',
    `type` VARCHAR(20) NOT NULL COMMENT '活动类型：gift-充值送礼',
    `config` JSON COMMENT '活动配置',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    `start_time` DATETIME NOT NULL COMMENT '开始时间',
    `end_time` DATETIME NOT NULL COMMENT '结束时间',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_status` (`status`),
    INDEX `idx_start_time` (`start_time`),
    INDEX `idx_end_time` (`end_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动表';

-- 更新外键约束
ALTER TABLE `goods` ADD CONSTRAINT `fk_goods_category` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE SET NULL;

-- 添加外键约束到相关表
ALTER TABLE `device` ADD CONSTRAINT `fk_device_store` FOREIGN KEY (`store_id`) REFERENCES `store` (`id`) ON DELETE SET NULL;

-- 添加现有表的微信相关字段
ALTER TABLE `wechat_user` ADD COLUMN IF NOT EXISTS `user_id` BIGINT COMMENT '关联用户ID' AFTER `id`;

ALTER TABLE `wechat_user` ADD CONSTRAINT IF NOT EXISTS `fk_wechat_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE;

-- 添加索引优化查询性能
CREATE INDEX IF NOT EXISTS `idx_wechat_user_user_id` ON `wechat_user` (`user_id`);