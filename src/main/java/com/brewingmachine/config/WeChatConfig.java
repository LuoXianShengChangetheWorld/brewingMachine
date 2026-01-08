package com.brewingmachine.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;
import com.brewingmachine.constant.WeChatConstants;

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
               "&scope=" + WeChatConstants.DEFAULT_SCOPE +
               "&state=" + state +
               "#wechat_redirect";
    }

    public String getMpAuthUrl() {
        return "https://open.weixin.qq.com/connect/oauth2/authorize" +
               "?appid=" + appId +
               "&redirect_uri=" + redirectUri +
               "&response_type=code" +
               "&scope=" + WeChatConstants.MP_SCOPE +
               "&state=" + state +
               "#wechat_redirect";
    }
}
