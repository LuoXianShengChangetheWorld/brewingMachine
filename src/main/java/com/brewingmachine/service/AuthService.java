package com.brewingmachine.service;

import com.brewingmachine.dto.WeChatLoginResultDTO;
import com.brewingmachine.dto.WeChatUserInfoDTO;
import com.brewingmachine.dto.response.UserInfoResponse;
import com.brewingmachine.entity.User;
import com.brewingmachine.entity.UserAuth;
import com.brewingmachine.entity.UserRole;
import com.brewingmachine.entity.Role;
import com.brewingmachine.mapper.UserMapper;
import com.brewingmachine.mapper.UserAuthMapper;
import com.brewingmachine.mapper.UserRoleMapper;
import com.brewingmachine.mapper.RoleMapper;
import com.brewingmachine.service.TokenService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class AuthService {

    private final UserMapper userMapper;
    private final UserAuthMapper userAuthMapper;
    private final UserRoleMapper userRoleMapper;
    private final RoleMapper roleMapper;
    private final WeChatLoginService weChatLoginService;
    private final TokenService tokenService;

    public AuthService(UserMapper userMapper, UserAuthMapper userAuthMapper, UserRoleMapper userRoleMapper, RoleMapper roleMapper, WeChatLoginService weChatLoginService, TokenService tokenService) {
        this.userMapper = userMapper;
        this.userAuthMapper = userAuthMapper;
        this.userRoleMapper = userRoleMapper;
        this.roleMapper = roleMapper;
        this.weChatLoginService = weChatLoginService;
        this.tokenService = tokenService;
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

        String token = tokenService.generateToken(user.getId());
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

        String token = tokenService.generateToken(user.getId());
        updateUserToken(user.getId(), token);

        UserInfoResponse response = convertToUserInfoResponse(user);
        response.setToken(token);
        return response;
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

    public UserInfoResponse getUserInfoByToken(String token) {
        // 使用TokenService验证JWT
        if (!tokenService.validateToken(token)) {
            throw new RuntimeException("token无效或已过期");
        }
        Long userId = tokenService.getUserIdFromToken(token);
        User user = userMapper.findById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        return convertToUserInfoResponse(user);
    }

    public Long getUserIdByToken(String token) {
        // 使用TokenService验证JWT
        if (!tokenService.validateToken(token)) {
            throw new RuntimeException("token无效或已过期");
        }
        return tokenService.getUserIdFromToken(token);
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

        // 检查是否是代理商角色
        if ("agent".equals(role)) {
            // 检查用户是否已经有代理商角色
            List<UserRole> userRoles = userRoleMapper.selectByUserId(userId);
            for (UserRole userRole : userRoles) {
                Role roleInfo = roleMapper.selectById(userRole.getRoleId());
                if (roleInfo != null && "agent".equals(roleInfo.getRoleCode())) {
                    throw new RuntimeException("用户已经是代理商角色，不能重复绑定");
                }
            }
        }

        // 保留原角色字段以兼容现有代码
        user.setRole(role);
        userMapper.update(user);
        
        // 如果是新角色，添加到用户角色关系表
        Role roleInfo = roleMapper.selectByRoleCode(role);
        if (roleInfo != null) {
            UserRole existingUserRole = userRoleMapper.selectByUserIdAndRoleId(userId, roleInfo.getId());
            if (existingUserRole == null) {
                UserRole userRole = new UserRole();
                userRole.setUserId(userId);
                userRole.setRoleId(roleInfo.getId());
                userRole.setStatus(1);
                userRoleMapper.insert(userRole);
            }
        }
    }

    @Transactional
    public void updateUserRoleAndHierarchy(Long userId, String role, String hierarchy) {
        User user = userMapper.findById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        // 检查是否是代理商角色
        if ("agent".equals(role)) {
            // 检查用户是否已经有代理商角色
            List<UserRole> userRoles = userRoleMapper.selectByUserId(userId);
            for (UserRole userRole : userRoles) {
                Role roleInfo = roleMapper.selectById(userRole.getRoleId());
                if (roleInfo != null && "agent".equals(roleInfo.getRoleCode())) {
                    throw new RuntimeException("用户已经是代理商角色，不能重复绑定");
                }
            }
        }

        // 保留原角色字段以兼容现有代码
        user.setRole(role);
        user.setHierarchy(hierarchy);
        userMapper.update(user);
        
        // 如果是新角色，添加到用户角色关系表
        Role roleInfo = roleMapper.selectByRoleCode(role);
        if (roleInfo != null) {
            UserRole existingUserRole = userRoleMapper.selectByUserIdAndRoleId(userId, roleInfo.getId());
            if (existingUserRole == null) {
                UserRole userRole = new UserRole();
                userRole.setUserId(userId);
                userRole.setRoleId(roleInfo.getId());
                userRole.setStatus(1);
                userRoleMapper.insert(userRole);
            }
        }
    }



    private boolean verifySmsCode(String phone, String code) {
        // TODO: 实现短信验证码验证逻辑
        // 这里应该调用短信服务验证验证码是否正确
        return true; // 临时返回true，实际需要实现验证逻辑
    }



    private void updateUserToken(Long userId, String token) {
        // JWT是无状态的，不需要在数据库中存储token
        // 只需更新最后登录时间
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
        return response;
    }
}