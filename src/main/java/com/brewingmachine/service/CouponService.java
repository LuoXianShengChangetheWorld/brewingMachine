package com.brewingmachine.service;

import com.brewingmachine.entity.Coupon;
import com.brewingmachine.entity.UserCoupon;

import java.util.List;

public interface CouponService {

    /**
     * 根据ID获取优惠券详情
     */
    Coupon getCouponById(Long id);

    /**
     * 获取所有有效的优惠券
     */
    List<Coupon> getAllActiveCoupons();

    /**
     * 根据状态获取优惠券列表
     */
    List<Coupon> getCouponsByStatus(String status);

    /**
     * 分页查询优惠券
     */
    List<Coupon> getCouponsByPage(String status, String keyword, Integer page, Integer size);

    /**
     * 统计优惠券数量
     */
    int countCoupons(String status, String keyword);

    /**
     * 创建优惠券
     */
    boolean createCoupon(Coupon coupon);

    /**
     * 更新优惠券
     */
    boolean updateCoupon(Coupon coupon);

    /**
     * 更新优惠券状态
     */
    boolean updateCouponStatus(Long id, String status);

    /**
     * 删除优惠券
     */
    boolean deleteCoupon(Long id);

    /**
     * 用户领取优惠券
     */
    boolean receiveCoupon(Long userId, Long couponId);

    /**
     * 使用优惠券
     */
    boolean useCoupon(Long userCouponId);

    /**
     * 获取用户优惠券列表
     */
    List<UserCoupon> getUserCoupons(Long userId, String status, Integer page, Integer size);

    /**
     * 统计用户优惠券数量
     */
    int countUserCoupons(Long userId, String status);

    /**
     * 获取用户有效优惠券列表
     */
    List<UserCoupon> getUserValidCoupons(Long userId);
}