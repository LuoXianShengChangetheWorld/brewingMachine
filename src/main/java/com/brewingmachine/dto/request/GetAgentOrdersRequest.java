package com.brewingmachine.dto.request;

import lombok.Data;

@Data
public class GetAgentOrdersRequest {
    private Long userId;
    private Long storeId;
    private String status;
    private String startTime;
    private String endTime;
    private Integer page;
    private Integer size;
}