package com.brewingmachine.service;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.brewingmachine.config.WeChatConfig;
import com.brewingmachine.constant.WeChatConstants;
import com.brewingmachine.dto.WeChatAccessTokenDTO;
import com.brewingmachine.dto.WeChatLoginResultDTO;
import com.brewingmachine.dto.WeChatUserInfoDTO;
import com.brewingmachine.entity.User;
import com.brewingmachine.entity.WeChatUser;
import com.brewingmachine.mapper.UserMapper;
import com.brewingmachine.mapper.WeChatUserMapper;
import com.brewingmachine.util.HttpClientUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
public class WeChatLoginService {

    @Autowired
    private WeChatConfig weChatConfig;

    @Autowired
    private WeChatUserMapper weChatUserMapper;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private TokenService tokenService;

    /**
     * 获取微信授权URL
     */
    public Map<String, Object> getAuthUrl() {
        Map<String, Object> result = new HashMap<>();
        result.put("authUrl", weChatConfig.getAuthUrl());
        result.put("appId", weChatConfig.getAppId());
        return result;
    }

    /**
     * 获取微信小程序授权URL
     */
    public Map<String, Object> getMpAuthUrl() {
        Map<String, Object> result = new HashMap<>();
        result.put("authUrl", weChatConfig.getMpAuthUrl());
        result.put("appId", weChatConfig.getAppId());
        return result;
    }

    /**
     * 微信扫码登录回调处理
     */
    @Transactional
    public WeChatLoginResultDTO handleCallback(String code) {
        WeChatLoginResultDTO result = new WeChatLoginResultDTO();

        try {
            if (code == null || code.isEmpty()) {
                result.setSuccess(false);
                result.setMessage("授权失败：未获取到授权码");
                return result;
            }

            // 1. 通过code获取access_token和openid
            WeChatAccessTokenDTO accessToken = getAccessToken(code);
            if (accessToken.getErrcode() != null && accessToken.getErrcode() != 0) {
                result.setSuccess(false);
                result.setMessage("获取授权信息失败：" + accessToken.getErrmsg());
                return result;
            }

            // 2. 获取用户信息
            WeChatUserInfoDTO userInfo = getUserInfo(accessToken.getAccess_token(), accessToken.getOpenid());
            if (userInfo == null) {
                result.setSuccess(false);
                result.setMessage("获取用户信息失败");
                return result;
            }

            // 3. 查找或创建用户
            WeChatUser weChatUser = weChatUserMapper.findByOpenid(accessToken.getOpenid());
            boolean isNewUser = false;

            if (weChatUser == null) {
                // 新用户，创建用户账号
                User newUser = createUserFromWeChat(userInfo);
                userMapper.insert(newUser);

                // 绑定微信账号
                WeChatUser newWeChatUser = createWeChatUser(accessToken, userInfo, newUser.getId());
                weChatUserMapper.insert(newWeChatUser);

                weChatUser = newWeChatUser;
                isNewUser = true;
            } else {
                // 老用户，更新用户信息
                if (weChatUser.getUserId() != null) {
                    User existingUser = userMapper.findById(weChatUser.getUserId());
                    if (existingUser != null) {
                        updateUserFromWeChat(existingUser, userInfo);
                        userMapper.update(existingUser);
                    }
                }

                // 更新微信用户信息
                updateWeChatUser(weChatUser, accessToken, userInfo);
                weChatUserMapper.updateByUserId(weChatUser.getUserId(), weChatUser);
            }

            // 4. 生成登录token
            String token = tokenService.generateToken(weChatUser.getUserId());

            // 5. 更新最后登录时间
            userMapper.updateLastLoginTime(weChatUser.getUserId(), LocalDateTime.now());

            // 6. 返回结果
            result.setSuccess(true);
            result.setMessage("登录成功");
            result.setToken(token);
            result.setUserId(weChatUser.getUserId());
            result.setNickname(userInfo.getNickname());
            result.setAvatar(userInfo.getHeadimgurl());
            result.setIsNewUser(isNewUser);

            log.info("微信登录成功，openid: {}, userId: {}", accessToken.getOpenid(), weChatUser.getUserId());
            return result;

        } catch (Exception e) {
            log.error("微信登录处理失败", e);
            result.setSuccess(false);
            result.setMessage("登录失败：" + e.getMessage());
            return result;
        }
    }

