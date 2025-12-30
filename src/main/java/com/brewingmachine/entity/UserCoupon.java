package com.brewingmachine.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class UserCoupon {
    private Long id;
    private Long userId;
    private Long couponId;
    private String status; // 状态: AVAILABLE(可用), USED(已使用), EXPIRED(已过期)
    private LocalDateTime receiveTime; // 领取时间
    private LocalDateTime useTime; // 使用时间
    private LocalDateTime expireTime; // 过期时间
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}