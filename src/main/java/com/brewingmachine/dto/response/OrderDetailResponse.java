package com.brewingmachine.dto.response;

import lombok.Data;

@Data
public class OrderDetailResponse {
    private String orderId;
    private String status;
    private String goodsName;
    private Integer capacity;
    private Double price;
    private Integer quantity;
    private Double totalAmount;
    private Double payAmount;
    private String payType;
    private String createTime;
    private String payTime;
    private String completeTime;
    private String remark;
}