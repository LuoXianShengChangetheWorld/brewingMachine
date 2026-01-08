package com.brewingmachine.controller;

import com.brewingmachine.dto.WeChatLoginResultDTO;
import com.brewingmachine.service.TokenService;
import com.brewingmachine.service.WeChatLoginService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/wechat")
@CrossOrigin(origins = "*")
public class WeChatLoginController {

    @Autowired
    private WeChatLoginService weChatLoginService;

    @Autowired
    private TokenService tokenService;

    /**
     * 获取微信扫码登录授权URL
     */
    @GetMapping("/auth/url")
    public Map<String, Object> getAuthUrl() {
        return weChatLoginService.getAuthUrl();
    }

    /**
     * 获取微信小程序授权URL
     */
    @GetMapping("/mp/auth/url")
    public Map<String, Object> getMpAuthUrl() {
        return weChatLoginService.getMpAuthUrl();
    }

    /**
     * 微信扫码登录回调
     */
    @GetMapping("/callback")
    public WeChatLoginResultDTO callback(@RequestParam String code, @RequestParam String state) {
        log.info("微信登录回调，code: {}, state: {}", code, state);
        return weChatLoginService.handleCallback(code);
    }

    /**
     * 验证token
     */
    @GetMapping("/token/validate")
    public Map<String, Object> validateToken(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        Map<String, Object> result = new HashMap<>();

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            result.put("valid", false);
            result.put("message", "未提供token");
            return result;
        }

        String token = authHeader.substring(7).trim();
        return tokenService.validateTokenAndGetUser(token);
    }

    /**
     * 刷新token
     */
    @PostMapping("/token/refresh")
    public Map<String, Object> refreshToken(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        Map<String, Object> result = new HashMap<>();

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            result.put("success", false);
            result.put("message", "未提供token");
            return result;
        }

        String token = authHeader.substring(7);
        String newToken = tokenService.refreshToken(token);

        if (newToken != null) {
            result.put("success", true);
            result.put("message", "刷新成功");
            result.put("token", newToken);
        } else {
            result.put("success", false);
            result.put("message", "刷新失败");
        }
        return result;
    }

    /**
     * 退出登录
     */
    @PostMapping("/logout")
    public Map<String, Object> logout(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        Map<String, Object> result = new HashMap<>();

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7).trim();
            tokenService.removeToken(token);
        }

        result.put("success", true);
        result.put("message", "退出成功");
        return result;
    }
}
