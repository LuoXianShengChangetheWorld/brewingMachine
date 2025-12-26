package com.brewingmachine.mapper;

import com.brewingmachine.entity.WeChatUser;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface WeChatUserMapper {

    int insert(WeChatUser weChatUser);

    WeChatUser findByOpenid(@Param("openid") String openid);

    WeChatUser findByUnionid(@Param("unionid") String unionid);

    WeChatUser findByUserId(@Param("userId") Long userId);

    int updateByUserId(@Param("userId") Long userId, @Param("weChatUser") WeChatUser weChatUser);

    int deleteByUserId(@Param("userId") Long userId);
}
