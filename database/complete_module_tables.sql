-- ========================================
-- 智能售酒机平台完整模块建表语句
-- ========================================

USE brewing_machine;

-- ========================================
-- 1. 用户角色体系模块
-- ========================================

-- 用户表
CREATE TABLE IF NOT EXISTS `user` (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    username VARCHAR(50) UNIQUE NOT NULL COMMENT '用户名',
    password VARCHAR(255) COMMENT '密码（加密存储）',
    nickname VARCHAR(100) COMMENT '昵称',
    phone VARCHAR(20) COMMENT '手机号',
    email VARCHAR(100) COMMENT '邮箱',
    avatar VARCHAR(500) COMMENT '头像URL',
    gender TINYINT DEFAULT 0 COMMENT '性别：0-未知，1-男，2-女',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    parent_user_id BIGINT COMMENT '上级用户ID（用于层级关系）',
    
    -- 代理相关业务字段
    agent_level VARCHAR(50) COMMENT '代理级别：PROVINCE-省代，CITY-市代，DISTRICT-区代，COMMUNITY-社区代',
    total_turnover DECIMAL(12, 2) DEFAULT 0.00 COMMENT '总营业额',
    total_commission DECIMAL(12, 2) DEFAULT 0.00 COMMENT '总分成',
    sub_agent_count INT DEFAULT 0 COMMENT '下级代理数量',
    commission_rate DECIMAL(5, 2) COMMENT '分成比例（百分比）',
    
    -- 用户财务相关字段
    balance DECIMAL(10, 2) DEFAULT 0.00 COMMENT '账户余额',
    points BIGINT DEFAULT 0 COMMENT '积分余额',
    gift_money DECIMAL(10, 2) DEFAULT 0.00 COMMENT '礼金余额',
    wine_gold DECIMAL(10, 2) DEFAULT 0.00 COMMENT '酒金余额',
    total_consumption DECIMAL(10, 2) DEFAULT 0.00 COMMENT '累计消费额',
    
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    last_login_time DATETIME COMMENT '最后登录时间',
    INDEX idx_username (username),
    INDEX idx_phone (phone),
    INDEX idx_status (status),
    INDEX idx_parent_user_id (parent_user_id),
    INDEX idx_agent_level (agent_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 角色表
CREATE TABLE IF NOT EXISTS role (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    role_code VARCHAR(50) UNIQUE NOT NULL COMMENT '角色编码',
    role_name VARCHAR(100) NOT NULL COMMENT '角色名称',
    role_type VARCHAR(50) NOT NULL COMMENT '角色类型：AGENT-代理商，MERCHANT-商家，SUPPLIER-供应商，OPERATOR-运营人员，MACHINE_OWNER-机主，PROMOTER-推广员，CONSUMER-消费者',
    description VARCHAR(500) COMMENT '角色描述',
    max_dividend DECIMAL(10, 2) COMMENT '最高分红金额',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_role_code (role_code),
    INDEX idx_role_type (role_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

-- 用户角色关联表
CREATE TABLE IF NOT EXISTS user_role (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    role_id BIGINT NOT NULL COMMENT '角色ID',
    commission_rate DECIMAL(5, 2) COMMENT '分成比例（百分比）',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_user_id (user_id),
    INDEX idx_role_id (role_id),
    UNIQUE KEY uk_user_role (user_id, role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户角色关联表';

-- ========================================
-- 2. 代理商管理模块（基于用户角色）
-- ========================================

-- 代理商分成明细表（直接关联用户表）
CREATE TABLE IF NOT EXISTS agent_commission_detail (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT NOT NULL COMMENT '代理商用户ID',
    order_id BIGINT COMMENT '订单ID',
    commission_amount DECIMAL(10, 2) NOT NULL COMMENT '分成金额',
    commission_rate DECIMAL(5, 2) NOT NULL COMMENT '分成比例',
    commission_type VARCHAR(50) NOT NULL COMMENT '分成类型：DEVICE_SALES-设备销售，ORDER_COMMISSION-订单分成，PROMOTION-推广分成',
    order_amount DECIMAL(10, 2) COMMENT '订单金额',
    parent_user_id BIGINT COMMENT '上级代理商用户ID',
    commission_level TINYINT COMMENT '分成层级',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_user_id (user_id),
    INDEX idx_order_id (order_id),
    INDEX idx_commission_type (commission_type),
    INDEX idx_create_time (create_time),
    INDEX idx_parent_user_id (parent_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='代理商分成明细表';

-- 代理商邀请二维码表（直接关联用户表）
CREATE TABLE IF NOT EXISTS agent_invite_qrcode (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    inviter_user_id BIGINT NOT NULL COMMENT '邀请人代理商用户ID',
    qr_token VARCHAR(64) UNIQUE NOT NULL COMMENT '二维码唯一标识',
    commission_rate DECIMAL(5, 2) NOT NULL COMMENT '分成比例',
    max_uses INT DEFAULT 1 COMMENT '最大使用次数',
    used_count INT DEFAULT 0 COMMENT '已使用次数',
    expire_time DATETIME NOT NULL COMMENT '过期时间',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_inviter_user_id (inviter_user_id),
    INDEX idx_qr_token (qr_token),
    INDEX idx_expire_time (expire_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='代理商邀请二维码表';

-- ========================================
-- 3. 商家管理模块
-- ========================================

-- 商家表
CREATE TABLE IF NOT EXISTS merchant (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    merchant_name VARCHAR(200) COMMENT '商家名称',
    commission_rate DECIMAL(5, 2) COMMENT '分成比例（百分比）',
    red_packet_total DECIMAL(10, 2) DEFAULT 0.00 COMMENT '红包总额',
    red_packet_pool DECIMAL(10, 2) DEFAULT 0.00 COMMENT '红包池余额',
    coupon_total_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT '可发行抵扣券总额',
    coupon_total_count INT DEFAULT 0 COMMENT '可发行抵扣券总张数',
    cross_store_red_packet TINYINT DEFAULT 1 COMMENT '跨店红包功能：0-关闭，1-开启',
    total_sales DECIMAL(12, 2) DEFAULT 0.00 COMMENT '销售总计',
    total_turnover DECIMAL(12, 2) DEFAULT 0.00 COMMENT '累计营业额',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家表';

-- 商家酒券配置表
CREATE TABLE IF NOT EXISTS merchant_coupon_config (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    merchant_id BIGINT NOT NULL COMMENT '商家ID',
    config_type VARCHAR(50) NOT NULL COMMENT '配置类型：SCAN_PAY-扫码支付，PLATFORM_ORDER-平台点菜，CUSTOM_DISH-自定义菜品',
    coupon_rate DECIMAL(5, 2) NOT NULL COMMENT '酒券发放比例',
    expire_days INT NOT NULL COMMENT '酒券有效期（天）',
    usage_scene VARCHAR(100) COMMENT '使用场景：STORE-本店使用，GENERAL-通用，WINE_ONLY-仅酒券',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_merchant_id (merchant_id),
    INDEX idx_config_type (config_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家酒券配置表';

-- 商家菜品酒券配置表
CREATE TABLE IF NOT EXISTS merchant_dish_coupon_config (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    merchant_id BIGINT NOT NULL COMMENT '商家ID',
    dish_id BIGINT COMMENT '菜品ID',
    dish_name VARCHAR(200) COMMENT '菜品名称',
    coupon_rate DECIMAL(5, 2) NOT NULL COMMENT '酒券发放比例',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_merchant_id (merchant_id),
    INDEX idx_dish_id (dish_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家菜品酒券配置表';

-- 商家红包池表
CREATE TABLE IF NOT EXISTS merchant_red_packet_pool (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    merchant_id BIGINT NOT NULL COMMENT '商家ID',
    pool_balance DECIMAL(10, 2) DEFAULT 0.00 COMMENT '红包池余额',
    total_recharge DECIMAL(10, 2) DEFAULT 0.00 COMMENT '累计充值金额',
    daily_limit DECIMAL(10, 2) DEFAULT 0.00 COMMENT '每日发放限制',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_merchant_id (merchant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家红包池表';

-- ========================================
-- 4. 店铺管理模块
-- ========================================

-- 店铺表
CREATE TABLE IF NOT EXISTS store (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    merchant_id BIGINT NOT NULL COMMENT '商家ID',
    store_name VARCHAR(200) NOT NULL COMMENT '店铺名称',
    order_phone VARCHAR(20) COMMENT '订餐电话',
    storefront_photo VARCHAR(500) COMMENT '门头照',
    business_hours_start TIME COMMENT '营业开始时间',
    business_hours_end TIME COMMENT '营业结束时间',
    store_city VARCHAR(50) COMMENT '店铺城市',
    store_address VARCHAR(500) COMMENT '商户地址',
    store_detail_address VARCHAR(500) COMMENT '店铺详细地址',
    latitude DECIMAL(10, 7) COMMENT '纬度',
    longitude DECIMAL(10, 7) COMMENT '经度',
    store_category VARCHAR(100) COMMENT '店铺分类',
    discount_rate DECIMAL(5, 2) COMMENT '商家折扣比例',
    gift_money_rate DECIMAL(5, 2) COMMENT '消费赠送礼金比例',
    red_packet_rate DECIMAL(5, 2) COMMENT '消费者红包额度百分比',
    new_user_red_packet_min DECIMAL(5, 2) DEFAULT 1.00 COMMENT '店铺新人红包最小值',
    new_user_red_packet_max DECIMAL(5, 2) DEFAULT 10.00 COMMENT '店铺新人红包最大值',
    store_intro TEXT COMMENT '店铺介绍（0-500字）',
    provider_user_id BIGINT COMMENT '店铺提供员用户ID',
    status TINYINT DEFAULT 1 COMMENT '状态：0-停业，1-营业',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_merchant_id (merchant_id),
    INDEX idx_store_city (store_city),
    INDEX idx_provider_user_id (provider_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='店铺表';

-- 店铺图片表
CREATE TABLE IF NOT EXISTS store_image (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    store_id BIGINT NOT NULL COMMENT '店铺ID',
    image_url VARCHAR(500) NOT NULL COMMENT '图片URL',
    image_type TINYINT COMMENT '图片类型：1-门头照，2-店内照',
    sort_order INT DEFAULT 0 COMMENT '排序',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_store_id (store_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='店铺图片表';

-- 店铺菜品表
CREATE TABLE IF NOT EXISTS store_dish (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    store_id BIGINT NOT NULL COMMENT '店铺ID',
    dish_name VARCHAR(200) NOT NULL COMMENT '菜品名称',
    dish_price DECIMAL(8, 2) NOT NULL COMMENT '菜品价格',
    dish_description TEXT COMMENT '菜品描述',
    dish_image VARCHAR(500) COMMENT '菜品图片',
    category VARCHAR(100) COMMENT '菜品分类',
    sort_order INT DEFAULT 0 COMMENT '排序',
    status TINYINT DEFAULT 1 COMMENT '状态：0-下架，1-上架',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_store_id (store_id),
    INDEX idx_category (category),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='店铺菜品表';

-- 红包充值码表
CREATE TABLE IF NOT EXISTS red_packet_recharge_code (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    merchant_id BIGINT NOT NULL COMMENT '商家ID',
    recharge_code VARCHAR(50) UNIQUE NOT NULL COMMENT '充值码',
    amount DECIMAL(10, 2) NOT NULL COMMENT '充值金额',
    status TINYINT DEFAULT 0 COMMENT '状态：0-未使用，1-已使用',
    used_user_id BIGINT COMMENT '使用用户ID',
    used_time DATETIME COMMENT '使用时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_merchant_id (merchant_id),
    INDEX idx_recharge_code (recharge_code),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='红包充值码表';

-- ========================================
-- 5. 设备管理模块
-- ========================================

-- 售酒机设备表
CREATE TABLE IF NOT EXISTS brewing_machine (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    machine_code VARCHAR(100) UNIQUE NOT NULL COMMENT '设备编号',
    machine_name VARCHAR(200) NOT NULL COMMENT '设备名称',
    machine_type VARCHAR(50) COMMENT '设备类型',
    location VARCHAR(500) COMMENT '设备位置',
    province VARCHAR(50) COMMENT '省份',
    city VARCHAR(50) COMMENT '城市',
    district VARCHAR(50) COMMENT '区县',
    area VARCHAR(100) COMMENT '片区',
    status TINYINT DEFAULT 1 COMMENT '状态：0-离线，1-在线，2-故障，3-维护中，4-缺电，5-缺货',
    ip_address VARCHAR(50) COMMENT 'IP地址',
    latitude DECIMAL(10, 7) COMMENT '纬度',
    longitude DECIMAL(10, 7) COMMENT '经度',
    battery_level INT COMMENT '电量百分比（0-100）',
    qr_code_content VARCHAR(500) COMMENT '设备二维码内容',
    traffic_card_id BIGINT COMMENT '流量卡ID',
    lock_status TINYINT DEFAULT 0 COMMENT '锁状态：0-关闭，1-开启',
    auto_dispense_mode TINYINT DEFAULT 0 COMMENT '自动出酒模式：0-关闭，1-开启',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    last_online_time DATETIME COMMENT '最后在线时间',
    INDEX idx_machine_code (machine_code),
    INDEX idx_status (status),
    INDEX idx_city (city),
    INDEX idx_district (district),
    INDEX idx_traffic_card_id (traffic_card_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='售酒机设备表';

-- 设备出酒口表
CREATE TABLE IF NOT EXISTS machine_outlet (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    machine_id BIGINT NOT NULL COMMENT '设备ID',
    outlet_number TINYINT NOT NULL COMMENT '出酒口号（1-6）',
    wine_id BIGINT COMMENT '酒类ID',
    wine_package_id BIGINT COMMENT '酒套餐ID',
    wine_volume INT COMMENT '酒水量（ML）',
    free_mode TINYINT DEFAULT 0 COMMENT '免费喝模式：0-关闭，1-开启',
    outlet_status TINYINT DEFAULT 1 COMMENT '出酒口状态：0-停用，1-可用',
    dispense_status TINYINT DEFAULT 0 COMMENT '出酒状态：0-停止，1-出酒中',
    quantity INT DEFAULT 0 COMMENT '库存数量',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_machine_id (machine_id),
    INDEX idx_outlet_number (outlet_number),
    INDEX idx_wine_id (wine_id),
    UNIQUE KEY uk_machine_outlet (machine_id, outlet_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备出酒口表';

-- 设备运维记录表
CREATE TABLE IF NOT EXISTS machine_maintenance_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    machine_id BIGINT NOT NULL COMMENT '设备ID',
    operator_id BIGINT COMMENT '操作员ID',
    operation_type VARCHAR(50) COMMENT '操作类型：UNLOCK-开锁，LOCK-关锁，WINE_CHANGE-换酒，QUANTITY_MODIFY-修改数量',
    outlet_number TINYINT COMMENT '出酒口号',
    operation_desc VARCHAR(500) COMMENT '操作描述',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_machine_id (machine_id),
    INDEX idx_operator_id (operator_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备运维记录表';

-- 设备状态记录表
CREATE TABLE IF NOT EXISTS machine_status_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    machine_id BIGINT NOT NULL COMMENT '设备ID',
    status TINYINT COMMENT '状态：0-离线，1-在线，2-故障，3-维护中，4-缺电，5-缺货',
    status_desc VARCHAR(500) COMMENT '状态描述',
    battery_level INT COMMENT '电量百分比',
    fault_desc VARCHAR(500) COMMENT '故障描述（如：设备号及几号出酒口泵或按钮不工作）',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_machine_id (machine_id),
    INDEX idx_status (status),
    INDEX idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备状态记录表';

-- 设备销量统计表
CREATE TABLE IF NOT EXISTS machine_sales_stats (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    machine_id BIGINT NOT NULL COMMENT '设备ID',
    outlet_number TINYINT NOT NULL COMMENT '出酒口号',
    stat_date DATE NOT NULL COMMENT '统计日期',
    cash_sales_count INT DEFAULT 0 COMMENT '现金支付销量',
    cash_sales_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT '现金支付金额',
    qr_sales_count INT DEFAULT 0 COMMENT '扫码支付销量',
    qr_sales_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT '扫码支付金额',
    balance_sales_count INT DEFAULT 0 COMMENT '余额支付销量',
    balance_sales_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT '余额支付金额',
    total_sales_count INT DEFAULT 0 COMMENT '总销量',
    total_sales_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT '总销售额',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_machine_id (machine_id),
    INDEX idx_outlet_number (outlet_number),
    INDEX idx_stat_date (stat_date),
    UNIQUE KEY uk_machine_outlet_date (machine_id, outlet_number, stat_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备销量统计表';

-- ========================================
-- 6. 供应商管理模块
-- ========================================

-- 供应商表
CREATE TABLE IF NOT EXISTS supplier (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    supplier_name VARCHAR(200) NOT NULL COMMENT '供应商名称',
    contact_person VARCHAR(100) COMMENT '联系人',
    contact_phone VARCHAR(20) COMMENT '联系电话',
    contact_email VARCHAR(100) COMMENT '联系邮箱',
    address VARCHAR(500) COMMENT '供应商地址',
    commission_rate DECIMAL(5, 2) COMMENT '分成比例',
    wine_gold_price DECIMAL(8, 2) COMMENT '酒金单价',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_user_id (user_id),
    INDEX idx_supplier_name (supplier_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='供应商表';

-- 供应商设备关联表
CREATE TABLE IF NOT EXISTS supplier_machine (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    supplier_id BIGINT NOT NULL COMMENT '供应商ID',
    machine_id BIGINT NOT NULL COMMENT '设备ID',
    outlet_number TINYINT NOT NULL COMMENT '出酒口号',
    commission_rate DECIMAL(5, 2) NOT NULL COMMENT '分成比例',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_supplier_id (supplier_id),
    INDEX idx_machine_id (machine_id),
    UNIQUE KEY uk_supplier_machine_outlet (supplier_id, machine_id, outlet_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='供应商设备关联表';

-- ========================================
-- 7. 运营人员管理模块
-- ========================================

-- 运营人员表
CREATE TABLE IF NOT EXISTS operator (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    operator_type VARCHAR(50) NOT NULL COMMENT '运营类型：MAINTENANCE-运维员，SALES-业务员',
    name VARCHAR(100) NOT NULL COMMENT '姓名',
    phone VARCHAR(20) COMMENT '联系电话',
    id_card VARCHAR(18) COMMENT '身份证号',
    commission_rate DECIMAL(5, 2) COMMENT '分成比例',
    manage_area VARCHAR(500) COMMENT '管理区域',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_user_id (user_id),
    INDEX idx_operator_type (operator_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='运营人员表';

-- 运营人员设备关联表
CREATE TABLE IF NOT EXISTS operator_machine (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    operator_id BIGINT NOT NULL COMMENT '运营人员ID',
    machine_id BIGINT NOT NULL COMMENT '设备ID',
    bind_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '绑定时间',
    INDEX idx_operator_id (operator_id),
    INDEX idx_machine_id (machine_id),
    UNIQUE KEY uk_operator_machine (operator_id, machine_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='运营人员设备关联表';

-- ========================================
-- 8. 机主管理模块
-- ========================================

-- 机主表
CREATE TABLE IF NOT EXISTS machine_owner (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    owner_type VARCHAR(50) NOT NULL COMMENT '机主类型：FULL_MACHINE-整台机主，OUTLET_MACHINE-出酒口机主',
    machine_id BIGINT COMMENT '设备ID（整台机主）',
    outlet_number TINYINT COMMENT '出酒口号（出酒口机主）',
    commission_rate DECIMAL(5, 2) COMMENT '分成比例',
    max_dividend DECIMAL(10, 2) COMMENT '最高分红金额',
    total_revenue DECIMAL(12, 2) DEFAULT 0.00 COMMENT '总收入',
    withdraw_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT '已提现金额',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_user_id (user_id),
    INDEX idx_machine_id (machine_id),
    INDEX idx_owner_type (owner_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='机主表';

-- 机主收入明细表
CREATE TABLE IF NOT EXISTS machine_owner_revenue (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    owner_id BIGINT NOT NULL COMMENT '机主ID',
    machine_id BIGINT NOT NULL COMMENT '设备ID',
    outlet_number TINYINT COMMENT '出酒口号',
    order_id BIGINT COMMENT '订单ID',
    revenue_amount DECIMAL(10, 2) NOT NULL COMMENT '收入金额',
    commission_rate DECIMAL(5, 2) NOT NULL COMMENT '分成比例',
    revenue_type VARCHAR(50) NOT NULL COMMENT '收入类型：DEVICE_SALES-设备销售，ORDER_COMMISSION-订单分成',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_owner_id (owner_id),
    INDEX idx_machine_id (machine_id),
    INDEX idx_order_id (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='机主收入明细表';

-- ========================================
-- 9. 推广员管理模块
-- ========================================

-- 推广员表
CREATE TABLE IF NOT EXISTS promoter (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    promoter_level VARCHAR(50) COMMENT '推广员级别',
    threshold_type VARCHAR(50) COMMENT '门槛类型：NO_THRESHOLD-无门槛，PURCHASE_THRESHOLD-购买门槛，AMOUNT_THRESHOLD-金额门槛',
    threshold_value DECIMAL(10, 2) COMMENT '门槛值',
    restaurant_commission_rate DECIMAL(5, 2) COMMENT '饭店消费提成比例',
    machine_commission_rate DECIMAL(5, 2) COMMENT '酒机消费提成比例',
    recharge_commission_rate DECIMAL(5, 2) COMMENT '充值提成比例',
    machine_purchase_commission_rate DECIMAL(5, 2) COMMENT '购买酒机提成比例',
    bound_user_commission_rate DECIMAL(5, 2) COMMENT '被绑定者消费提成比例',
    total_promoted_restaurants INT DEFAULT 0 COMMENT '推广餐厅数量',
    total_promoted_users INT DEFAULT 0 COMMENT '推广用户数量',
    total_revenue DECIMAL(12, 2) DEFAULT 0.00 COMMENT '总收入',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_user_id (user_id),
    INDEX idx_promoter_level (promoter_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='推广员表';

-- 推广关系表
CREATE TABLE IF NOT EXISTS promotion_relationship (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    promoter_id BIGINT NOT NULL COMMENT '推广员ID',
    promoted_user_id BIGINT NOT NULL COMMENT '被推广用户ID',
    promoted_merchant_id BIGINT COMMENT '被推广商家ID',
    promotion_type VARCHAR(50) NOT NULL COMMENT '推广类型：USER_PROMOTION-用户推广，MERCHANT_PROMOTION-商家推广',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_promoter_id (promoter_id),
    INDEX idx_promoted_user_id (promoted_user_id),
    INDEX idx_promoted_merchant_id (promoted_merchant_id),
    UNIQUE KEY uk_promotion_user (promoter_id, promoted_user_id),
    UNIQUE KEY uk_promotion_merchant (promoter_id, promoted_merchant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='推广关系表';

-- 推广员收入明细表
CREATE TABLE IF NOT EXISTS promoter_revenue (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    promoter_id BIGINT NOT NULL COMMENT '推广员ID',
    order_id BIGINT COMMENT '订单ID',
    revenue_amount DECIMAL(10, 2) NOT NULL COMMENT '收入金额',
    revenue_type VARCHAR(50) NOT NULL COMMENT '收入类型：RESTAURANT_CONSUMPTION-饭店消费，MACHINE_CONSUMPTION-酒机消费，RECHARGE-充值，MACHINE_PURCHASE-酒机购买，BOUND_USER_CONSUMPTION-绑定用户消费',
    commission_rate DECIMAL(5, 2) NOT NULL COMMENT '分成比例',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_promoter_id (promoter_id),
    INDEX idx_order_id (order_id),
    INDEX idx_revenue_type (revenue_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='推广员收入明细表';

-- ========================================
-- 10. 酒类管理模块
-- ========================================

-- 酒类表
CREATE TABLE IF NOT EXISTS wine (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    wine_name VARCHAR(200) NOT NULL COMMENT '酒类名称',
    wine_brand VARCHAR(100) COMMENT '酒类品牌',
    wine_type VARCHAR(100) COMMENT '酒类类型：RED_WINE-红酒，Baijiu_LIGHT-清香型白酒，Baijiu_STRONG-浓香型白酒，Baijiao_JIANGXING-酱香型白酒，WHISKEY-威士忌，RUM-朗姆酒',
    wine_category_id BIGINT COMMENT '酒类分类ID',
    unit_price DECIMAL(8, 2) NOT NULL COMMENT '单价',
    dispense_time INT COMMENT '出酒时间（秒）',
    dispense_volume INT COMMENT '出酒量（ML）',
    specifications VARCHAR(100) COMMENT '规格',
    description TEXT COMMENT '酒类描述',
    image_url VARCHAR(500) COMMENT '酒类图片',
    status TINYINT DEFAULT 1 COMMENT '状态：0-下架，1-上架',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_wine_name (wine_name),
    INDEX idx_wine_brand (wine_brand),
    INDEX idx_wine_type (wine_type),
    INDEX idx_wine_category_id (wine_category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='酒类表';

-- 酒类分类表
CREATE TABLE IF NOT EXISTS wine_category (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    category_name VARCHAR(100) NOT NULL COMMENT '分类名称',
    parent_id BIGINT COMMENT '父分类ID',
    category_level TINYINT DEFAULT 1 COMMENT '分类级别',
    sort_order INT DEFAULT 0 COMMENT '排序',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_category_name (category_name),
    INDEX idx_parent_id (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='酒类分类表';

-- 酒套餐表
CREATE TABLE IF NOT EXISTS wine_package (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    package_name VARCHAR(200) NOT NULL COMMENT '套餐名称',
    wine_list TEXT COMMENT '包含酒类列表（JSON格式）',
    total_volume INT COMMENT '总容量（ML）',
    package_price DECIMAL(8, 2) NOT NULL COMMENT '套餐价格',
    description TEXT COMMENT '套餐描述',
    image_url VARCHAR(500) COMMENT '套餐图片',
    status TINYINT DEFAULT 1 COMMENT '状态：0-下架，1-上架',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_package_name (package_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='酒套餐表';

-- ========================================
-- 11. 流量卡管理模块
-- ========================================

-- 流量卡表
CREATE TABLE IF NOT EXISTS traffic_card (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    card_number VARCHAR(50) UNIQUE NOT NULL COMMENT '卡号',
    card_type VARCHAR(50) COMMENT '卡类型',
    data_package VARCHAR(100) COMMENT '流量包',
    expire_date DATE COMMENT '到期日期',
    status TINYINT DEFAULT 1 COMMENT '状态：0-停用，1-正常，2-到期',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_card_number (card_number),
    INDEX idx_expire_date (expire_date),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='流量卡表';

-- ========================================
-- 12. 订单管理模块
-- ========================================

-- 订单表
CREATE TABLE IF NOT EXISTS `order` (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    order_no VARCHAR(50) UNIQUE NOT NULL COMMENT '订单号',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    order_type VARCHAR(50) NOT NULL COMMENT '订单类型：WINE_ORDER-酒水订单，RESTAURANT_ORDER-餐厅订单，MACHINE_PURCHASE-酒机购买',
    machine_id BIGINT COMMENT '设备ID',
    outlet_number TINYINT COMMENT '出酒口号',
    store_id BIGINT COMMENT '店铺ID',
    dish_id BIGINT COMMENT '菜品ID',
    total_amount DECIMAL(10, 2) NOT NULL COMMENT '订单总金额',
    discount_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT '折扣金额',
    payable_amount DECIMAL(10, 2) NOT NULL COMMENT '应付金额',
    paid_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT '实付金额',
    payment_method VARCHAR(50) COMMENT '支付方式：CASH-现金，WECHAT-微信，ALIPAY-支付宝，BALANCE-余额，POINTS-积分，GIFT_MONEY-礼金，WINE_GOLD-酒金，COUPON-优惠券',
    coupon_id BIGINT COMMENT '优惠券ID',
    coupon_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT '优惠券金额',
    status VARCHAR(50) DEFAULT 'PENDING' COMMENT '订单状态：PENDING-待支付，PAID-已支付，COMPLETED-已完成，CANCELLED-已取消，REFUNDED-已退款',
    pay_time DATETIME COMMENT '支付时间',
    complete_time DATETIME COMMENT '完成时间',
    cancel_time DATETIME COMMENT '取消时间',
    refund_time DATETIME COMMENT '退款时间',
    remark TEXT COMMENT '备注',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_order_no (order_no),
    INDEX idx_user_id (user_id),
    INDEX idx_order_type (order_type),
    INDEX idx_machine_id (machine_id),
    INDEX idx_store_id (store_id),
    INDEX idx_status (status),
    INDEX idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- 订单明细表
CREATE TABLE IF NOT EXISTS order_detail (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    order_id BIGINT NOT NULL COMMENT '订单ID',
    item_type VARCHAR(50) NOT NULL COMMENT '商品类型：WINE-酒类，DISH-菜品，PACKAGE-套餐',
    item_id BIGINT NOT NULL COMMENT '商品ID',
    item_name VARCHAR(200) NOT NULL COMMENT '商品名称',
    quantity INT NOT NULL COMMENT '数量',
    unit_price DECIMAL(8, 2) NOT NULL COMMENT '单价',
    total_price DECIMAL(10, 2) NOT NULL COMMENT '小计',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_order_id (order_id),
    INDEX idx_item_id (item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单明细表';

-- ========================================
-- 13. 支付管理模块
-- ========================================

-- 支付记录表
CREATE TABLE IF NOT EXISTS payment_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    order_id BIGINT NOT NULL COMMENT '订单ID',
    payment_no VARCHAR(50) UNIQUE NOT NULL COMMENT '支付流水号',
    payment_method VARCHAR(50) NOT NULL COMMENT '支付方式',
    payment_amount DECIMAL(10, 2) NOT NULL COMMENT '支付金额',
    payment_status VARCHAR(50) NOT NULL COMMENT '支付状态：PENDING-待支付，SUCCESS-支付成功，FAILED-支付失败，REFUNDED-已退款',
    payment_time DATETIME COMMENT '支付时间',
    third_party_order_no VARCHAR(100) COMMENT '第三方订单号',
    third_party_response TEXT COMMENT '第三方响应',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_order_id (order_id),
    INDEX idx_payment_no (payment_no),
    INDEX idx_payment_method (payment_method),
    INDEX idx_payment_status (payment_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='支付记录表';

-- ========================================
-- 14. 优惠券管理模块
-- ========================================

-- 优惠券表
CREATE TABLE IF NOT EXISTS coupon (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    coupon_name VARCHAR(200) NOT NULL COMMENT '优惠券名称',
    coupon_type VARCHAR(50) NOT NULL COMMENT '优惠券类型：DISCOUNT-折扣券，CASH-现金券，SPECIAL-专用券',
    discount_type VARCHAR(50) COMMENT '折扣类型：PERCENTAGE-百分比，FIXED_AMOUNT-固定金额',
    discount_value DECIMAL(8, 2) COMMENT '折扣值',
    min_order_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT '最低订单金额',
    max_discount_amount DECIMAL(10, 2) COMMENT '最高折扣金额',
    total_quantity INT NOT NULL COMMENT '发行总量',
    used_quantity INT DEFAULT 0 COMMENT '已使用数量',
    valid_from DATETIME NOT NULL COMMENT '有效期开始',
    valid_to DATETIME NOT NULL COMMENT '有效期结束',
    usage_scope VARCHAR(100) COMMENT '使用范围：STORE-本店，GENERAL-通用，WINE_ONLY-仅酒券',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_coupon_name (coupon_name),
    INDEX idx_coupon_type (coupon_type),
    INDEX idx_valid_from (valid_from),
    INDEX idx_valid_to (valid_to)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='优惠券表';

-- 用户优惠券表
CREATE TABLE IF NOT EXISTS user_coupon (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    coupon_id BIGINT NOT NULL COMMENT '优惠券ID',
    coupon_code VARCHAR(50) COMMENT '优惠券码',
    obtain_type VARCHAR(50) COMMENT '获得方式：PURCHASE-购买，GIFT-赠送，PROMOTION-推广',
    status TINYINT DEFAULT 0 COMMENT '状态：0-未使用，1-已使用，2-已过期',
    used_time DATETIME COMMENT '使用时间',
    expire_time DATETIME COMMENT '过期时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_user_id (user_id),
    INDEX idx_coupon_id (coupon_id),
    INDEX idx_status (status),
    UNIQUE KEY uk_user_coupon (user_id, coupon_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户优惠券表';

-- ========================================
-- 15. 红包管理模块
-- ========================================

-- 红包表
CREATE TABLE IF NOT EXISTS red_packet (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    red_packet_type VARCHAR(50) NOT NULL COMMENT '红包类型：MERCHANT_RED_PACKET-商家红包，ROLE_RED_PACKET-角色红包，CONSUMER_RED_PACKET-消费者红包',
    red_packet_source VARCHAR(100) COMMENT '红包来源',
    amount DECIMAL(10, 2) NOT NULL COMMENT '红包金额',
    min_consumption DECIMAL(10, 2) DEFAULT 0.00 COMMENT '最低消费金额',
    valid_days INT COMMENT '有效天数',
    status TINYINT DEFAULT 0 COMMENT '状态：0-未使用，1-已使用，2-已过期',
    used_time DATETIME COMMENT '使用时间',
    expire_time DATETIME COMMENT '过期时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_user_id (user_id),
    INDEX idx_red_packet_type (red_packet_type),
    INDEX idx_status (status),
    INDEX idx_expire_time (expire_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='红包表';

-- ========================================
-- 16. 积分管理模块
-- ========================================

-- 积分规则表
CREATE TABLE IF NOT EXISTS points_rule (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    rule_name VARCHAR(200) NOT NULL COMMENT '规则名称',
    rule_type VARCHAR(50) NOT NULL COMMENT '规则类型：CONSUME_POINTS-消费积分，REGISTER_POINTS-注册积分，PROMOTION_POINTS-推广积分',
    points_rate DECIMAL(8, 2) COMMENT '积分比例（如：消费1元获得多少积分）',
    fixed_points INT COMMENT '固定积分',
    min_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT '最低金额',
    max_points_per_day INT COMMENT '每日最大积分',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_rule_name (rule_name),
    INDEX idx_rule_type (rule_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='积分规则表';

-- 用户积分记录表
CREATE TABLE IF NOT EXISTS user_points_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    points_type VARCHAR(50) NOT NULL COMMENT '积分类型：EARN-获得，USE-使用',
    points_amount INT NOT NULL COMMENT '积分数量',
    points_balance INT NOT NULL COMMENT '积分余额',
    rule_id BIGINT COMMENT '规则ID',
    order_id BIGINT COMMENT '订单ID',
    description VARCHAR(500) COMMENT '描述',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_user_id (user_id),
    INDEX idx_points_type (points_type),
    INDEX idx_order_id (order_id),
    INDEX idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户积分记录表';

-- ========================================
-- 17. 礼金管理模块
-- ========================================

-- 礼金规则表
CREATE TABLE IF NOT EXISTS gift_money_rule (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    rule_name VARCHAR(200) NOT NULL COMMENT '规则名称',
    rule_type VARCHAR(50) NOT NULL COMMENT '规则类型：CONSUME_GIFT-消费礼金，RECHARGE_GIFT-充值礼金，PROMOTION_GIFT-推广礼金',
    gift_money_rate DECIMAL(8, 2) COMMENT '礼金比例',
    fixed_gift_money DECIMAL(10, 2) COMMENT '固定礼金',
    min_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT '最低金额',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_rule_name (rule_name),
    INDEX idx_rule_type (rule_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='礼金规则表';

-- 用户礼金记录表
CREATE TABLE IF NOT EXISTS user_gift_money_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    gift_money_type VARCHAR(50) NOT NULL COMMENT '礼金类型：EARN-获得，USE-使用',
    gift_money_amount DECIMAL(10, 2) NOT NULL COMMENT '礼金数量',
    gift_money_balance DECIMAL(10, 2) NOT NULL COMMENT '礼金余额',
    rule_id BIGINT COMMENT '规则ID',
    order_id BIGINT COMMENT '订单ID',
    description VARCHAR(500) COMMENT '描述',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_user_id (user_id),
    INDEX idx_gift_money_type (gift_money_type),
    INDEX idx_order_id (order_id),
    INDEX idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户礼金记录表';

-- ========================================
-- 18. 酒金管理模块
-- ========================================

-- 酒金规则表
CREATE TABLE IF NOT EXISTS wine_gold_rule (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    rule_name VARCHAR(200) NOT NULL COMMENT '规则名称',
    rule_type VARCHAR(50) NOT NULL COMMENT '规则类型：CONSUME_WINE_GOLD-消费酒金，VOLUME_WINE_GOLD-销量酒金',
    wine_gold_rate DECIMAL(8, 2) COMMENT '酒金比例（如：销售1000ML给10个酒金）',
    volume_base INT COMMENT '酒金基础量（如：1000ML）',
    wine_gold_amount INT COMMENT '酒金数量',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_rule_name (rule_name),
    INDEX idx_rule_type (rule_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='酒金规则表';

-- 用户酒金记录表
CREATE TABLE IF NOT EXISTS user_wine_gold_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    wine_gold_type VARCHAR(50) NOT NULL COMMENT '酒金类型：EARN-获得，USE-使用',
    wine_gold_amount INT NOT NULL COMMENT '酒金数量',
    wine_gold_balance INT NOT NULL COMMENT '酒金余额',
    rule_id BIGINT COMMENT '规则ID',
    order_id BIGINT COMMENT '订单ID',
    machine_id BIGINT COMMENT '设备ID',
    outlet_number TINYINT COMMENT '出酒口号',
    description VARCHAR(500) COMMENT '描述',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_user_id (user_id),
    INDEX idx_wine_gold_type (wine_gold_type),
    INDEX idx_order_id (order_id),
    INDEX idx_machine_id (machine_id),
    INDEX idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户酒金记录表';

-- ========================================
-- 19. 提现管理模块
-- ========================================

-- 提现记录表
CREATE TABLE IF NOT EXISTS withdrawal_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    withdrawal_no VARCHAR(50) UNIQUE NOT NULL COMMENT '提现单号',
    withdrawal_amount DECIMAL(10, 2) NOT NULL COMMENT '提现金额',
    withdrawal_type VARCHAR(50) NOT NULL COMMENT '提现类型：BALANCE-余额，COMMISSION-分成',
    withdraw_method VARCHAR(50) NOT NULL COMMENT '提现方式：BANK_CARD-银行卡，WECHAT-微信，ALIPAY-支付宝',
    bank_account VARCHAR(100) COMMENT '银行账号',
    bank_name VARCHAR(100) COMMENT '银行名称',
    account_holder VARCHAR(100) COMMENT '账户持有人',
    status VARCHAR(50) DEFAULT 'PENDING' COMMENT '状态：PENDING-待处理，PROCESSING-处理中，SUCCESS-成功，FAILED-失败',
    fail_reason VARCHAR(500) COMMENT '失败原因',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    process_time DATETIME COMMENT '处理时间',
    INDEX idx_user_id (user_id),
    INDEX idx_withdrawal_no (withdrawal_no),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='提现记录表';

-- ========================================
-- 20. 促销活动模块
-- ========================================

-- 活动表
CREATE TABLE IF NOT EXISTS activity (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    activity_name VARCHAR(200) NOT NULL COMMENT '活动名称',
    activity_type VARCHAR(50) NOT NULL COMMENT '活动类型：COUPON_ACTIVITY-券发放，RECHARGE_ACTIVITY-充值活动，VIP_CARD-会员卡，NEW_USER_GIFT-新用户送券，FREE_DRINK-免费喝',
    activity_config TEXT COMMENT '活动配置（JSON格式）',
    start_time DATETIME NOT NULL COMMENT '活动开始时间',
    end_time DATETIME NOT NULL COMMENT '活动结束时间',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_activity_name (activity_name),
    INDEX idx_activity_type (activity_type),
    INDEX idx_start_time (start_time),
    INDEX idx_end_time (end_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动表';

-- VIP会员卡表
CREATE TABLE IF NOT EXISTS vip_card (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    card_name VARCHAR(200) NOT NULL COMMENT '会员卡名称',
    card_type VARCHAR(50) NOT NULL COMMENT '会员卡类型：MONTHLY-月卡，QUARTERLY-季卡，YEARLY-年卡',
    card_price DECIMAL(8, 2) NOT NULL COMMENT '会员卡价格',
    discount_rate DECIMAL(5, 2) COMMENT '折扣比例',
    valid_days INT NOT COMMENT '有效天数',
    promotion_commission_rate DECIMAL(5, 2) COMMENT '推广者分佣比例',
    benefits TEXT COMMENT '会员权益（JSON格式）',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_card_name (card_name),
    INDEX idx_card_type (card_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='VIP会员卡表';

-- 用户会员卡表
CREATE TABLE IF NOT EXISTS user_vip_card (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    vip_card_id BIGINT NOT NULL COMMENT '会员卡ID',
    card_no VARCHAR(50) UNIQUE NOT NULL COMMENT '会员卡号',
    purchase_amount DECIMAL(8, 2) NOT NULL COMMENT '购买金额',
    start_time DATETIME NOT NULL COMMENT '生效时间',
    end_time DATETIME NOT NULL COMMENT '失效时间',
    status TINYINT DEFAULT 1 COMMENT '状态：0-已过期，1-生效中',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_user_id (user_id),
    INDEX idx_vip_card_id (vip_card_id),
    INDEX idx_card_no (card_no),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户会员卡表';

-- ========================================
-- 21. 广告管理模块
-- ========================================

-- 广告表
CREATE TABLE IF NOT EXISTS advertisement (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    ad_name VARCHAR(200) NOT NULL COMMENT '广告名称',
    ad_type VARCHAR(50) NOT NULL COMMENT '广告类型：BANNER-轮播广告，POPUP-弹窗广告，THIRD_PARTY-第三方广告',
    ad_content TEXT NOT NULL COMMENT '广告内容（JSON格式）',
    ad_url VARCHAR(500) COMMENT '广告链接',
    image_url VARCHAR(500) COMMENT '广告图片',
    display_order INT DEFAULT 0 COMMENT '显示顺序',
    click_count INT DEFAULT 0 COMMENT '点击次数',
    view_count INT DEFAULT 0 COMMENT '展示次数',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    start_time DATETIME COMMENT '开始时间',
    end_time DATETIME COMMENT '结束时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_ad_name (ad_name),
    INDEX idx_ad_type (ad_type),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='广告表';

-- 广告点击记录表
CREATE TABLE IF NOT EXISTS ad_click_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    ad_id BIGINT NOT NULL COMMENT '广告ID',
    user_id BIGINT COMMENT '用户ID',
    ip_address VARCHAR(50) COMMENT 'IP地址',
    click_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '点击时间',
    INDEX idx_ad_id (ad_id),
    INDEX idx_user_id (user_id),
    INDEX idx_click_time (click_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='广告点击记录表';

-- ========================================
-- 22. 抽奖活动模块
-- ========================================

-- 抽奖活动表
CREATE TABLE IF NOT EXISTS lottery_activity (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    activity_name VARCHAR(200) NOT NULL COMMENT '活动名称',
    lottery_type VARCHAR(50) NOT NULL COMMENT '抽奖类型：WHEEL-大转盘，BLIND_BOX-盲盒',
    activity_config TEXT NOT NULL COMMENT '活动配置（JSON格式）',
    prize_config TEXT NOT NULL COMMENT '奖品配置（JSON格式）',
    start_time DATETIME NOT NULL COMMENT '活动开始时间',
    end_time DATETIME NOT NULL COMMENT '活动结束时间',
    daily_limit INT COMMENT '每日参与限制',
    total_limit INT COMMENT '总参与限制',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_activity_name (activity_name),
    INDEX idx_start_time (start_time),
    INDEX idx_end_time (end_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='抽奖活动表';

-- 抽奖记录表
CREATE TABLE IF NOT EXISTS lottery_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    activity_id BIGINT NOT NULL COMMENT '活动ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    prize_id BIGINT COMMENT '奖品ID',
    prize_name VARCHAR(200) COMMENT '奖品名称',
    prize_type VARCHAR(50) COMMENT '奖品类型：COUPON-优惠券，POINTS-积分，GIFT_MONEY-礼金，PHYSICAL-实物奖品',
    prize_value DECIMAL(10, 2) COMMENT '奖品价值',
    status TINYINT DEFAULT 0 COMMENT '状态：0-未领取，1-已领取',
    lottery_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '抽奖时间',
    claim_time DATETIME COMMENT '领取时间',
    INDEX idx_activity_id (activity_id),
    INDEX idx_user_id (user_id),
    INDEX idx_lottery_time (lottery_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='抽奖记录表';

-- ========================================
-- 23. 统计分析模块
-- ========================================

-- 日统计表
CREATE TABLE IF NOT EXISTS daily_stats (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    stat_date DATE NOT NULL COMMENT '统计日期',
    total_order_amount DECIMAL(12, 2) DEFAULT 0.00 COMMENT '订单金额总计',
    total_points_purchase DECIMAL(12, 2) DEFAULT 0.00 COMMENT '积分购买',
    total_coupon_purchase DECIMAL(12, 2) DEFAULT 0.00 COMMENT '折扣券购买',
    total_wine_gold_purchase DECIMAL(12, 2) DEFAULT 0.00 COMMENT '酒金明细',
    total_gift_money_purchase DECIMAL(12, 2) DEFAULT 0.00 COMMENT '礼金购买',
    total_balance_purchase DECIMAL(12, 2) DEFAULT 0.00 COMMENT '余额购买',
    total_commission DECIMAL(12, 2) DEFAULT 0.00 COMMENT '我的分成',
    total_recharge DECIMAL(12, 2) DEFAULT 0.00 COMMENT '充值统计',
    today_orders INT DEFAULT 0 COMMENT '今日订单数',
    today_users INT DEFAULT 0 COMMENT '今日用户数',
    today_devices INT DEFAULT 0 COMMENT '今日设备数',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_stat_date (stat_date),
    UNIQUE KEY uk_daily_stats (stat_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='日统计表';

-- 月统计表
CREATE TABLE IF NOT EXISTS monthly_stats (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    stat_year INT NOT NULL COMMENT '统计年份',
    stat_month INT NOT NULL COMMENT '统计月份',
    total_order_amount DECIMAL(12, 2) DEFAULT 0.00 COMMENT '订单金额总计',
    total_points_purchase DECIMAL(12, 2) DEFAULT 0.00 COMMENT '积分购买',
    total_coupon_purchase DECIMAL(12, 2) DEFAULT 0.00 COMMENT '折扣券购买',
    total_wine_gold_purchase DECIMAL(12, 2) DEFAULT 0.00 COMMENT '酒金明细',
    total_gift_money_purchase DECIMAL(12, 2) DEFAULT 0.00 COMMENT '礼金购买',
    total_balance_purchase DECIMAL(12, 2) DEFAULT 0.00 COMMENT '余额购买',
    total_commission DECIMAL(12, 2) DEFAULT 0.00 COMMENT '我的分成',
    total_recharge DECIMAL(12, 2) DEFAULT 0.00 COMMENT '充值统计',
    total_orders INT DEFAULT 0 COMMENT '月订单数',
    total_users INT DEFAULT 0 COMMENT '月用户数',
    total_devices INT DEFAULT 0 COMMENT '月设备数',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_stat_year_month (stat_year, stat_month),
    UNIQUE KEY uk_monthly_stats (stat_year, stat_month)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='月统计表';

-- ========================================
-- 24. 系统管理模块
-- ========================================

-- 系统配置表
CREATE TABLE IF NOT EXISTS system_config (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    config_key VARCHAR(100) UNIQUE NOT NULL COMMENT '配置键',
    config_value TEXT COMMENT '配置值',
    config_type VARCHAR(50) COMMENT '配置类型：STRING-字符串，NUMBER-数字，BOOLEAN-布尔，JSON-JSON对象',
    config_desc VARCHAR(500) COMMENT '配置描述',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_config_key (config_key),
    INDEX idx_config_type (config_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统配置表';

-- 操作日志表
CREATE TABLE IF NOT EXISTS operation_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    user_id BIGINT COMMENT '用户ID',
    operation_type VARCHAR(50) NOT NULL COMMENT '操作类型',
    operation_desc VARCHAR(500) NOT NULL COMMENT '操作描述',
    request_url VARCHAR(500) COMMENT '请求URL',
    request_method VARCHAR(10) COMMENT '请求方法',
    request_params TEXT COMMENT '请求参数',
    response_result TEXT COMMENT '响应结果',
    ip_address VARCHAR(50) COMMENT 'IP地址',
    user_agent TEXT COMMENT '用户代理',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_user_id (user_id),
    INDEX idx_operation_type (operation_type),
    INDEX idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';

-- ========================================
-- 外键约束
-- ========================================

-- 添加外键约束
ALTER TABLE user_role ADD CONSTRAINT fk_user_role_user_id FOREIGN KEY (user_id) REFERENCES `user`(id);
ALTER TABLE user_role ADD CONSTRAINT fk_user_role_role_id FOREIGN KEY (role_id) REFERENCES role(id);

-- 已删除独立的代理商表，相关约束已移除
-- 代理功能现在通过用户角色和用户表中的代理字段实现
ALTER TABLE agent_commission_detail ADD CONSTRAINT fk_commission_user_id FOREIGN KEY (user_id) REFERENCES `user`(id);
ALTER TABLE agent_commission_detail ADD CONSTRAINT fk_commission_parent_user_id FOREIGN KEY (parent_user_id) REFERENCES `user`(id);
ALTER TABLE agent_invite_qrcode ADD CONSTRAINT fk_invite_user_id FOREIGN KEY (inviter_user_id) REFERENCES `user`(id);

ALTER TABLE merchant ADD CONSTRAINT fk_merchant_user_id FOREIGN KEY (user_id) REFERENCES `user`(id);
ALTER TABLE merchant_coupon_config ADD CONSTRAINT fk_coupon_config_merchant_id FOREIGN KEY (merchant_id) REFERENCES merchant(id);
ALTER TABLE merchant_dish_coupon_config ADD CONSTRAINT fk_dish_coupon_merchant_id FOREIGN KEY (merchant_id) REFERENCES merchant(id);
ALTER TABLE merchant_red_packet_pool ADD CONSTRAINT fk_red_packet_pool_merchant_id FOREIGN KEY (merchant_id) REFERENCES merchant(id);

ALTER TABLE store ADD CONSTRAINT fk_store_merchant_id FOREIGN KEY (merchant_id) REFERENCES merchant(id);
ALTER TABLE store_image ADD CONSTRAINT fk_image_store_id FOREIGN KEY (store_id) REFERENCES store(id);
ALTER TABLE store_dish ADD CONSTRAINT fk_dish_store_id FOREIGN KEY (store_id) REFERENCES store(id);
ALTER TABLE red_packet_recharge_code ADD CONSTRAINT fk_recharge_code_merchant_id FOREIGN KEY (merchant_id) REFERENCES merchant(id);

ALTER TABLE machine_outlet ADD CONSTRAINT fk_outlet_machine_id FOREIGN KEY (machine_id) REFERENCES brewing_machine(id);
ALTER TABLE machine_outlet ADD CONSTRAINT fk_outlet_wine_id FOREIGN KEY (wine_id) REFERENCES wine(id);
ALTER TABLE machine_outlet ADD CONSTRAINT fk_outlet_wine_package_id FOREIGN KEY (wine_package_id) REFERENCES wine_package(id);

ALTER TABLE machine_maintenance_log ADD CONSTRAINT fk_maintenance_machine_id FOREIGN KEY (machine_id) REFERENCES brewing_machine(id);
ALTER TABLE machine_maintenance_log ADD CONSTRAINT fk_maintenance_operator_id FOREIGN KEY (operator_id) REFERENCES `user`(id);
ALTER TABLE machine_status_log ADD CONSTRAINT fk_status_log_machine_id FOREIGN KEY (machine_id) REFERENCES brewing_machine(id);
ALTER TABLE machine_sales_stats ADD CONSTRAINT fk_sales_stats_machine_id FOREIGN KEY (machine_id) REFERENCES brewing_machine(id);

ALTER TABLE supplier ADD CONSTRAINT fk_supplier_user_id FOREIGN KEY (user_id) REFERENCES `user`(id);
ALTER TABLE supplier_machine ADD CONSTRAINT fk_supplier_machine_supplier_id FOREIGN KEY (supplier_id) REFERENCES supplier(id);
ALTER TABLE supplier_machine ADD CONSTRAINT fk_supplier_machine_machine_id FOREIGN KEY (machine_id) REFERENCES brewing_machine(id);

ALTER TABLE operator ADD CONSTRAINT fk_operator_user_id FOREIGN KEY (user_id) REFERENCES `user`(id);
ALTER TABLE operator_machine ADD CONSTRAINT fk_operator_machine_operator_id FOREIGN KEY (operator_id) REFERENCES operator(id);
ALTER TABLE operator_machine ADD CONSTRAINT fk_operator_machine_machine_id FOREIGN KEY (machine_id) REFERENCES brewing_machine(id);

ALTER TABLE machine_owner ADD CONSTRAINT fk_owner_user_id FOREIGN KEY (user_id) REFERENCES `user`(id);
ALTER TABLE machine_owner ADD CONSTRAINT fk_owner_machine_id FOREIGN KEY (machine_id) REFERENCES brewing_machine(id);
ALTER TABLE machine_owner_revenue ADD CONSTRAINT fk_revenue_owner_id FOREIGN KEY (owner_id) REFERENCES machine_owner(id);
ALTER TABLE machine_owner_revenue ADD CONSTRAINT fk_revenue_machine_id FOREIGN KEY (machine_id) REFERENCES brewing_machine(id);

ALTER TABLE promoter ADD CONSTRAINT fk_promoter_user_id FOREIGN KEY (user_id) REFERENCES `user`(id);
ALTER TABLE promotion_relationship ADD CONSTRAINT fk_promotion_promoter_id FOREIGN KEY (promoter_id) REFERENCES promoter(id);
ALTER TABLE promotion_relationship ADD CONSTRAINT fk_promotion_user_id FOREIGN KEY (promoted_user_id) REFERENCES `user`(id);
ALTER TABLE promotion_relationship ADD CONSTRAINT fk_promotion_merchant_id FOREIGN KEY (promoted_merchant_id) REFERENCES merchant(id);
ALTER TABLE promoter_revenue ADD CONSTRAINT fk_promoter_revenue_promoter_id FOREIGN KEY (promoter_id) REFERENCES promoter(id);

ALTER TABLE wine ADD CONSTRAINT fk_wine_category_id FOREIGN KEY (wine_category_id) REFERENCES wine_category(id);
ALTER TABLE wine_package ADD CONSTRAINT fk_package_wine_list FOREIGN KEY (id) REFERENCES wine(id);

ALTER TABLE `order` ADD CONSTRAINT fk_order_user_id FOREIGN KEY (user_id) REFERENCES `user`(id);
ALTER TABLE `order` ADD CONSTRAINT fk_order_machine_id FOREIGN KEY (machine_id) REFERENCES brewing_machine(id);
ALTER TABLE `order` ADD CONSTRAINT fk_order_store_id FOREIGN KEY (store_id) REFERENCES store(id);
ALTER TABLE `order` ADD CONSTRAINT fk_order_dish_id FOREIGN KEY (dish_id) REFERENCES store_dish(id);
ALTER TABLE `order` ADD CONSTRAINT fk_order_coupon_id FOREIGN KEY (coupon_id) REFERENCES user_coupon(id);
ALTER TABLE order_detail ADD CONSTRAINT fk_detail_order_id FOREIGN KEY (order_id) REFERENCES `order`(id);

ALTER TABLE payment_record ADD CONSTRAINT fk_payment_order_id FOREIGN KEY (order_id) REFERENCES `order`(id);

ALTER TABLE user_coupon ADD CONSTRAINT fk_user_coupon_user_id FOREIGN KEY (user_id) REFERENCES `user`(id);
ALTER TABLE user_coupon ADD CONSTRAINT fk_user_coupon_coupon_id FOREIGN KEY (coupon_id) REFERENCES coupon(id);

ALTER TABLE red_packet ADD CONSTRAINT fk_red_packet_user_id FOREIGN KEY (user_id) REFERENCES `user`(id);

ALTER TABLE user_points_record ADD CONSTRAINT fk_points_user_id FOREIGN KEY (user_id) REFERENCES `user`(id);
ALTER TABLE user_points_record ADD CONSTRAINT fk_points_rule_id FOREIGN KEY (rule_id) REFERENCES points_rule(id);
ALTER TABLE user_points_record ADD CONSTRAINT fk_points_order_id FOREIGN KEY (order_id) REFERENCES `order`(id);

ALTER TABLE user_gift_money_record ADD CONSTRAINT fk_gift_money_user_id FOREIGN KEY (user_id) REFERENCES `user`(id);
ALTER TABLE user_gift_money_record ADD CONSTRAINT fk_gift_money_rule_id FOREIGN KEY (rule_id) REFERENCES gift_money_rule(id);
ALTER TABLE user_gift_money_record ADD CONSTRAINT fk_gift_money_order_id FOREIGN KEY (order_id) REFERENCES `order`(id);

ALTER TABLE user_wine_gold_record ADD CONSTRAINT fk_wine_gold_user_id FOREIGN KEY (user_id) REFERENCES `user`(id);
ALTER TABLE user_wine_gold_record ADD CONSTRAINT fk_wine_gold_rule_id FOREIGN KEY (rule_id) REFERENCES wine_gold_rule(id);
ALTER TABLE user_wine_gold_record ADD CONSTRAINT fk_wine_gold_order_id FOREIGN KEY (order_id) REFERENCES `order`(id);
ALTER TABLE user_wine_gold_record ADD CONSTRAINT fk_wine_gold_machine_id FOREIGN KEY (machine_id) REFERENCES brewing_machine(id);

ALTER TABLE withdrawal_record ADD CONSTRAINT fk_withdrawal_user_id FOREIGN KEY (user_id) REFERENCES `user`(id);

ALTER TABLE user_vip_card ADD CONSTRAINT fk_vip_card_user_id FOREIGN KEY (user_id) REFERENCES `user`(id);
ALTER TABLE user_vip_card ADD CONSTRAINT fk_vip_card_id FOREIGN KEY (vip_card_id) REFERENCES vip_card(id);

ALTER TABLE advertisement ADD CONSTRAINT fk_advertisement_id FOREIGN KEY (id) REFERENCES `user`(id);
ALTER TABLE ad_click_record ADD CONSTRAINT fk_ad_click_ad_id FOREIGN KEY