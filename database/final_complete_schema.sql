-- ============================================
-- 智能售酒机平台完整数据库设计
-- 合并所有模块的表结构和字段
-- ============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS brewing_machine DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE brewing_machine;

-- ============================================
-- 1. 用户与认证模块
-- ============================================

-- 用户表
CREATE TABLE IF NOT EXISTS `user` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `username` VARCHAR(50) UNIQUE NOT NULL COMMENT '用户名',
    `password` VARCHAR(255) NOT NULL COMMENT '密码（加密存储）',
    `nickname` VARCHAR(100) COMMENT '昵称',
    `phone` VARCHAR(20) UNIQUE COMMENT '手机号',
    `email` VARCHAR(100) COMMENT '邮箱',
    `avatar` VARCHAR(500) COMMENT '头像URL',
    `gender` TINYINT DEFAULT 0 COMMENT '性别：0-未知，1-男，2-女',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    `role` VARCHAR(20) DEFAULT 'member' COMMENT '角色：member-会员，agent-代理商，merchant-商家，supplier-供应商',
    `parent_user_id` BIGINT COMMENT '上级用户ID（用于层级关系）',
    
    -- 财务相关字段
    `balance` DECIMAL(10, 2) DEFAULT 0.00 COMMENT '账户余额',
    `frozen` DECIMAL(10, 2) DEFAULT 0.00 COMMENT '冻结金额',
    `points` BIGINT DEFAULT 0 COMMENT '积分余额',
    `gift_money` DECIMAL(10, 2) DEFAULT 0.00 COMMENT '礼金余额',
    `wine_gold` DECIMAL(10, 2) DEFAULT 0.00 COMMENT '酒金余额',
    `total_consumption` DECIMAL(10, 2) DEFAULT 0.00 COMMENT '累计消费额',
    `total_recharge` DECIMAL(10, 2) DEFAULT 0.00 COMMENT '累计充值',
    `total_withdraw` DECIMAL(10, 2) DEFAULT 0.00 COMMENT '累计提现',
    
    -- 代理相关字段
    `agent_level` VARCHAR(50) COMMENT '代理级别：PROVINCE-省代，CITY-市代，DISTRICT-区代，COMMUNITY-社区代',
    `total_turnover` DECIMAL(12, 2) DEFAULT 0.00 COMMENT '总营业额',
    `total_commission` DECIMAL(12, 2) DEFAULT 0.00 COMMENT '总分成',
    `sub_agent_count` INT DEFAULT 0 COMMENT '下级代理数量',
    `commission_rate` DECIMAL(5, 2) COMMENT '分成比例（百分比）',
    
    -- 登录相关字段
    `token` VARCHAR(255) COMMENT '登录token',
    `token_expire_time` DATETIME COMMENT 'token过期时间',
    `last_login_time` DATETIME COMMENT '最后登录时间',
    
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX `idx_username` (`username`),
    INDEX `idx_phone` (`phone`),
    INDEX `idx_status` (`status`),
    INDEX `idx_parent_user_id` (`parent_user_id`),
    INDEX `idx_agent_level` (`agent_level`)
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

