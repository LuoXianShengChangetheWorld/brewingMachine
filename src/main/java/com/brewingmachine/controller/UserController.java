package com.brewingmachine.controller;

import com.brewingmachine.dto.Result;
import com.brewingmachine.dto.request.WeChatLoginRequest;
import com.brewingmachine.dto.request.BasicLoginRequest;
import com.brewingmachine.dto.request.UpdateUserInfoRequest;
import com.brewingmachine.dto.request.UpdateAvatarRequest;
import com.brewingmachine.dto.request.BindPhoneRequest;
import com.brewingmachine.dto.request.ChangePasswordRequest;
import com.brewingmachine.dto.request.BindReferrerRequest;
import com.brewingmachine.dto.response.UserInfoResponse;
import com.brewingmachine.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/user")
@RequiredArgsConstructor
public class UserController {

    private final AuthService authService;

    @GetMapping("/info")
    public Result<UserInfoResponse> getUserInfo(@RequestHeader("Authorization") String token) {
        try {
            UserInfoResponse userInfo = authService.getUserInfoByToken(token);
            return Result.success(userInfo);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/info/set")
    public Result<UserInfoResponse> updateUserInfo(@RequestHeader("Authorization") String token,
                                                   @RequestBody UpdateUserInfoRequest request) {
        try {
            Long userId = authService.getUserIdByToken(token);
            UserInfoResponse userInfo = authService.updateUserInfo(userId, request.getNickName(), request.getAvatar());
            return Result.success(userInfo);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/avatar/set")
    public Result<UserInfoResponse> updateAvatar(@RequestHeader("Authorization") String token,
                                                @RequestBody UpdateAvatarRequest request) {
        try {
            Long userId = authService.getUserIdByToken(token);
            UserInfoResponse userInfo = authService.updateUserInfo(userId, null, request.getAvatar());
            return Result.success(userInfo);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/phone/set")
    public Result<UserInfoResponse> bindPhone(@RequestHeader("Authorization") String token,
                                            @RequestBody BindPhoneRequest request) {
        try {
            Long userId = authService.getUserIdByToken(token);
            UserInfoResponse userInfo = authService.bindPhone(userId, request.getPhone(), request.getCode());
            return Result.success(userInfo);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/password/set")
    public Result<Void> changePassword(@RequestHeader("Authorization") String token,
                                     @RequestBody ChangePasswordRequest request) {
        try {
            Long userId = authService.getUserIdByToken(token);
            authService.changePassword(userId, request.getOldPassword(), request.getNewPassword());
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/member/referrer/bind")
    public Result<Void> bindReferrer(@RequestHeader("Authorization") String token,
                                   @RequestBody BindReferrerRequest request) {
        try {
            Long userId = authService.getUserIdByToken(token);
            authService.bindReferrer(userId, request.getReferrerId());
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}