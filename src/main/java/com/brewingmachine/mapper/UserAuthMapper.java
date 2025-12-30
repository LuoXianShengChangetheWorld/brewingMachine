package com.brewingmachine.mapper;

import com.brewingmachine.entity.UserAuth;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface UserAuthMapper {

    int insert(UserAuth userAuth);

    UserAuth findByUserIdAndType(@Param("userId") Long userId, @Param("type") String type);

    UserAuth findByAccessKey(@Param("accessKey") String accessKey);

    List<UserAuth> findByUserId(@Param("userId") Long userId);

    int deleteByUserIdAndType(@Param("userId") Long userId, @Param("type") String type);

    int update(UserAuth userAuth);
}