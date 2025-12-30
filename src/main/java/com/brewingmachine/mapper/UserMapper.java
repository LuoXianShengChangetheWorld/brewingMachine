package com.brewingmachine.mapper;

import com.brewingmachine.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;

@Mapper
public interface UserMapper {

    int insert(User user);

    User findById(@Param("id") Long id);

    User findByUsername(@Param("username") String username);

    User findByPhone(@Param("phone") String phone);

    User findByToken(@Param("token") String token);

    int update(User user);

    int updateLastLoginTime(@Param("id") Long id, @Param("lastLoginTime") LocalDateTime lastLoginTime);

    int updateToken(@Param("id") Long id, @Param("token") String token, @Param("expireTime") LocalDateTime expireTime);

    int updateTokenExpireTime(@Param("id") Long id, @Param("expireTime") LocalDateTime expireTime);

    int clearToken(@Param("id") Long id);
}
