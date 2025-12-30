package com.brewingmachine.dto.response;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class CouponListResponse {
    private Long id;
    private String name;
    private String description;
    private String type;
    private Double value;
    private Integer totalCount;
    private Integer usedCount;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String status;
    private LocalDateTime createTime;
}