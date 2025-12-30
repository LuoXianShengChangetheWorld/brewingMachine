package com.brewingmachine.dto.response;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class CouponDetailResponse {
    private Long id;
    private String name;
    private String description;
    private String type;
    private Double value;
    private Double minAmount;
    private Integer maxDiscount;
    private Integer totalCount;
    private Integer usedCount;
    private Integer perUserLimit;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}