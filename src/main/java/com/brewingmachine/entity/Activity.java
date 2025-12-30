package com.brewingmachine.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Activity {
    private Long id;
    private String name;
    private String description;
    private String type; // 活动类型: DISCOUNT(折扣), FULL_REDUCTION(满减), GIFT(赠送), OTHER(其他)
    private String rule; // 活动规则，JSON格式存储
    private LocalDateTime startTime; // 活动开始时间
    private LocalDateTime endTime; // 活动结束时间
    private String status; // 状态: ACTIVE(有效), INACTIVE(无效)
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}