package com.brewingmachine.entity;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class User {

    private Long id;

    private String username;

    private String password;

    private String nickname;

    private String phone;

    private String email;

    private String avatar;

    private Integer gender;

    private Integer status;

    private String role; // 保留原字段以兼容现有代码

    private List<UserRole> roles; // 支持多角色

    private Long parentUserId;

    private BigDecimal balance;

    private BigDecimal frozen;

    private Long points;

    private BigDecimal totalRecharge;

    private BigDecimal totalWithdraw;

    private String token;

    private LocalDateTime tokenExpireTime;

    private LocalDateTime lastLoginTime;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;

    // 层级信息字段（存储省市区街道等层级信息）
    private String hierarchy;
    
    // 财务相关字段
    private BigDecimal giftMoney;
    private BigDecimal wineGold;
    private BigDecimal totalConsumption;


}
