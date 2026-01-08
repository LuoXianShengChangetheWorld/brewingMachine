package com.brewingmachine.controller;

import com.brewingmachine.dto.Result;
import com.brewingmachine.entity.Role;
import com.brewingmachine.service.RoleService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/role")
@RequiredArgsConstructor
public class RoleController {

    private final RoleService roleService;

    @PostMapping
    public Result<Role> createRole(@RequestBody Role role) {
        try {
            Role createdRole = roleService.createRole(role);
            return Result.success(createdRole);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @PutMapping
    public Result<Role> updateRole(@RequestBody Role role) {
        try {
            Role updatedRole = roleService.updateRole(role);
            return Result.success(updatedRole);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteRole(@PathVariable Long id) {
        try {
            roleService.deleteRole(id);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/{id}")
    public Result<Role> getRoleById(@PathVariable Long id) {
        try {
            Role role = roleService.getRoleById(id);
            return Result.success(role);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping
    public Result<List<Role>> getAllRoles() {
        try {
            List<Role> roles = roleService.getAllRoles();
            return Result.success(roles);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/code/{roleCode}")
    public Result<Role> getRoleByCode(@PathVariable String roleCode) {
        try {
            Role role = roleService.getRoleByCode(roleCode);
            return Result.success(role);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/user/{userId}")
    public Result<List<Role>> getRolesByUserId(@PathVariable Long userId) {
        try {
            List<Role> roles = roleService.getRolesByUserId(userId);
            return Result.success(roles);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
