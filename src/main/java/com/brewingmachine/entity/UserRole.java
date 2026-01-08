package com.brewingmachine.entity;

import lombok.Data;
import java.time.LocalDateTime;
import java.math.BigDecimal;

@Data
public class UserRole {
    private Long id;
    private Long userId;
    private Long roleId;
    private BigDecimal commissionRate;
    private Integer status;
    private LocalDateTime createTime;
}