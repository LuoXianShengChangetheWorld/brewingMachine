package com.brewingmachine.mapper;

import com.brewingmachine.entity.Coupon;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface CouponMapper {

    Coupon findById(Long id);
    
    List<Coupon> findAllActive();
    
    List<Coupon> findByStatus(@Param("status") String status);
    
    List<Coupon> findByPage(@Param("status") String status, @Param("keyword") String keyword, 
                           @Param("page") Integer page, @Param("size") Integer size);
    
    int count(@Param("status") String status, @Param("keyword") String keyword);
    
    int insert(Coupon coupon);
    
    int update(Coupon coupon);
    
    int updateStatus(@Param("id") Long id, @Param("status") String status);
    
    int deleteById(Long id);
}