-- 二维码登录表
CREATE TABLE IF NOT EXISTS `qr_code_login` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `qr_token` VARCHAR(64) UNIQUE NOT NULL COMMENT '二维码唯一标识',
    `status` INT NOT NULL DEFAULT 0 COMMENT '状态：0-未扫描，1-已扫描未确认，2-已确认登录，3-已过期',
    `user_id` BIGINT COMMENT '用户ID',
    `user_info` TEXT COMMENT '用户信息（JSON格式）',
    `role` VARCHAR(20) COMMENT '角色：agent-代理商，merchant-商家，machine_owner-机主等',
    `province` VARCHAR(50) COMMENT '省份',
    `city` VARCHAR(50) COMMENT '城市',
    `district` VARCHAR(50) COMMENT '区县',
    `street` VARCHAR(100) COMMENT '街道',
    `create_time` DATETIME NOT NULL COMMENT '创建时间',
    `expire_time` DATETIME NOT NULL COMMENT '过期时间',
    `scan_time` DATETIME COMMENT '扫描时间',
    `confirm_time` DATETIME COMMENT '确认时间',
    
    INDEX `idx_qr_token` (`qr_token`),
    INDEX `idx_status` (`status`),
    INDEX `idx_expire_time` (`expire_time`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_role` (`role`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='二维码登录表';

-- 用户账户记录表
CREATE TABLE IF NOT EXISTS `user_account_record` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `type` VARCHAR(20) NOT NULL COMMENT '记录类型：recharge-充值，withdraw-提现，consume-消费，refund-退款',
    `amount` DECIMAL(10, 2) NOT NULL COMMENT '金额',
    `balance` DECIMAL(10, 2) NOT NULL COMMENT '变动后余额',
    `remark` VARCHAR(200) COMMENT '备注',
    `order_id` VARCHAR(50) COMMENT '关联订单ID',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_type` (`type`),
    INDEX `idx_create_time` (`create_time`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户账户记录表';

-- ============================================
-- 2. 角色与权限模块
-- ============================================

-- 角色表
CREATE TABLE IF NOT EXISTS `role` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `role_code` VARCHAR(50) UNIQUE NOT NULL COMMENT '角色编码',
    `role_name` VARCHAR(100) NOT NULL COMMENT '角色名称',
    `role_type` VARCHAR(50) NOT NULL COMMENT '角色类型：AGENT-代理商，MERCHANT-商家，SUPPLIER-供应商，OPERATOR-运营人员，MACHINE_OWNER-机主，PROMOTER-推广员，CONSUMER-消费者',
    `description` VARCHAR(500) COMMENT '角色描述',
    `max_dividend` DECIMAL(10, 2) COMMENT '最高分红金额',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX `idx_role_code` (`role_code`),
    INDEX `idx_role_type` (`role_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

-- 用户角色关联表
CREATE TABLE IF NOT EXISTS `user_role` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `role_id` BIGINT NOT NULL COMMENT '角色ID',
    `commission_rate` DECIMAL(5, 2) COMMENT '分成比例（百分比）',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_role_id` (`role_id`),
    UNIQUE KEY `uk_user_role` (`user_id`, `role_id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户角色关联表';

-- ============================================
-- 3. 代理商管理模块
-- ============================================

-- 代理商表（扩展用户表的代理功能）
CREATE TABLE IF NOT EXISTS `agent` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `agent_level` VARCHAR(50) COMMENT '代理级别：PROVINCE-省代，CITY-市代，DISTRICT-区代，COMMUNITY-社区代',
    `total_turnover` DECIMAL(12, 2) DEFAULT 0.00 COMMENT '总营业额',
    `total_commission` DECIMAL(12, 2) DEFAULT 0.00 COMMENT '总分成',
    `sub_agent_count` INT DEFAULT 0 COMMENT '下级代理数量',
    `commission_rate` DECIMAL(5, 2) COMMENT '分成比例（百分比）',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_agent_level` (`agent_level`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='代理商表';

-- 代理商分成明细表
CREATE TABLE IF NOT EXISTS `agent_commission_detail` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '代理商用户ID',
    `order_id` BIGINT COMMENT '订单ID',
    `commission_amount` DECIMAL(10, 2) NOT NULL COMMENT '分成金额',
    `commission_rate` DECIMAL(5, 2) NOT NULL COMMENT '分成比例',
    `commission_type` VARCHAR(50) NOT NULL COMMENT '分成类型：DEVICE_SALES-设备销售，ORDER_COMMISSION-订单分成，PROMOTION-推广分成',
    `order_amount` DECIMAL(10, 2) COMMENT '订单金额',
    `parent_user_id` BIGINT COMMENT '上级代理商用户ID',
    `commission_level` TINYINT COMMENT '分成层级',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_order_id` (`order_id`),
    INDEX `idx_commission_type` (`commission_type`),
    INDEX `idx_create_time` (`create_time`),
    INDEX `idx_parent_user_id` (`parent_user_id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='代理商分成明细表';

-- 代理商邀请二维码表
CREATE TABLE IF NOT EXISTS `agent_invite_qrcode` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `inviter_user_id` BIGINT NOT NULL COMMENT '邀请人代理商用户ID',
    `qr_token` VARCHAR(64) UNIQUE NOT NULL COMMENT '二维码唯一标识',
    `commission_rate` DECIMAL(5, 2) NOT NULL COMMENT '分成比例',
    `max_uses` INT DEFAULT 1 COMMENT '最大使用次数',
    `used_count` INT DEFAULT 0 COMMENT '已使用次数',
    `expire_time` DATETIME NOT NULL COMMENT '过期时间',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    
    INDEX `idx_inviter_user_id` (`inviter_user_id`),
    INDEX `idx_qr_token` (`qr_token`),
    INDEX `idx_expire_time` (`expire_time`),
    FOREIGN KEY (`inviter_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='代理商邀请二维码表';

-- ============================================
-- 4. 商家管理模块
-- ============================================

-- 商家表
CREATE TABLE IF NOT EXISTS `merchant` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `merchant_name` VARCHAR(200) COMMENT '商家名称',
    `commission_rate` DECIMAL(5, 2) COMMENT '分成比例（百分比）',
    `red_packet_total` DECIMAL(10, 2) DEFAULT 0.00 COMMENT '红包总额',
    `red_packet_pool` DECIMAL(10, 2) DEFAULT 0.00 COMMENT '红包池余额',
    `coupon_total_amount` DECIMAL(10, 2) DEFAULT 0.00 COMMENT '可发行抵扣券总额',
    `coupon_total_count` INT DEFAULT 0 COMMENT '可发行抵扣券总张数',
    `cross_store_red_packet` TINYINT DEFAULT 1 COMMENT '跨店红包功能：0-关闭，1-开启',
    `total_sales` DECIMAL(12, 2) DEFAULT 0.00 COMMENT '销售总计',
    `total_turnover` DECIMAL(12, 2) DEFAULT 0.00 COMMENT '累计营业额',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX `idx_user_id` (`user_id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家表';

-- 商家酒券配置表
CREATE TABLE IF NOT EXISTS `merchant_coupon_config` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `merchant_id` BIGINT NOT NULL COMMENT '商家ID',
    `config_type` VARCHAR(50) NOT NULL COMMENT '配置类型：SCAN_PAY-扫码支付，PLATFORM_ORDER-平台点菜，CUSTOM_DISH-自定义菜品',
    `coupon_rate` DECIMAL(5, 2) NOT NULL COMMENT '酒券发放比例',
    `expire_days` INT NOT NULL COMMENT '酒券有效期（天）',
    `usage_scene` VARCHAR(100) COMMENT '使用场景：STORE-本店使用，GENERAL-通用，WINE_ONLY-仅酒券',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX `idx_merchant_id` (`merchant_id`),
    INDEX `idx_config_type` (`config_type`),
    FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家酒券配置表';

-- 商家菜品酒券配置表
CREATE TABLE IF NOT EXISTS `merchant_dish_coupon_config` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `merchant_id` BIGINT NOT NULL COMMENT '商家ID',
    `dish_id` BIGINT COMMENT '菜品ID',
    `dish_name` VARCHAR(200) COMMENT '菜品名称',
    `coupon_rate` DECIMAL(5, 2) NOT NULL COMMENT '酒券发放比例',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX `idx_merchant_id` (`merchant_id`),
    INDEX `idx_dish_id` (`dish_id`),
    FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家菜品酒券配置表';

-- 商家红包池表
CREATE TABLE IF NOT EXISTS `merchant_red_packet_pool` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `merchant_id` BIGINT NOT NULL COMMENT '商家ID',
    `pool_balance` DECIMAL(10, 2) DEFAULT 0.00 COMMENT '红包池余额',
    `total_recharge` DECIMAL(10, 2) DEFAULT 0.00 COMMENT '累计充值金额',
    `daily_limit` DECIMAL(10, 2) DEFAULT 0.00 COMMENT '每日发放限制',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX `idx_merchant_id` (`merchant_id`),
    FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家红包池表';

-- ============================================
-- 5. 店铺管理模块
-- ============================================

-- 店铺表
CREATE TABLE IF NOT EXISTS `store` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `merchant_id` BIGINT NOT NULL COMMENT '商家ID',
    `store_name` VARCHAR(200) NOT NULL COMMENT '店铺名称',
    `order_phone` VARCHAR(20) COMMENT '订餐电话',
    `storefront_photo` VARCHAR(500) COMMENT '门头照',
    `business_hours_start` TIME COMMENT '营业开始时间',
    `business_hours_end` TIME COMMENT '营业结束时间',
    `store_city` VARCHAR(50) COMMENT '店铺城市',
    `store_address` VARCHAR(500) COMMENT '商户地址',
    `store_detail_address` VARCHAR(500) COMMENT '店铺详细地址',
    `latitude` DECIMAL(10, 7) COMMENT '纬度',
    `longitude` DECIMAL(10, 7) COMMENT '经度',
    `store_category` VARCHAR(100) COMMENT '店铺分类',
    `discount_rate` DECIMAL(5, 2) COMMENT '商家折扣比例',
    `gift_money_rate` DECIMAL(5, 2) COMMENT '消费赠送礼金比例',
    `red_packet_rate` DECIMAL(5, 2) COMMENT '消费者红包额度百分比',
    `new_user_red_packet_min` DECIMAL(5, 2) DEFAULT 1.00 COMMENT '店铺新人红包最小值',
    `new_user_red_packet_max` DECIMAL(5, 2) DEFAULT 10.00 COMMENT '店铺新人红包最大值',
    `store_intro` TEXT COMMENT '店铺介绍（0-500字）',
    `provider_user_id` BIGINT COMMENT '店铺提供员用户ID',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-停业，1-营业',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX `idx_merchant_id` (`merchant_id`),
    INDEX `idx_store_city` (`store_city`),
    INDEX `idx_provider_user_id` (`provider_user_id`),
    FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`provider_user_id`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='店铺表';

-- 店铺图片表
CREATE TABLE IF NOT EXISTS `store_image` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `store_id` BIGINT NOT NULL COMMENT '店铺ID',
    `image_url` VARCHAR(500) NOT NULL COMMENT '图片URL',
    `image_type` TINYINT COMMENT '图片类型：1-门头照，2-店内照',
    `sort_order` INT DEFAULT 0 COMMENT '排序',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    
    INDEX `idx_store_id` (`store_id`),
    FOREIGN KEY (`store_id`) REFERENCES `store` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='店铺图片表';

-- 店铺菜品表
CREATE TABLE IF NOT EXISTS `store_dish` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `store_id` BIGINT NOT NULL COMMENT '店铺ID',
    `dish_name` VARCHAR(200) NOT NULL COMMENT '菜品名称',
    `dish_price` DECIMAL(8, 2) NOT NULL COMMENT '菜品价格',
    `dish_description` TEXT COMMENT '菜品描述',
    `dish_image` VARCHAR(500) COMMENT '菜品图片',
    `category` VARCHAR(100) COMMENT '菜品分类',
    `sort_order` INT DEFAULT 0 COMMENT '排序',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-下架，1-上架',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX `idx_store_id` (`store_id`),
    INDEX `idx_category` (`category`),
    INDEX `idx_status` (`status`),
    FOREIGN KEY (`store_id`) REFERENCES `store` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='店铺菜品表';

-- 红包充值码表
CREATE TABLE IF NOT EXISTS `red_packet_recharge_code` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `merchant_id` BIGINT NOT NULL COMMENT '商家ID',
    `recharge_code` VARCHAR(50) UNIQUE NOT NULL COMMENT '充值码',
    `amount` DECIMAL(10, 2) NOT NULL COMMENT '充值金额',
    `status` TINYINT DEFAULT 0 COMMENT '状态：0-未使用，1-已使用',
    `used_user_id` BIGINT COMMENT '使用用户ID',
    `used_time` DATETIME COMMENT '使用时间',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    
    INDEX `idx_merchant_id` (`merchant_id`),
    INDEX `idx_recharge_code` (`recharge_code`),
    INDEX `idx_status` (`status`),
    FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`used_user_id`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='红包充值码表';

-- ============================================
-- 6. 设备管理模块
-- ============================================

-- 售酒机设备表
CREATE TABLE IF NOT EXISTS `brewing_machine` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `machine_code` VARCHAR(100) UNIQUE NOT NULL COMMENT '设备编号',
    `machine_name` VARCHAR(200) NOT NULL COMMENT '设备名称',
    `machine_type` VARCHAR(50) COMMENT '设备类型',
    `location` VARCHAR(500) COMMENT '设备位置',
    `province` VARCHAR(50) COMMENT '省份',
    `city` VARCHAR(50) COMMENT '城市',
    `district` VARCHAR(50) COMMENT '区县',
    `area` VARCHAR(100) COMMENT '片区',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-离线，1-在线，2-故障，3-维护中，4-缺电，5-缺货',
    `ip_address` VARCHAR(50) COMMENT 'IP地址',
    `latitude` DECIMAL(10, 7) COMMENT '纬度',
    `longitude` DECIMAL(10, 7) COMMENT '经度',
    `battery_level` INT COMMENT '电量百分比（0-100）',
    `qr_code_content` VARCHAR(500) COMMENT '设备二维码内容',
    `traffic_card_id` BIGINT COMMENT '流量卡ID',
    `lock_status` TINYINT DEFAULT 0 COMMENT '锁状态：0-关闭，1-开启',
    `auto_dispense_mode` TINYINT DEFAULT 0 COMMENT '自动出酒模式：0-关闭，1-开启',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `last_online_time` DATETIME COMMENT '最后在线时间',
    
    INDEX `idx_machine_code` (`machine_code`),
    INDEX `idx_status` (`status`),
    INDEX `idx_city` (`city`),
    INDEX `idx_district` (`district`),
    INDEX `idx_traffic_card_id` (`traffic_card_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='售酒机设备表';

-- 设备出酒口表
CREATE TABLE IF NOT EXISTS `machine_outlet` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `machine_id` BIGINT NOT NULL COMMENT '设备ID',
    `outlet_number` TINYINT NOT NULL COMMENT '出酒口号（1-6）',
    `wine_id` BIGINT COMMENT '酒类ID',
    `wine_package_id` BIGINT COMMENT '酒套餐ID',
    `ml_volume` INT COMMENT '出酒量（ML）',
    `capacity` INT COMMENT '容量(ml)',
    `price` DECIMAL(8, 2) COMMENT '当前价格',
    `stock` INT DEFAULT 0 COMMENT '库存数量',
    `locked` TINYINT DEFAULT 0 COMMENT '锁定状态：0-未锁定，1-已锁定',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-停用，1-可用',
    `free_mode` TINYINT DEFAULT 0 COMMENT '免费喝模式：0-关闭，1-开启',
    `dispense_status` TINYINT DEFAULT 0 COMMENT '出酒状态：0-停止，1-出酒中',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX `idx_machine_id` (`machine_id`),
    INDEX `idx_outlet_number` (`outlet_number`),
    INDEX `idx_wine_id` (`wine_id`),
    INDEX `idx_locked` (`locked`),
    UNIQUE KEY `uk_machine_outlet` (`machine_id`, `outlet_number`),
    FOREIGN KEY (`machine_id`) REFERENCES `brewing_machine` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备出酒口表';

-- 设备运维记录表
CREATE TABLE IF NOT EXISTS `machine_maintenance_log` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `machine_id` BIGINT NOT NULL COMMENT '设备ID',
    `operator_id` BIGINT COMMENT '操作员ID',
    `operation_type` VARCHAR(50) COMMENT '操作类型：UNLOCK-开锁，LOCK-关锁，WINE_CHANGE-换酒，QUANTITY_MODIFY-修改数量',
    `outlet_number` TINYINT COMMENT '出酒口号',
    `operation_desc` VARCHAR(500) COMMENT '操作描述',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    
    INDEX `idx_machine_id` (`machine_id`),
    INDEX `idx_operator_id` (`operator_id`),
    FOREIGN KEY (`machine_id`) REFERENCES `brewing_machine` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`operator_id`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备运维记录表';

-- 设备状态记录表
CREATE TABLE IF NOT EXISTS `machine_status_log` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `machine_id` BIGINT NOT NULL COMMENT '设备ID',
    `status` TINYINT COMMENT '状态：0-离线，1-在线，2-故障，3-维护中，4-缺电，5-缺货',
    `status_desc` VARCHAR(500) COMMENT '状态描述',
    `battery_level` INT COMMENT '电量百分比',
    `fault_desc` VARCHAR(500) COMMENT '故障描述（如：设备号及几号出酒口泵或按钮不工作）',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    
    INDEX `idx_machine_id` (`machine_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_create_time` (`create_time`),
    FOREIGN KEY (`machine_id`) REFERENCES `brewing_machine` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备状态记录表';

-- 设备销量统计表
CREATE TABLE IF NOT EXISTS `machine_sales_stats` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `machine_id` BIGINT NOT NULL COMMENT '设备ID',
    `outlet_number` TINYINT NOT NULL COMMENT '出酒口号',
    `stat_date` DATE NOT NULL COMMENT '统计日期',
    `cash_sales_count` INT DEFAULT 0 COMMENT '现金支付销量',
    `cash_sales_amount` DECIMAL(10, 2) DEFAULT 0.00 COMMENT '现金支付金额',
    `qr_sales_count` INT DEFAULT 0 COMMENT '扫码支付销量',
    `qr_sales_amount` DECIMAL(10, 2) DEFAULT 0.00 COMMENT '扫码支付金额',
    `balance_sales_count` INT DEFAULT 0 COMMENT '余额支付销量',
    `balance_sales_amount` DECIMAL(10, 2) DEFAULT 0.00 COMMENT '余额支付金额',
    `total_sales_count` INT DEFAULT 0 COMMENT '总销量',
    `total_sales_amount` DECIMAL(10, 2) DEFAULT 0.00 COMMENT '总销售额',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX `idx_machine_id` (`machine_id`),
    INDEX `idx_outlet_number` (`outlet_number`),
    INDEX `idx_stat_date` (`stat_date`),
    UNIQUE KEY `uk_machine_outlet_date` (`machine_id`, `outlet_number`, `stat_date`),
    FOREIGN KEY (`machine_id`) REFERENCES `brewing_machine` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备销量统计表';

-- 设备绑定表（设备与角色的绑定关系及分成设置）
CREATE TABLE IF NOT EXISTS `machine_binding` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `machine_id` BIGINT NOT NULL COMMENT '设备ID',
    `user_id` BIGINT NOT NULL COMMENT '绑定用户ID',
    `role_type` VARCHAR(50) NOT NULL COMMENT '绑定角色类型',
    `commission_rate` DECIMAL(5, 2) COMMENT '分成比例',
    `binding_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '绑定时间',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-解绑，1-绑定',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    
    INDEX `idx_machine_id` (`machine_id`),
    INDEX `idx_user_id` (`user_id`),
    FOREIGN KEY (`machine_id`) REFERENCES `brewing_machine` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备绑定表';

-- ============================================
-- 7. 商品与分类模块
-- ============================================

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
    INDEX `idx_status` (`status`),
    FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品表';

-- 商品规格价格表
CREATE TABLE IF NOT EXISTS `goods_price` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '价格ID',
    `goods_id` BIGINT NOT NULL COMMENT '商品ID',
    `capacity` INT NOT NULL COMMENT '容量(ml)',
    `price` DECIMAL(8, 2) NOT NULL COMMENT '价格',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    UNIQUE KEY `uk_goods_capacity` (`goods_id`, `capacity`),
    INDEX `idx_goods_id` (`goods_id`),
    FOREIGN KEY (`goods_id`) REFERENCES `goods` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品规格价格表';

-- ============================================
-- 8. 订单与支付模块
-- ============================================

-- 订单表
CREATE TABLE IF NOT EXISTS `order` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '订单ID',
    `order_id` VARCHAR(50) UNIQUE NOT NULL COMMENT '订单编号',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `device_id` BIGINT NOT NULL COMMENT '设备ID',
    `slot_id` BIGINT NOT NULL COMMENT '槽位ID',
    `goods_id` BIGINT COMMENT '商品ID',
    `goods_name` VARCHAR(100) COMMENT '商品名称',
    `capacity` INT COMMENT '容量(ml)',
    `price` DECIMAL(8, 2) NOT NULL COMMENT '单价',
    `quantity` INT DEFAULT 1 COMMENT '数量',
    `total_amount` DECIMAL(8, 2) NOT NULL COMMENT '总金额',
    `coupon_id` BIGINT COMMENT '优惠券ID',
    `coupon_amount` DECIMAL(8, 2) DEFAULT 0.00 COMMENT '优惠券减免金额',
    `pay_amount` DECIMAL(8, 2) NOT NULL COMMENT '实际支付金额',
    `pay_type` VARCHAR(20) COMMENT '支付方式：wechat-微信，alipay-支付宝，balance-余额',
    `status` VARCHAR(20) DEFAULT 'pending' COMMENT '订单状态：pending-待支付，paid-已支付，completed-已完成，cancelled-已取消',
    `pay_time` DATETIME COMMENT '支付时间',
    `complete_time` DATETIME COMMENT '完成时间',
    `refund_time` DATETIME COMMENT '退款时间',
    `remark` VARCHAR(200) COMMENT '备注',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_device_id` (`device_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_create_time` (`create_time`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT,
    FOREIGN KEY (`device_id`) REFERENCES `brewing_machine` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- ============================================
-- 9. 优惠券与活动模块
-- ============================================

-- 优惠券表
CREATE TABLE IF NOT EXISTS `coupon` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '优惠券ID',
    `name` VARCHAR(100) NOT NULL COMMENT '优惠券名称',
    `type` VARCHAR(20) NOT NULL COMMENT '类型：fixed-固定金额，percent-百分比',
    `value` DECIMAL(8, 2) NOT NULL COMMENT '优惠值',
    `min_amount` DECIMAL(8, 2) DEFAULT 0.00 COMMENT '最低使用金额',
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

-- ============================================
-- 10. 系统配置与工具表
-- ============================================

-- 系统配置表
CREATE TABLE IF NOT EXISTS `system_config` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '配置ID',
    `config_key` VARCHAR(100) UNIQUE NOT NULL COMMENT '配置键',
    `config_value` TEXT COMMENT '配置值',
    `description` VARCHAR(200) COMMENT '配置描述',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX `idx_config_key` (`config_key`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统配置表';

-- 日志表
CREATE TABLE IF NOT EXISTS `system_log` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID',
    `log_type` VARCHAR(50) NOT NULL COMMENT '日志类型',
    `user_id` BIGINT COMMENT '操作用户ID',
    `operation` VARCHAR(200) NOT NULL COMMENT '操作描述',
    `request_url` VARCHAR(200) COMMENT '请求URL',
    `request_method` VARCHAR(10) COMMENT '请求方法',
    `request_params` TEXT COMMENT '请求参数',
    `response_result` TEXT COMMENT '响应结果',
    `ip_address` VARCHAR(50) COMMENT 'IP地址',
    `user_agent` VARCHAR(500) COMMENT '用户代理',
    `execution_time` INT COMMENT '执行时间(ms)',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-失败，1-成功',
    `error_message` TEXT COMMENT '错误信息',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    
    INDEX `idx_log_type` (`log_type`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统日志表';

-- ============================================
-- 初始化数据
-- ============================================

-- 插入系统角色
INSERT INTO `role` (`role_code`, `role_name`, `role_type`, `description`) VALUES
('ROLE_MEMBER', '会员', 'CONSUMER', '普通消费者'),
('ROLE_AGENT', '代理商', 'AGENT', '代理商角色'),
('ROLE_MERCHANT', '商家', 'MERCHANT', '商家角色'),
('ROLE_SUPPLIER', '供应商', 'SUPPLIER', '供应商角色'),
('ROLE_OPERATOR', '运营人员', 'OPERATOR', '平台运营人员');

-- 插入系统配置
INSERT INTO `system_config` (`config_key`, `config_value`, `description`) VALUES
('system_name', '智能售酒机平台', '系统名称'),
('system_version', '1.0.0', '系统版本'),
('wechat_appid', '', '微信小程序AppID'),
('wechat_secret', '', '微信小程序Secret'),
('default_recharge_gift_rate', '0.1', '默认充值送礼比例');

-- 插入测试数据
INSERT INTO `user` (`username`, `password`, `nickname`, `role`) VALUES
('admin', MD5('123456'), '管理员', 'admin'),
('test_user', MD5('123456'), '测试用户', 'member'),
('test_agent', MD5('123456'), '测试代理商', 'agent'),
('test_merchant', MD5('123456'), '测试商家', 'merchant');

-- 创建视图
CREATE OR REPLACE VIEW `v_user_role` AS
SELECT u.*, r.role_name, r.role_type
FROM `user` u
LEFT JOIN `user_role` ur ON u.id = ur.user_id
LEFT JOIN `role` r ON ur.role_id = r.id;

CREATE OR REPLACE VIEW `v_machine_status` AS
SELECT bm.*, COUNT(mo.id) AS outlet_count,
       SUM(CASE WHEN mo.stock <= 0 THEN 1 ELSE 0 END) AS lack_count
FROM `brewing_machine` bm
LEFT JOIN `machine_outlet` mo ON bm.id = mo.machine_id
GROUP BY bm.id;

-- 创建存储过程
DELIMITER //

-- 计算代理商分成的存储过程
CREATE PROCEDURE `calculate_agent_commission`(IN order_id BIGINT)
BEGIN
    DECLARE order_amount DECIMAL(10, 2);
    DECLARE machine_id BIGINT;
    DECLARE agent_id BIGINT;
    DECLARE commission_rate DECIMAL(5, 2);
    DECLARE commission_amount DECIMAL(10, 2);
    
    -- 获取订单信息
    SELECT total_amount, device_id INTO order_amount, machine_id
    FROM `order` WHERE id = order_id AND status = 'completed';
    
    -- 获取设备绑定的代理商
    SELECT user_id, commission_rate INTO agent_id, commission_rate
    FROM `machine_binding`
    WHERE machine_id = machine_id AND role_type = 'AGENT' AND status = 1;
    
    -- 计算分成金额
    SET commission_amount = order_amount * (commission_rate / 100);
    
    -- 插入分成记录
    INSERT INTO `agent_commission_detail` (user_id, order_id, commission_amount, commission_rate, commission_type, order_amount)
    VALUES (agent_id, order_id, commission_amount, commission_rate, 'ORDER_COMMISSION', order_amount);
    
    -- 更新代理商总分成
    UPDATE `agent` SET total_commission = total_commission + commission_amount WHERE user_id = agent_id;
    
    -- 更新用户余额
    UPDATE `user` SET balance = balance + commission_amount WHERE id = agent_id;
    
END //

DELIMITER ;

-- 创建触发器
DELIMITER //

-- 订单完成时自动计算代理商分成
CREATE TRIGGER `after_order_completed` AFTER UPDATE ON `order`
FOR EACH ROW
BEGIN
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        CALL `calculate_agent_commission`(NEW.id);
    END IF;
END //

DELIMITER ;

-- ============================================
-- 完成数据库创建
-- ============================================

SELECT '数据库创建完成' AS message;
