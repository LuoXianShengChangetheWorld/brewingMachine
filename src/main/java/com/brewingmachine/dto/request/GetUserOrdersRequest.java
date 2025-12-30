package com.brewingmachine.dto.request;

import lombok.Data;

@Data
public class GetUserOrdersRequest {
    private Long userId;
    private String status;
    private Integer page;
    private Integer size;
}