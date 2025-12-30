package com.brewingmachine.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Device {

    private Long id;

    private String sn;

    private String name;

    private Long storeId;

    private Integer online;

    private Integer battery;

    private String status;

    private LocalDateTime lastHeartbeat;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}