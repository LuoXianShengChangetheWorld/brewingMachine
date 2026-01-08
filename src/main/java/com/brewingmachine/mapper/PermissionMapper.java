package com.brewingmachine.mapper;

import com.brewingmachine.entity.Permission;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface PermissionMapper {
    int insert(Permission permission);
    int update(Permission permission);
    int deleteById(Long id);
    Permission selectById(Long id);
    List<Permission> selectAll();
    List<Permission> selectByRoleId(Long roleId);
}