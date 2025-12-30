package com.brewingmachine.entity;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class Order {

    private Long id;

    private String orderId;

    private Long userId;

    private Long deviceId;

    private Long slotId;

    private Long goodsId;

    private String goodsName;

    private Integer capacity;

    private BigDecimal price;

    private Integer quantity;

    private BigDecimal totalAmount;

    private Long couponId;

    private BigDecimal couponAmount;

    private BigDecimal payAmount;

    private String payType;

    private String status;

    private LocalDateTime payTime;

    private LocalDateTime completeTime;

    private LocalDateTime refundTime;

    private String remark;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}