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

    private String role;

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
}
