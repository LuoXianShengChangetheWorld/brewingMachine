    -- 创建数据库
    CREATE DATABASE IF NOT EXISTS brewing_machine DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

    USE brewing_machine;

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
        INDEX idx_parent_user_id (parent_user_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

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
        INDEX idx_expire_time (expire_time),
        INDEX idx_user_id (user_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='二维码登录表';

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

    -- 代理商表
    CREATE TABLE IF NOT EXISTS agent (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        user_id BIGINT NOT NULL COMMENT '用户ID',
        agent_level VARCHAR(50) COMMENT '代理级别：PROVINCE-省代，CITY-市代，DISTRICT-区代，COMMUNITY-社区代',
        total_turnover DECIMAL(12, 2) DEFAULT 0.00 COMMENT '总营业额',
        total_commission DECIMAL(12, 2) DEFAULT 0.00 COMMENT '总分成',
        sub_agent_count INT DEFAULT 0 COMMENT '下级代理数量',
        commission_rate DECIMAL(5, 2) COMMENT '分成比例（百分比）',
        status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        INDEX idx_user_id (user_id),
        INDEX idx_agent_level (agent_level)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='代理商表';

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

    -- 设备出酒口表
    CREATE TABLE IF NOT EXISTS machine_outlet (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        machine_id BIGINT NOT NULL COMMENT '设备ID',
        outlet_number TINYINT NOT NULL COMMENT '出酒口号（1-6）',
        wine_id BIGINT COMMENT '酒类ID',
        wine_package_id BIGINT COMMENT '酒套餐ID',
        ml_volume INT COMMENT '出酒量（ML）',
        status TINYINT DEFAULT 1 COMMENT '状态：0-停用，1-可用',
        free_mode TINYINT DEFAULT 0 COMMENT '免费喝模式：0-关闭，1-开启',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        INDEX idx_machine_id (machine_id),
        INDEX idx_wine_id (wine_id),
        UNIQUE KEY uk_machine_outlet (machine_id, outlet_number)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备出酒口表';

    -- 设备绑定表（设备与角色的绑定关系及分成设置）
    CREATE TABLE IF NOT EXISTS machine_binding (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        machine_id BIGINT NOT NULL COMMENT '设备ID',
        outlet_number TINYINT COMMENT '出酒口号（NULL表示整台设备）',
        role_type VARCHAR(50) NOT NULL COMMENT '角色类型',
        user_id BIGINT NOT NULL COMMENT '用户ID',
        commission_rate DECIMAL(5, 2) COMMENT '分成比例（百分比）',
        max_commission_amount DECIMAL(10, 2) COMMENT '最高分成金额',
        current_commission_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT '当前已分金额',
        status TINYINT DEFAULT 1 COMMENT '状态：0-解绑，1-绑定',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        INDEX idx_machine_id (machine_id),
        INDEX idx_user_id (user_id),
        INDEX idx_role_type (role_type)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备绑定表';

    -- 供应商表
    CREATE TABLE IF NOT EXISTS supplier (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        user_id BIGINT NOT NULL COMMENT '用户ID',
        supplier_name VARCHAR(200) COMMENT '供应商名称',
        status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        INDEX idx_user_id (user_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='供应商表';

    -- 运营人员表
    CREATE TABLE IF NOT EXISTS operator (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        user_id BIGINT NOT NULL COMMENT '用户ID',
        operator_type VARCHAR(50) NOT NULL COMMENT '运营人员类型：MAINTENANCE-运维员，SALES-业务员',
        machine_count INT DEFAULT 0 COMMENT '管理的设备数量',
        commission_rate DECIMAL(5, 2) COMMENT '分成比例（百分比）',
        status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        INDEX idx_user_id (user_id),
        INDEX idx_operator_type (operator_type)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='运营人员表';

    -- 机主表
    CREATE TABLE IF NOT EXISTS machine_owner (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        user_id BIGINT NOT NULL COMMENT '用户ID',
        machine_count INT DEFAULT 0 COMMENT '设备数量',
        total_income DECIMAL(12, 2) DEFAULT 0.00 COMMENT '总收入',
        commission_rate DECIMAL(5, 2) COMMENT '分成比例（百分比）',
        max_commission_amount DECIMAL(10, 2) COMMENT '最高分成金额',
        status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        INDEX idx_user_id (user_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='机主表';

    -- 推广员表
    CREATE TABLE IF NOT EXISTS promoter (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        user_id BIGINT NOT NULL COMMENT '用户ID',
        threshold_type TINYINT DEFAULT 0 COMMENT '门槛类型：0-无门槛，1-有门槛',
        threshold_product_id BIGINT COMMENT '门槛产品ID（购买指定产品）',
        threshold_amount DECIMAL(10, 2) COMMENT '门槛金额（消费达到指定金额）',
        restaurant_commission_rate DECIMAL(5, 2) COMMENT '饭店消费提成比例',
        machine_commission_rate DECIMAL(5, 2) COMMENT '酒机上消费提成比例',
        recharge_commission_rate DECIMAL(5, 2) COMMENT '充值提成比例',
        machine_purchase_commission_rate DECIMAL(5, 2) COMMENT '购买酒机提成比例',
        bound_user_commission_rate DECIMAL(5, 2) COMMENT '被绑定者消费提成比例',
        promoted_user_count INT DEFAULT 0 COMMENT '推广的用户数量',
        promoted_store_count INT DEFAULT 0 COMMENT '推广的店铺数量',
        total_turnover DECIMAL(12, 2) DEFAULT 0.00 COMMENT '总营业额',
        total_commission DECIMAL(12, 2) DEFAULT 0.00 COMMENT '总提成',
        consuming_user_count INT DEFAULT 0 COMMENT '有消费用户数量',
        non_consuming_user_count INT DEFAULT 0 COMMENT '未消费用户数量',
        status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        INDEX idx_user_id (user_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='推广员表';

    -- 推广员绑定关系表
    CREATE TABLE IF NOT EXISTS promoter_binding (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        promoter_id BIGINT NOT NULL COMMENT '推广员ID',
        bound_type VARCHAR(50) NOT NULL COMMENT '绑定类型：USER-用户，STORE-店铺，MACHINE-设备',
        bound_id BIGINT NOT NULL COMMENT '绑定对象ID',
        status TINYINT DEFAULT 1 COMMENT '状态：0-解绑，1-绑定',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        INDEX idx_promoter_id (promoter_id),
        INDEX idx_bound (bound_type, bound_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='推广员绑定关系表';

    -- 流量卡表
    CREATE TABLE IF NOT EXISTS traffic_card (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        card_number VARCHAR(100) UNIQUE NOT NULL COMMENT '卡号',
        card_provider VARCHAR(100) COMMENT '卡服务商',
        total_traffic DECIMAL(10, 2) COMMENT '总流量（GB）',
        used_traffic DECIMAL(10, 2) DEFAULT 0.00 COMMENT '已用流量（GB）',
        remaining_traffic DECIMAL(10, 2) COMMENT '剩余流量（GB）',
        expire_date DATE COMMENT '到期日期',
        status TINYINT DEFAULT 1 COMMENT '状态：0-停用，1-启用，2-已到期',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        INDEX idx_card_number (card_number),
        INDEX idx_expire_date (expire_date)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='流量卡表';

    -- 酒类分类表
    CREATE TABLE IF NOT EXISTS wine_category (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        category_name VARCHAR(100) NOT NULL COMMENT '分类名称（如：红酒、浓香、酱香、清香、洋酒等）',
        parent_id BIGINT COMMENT '父分类ID',
        sort_order INT DEFAULT 0 COMMENT '排序',
        status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        INDEX idx_parent_id (parent_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='酒类分类表';

    -- 酒类商品表
    CREATE TABLE IF NOT EXISTS wine (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        wine_name VARCHAR(200) NOT NULL COMMENT '酒类名称',
        brand VARCHAR(100) COMMENT '品牌',
        category_id BIGINT COMMENT '分类ID',
        unit_price DECIMAL(10, 2) COMMENT '单价',
        dispense_time INT COMMENT '出酒时间（秒）',
        dispense_volume INT COMMENT '出酒量（ML）',
        specification VARCHAR(200) COMMENT '规格',
        description TEXT COMMENT '描述',
        image_url VARCHAR(500) COMMENT '图片URL',
        status TINYINT DEFAULT 1 COMMENT '状态：0-下架，1-上架',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        INDEX idx_category_id (category_id),
        INDEX idx_wine_name (wine_name)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='酒类商品表';

    -- 酒金价格表
    CREATE TABLE IF NOT EXISTS wine_gold_price (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        wine_id BIGINT NOT NULL COMMENT '酒类ID',
        current_price DECIMAL(10, 2) COMMENT '当前价格（酒金个数）',
        sales_volume_rule VARCHAR(500) COMMENT '销量规则（如：售出1000ml给10个酒金）',
        status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        INDEX idx_wine_id (wine_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='酒金价格表';

    -- 订单表
    CREATE TABLE IF NOT EXISTS `order` (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        order_no VARCHAR(64) UNIQUE NOT NULL COMMENT '订单号',
        user_id BIGINT NOT NULL COMMENT '用户ID',
        order_type VARCHAR(50) NOT NULL COMMENT '订单类型：SALES-销售订单，RECHARGE-充值订单',
        order_source VARCHAR(50) COMMENT '订单来源：MACHINE-酒机，STORE-店铺，MINI_PROGRAM-小程序',
        machine_id BIGINT COMMENT '设备ID',
        store_id BIGINT COMMENT '店铺ID',
        total_amount DECIMAL(10, 2) COMMENT '订单总金额',
        discount_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT '折扣金额',
        coupon_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT '使用券金额',
        actual_amount DECIMAL(10, 2) COMMENT '实际支付金额',
        payment_method VARCHAR(50) COMMENT '支付方式：CASH-现金，SCAN-扫码，BALANCE-余额，POINTS-积分，COUPON-券，GIFT_MONEY-礼金，WINE_GOLD-酒金',
        order_status VARCHAR(50) DEFAULT 'PENDING' COMMENT '订单状态：PENDING-待支付，PAID-已支付，COMPLETED-已完成，CANCELLED-已取消',
        merchant_discount_rate DECIMAL(5, 2) COMMENT '商家折扣比例',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        pay_time DATETIME COMMENT '支付时间',
        INDEX idx_order_no (order_no),
        INDEX idx_user_id (user_id),
        INDEX idx_order_type (order_type),
        INDEX idx_order_status (order_status),
        INDEX idx_machine_id (machine_id),
        INDEX idx_store_id (store_id),
        INDEX idx_create_time (create_time)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

    -- 订单明细表
    CREATE TABLE IF NOT EXISTS order_item (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        order_id BIGINT NOT NULL COMMENT '订单ID',
        wine_id BIGINT COMMENT '酒类ID',
        item_name VARCHAR(200) COMMENT '商品名称',
        item_type VARCHAR(50) COMMENT '商品类型：WINE-酒类，CATERING-餐饮',
        quantity INT DEFAULT 1 COMMENT '数量',
        unit_price DECIMAL(10, 2) COMMENT '单价',
        total_price DECIMAL(10, 2) COMMENT '总价',
        machine_id BIGINT COMMENT '设备ID',
        outlet_number TINYINT COMMENT '出酒口号',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        INDEX idx_order_id (order_id),
        INDEX idx_wine_id (wine_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单明细表';

    -- 充值订单表
    CREATE TABLE IF NOT EXISTS recharge_order (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        order_no VARCHAR(64) UNIQUE NOT NULL COMMENT '订单号',
        user_id BIGINT NOT NULL COMMENT '用户ID',
        recharge_amount DECIMAL(10, 2) COMMENT '充值金额',
        payment_method VARCHAR(50) COMMENT '支付方式',
        order_status VARCHAR(50) DEFAULT 'PENDING' COMMENT '订单状态',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        pay_time DATETIME COMMENT '支付时间',
        INDEX idx_order_no (order_no),
        INDEX idx_user_id (user_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='充值订单表';

    -- 分成记录表
    CREATE TABLE IF NOT EXISTS commission_record (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        order_id BIGINT NOT NULL COMMENT '订单ID',
        commission_type VARCHAR(50) NOT NULL COMMENT '分成类型：AGENT-代理商，MERCHANT-商家，SUPPLIER-供应商，MACHINE_OWNER-机主，PROMOTER-推广员，OPERATOR-运营人员',
        role_user_id BIGINT NOT NULL COMMENT '分成角色用户ID',
        commission_level INT COMMENT '分成层级',
        commission_rate DECIMAL(5, 2) COMMENT '分成比例（百分比）',
        commission_amount DECIMAL(10, 2) COMMENT '分成金额',
        commission_source VARCHAR(50) COMMENT '分成来源：MACHINE-酒机，STORE-店铺，RECHARGE-充值',
        status TINYINT DEFAULT 0 COMMENT '状态：0-未结算，1-已结算',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        settle_time DATETIME COMMENT '结算时间',
        INDEX idx_order_id (order_id),
        INDEX idx_role_user_id (role_user_id),
        INDEX idx_commission_type (commission_type),
        INDEX idx_status (status)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='分成记录表';

    -- 分成明细统计表
    CREATE TABLE IF NOT EXISTS commission_detail (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        user_id BIGINT NOT NULL COMMENT '用户ID',
        commission_type VARCHAR(50) NOT NULL COMMENT '分成类型',
        statistics_type VARCHAR(50) NOT NULL COMMENT '统计类型：DAY-日，MONTH-月，YEAR-年',
        statistics_date DATE NOT NULL COMMENT '统计日期',
        total_commission DECIMAL(12, 2) DEFAULT 0.00 COMMENT '总分成金额',
        order_count INT DEFAULT 0 COMMENT '订单数量',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        INDEX idx_user_id (user_id),
        INDEX idx_statistics (statistics_type, statistics_date),
        UNIQUE KEY uk_user_statistics (user_id, commission_type, statistics_type, statistics_date)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='分成明细统计表';

    -- 红包池表
    CREATE TABLE IF NOT EXISTS red_packet_pool (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        pool_type VARCHAR(50) NOT NULL COMMENT '红包池类型：MERCHANT-商家，ROLE-角色，CONSUMER-消费者',
        owner_id BIGINT NOT NULL COMMENT '拥有者ID（商家ID/角色ID/用户ID）',
        total_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT '总金额',
        remaining_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT '剩余金额',
        used_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT '已使用金额',
        recharge_amount DECIMAL(10, 2) DEFAULT 0.00 COMMENT '充值金额',
        cumulative_turnover DECIMAL(12, 2) DEFAULT 0.00 COMMENT '累计营业额（用于计算红包额度）',
        status TINYINT DEFAULT 1 COMMENT '状态：0-停用，1-启用',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        INDEX idx_pool_type (pool_type, owner_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='红包池表';

    -- 红包领取记录表
    CREATE TABLE IF NOT EXISTS red_packet_record (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        pool_id BIGINT NOT NULL COMMENT '红包池ID',
        user_id BIGINT NOT NULL COMMENT '用户ID',
        packet_amount DECIMAL(10, 2) COMMENT '红包金额',
        receive_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '领取时间',
        INDEX idx_pool_id (pool_id),
        INDEX idx_user_id (user_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='红包领取记录表';

    -- 红包充值码表
    CREATE TABLE IF NOT EXISTS red_packet_recharge_code (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        merchant_id BIGINT COMMENT '商家ID（如果为商家红包池充值码）',
        recharge_code VARCHAR(100) UNIQUE NOT NULL COMMENT '充值码',
        recharge_amount DECIMAL(10, 2) COMMENT '充值金额',
        status TINYINT DEFAULT 0 COMMENT '状态：0-未使用，1-已使用',
        use_time DATETIME COMMENT '使用时间',
        use_user_id BIGINT COMMENT '使用用户ID',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        INDEX idx_recharge_code (recharge_code),
        INDEX idx_merchant_id (merchant_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='红包充值码表';

    -- 优惠券模板表
    CREATE TABLE IF NOT EXISTS coupon_template (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        template_name VARCHAR(200) COMMENT '模板名称',
        coupon_type VARCHAR(50) COMMENT '券类型：WINE-酒券，GENERAL-通用券',
        discount_type VARCHAR(50) COMMENT '折扣类型：AMOUNT-金额，PERCENT-百分比',
        discount_value DECIMAL(10, 2) COMMENT '折扣值',
        min_amount DECIMAL(10, 2) COMMENT '最低消费金额',
        valid_days INT COMMENT '有效天数',
        use_scenario VARCHAR(200) COMMENT '使用场景：STORE-本店使用，GENERAL-通用，WINE_ONLY-仅酒券',
        status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='优惠券模板表';

    -- 用户优惠券表
    CREATE TABLE IF NOT EXISTS user_coupon (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        user_id BIGINT NOT NULL COMMENT '用户ID',
        coupon_template_id BIGINT COMMENT '券模板ID',
        order_id BIGINT COMMENT '发放订单ID（支付后送券）',
        store_id BIGINT COMMENT '店铺ID',
        dish_id BIGINT COMMENT '菜品ID（菜品核销支付后送券）',
        coupon_code VARCHAR(100) UNIQUE COMMENT '券码',
        coupon_type VARCHAR(50) COMMENT '券类型',
        discount_type VARCHAR(50) COMMENT '折扣类型',
        discount_value DECIMAL(10, 2) COMMENT '折扣值',
        min_amount DECIMAL(10, 2) COMMENT '最低消费金额',
        use_scenario VARCHAR(200) COMMENT '使用场景',
        valid_start_date DATE COMMENT '有效开始日期',
        valid_end_date DATE COMMENT '有效结束日期',
        status VARCHAR(50) DEFAULT 'UNUSED' COMMENT '状态：UNUSED-未使用，USED-已使用，EXPIRED-已过期',
        use_time DATETIME COMMENT '使用时间',
        use_order_id BIGINT COMMENT '使用订单ID',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        INDEX idx_user_id (user_id),
        INDEX idx_status (status),
        INDEX idx_coupon_code (coupon_code)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户优惠券表';

    -- VIP卡表
    CREATE TABLE IF NOT EXISTS vip_card (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        card_name VARCHAR(200) COMMENT '卡名称',
        card_type VARCHAR(50) NOT NULL COMMENT '卡类型：MONTH-月卡，QUARTER-季卡，YEAR-年卡',
        original_price DECIMAL(10, 2) COMMENT '原价',
        sale_price DECIMAL(10, 2) COMMENT '售价',
        discount_rate DECIMAL(5, 2) COMMENT '折扣比例（在酒机上现金支付或扫码支付的折扣）',
        promotion_commission_rate DECIMAL(5, 2) COMMENT '推广分佣比例',
        valid_days INT COMMENT '有效天数',
        status TINYINT DEFAULT 1 COMMENT '状态：0-下架，1-上架',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        INDEX idx_card_type (card_type)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='VIP卡表';

    -- 用户VIP卡表
    CREATE TABLE IF NOT EXISTS vip_card_user (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        user_id BIGINT NOT NULL COMMENT '用户ID',
        vip_card_id BIGINT NOT NULL COMMENT 'VIP卡ID',
        promoter_id BIGINT COMMENT '推广员ID',
        valid_start_date DATE COMMENT '有效开始日期',
        valid_end_date DATE COMMENT '有效结束日期',
        status VARCHAR(50) DEFAULT 'ACTIVE' COMMENT '状态：ACTIVE-有效，EXPIRED-已过期',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        INDEX idx_user_id (user_id),
        INDEX idx_vip_card_id (vip_card_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户VIP卡表';

    -- 提现记录表
    CREATE TABLE IF NOT EXISTS withdrawal (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        user_id BIGINT NOT NULL COMMENT '用户ID',
        withdrawal_no VARCHAR(64) UNIQUE NOT NULL COMMENT '提现单号',
        withdrawal_amount DECIMAL(10, 2) COMMENT '提现金额',
        handling_fee DECIMAL(10, 2) COMMENT '手续费',
        actual_amount DECIMAL(10, 2) COMMENT '实际到账金额',
        account_type VARCHAR(50) COMMENT '账户类型：BANK-银行卡，ALIPAY-支付宝，WECHAT-微信',
        account_number VARCHAR(200) COMMENT '账户号码',
        account_name VARCHAR(100) COMMENT '账户姓名',
        status VARCHAR(50) DEFAULT 'PENDING' COMMENT '状态：PENDING-待处理，SUCCESS-成功，FAILED-失败',
        third_party_trade_no VARCHAR(100) COMMENT '第三方交易号',
        fail_reason VARCHAR(500) COMMENT '失败原因',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        process_time DATETIME COMMENT '处理时间',
        INDEX idx_user_id (user_id),
        INDEX idx_withdrawal_no (withdrawal_no),
        INDEX idx_status (status)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='提现记录表';

    -- 二维码授权表（角色授权二维码）
    CREATE TABLE IF NOT EXISTS qr_code_role_auth (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        qr_token VARCHAR(64) UNIQUE NOT NULL COMMENT '二维码唯一标识',
        role_type VARCHAR(50) NOT NULL COMMENT '角色类型',
        role_id BIGINT COMMENT '角色ID',
        config_data TEXT COMMENT '配置数据（JSON格式，如代理商的百分比等）',
        status TINYINT DEFAULT 0 COMMENT '状态：0-未使用，1-已使用',
        use_user_id BIGINT COMMENT '使用用户ID',
        use_time DATETIME COMMENT '使用时间',
        expire_time DATETIME COMMENT '过期时间',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        INDEX idx_qr_token (qr_token),
        INDEX idx_role_type (role_type),
        INDEX idx_status (status)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='二维码授权表';

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

    -- 数据统计表（日统计）
    CREATE TABLE IF NOT EXISTS statistics_daily (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        statistics_date DATE NOT NULL COMMENT '统计日期',
        user_id BIGINT COMMENT '用户ID（NULL表示全局统计）',
        statistics_type VARCHAR(50) COMMENT '统计类型：ORDER_AMOUNT-订单金额，POINTS_PURCHASE-积分购买，COUPON_PURCHASE-折扣券购买，WINE_GOLD-酒金，GIFT_MONEY-礼金，BALANCE_PURCHASE-余额购买，COMMISSION-分成，RECHARGE-充值',
        statistics_value DECIMAL(12, 2) DEFAULT 0.00 COMMENT '统计值',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        INDEX idx_statistics_date (statistics_date),
        INDEX idx_user_id (user_id),
        INDEX idx_statistics_type (statistics_type)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据统计表（日统计）';

    -- 菜品表
    CREATE TABLE IF NOT EXISTS dish (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        store_id BIGINT NOT NULL COMMENT '店铺ID',
        dish_name VARCHAR(200) NOT NULL COMMENT '菜品名称',
        dish_image VARCHAR(500) COMMENT '菜品图片',
        price DECIMAL(10, 2) COMMENT '价格',
        description TEXT COMMENT '描述',
        wine_coupon_rate DECIMAL(5, 2) COMMENT '支付后送酒券比例',
        wine_coupon_template_id BIGINT COMMENT '酒券模板ID',
        status TINYINT DEFAULT 1 COMMENT '状态：0-下架，1-上架',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        INDEX idx_store_id (store_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜品表';

    -- 促销活动表
    CREATE TABLE IF NOT EXISTS promotion_activity (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        activity_name VARCHAR(200) COMMENT '活动名称',
        activity_type VARCHAR(50) COMMENT '活动类型：NEW_USER_COUPON-新户送券，FREE_DRINK-免费喝',
        config_data TEXT COMMENT '配置数据（JSON格式）',
        free_drink_count INT COMMENT '免费喝酒数量',
        new_user_coupon_template_id BIGINT COMMENT '新户券模板ID',
        valid_start_date DATE COMMENT '有效开始日期',
        valid_end_date DATE COMMENT '有效结束日期',
        status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='促销活动表';

    -- 抽奖活动表
    CREATE TABLE IF NOT EXISTS lottery_activity (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        activity_name VARCHAR(200) COMMENT '活动名称',
        activity_type VARCHAR(50) COMMENT '活动类型：WHEEL-大转盘，BLIND_BOX-盲盒',
        description TEXT COMMENT '活动描述',
        valid_start_date DATE COMMENT '有效开始日期',
        valid_end_date DATE COMMENT '有效结束日期',
        status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='抽奖活动表';

    -- 抽奖奖品表
    CREATE TABLE IF NOT EXISTS lottery_prize (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        lottery_activity_id BIGINT NOT NULL COMMENT '抽奖活动ID',
        prize_name VARCHAR(200) COMMENT '奖品名称',
        prize_type VARCHAR(50) COMMENT '奖品类型：COUPON-优惠券，POINTS-积分，GIFT_MONEY-礼金，WINE_GOLD-酒金',
        prize_value VARCHAR(500) COMMENT '奖品值',
        prize_probability DECIMAL(5, 2) COMMENT '中奖概率（百分比）',
        prize_stock INT COMMENT '奖品库存',
        sort_order INT DEFAULT 0 COMMENT '排序',
        status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        INDEX idx_lottery_activity_id (lottery_activity_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='抽奖奖品表';

    -- 广告表
    CREATE TABLE IF NOT EXISTS advertisement (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        ad_name VARCHAR(200) COMMENT '广告名称',
        ad_type VARCHAR(50) COMMENT '广告类型：CAROUSEL-轮播，POPUP-弹窗',
        ad_image VARCHAR(500) COMMENT '广告图片',
        ad_link VARCHAR(500) COMMENT '广告链接',
        third_party_ad_id VARCHAR(100) COMMENT '第三方广告ID',
        view_commission_rate DECIMAL(5, 2) COMMENT '观看分成比例',
        valid_start_date DATE COMMENT '有效开始日期',
        valid_end_date DATE COMMENT '有效结束日期',
        sort_order INT DEFAULT 0 COMMENT '排序',
        status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
        create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='广告表';

    -- 广告观看记录表
    CREATE TABLE IF NOT EXISTS advertisement_view_log (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        ad_id BIGINT NOT NULL COMMENT '广告ID',
        user_id BIGINT COMMENT '用户ID',
        view_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '观看时间',
        commission_amount DECIMAL(10, 2) COMMENT '分成金额',
        INDEX idx_ad_id (ad_id),
        INDEX idx_user_id (user_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='广告观看记录表';

    -- 系统配置表
    CREATE TABLE IF NOT EXISTS system_config (
        id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
        config_key VARCHAR(100) UNIQUE NOT NULL COMMENT '配置键',
        config_value TEXT COMMENT '配置值',
        config_desc VARCHAR(500) COMMENT '配置描述',
        config_type VARCHAR(50) COMMENT '配置类型',
        update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
        INDEX idx_config_key (config_key)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统配置表';

