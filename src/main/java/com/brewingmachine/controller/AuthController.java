package com.brewingmachine.controller;

import com.brewingmachine.dto.Result;
import com.brewingmachine.dto.request.WeChatLoginRequest;
import com.brewingmachine.dto.request.BasicLoginRequest;
import com.brewingmachine.dto.response.UserInfoResponse;
import com.brewingmachine.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/login")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/wx/app")
    public Result<UserInfoResponse> weChatLogin(@RequestBody WeChatLoginRequest request) {
        try {
            UserInfoResponse userInfo = authService.loginByWeChat(request.getCode());
            return Result.success(userInfo);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/basic")
    public Result<UserInfoResponse> basicLogin(@RequestBody BasicLoginRequest request) {
        try {
            UserInfoResponse userInfo = authService.loginByBasic(request.getUsername(), request.getPassword());
            return Result.success(userInfo);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/token")
    public Result<UserInfoResponse> loginByToken(@RequestHeader("Authorization") String token) {
        try {
            // 验证token并获取用户信息
            UserInfoResponse userInfo = authService.getUserInfoByToken(token);
            return Result.success(userInfo);
        } catch (Exception e) {
            return Result.error("登录已过期");
        }
    }
}