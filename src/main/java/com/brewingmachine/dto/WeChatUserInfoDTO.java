package com.brewingmachine.dto;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 微信用户信息DTO
 */
@Data
public class WeChatUserInfoDTO {

    private String openid;

    private String nickname;

    private String sex;

    private String province;

    private String city;

    private String country;

    private String headimgurl;

    private String privilege;

    private String unionid;
}
