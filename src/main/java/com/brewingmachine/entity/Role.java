package com.brewingmachine.entity;

import lombok.Data;
import java.time.LocalDateTime;
import java.math.BigDecimal;

@Data
public class Role {
    private Long id;
    private String roleCode;
    private String roleName;
    private String roleType;
    private String description;
    private BigDecimal maxDividend;
    private Integer status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}