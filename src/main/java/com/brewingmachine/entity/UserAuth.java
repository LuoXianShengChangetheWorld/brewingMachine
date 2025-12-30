package com.brewingmachine.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class UserAuth {

    private Long id;

    private Long userId;

    private String type;

    private String accessKey;

    private String secretKey;

    private LocalDateTime bindTime;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}