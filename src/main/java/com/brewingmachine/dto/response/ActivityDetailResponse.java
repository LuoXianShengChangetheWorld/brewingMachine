package com.brewingmachine.dto.response;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class ActivityDetailResponse {
    private Long id;
    private String name;
    private String description;
    private String type;
    private String rule;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}