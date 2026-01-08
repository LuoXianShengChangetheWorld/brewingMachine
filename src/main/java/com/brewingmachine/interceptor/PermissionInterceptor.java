package com.brewingmachine.interceptor;

import com.brewingmachine.annotation.RequiresPermission;
import com.brewingmachine.annotation.RequiresRole;
import com.brewingmachine.entity.User;
import com.brewingmachine.entity.UserRole;
import com.brewingmachine.entity.Role;
import com.brewingmachine.entity.Permission;
import com.brewingmachine.mapper.UserMapper;
import com.brewingmachine.mapper.UserRoleMapper;
import com.brewingmachine.mapper.RoleMapper;
import com.brewingmachine.mapper.PermissionMapper;
import com.brewingmachine.service.TokenService;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.lang.reflect.Method;
import java.util.List;

@Component
public class PermissionInterceptor implements HandlerInterceptor {

    private final TokenService tokenService;
    private final UserMapper userMapper;
    private final UserRoleMapper userRoleMapper;
    private final RoleMapper roleMapper;
    private final PermissionMapper permissionMapper;

    public PermissionInterceptor(TokenService tokenService, UserMapper userMapper, UserRoleMapper userRoleMapper, RoleMapper roleMapper, PermissionMapper permissionMapper) {
        this.tokenService = tokenService;
        this.userMapper = userMapper;
        this.userRoleMapper = userRoleMapper;
        this.roleMapper = roleMapper;
        this.permissionMapper = permissionMapper;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 如果不是处理方法，直接通过
        if (!(handler instanceof HandlerMethod)) {
            return true;
        }

        HandlerMethod handlerMethod = (HandlerMethod) handler;
        Method method = handlerMethod.getMethod();

        // 检查是否有@RequiresRole注解
        RequiresRole requiresRole = method.getAnnotation(RequiresRole.class);
        if (requiresRole == null) {
            requiresRole = method.getDeclaringClass().getAnnotation(RequiresRole.class);
        }

        // 检查是否有@RequiresPermission注解
        RequiresPermission requiresPermission = method.getAnnotation(RequiresPermission.class);
        if (requiresPermission == null) {
            requiresPermission = method.getDeclaringClass().getAnnotation(RequiresPermission.class);
        }

        // 如果没有权限注解，直接通过
        if (requiresRole == null && requiresPermission == null) {
            return true;
        }

        // 获取token
        String token = request.getHeader("Authorization");
        if (!StringUtils.hasText(token)) {
            response.setStatus(HttpStatus.UNAUTHORIZED.value());
            response.getWriter().write("{\"code\":401,\"msg\":\"缺少Authorization头\",\"data\":null}");
            return false;
        }

        // 验证token并获取用户ID
        if (!tokenService.validateToken(token)) {
            response.setStatus(HttpStatus.UNAUTHORIZED.value());
            response.getWriter().write("{\"code\":401,\"msg\":\"token无效或已过期\",\"data\":null}");
            return false;
        }

        Long userId = tokenService.getUserIdFromToken(token);
        User user = userMapper.findById(userId);
        if (user == null) {
            response.setStatus(HttpStatus.UNAUTHORIZED.value());
            response.getWriter().write("{\"code\":401,\"msg\":\"用户不存在\",\"data\":null}");
            return false;
        }

        // 检查角色权限
        if (requiresRole != null) {
            if (!checkRolePermission(userId, requiresRole)) {
                response.setStatus(HttpStatus.FORBIDDEN.value());
                response.getWriter().write("{\"code\":403,\"msg\":\"无角色权限\",\"data\":null}");
                return false;
            }
        }

        // 检查功能权限
        if (requiresPermission != null) {
            if (!checkFunctionPermission(userId, requiresPermission)) {
                response.setStatus(HttpStatus.FORBIDDEN.value());
                response.getWriter().write("{\"code\":403,\"msg\":\"无功能权限\",\"data\":null}");
                return false;
            }
        }

        return true;
    }

    private boolean checkRolePermission(Long userId, RequiresRole requiresRole) {
        List<UserRole> userRoles = userRoleMapper.selectByUserId(userId);
        String[] requiredRoles = requiresRole.value();
        String logical = requiresRole.logical();

        if (userRoles == null || userRoles.isEmpty()) {
            return false;
        }

        if ("or".equalsIgnoreCase(logical)) {
            // 只要有一个角色匹配就通过
            for (UserRole userRole : userRoles) {
                // 获取角色信息
                Role role = roleMapper.selectById(userRole.getRoleId());
                if (role != null) {
                    for (String requiredRole : requiredRoles) {
                        if (requiredRole.equals(role.getRoleCode())) {
                            return true;
                        }
                    }
                }
            }
            return false;
        } else {
            // 所有角色都必须匹配
            for (String requiredRole : requiredRoles) {
                boolean hasRole = false;
                for (UserRole userRole : userRoles) {
                    // 获取角色信息
                    Role role = roleMapper.selectById(userRole.getRoleId());
                    if (role != null && requiredRole.equals(role.getRoleCode())) {
                        hasRole = true;
                        break;
                    }
                }
                if (!hasRole) {
                    return false;
                }
            }
            return true;
        }
    }

    private boolean checkFunctionPermission(Long userId, RequiresPermission requiresPermission) {
        List<UserRole> userRoles = userRoleMapper.selectByUserId(userId);
        String requiredPermission = requiresPermission.value();

        if (userRoles == null || userRoles.isEmpty()) {
            return false;
        }

        // 检查用户的所有角色是否有该权限
        for (UserRole userRole : userRoles) {
            List<Permission> permissions = permissionMapper.selectByRoleId(userRole.getRoleId());
            if (permissions != null) {
                for (Permission permission : permissions) {
                    if (requiredPermission.equals(permission.getPermissionCode())) {
                        return true;
                    }
                }
            }
        }

        return false;
    }
}