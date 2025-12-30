package com.brewingmachine.entity;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class UserAccountRecord {

    private Long id;

    private Long userId;

    private String type;

    private BigDecimal amount;

    private BigDecimal balance;

    private String remark;

    private String orderId;

    private LocalDateTime createTime;
}