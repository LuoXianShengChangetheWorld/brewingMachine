package com.brewingmachine.mapper;

import com.brewingmachine.entity.UserRole;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface UserRoleMapper {
    int insert(UserRole userRole);
    int update(UserRole userRole);
    int deleteById(Long id);
    int deleteByUserId(Long userId);
    UserRole selectById(Long id);
    List<UserRole> selectByUserId(Long userId);
    List<UserRole> selectByRoleId(Long roleId);
    UserRole selectByUserIdAndRoleId(Long userId, Long roleId);
}