package com.brewingmachine.dto;

import lombok.Data;

/**
 * 微信Access Token DTO
 */
@Data
public class WeChatAccessTokenDTO {

    private String access_token;

    private String expires_in;

    private String refresh_token;

    private String openid;

    private String scope;

    private String unionid;

    private Integer errcode;

    private String errmsg;
}
