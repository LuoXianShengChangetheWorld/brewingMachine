package com.brewingmachine.service;

import com.brewingmachine.entity.Permission;
import com.brewingmachine.mapper.PermissionMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class PermissionService {

    private final PermissionMapper permissionMapper;

    public PermissionService(PermissionMapper permissionMapper) {
        this.permissionMapper = permissionMapper;
    }

    @Transactional
    public Permission createPermission(Permission permission) {
        permissionMapper.insert(permission);
        return permissionMapper.selectById(permission.getId());
    }

    @Transactional
    public Permission updatePermission(Permission permission) {
        permissionMapper.update(permission);
        return permissionMapper.selectById(permission.getId());
    }

    @Transactional
    public void deletePermission(Long id) {
        permissionMapper.deleteById(id);
    }

    public Permission getPermissionById(Long id) {
        return permissionMapper.selectById(id);
    }

    public List<Permission> getAllPermissions() {
        return permissionMapper.selectAll();
    }

    public List<Permission> getPermissionsByRoleId(Long roleId) {
        return permissionMapper.selectByRoleId(roleId);
    }
}
