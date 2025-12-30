package com.brewingmachine.dto.response;

import lombok.Data;

@Data
public class CreateOrderResponse {
    private String orderId;
    private Double totalAmount;
    private Double payAmount;
    private String createTime;
}