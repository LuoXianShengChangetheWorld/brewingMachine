package com.brewingmachine.service;

import com.brewingmachine.dto.WeChatLoginResultDTO;
import com.brewingmachine.dto.WeChatUserInfoDTO;
import com.brewingmachine.dto.response.UserInfoResponse;
import com.brewingmachine.entity.User;
import com.brewingmachine.entity.UserAuth;
import com.brewingmachine.mapper.UserMapper;
import com.brewingmachine.mapper.UserAuthMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
public class AuthService {

    private final UserMapper userMapper;
    private final UserAuthMapper userAuthMapper;
    private final WeChatLoginService weChatLoginService;

    public AuthService(UserMapper userMapper, UserAuthMapper userAuthMapper, WeChatLoginService weChatLoginService) {
        this.userMapper = userMapper;
        this.userAuthMapper = userAuthMapper;
        this.weChatLoginService = weChatLoginService;
    }

    @Transactional
    public UserInfoResponse loginByWeChat(String code) {
        WeChatLoginResultDTO loginResult = weChatLoginService.handleCallback(code);
        if (!loginResult.isSuccess()) {
            throw new RuntimeException("微信登录失败：" + loginResult.getMessage());
        }

        User user = userMapper.findById(loginResult.getUserId());
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        String token = generateToken();
        updateUserToken(user.getId(), token);
        
        UserInfoResponse response = convertToUserInfoResponse(user);
        response.setToken(token);
        return response;
    }

    @Transactional
    public UserInfoResponse loginByBasic(String username, String password) {
        User user = userMapper.findByUsername(username);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        if (!password.equals(user.getPassword())) {
            throw new RuntimeException("密码错误");
        }

        String token = generateToken();
        updateUserToken(user.getId(), token);

        return convertToUserInfoResponse(user);
    }

    @Transactional
    public UserInfoResponse getUserInfo(Long userId) {
        User user = userMapper.findById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        return convertToUserInfoResponse(user);
    }

    @Transactional
    public UserInfoResponse updateUserInfo(Long userId, String nickName, String avatar) {
        User user = userMapper.findById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        if (nickName != null) {
            user.setNickname(nickName);
        }
        if (avatar != null) {
            user.setAvatar(avatar);
        }

        userMapper.update(user);

        return convertToUserInfoResponse(user);
    }

    @Transactional
    public UserInfoResponse getUserInfoByToken(String token) {
        User user = userMapper.findByToken(token);
        if (user == null) {
            throw new RuntimeException("token无效");
        }

        if (user.getTokenExpireTime() != null && user.getTokenExpireTime().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("token已过期");
        }

        return convertToUserInfoResponse(user);
    }

    public Long getUserIdByToken(String token) {
        User user = userMapper.findByToken(token);
        if (user == null) {
            throw new RuntimeException("token无效");
        }

        if (user.getTokenExpireTime() != null && user.getTokenExpireTime().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("token已过期");
        }

        return user.getId();
    }

    @Transactional
    public UserInfoResponse bindPhone(Long userId, String phone, String code) {
        User user = userMapper.findById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        // 验证短信验证码（这里需要实现短信验证逻辑）
        if (!verifySmsCode(phone, code)) {
            throw new RuntimeException("验证码错误");
        }

        // 检查手机号是否已被使用
        User existUser = userMapper.findByPhone(phone);
        if (existUser != null && !existUser.getId().equals(userId)) {
            throw new RuntimeException("手机号已被使用");
        }

        user.setPhone(phone);
        userMapper.update(user);

        return convertToUserInfoResponse(user);
    }

    @Transactional
    public void changePassword(Long userId, String oldPassword, String newPassword) {
        User user = userMapper.findById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        if (!oldPassword.equals(user.getPassword())) {
            throw new RuntimeException("原密码错误");
        }

        user.setPassword(newPassword);
        userMapper.update(user);
    }

    @Transactional
    public void bindReferrer(Long userId, Long referrerId) {
        User user = userMapper.findById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        if (user.getParentUserId() != null) {
            throw new RuntimeException("用户已有上级推荐人");
        }

        User referrer = userMapper.findById(referrerId);
        if (referrer == null) {
            throw new RuntimeException("推荐人不存在");
        }

        user.setParentUserId(referrerId);
        userMapper.update(user);
    }

    @Transactional
    public void updateUserRole(Long userId, String role) {
        User user = userMapper.findById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        user.setRole(role);
        userMapper.update(user);
    }



    private boolean verifySmsCode(String phone, String code) {
        // TODO: 实现短信验证码验证逻辑
        // 这里应该调用短信服务验证验证码是否正确
        return true; // 临时返回true，实际需要实现验证逻辑
    }

    private String generateToken() {
        return UUID.randomUUID().toString().replace("-", "");
    }

    private void updateUserToken(Long userId, String token) {
        LocalDateTime expireTime = LocalDateTime.now().plusDays(7);
        userMapper.updateToken(userId, token, expireTime);
        userMapper.updateLastLoginTime(userId, LocalDateTime.now());
    }

    private UserInfoResponse convertToUserInfoResponse(User user) {
        UserInfoResponse response = new UserInfoResponse();
        response.setId(user.getId().toString());
        response.setNickName(user.getNickname());
        response.setAvatar(user.getAvatar());
        response.setPhone(user.getPhone());
        response.setBalance(user.getBalance() != null ? user.getBalance().doubleValue() : 0.0);
        response.setIntegral(user.getPoints() != null ? user.getPoints() : 0L);
        response.setRole(user.getRole());
        response.setToken(user.getToken());
        return response;
    }
}