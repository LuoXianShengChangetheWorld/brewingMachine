package com.brewingmachine.service;

import com.brewingmachine.mapper.UserMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Service
public class TokenService {

    @Autowired
    private UserMapper userMapper;

    private static final long TOKEN_EXPIRE_HOURS = 24;

    private static final Map<String, TokenInfo> tokenStore = new ConcurrentHashMap<>();

    private static class TokenInfo {
        private Long userId;
        private LocalDateTime expireTime;

        public TokenInfo(Long userId, LocalDateTime expireTime) {
            this.userId = userId;
            this.expireTime = expireTime;
        }
    }

    /**
     * 生成token
     */
    public String generateToken(Long userId) {
        String token = UUID.randomUUID().toString().replace("-", "");
        TokenInfo tokenInfo = new TokenInfo(userId, LocalDateTime.now().plusHours(TOKEN_EXPIRE_HOURS));
        tokenStore.put(token, tokenInfo);

        // 更新数据库中的token
        userMapper.updateToken(userId, token, tokenInfo.expireTime);

        log.info("生成token，用户ID: {}", userId);
        return token;
    }

    /**
     * 验证token
     */
    public boolean validateToken(String token) {
        if (token == null || token.isEmpty()) {
            return false;
        }

        TokenInfo tokenInfo = tokenStore.get(token);
        if (tokenInfo == null) {
            return false;
        }

        if (LocalDateTime.now().isAfter(tokenInfo.expireTime)) {
            tokenStore.remove(token);
            return false;
        }

        return true;
    }

    /**
     * 获取token对应的用户ID
     */
    public Long getUserIdByToken(String token) {
        if (!validateToken(token)) {
            return null;
        }
        return tokenStore.get(token).userId;
    }

    /**
     * 验证token并返回用户ID
     */
    public Map<String, Object> validateTokenAndGetUser(String token) {
        Map<String, Object> result = new HashMap<>();

        if (!validateToken(token)) {
            result.put("valid", false);
            result.put("message", "token无效或已过期");
            return result;
        }

        TokenInfo tokenInfo = tokenStore.get(token);
        result.put("valid", true);
        result.put("userId", tokenInfo.userId);
        return result;
    }

    /**
     * 移除token
     */
    public void removeToken(String token) {
        if (token != null) {
            TokenInfo tokenInfo = tokenStore.get(token);
            if (tokenInfo != null) {
                userMapper.clearToken(tokenInfo.userId);
            }
            tokenStore.remove(token);
        }
    }

    /**
     * 刷新token过期时间
     */
    public boolean refreshTokenExpireTime(String token) {
        if (!validateToken(token)) {
            return false;
        }

        TokenInfo tokenInfo = tokenStore.get(token);
        tokenInfo.expireTime = LocalDateTime.now().plusHours(TOKEN_EXPIRE_HOURS);
        userMapper.updateTokenExpireTime(tokenInfo.userId, tokenInfo.expireTime);

        return true;
    }
}
