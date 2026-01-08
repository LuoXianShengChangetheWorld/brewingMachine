package com.brewingmachine.controller;

import com.brewingmachine.dto.Result;
import com.brewingmachine.entity.Permission;
import com.brewingmachine.service.PermissionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/permission")
@RequiredArgsConstructor
public class PermissionController {

    private final PermissionService permissionService;

    @PostMapping
    public Result<Permission> createPermission(@RequestBody Permission permission) {
        try {
            Permission createdPermission = permissionService.createPermission(permission);
            return Result.success(createdPermission);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @PutMapping
    public Result<Permission> updatePermission(@RequestBody Permission permission) {
        try {
            Permission updatedPermission = permissionService.updatePermission(permission);
            return Result.success(updatedPermission);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public Result<Void> deletePermission(@PathVariable Long id) {
        try {
            permissionService.deletePermission(id);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/{id}")
    public Result<Permission> getPermissionById(@PathVariable Long id) {
        try {
            Permission permission = permissionService.getPermissionById(id);
            return Result.success(permission);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping
    public Result<List<Permission>> getAllPermissions() {
        try {
            List<Permission> permissions = permissionService.getAllPermissions();
            return Result.success(permissions);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/role/{roleId}")
    public Result<List<Permission>> getPermissionsByRoleId(@PathVariable Long roleId) {
        try {
            List<Permission> permissions = permissionService.getPermissionsByRoleId(roleId);
            return Result.success(permissions);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
