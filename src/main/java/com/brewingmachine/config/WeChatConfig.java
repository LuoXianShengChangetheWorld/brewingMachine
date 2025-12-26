package com.brewingmachine.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "wechat")
public class WeChatConfig {

    private String appId;

    private String appSecret;

    private String redirectUri;

    private String scope;

    private String state;

    public String getAuthUrl() {
        return "https://open.weixin.qq.com/connect/qrconnect" +
               "?appid=" + appId +
               "&redirect_uri=" + redirectUri +
               "&response_type=code" +
               "&scope=" + scope +
               "&state=" + state +
               "#wechat_redirect";
    }

    public String getMpAuthUrl() {
        return "https://open.weixin.qq.com/connect/oauth2/authorize" +
               "?appid=" + appId +
               "&redirect_uri=" + redirectUri +
               "&response_type=code" +
               "&scope=" + scope +
               "&state=" + state +
               "#wechat_redirect";
    }
}
