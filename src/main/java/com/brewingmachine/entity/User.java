package com.brewingmachine.entity;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

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

    private Long parentUserId;

    private BigDecimal balance;

    private Long points;

    private BigDecimal giftMoney;

    private BigDecimal wineGold;

    private BigDecimal totalConsumption;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;

    private LocalDateTime lastLoginTime;

    private String token;

    private LocalDateTime tokenExpireTime;
}
