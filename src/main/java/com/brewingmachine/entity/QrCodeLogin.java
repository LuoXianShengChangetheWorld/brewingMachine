package com.brewingmachine.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 二维码登录实体类
 */
@Data
public class QrCodeLogin {

    /**
     * 主键ID
     */
    private Long id;

    /**
     * 二维码唯一标识
     */
    private String qrToken;

    /**
     * 二维码状态：0-未扫描，1-已扫描未确认，2-已确认登录，3-已过期
     */
    private Integer status;

    /**
     * 用户ID（确认登录后存储）
     */
    private Long userId;

    /**
     * 用户信息（JSON格式）
     */
    private String userInfo;

    /**
     * 创建时间
     */
    private LocalDateTime createTime;

    /**
     * 过期时间
     */
    private LocalDateTime expireTime;

    /**
     * 扫描时间
     */
    private LocalDateTime scanTime;

    /**
     * 确认时间
     */
    private LocalDateTime confirmTime;
}
