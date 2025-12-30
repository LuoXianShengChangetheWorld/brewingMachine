package com.brewingmachine.entity;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class DeviceSlot {

    private Long id;

    private Long deviceId;

    private String slotId;

    private Long goodsId;

    private Long priceId;

    private Integer capacity;

    private BigDecimal price;

    private Integer stock;

    private Integer locked;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}