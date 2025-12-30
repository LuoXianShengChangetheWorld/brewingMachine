package com.brewingmachine.dto.request;

import lombok.Data;

@Data
public class UpdateCouponRequest {
    private Long id;
    private String name;
    private String description;
    private String type;
    private Double value;
    private Double minAmount;
    private Integer maxDiscount;
    private Integer totalCount;
    private Integer perUserLimit;
    private String status;
}