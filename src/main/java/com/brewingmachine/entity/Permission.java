package com.brewingmachine.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Permission {
    private Long id;
    private String permissionCode;
    private String permissionName;
    private String description;
    private String url;
    private Integer status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}