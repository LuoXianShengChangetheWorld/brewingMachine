package com.brewingmachine.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Coupon {
    private Long id;
    private String name;
    private String description;
    private String type; // 折扣类型: PERCENTAGE(百分比), FIXED_AMOUNT(固定金额)
    private Double value; // 折扣值: 百分比时为0-100的数值，固定金额时为实际金额
    private Double minAmount; // 使用最低金额要求
    private Integer maxDiscount; // 最大折扣金额(百分比折扣时有效)
    private Integer totalCount; // 发放总数量
    private Integer usedCount; // 已使用数量
    private Integer perUserLimit; // 每人限领数量，0表示不限制
    private LocalDateTime startTime; // 有效期开始时间
    private LocalDateTime endTime; // 有效期结束时间
    private String status; // 状态: ACTIVE(有效), INACTIVE(无效)
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}