package com.brewingmachine.mapper;

import com.brewingmachine.entity.UserCoupon;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface UserCouponMapper {

    UserCoupon findById(Long id);

    List<UserCoupon> findByUserId(@Param("userId") Long userId);

    List<UserCoupon> findByUserIdAndStatus(@Param("userId") Long userId, @Param("status") String status);

    List<UserCoupon> findByPage(@Param("userId") Long userId, @Param("status") String status,
                                @Param("page") Integer page, @Param("size") Integer size);

    int count(@Param("userId") Long userId, @Param("status") String status);

    int insert(UserCoupon userCoupon);

    int updateStatus(@Param("id") Long id, @Param("status") String status);

    int updateUseTime(@Param("id") Long id, @Param("useTime") String useTime);

    int deleteById(Long id);
}