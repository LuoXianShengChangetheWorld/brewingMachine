package com.brewingmachine.constant;

/**
 * 微信相关常量
 */
public class WeChatConstants {

    public static final String BASE_URL = "https://api.weixin.qq.com";

    public static final String ACCESS_TOKEN_URL = BASE_URL + "/sns/oauth2/access_token";

    public static final String REFRESH_TOKEN_URL = BASE_URL + "/sns/oauth2/refresh_token";

    public static final String USER_INFO_URL = BASE_URL + "/sns/userinfo";

    public static final String CHECK_TOKEN_URL = BASE_URL + "/sns/auth";

    public static final String DEFAULT_SCOPE = "snsapi_login";

    public static final String MP_SCOPE = "snsapi_userinfo";

    public static final int ACCESS_TOKEN_EXPIRE = 7200;

    public static final int REFRESH_TOKEN_EXPIRE = 30 * 24 * 3600;

    public static final String DEFAULT_STATE = "STATE";
}
