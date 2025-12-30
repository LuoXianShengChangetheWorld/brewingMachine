package com.brewingmachine.entity;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class GoodsPrice {

    private Long id;

    private Long goodsId;

    private Integer capacity;

    private BigDecimal price;

    private Integer status;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}