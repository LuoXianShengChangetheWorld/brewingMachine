package com.brewingmachine.dto.request;

import lombok.Data;

@Data
public class UpdateActivityRequest {
    private Long id;
    private String name;
    private String description;
    private String type;
    private String rule;
    private String status;
}