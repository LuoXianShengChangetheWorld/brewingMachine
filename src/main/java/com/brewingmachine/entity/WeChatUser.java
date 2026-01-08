package com.brewingmachine.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 微信用户实体类
 */
@Data
public class WeChatUser {

    private Long id;

    private String openid;

    private String unionid;

    private String sessionKey;

    private String nickname;

    private String avatar;

    private Integer gender;

    private String city;

    private String province;

    private String country;

    private String language;

    private Long userId;

    private LocalDateTime bindTime;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
