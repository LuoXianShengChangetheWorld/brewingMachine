-- 创建数据库
CREATE DATABASE IF NOT EXISTS brewing_machine DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE brewing_machine;

-- 二维码登录表
CREATE TABLE IF NOT EXISTS qr_code_login (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    qr_token VARCHAR(64) UNIQUE NOT NULL COMMENT '二维码唯一标识',
    status INT NOT NULL DEFAULT 0 COMMENT '状态：0-未扫描，1-已扫描未确认，2-已确认登录，3-已过期',
    user_id BIGINT COMMENT '用户ID',
    user_info TEXT COMMENT '用户信息（JSON格式）',
    create_time DATETIME NOT NULL COMMENT '创建时间',
    expire_time DATETIME NOT NULL COMMENT '过期时间',
    scan_time DATETIME COMMENT '扫描时间',
    confirm_time DATETIME COMMENT '确认时间',
    INDEX idx_qr_token (qr_token),
    INDEX idx_status (status),
    INDEX idx_expire_time (expire_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='二维码登录表';

