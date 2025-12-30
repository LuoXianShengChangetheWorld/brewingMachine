package com.brewingmachine.dto.response;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class ActivityListResponse {
    private Long id;
    private String name;
    private String description;
    private String type;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String status;
    private LocalDateTime createTime;
}