package com.brewingmachine.dto;

import lombok.Data;

/**
 * 微信登录结果DTO
 */
@Data
public class WeChatLoginResultDTO {

    private boolean success;

    private String message;

    private String token;

    private Long userId;

    private String nickname;

    private String avatar;

    private Boolean isNewUser;
}
