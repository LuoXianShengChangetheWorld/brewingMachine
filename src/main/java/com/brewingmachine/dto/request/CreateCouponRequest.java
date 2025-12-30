package com.brewingmachine.dto.request;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class CreateCouponRequest {
    private String name;
    private String description;
    private String type;
    private Double value;
    private Double minAmount;
    private Integer maxDiscount;
    private Integer totalCount;
    private Integer perUserLimit;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
}