    /**
     * 获取access_token
     */
    private WeChatAccessTokenDTO getAccessToken(String code) {
        String url = String.format("%s?appid=%s&secret=%s&code=%s&grant_type=authorization_code",
                WeChatConstants.ACCESS_TOKEN_URL,
                weChatConfig.getAppId(),
                weChatConfig.getAppSecret(),
                code);

        String response = HttpClientUtil.get(url);
        return JSON.parseObject(response, WeChatAccessTokenDTO.class);
    }

    /**
     * 获取用户信息
     */
    private WeChatUserInfoDTO getUserInfo(String accessToken, String openid) {
        String url = String.format("%s?access_token=%s&openid=%s&lang=zh_CN",
                WeChatConstants.USER_INFO_URL,
                accessToken,
                openid);

        String response = HttpClientUtil.get(url);
        JSONObject jsonObject = JSON.parseObject(response);

        if (jsonObject.getInteger("errcode") != null && jsonObject.getInteger("errcode") != 0) {
            log.error("获取用户信息失败：{}", jsonObject.getString("errmsg"));
            return null;
        }

        return JSON.parseObject(response, WeChatUserInfoDTO.class);
    }

    /**
     * 创建用户
     */
    private User createUserFromWeChat(WeChatUserInfoDTO userInfo) {
        User user = new User();
        user.setUsername("wechat_" + UUID.randomUUID().toString().substring(0, 8));
        user.setNickname(userInfo.getNickname());
        user.setAvatar(userInfo.getHeadimgurl());
        user.setGender("1".equals(userInfo.getSex()) ? 1 : ("2".equals(userInfo.getSex()) ? 2 : 0));
        user.setStatus(1);
        user.setCreateTime(LocalDateTime.now());
        user.setUpdateTime(LocalDateTime.now());
        return user;
    }

    /**
     * 更新用户信息
     */
    private void updateUserFromWeChat(User user, WeChatUserInfoDTO userInfo) {
        user.setNickname(userInfo.getNickname());
        user.setAvatar(userInfo.getHeadimgurl());
        user.setGender("1".equals(userInfo.getSex()) ? 1 : ("2".equals(userInfo.getSex()) ? 2 : 0));
        user.setUpdateTime(LocalDateTime.now());
    }

    /**
     * 创建微信用户绑定记录
     */
    private WeChatUser createWeChatUser(WeChatAccessTokenDTO accessToken, WeChatUserInfoDTO userInfo, Long userId) {
        WeChatUser weChatUser = new WeChatUser();
        weChatUser.setOpenid(accessToken.getOpenid());
        weChatUser.setUnionid(accessToken.getUnionid());
        weChatUser.setNickname(userInfo.getNickname());
        weChatUser.setAvatar(userInfo.getHeadimgurl());
        weChatUser.setGender("1".equals(userInfo.getSex()) ? 1 : ("2".equals(userInfo.getSex()) ? 2 : 0));
        weChatUser.setCity(userInfo.getCity());
        weChatUser.setProvince(userInfo.getProvince());
        weChatUser.setCountry(userInfo.getCountry());
        weChatUser.setLanguage("zh_CN");
        weChatUser.setUserId(userId);
        weChatUser.setBindTime(LocalDateTime.now());
        weChatUser.setCreateTime(LocalDateTime.now());
        weChatUser.setUpdateTime(LocalDateTime.now());
        return weChatUser;
    }

    /**
     * 更新微信用户信息
     */
    private void updateWeChatUser(WeChatUser weChatUser, WeChatAccessTokenDTO accessToken, WeChatUserInfoDTO userInfo) {
        weChatUser.setOpenid(accessToken.getOpenid());
        weChatUser.setUnionid(accessToken.getUnionid());
        weChatUser.setNickname(userInfo.getNickname());
        weChatUser.setAvatar(userInfo.getHeadimgurl());
        weChatUser.setGender("1".equals(userInfo.getSex()) ? 1 : ("2".equals(userInfo.getSex()) ? 2 : 0));
        weChatUser.setCity(userInfo.getCity());
        weChatUser.setProvince(userInfo.getProvince());
        weChatUser.setCountry(userInfo.getCountry());
        weChatUser.setUpdateTime(LocalDateTime.now());
    }

