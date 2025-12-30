package com.brewingmachine.dto.response;

import lombok.Data;

@Data
public class OrderListItem {
    private String orderId;
    private String status;
    private String goodsName;
    private Double price;
    private Integer quantity;
    private Double totalAmount;
    private String createTime;
}