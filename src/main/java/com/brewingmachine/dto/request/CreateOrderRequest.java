package com.brewingmachine.dto.request;

import lombok.Data;

@Data
public class CreateOrderRequest {
    private Long userId;
    private String sn;
    private Long slotId;
    private Integer quantity;
    private String remark;
}