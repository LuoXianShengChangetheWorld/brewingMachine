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

-- 更新用户表，添加token相关字段
ALTER TABLE `user` ADD COLUMN IF NOT EXISTS token VARCHAR(255) COMMENT '登录token' AFTER `last_login_time`;
ALTER TABLE `user` ADD COLUMN IF NOT EXISTS token_expire_time DATETIME COMMENT 'token过期时间' AFTER `token`;
