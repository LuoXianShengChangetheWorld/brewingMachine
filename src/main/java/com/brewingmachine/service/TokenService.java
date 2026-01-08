package com.brewingmachine.service;

import com.brewingmachine.mapper.UserMapper;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.security.Key;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@Service
public class TokenService {

    // JWT是无状态的，不需要UserMapper来操作token
    // @Autowired
    // private UserMapper userMapper;

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.expire-hours}")
    private Long expireHours;

    @Value("${jwt.issuer}")
    private String issuer;

    private Key getSigningKey() {
        byte[] keyBytes = jwtSecret.getBytes();
        return Keys.hmacShaKeyFor(keyBytes);
    }

    /**
     * 生成JWT token
     */
    public String generateToken(Long userId) {
        LocalDateTime expireTime = LocalDateTime.now().plusHours(expireHours);
        Date expireDate = Date.from(expireTime.atZone(ZoneId.systemDefault()).toInstant());
        Date now = new Date();

        // 构建JWT声明
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);

        // 生成JWT token
        String token = Jwts.builder()
                .setClaims(claims)
                .setIssuer(issuer)
                .setIssuedAt(now)
                .setExpiration(expireDate)
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();

        log.info("生成JWT token，用户ID: {}", userId);
        return token;
    }

    /**
     * 验证token
     */
    public boolean validateToken(String token) {
        try {
            Claims claims = parseToken(token);
            // 检查token是否过期
            return claims.getExpiration().after(new Date());
        } catch (Exception e) {
            log.warn("验证token失败: {}", e.getMessage());
            return false;
        }
    }

    /**
     * 解析token获取声明
     */
    private Claims parseToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    /**
     * 获取token对应的用户ID
     */
    public Long getUserIdFromToken(String token) {
        try {
            Claims claims = parseToken(token);
            return claims.get("userId", Long.class);
        } catch (Exception e) {
            log.warn("获取用户ID失败: {}", e.getMessage());
            return null;
        }
    }

    /**
     * 验证token并返回用户ID
     */
    public Map<String, Object> validateTokenAndGetUser(String token) {
        Map<String, Object> result = new HashMap<>();

        try {
            Claims claims = parseToken(token);
            // 检查token是否过期
            if (claims.getExpiration().after(new Date())) {
                result.put("valid", true);
                result.put("userId", claims.get("userId", Long.class));
            } else {
                result.put("valid", false);
                result.put("message", "token已过期");
            }
        } catch (Exception e) {
            result.put("valid", false);
            result.put("message", "token无效");
        }

        return result;
    }

    /**
     * 移除token
     * JWT是无状态的，不需要在数据库中清除token
     * 这里只是提供一个接口，实际操作是客户端删除token
     */
    public void removeToken(String token) {
        // JWT是无状态的，不需要在数据库中清除token
        log.info("移除JWT token");
    }

    /**
     * 刷新token过期时间
     */
    public String refreshToken(String token) {
        try {
            Claims claims = parseToken(token);
            Long userId = claims.get("userId", Long.class);
            if (userId != null) {
                // 生成新的token
                return generateToken(userId);
            }
            return null;
        } catch (Exception e) {
            log.warn("刷新token失败: {}", e.getMessage());
            return null;
        }
    }
}
