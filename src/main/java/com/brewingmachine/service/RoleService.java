package com.brewingmachine.service;

import com.brewingmachine.entity.Role;
import com.brewingmachine.mapper.RoleMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class RoleService {

    private final RoleMapper roleMapper;

    public RoleService(RoleMapper roleMapper) {
        this.roleMapper = roleMapper;
    }

    @Transactional
    public Role createRole(Role role) {
        roleMapper.insert(role);
        return roleMapper.selectById(role.getId());
    }

    @Transactional
    public Role updateRole(Role role) {
        roleMapper.update(role);
        return roleMapper.selectById(role.getId());
    }

    @Transactional
    public void deleteRole(Long id) {
        roleMapper.deleteById(id);
    }

    public Role getRoleById(Long id) {
        return roleMapper.selectById(id);
    }

    public List<Role> getAllRoles() {
        return roleMapper.selectAll();
    }

    public Role getRoleByCode(String roleCode) {
        return roleMapper.selectByRoleCode(roleCode);
    }

    public List<Role> getRolesByUserId(Long userId) {
        return roleMapper.selectByUserId(userId);
    }
}
