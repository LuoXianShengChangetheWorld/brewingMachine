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
    `hierarchy` VARCHAR(200) COMMENT '层级信息（省市区街道，格式如：北京-北京市-海淀区-中关村）',

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




    -- 微信用户绑定表
CREATE TABLE IF NOT EXISTS wechat_user (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    openid VARCHAR(64) NOT NULL COMMENT '微信OpenID',
    unionid VARCHAR(64) COMMENT '微信UnionID',
    nickname VARCHAR(200) COMMENT '昵称',
    avatar VARCHAR(500) COMMENT '头像URL',
    gender TINYINT COMMENT '性别：0-未知，1-男，2-女',
    city VARCHAR(100) COMMENT '城市',
    province VARCHAR(100) COMMENT '省份',
    country VARCHAR(100) COMMENT '国家',
    language VARCHAR(50) COMMENT '语言',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    bind_time DATETIME COMMENT '绑定时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_openid (openid),
    INDEX idx_unionid (unionid),
    INDEX idx_user_id (user_id),
    UNIQUE KEY uk_openid (openid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='微信用户绑定表';