package com.brewingmachine.dto.request;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class CreateActivityRequest {
    private String name;
    private String description;
    private String type;
    private String rule;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
}