    /**
     * 刷新access_token
     */
    public WeChatAccessTokenDTO refreshToken(String refreshToken) {
        String url = String.format("%s?appid=%s&grant_type=refresh_token&refresh_token=%s",
                WeChatConstants.REFRESH_TOKEN_URL,
                weChatConfig.getAppId(),
                refreshToken);

        String response = HttpClientUtil.get(url);
        return JSON.parseObject(response, WeChatAccessTokenDTO.class);
    }

    /**
     * 验证access_token是否有效
     */
    public boolean checkToken(String accessToken, String openid) {
        String url = String.format("%s?access_token=%s&openid=%s",
                WeChatConstants.CHECK_TOKEN_URL,
                accessToken,
                openid);

        String response = HttpClientUtil.get(url);
        JSONObject jsonObject = JSON.parseObject(response);
        return jsonObject.getInteger("errcode") == 0;
    }

    /**
     * 微信小程序登录处理
     */
    @Transactional
    public WeChatLoginResultDTO handleMiniProgramLogin(String code) {
        WeChatLoginResultDTO result = new WeChatLoginResultDTO();

        try {
            if (code == null || code.isEmpty()) {
                result.setSuccess(false);
                result.setMessage("授权失败：未获取到登录凭证");
                return result;
            }

            // 1. 通过code获取openid和session_key
            Map<String, String> sessionInfo = getSessionInfo(code);
            if (sessionInfo == null || sessionInfo.get("errcode") != null) {
                result.setSuccess(false);
                result.setMessage("获取会话信息失败：" + sessionInfo.get("errmsg"));
                return result;
            }

            String openid = sessionInfo.get("openid");
            String sessionKey = sessionInfo.get("session_key");

            // 2. 查找或创建用户
            WeChatUser weChatUser = weChatUserMapper.findByOpenid(openid);
            boolean isNewUser = false;

            if (weChatUser == null) {
                // 新用户，创建用户账号
                User newUser = new User();
                newUser.setUsername("wxmp_" + UUID.randomUUID().toString().substring(0, 8));
                newUser.setStatus(1);
                newUser.setCreateTime(LocalDateTime.now());
                newUser.setUpdateTime(LocalDateTime.now());
                userMapper.insert(newUser);

                // 绑定微信账号
                WeChatUser newWeChatUser = new WeChatUser();
                newWeChatUser.setOpenid(openid);
                newWeChatUser.setSessionKey(sessionKey);
                newWeChatUser.setUserId(newUser.getId());
                newWeChatUser.setBindTime(LocalDateTime.now());
                newWeChatUser.setCreateTime(LocalDateTime.now());
                newWeChatUser.setUpdateTime(LocalDateTime.now());
                weChatUserMapper.insert(newWeChatUser);

                weChatUser = newWeChatUser;
                isNewUser = true;
            } else {
                // 老用户，更新session_key
                weChatUser.setSessionKey(sessionKey);
                weChatUser.setUpdateTime(LocalDateTime.now());
                weChatUserMapper.updateByUserId(weChatUser.getUserId(), weChatUser);

                // 更新最后登录时间
                userMapper.updateLastLoginTime(weChatUser.getUserId(), LocalDateTime.now());
            }

            // 3. 生成登录token
            String token = tokenService.generateToken(weChatUser.getUserId());

            // 4. 返回结果
            result.setSuccess(true);
            result.setMessage("登录成功");
            result.setToken(token);
            result.setUserId(weChatUser.getUserId());
            result.setIsNewUser(isNewUser);

            log.info("微信小程序登录成功，openid: {}, userId: {}", openid, weChatUser.getUserId());
            return result;

        } catch (Exception e) {
            log.error("微信小程序登录处理失败", e);
            result.setSuccess(false);
            result.setMessage("登录失败：" + e.getMessage());
            return result;
        }
    }

    /**
     * 通过code获取小程序session信息
     */
    private Map<String, String> getSessionInfo(String code) {
        String url = String.format("%s?appid=%s&secret=%s&js_code=%s&grant_type=%s",
                WeChatConstants.JSCODE2SESSION_URL,
                weChatConfig.getAppId(),
                weChatConfig.getAppSecret(),
                code,
                WeChatConstants.GRAND_TYPE);

        String response = HttpClientUtil.get(url);
        return JSON.parseObject(response, Map.class);
    }
}
