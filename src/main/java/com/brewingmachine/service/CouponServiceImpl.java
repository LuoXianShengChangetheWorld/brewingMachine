package com.brewingmachine.service;

import com.brewingmachine.entity.Coupon;
import com.brewingmachine.entity.UserCoupon;
import com.brewingmachine.mapper.CouponMapper;
import com.brewingmachine.mapper.UserCouponMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class CouponServiceImpl implements CouponService {

    @Autowired
    private CouponMapper couponMapper;

    @Autowired
    private UserCouponMapper userCouponMapper;

    @Override
    public Coupon getCouponById(Long id) {
        return couponMapper.findById(id);
    }

    @Override
    public List<Coupon> getAllActiveCoupons() {
        return couponMapper.findAllActive();
    }

    @Override
    public List<Coupon> getCouponsByStatus(String status) {
        return couponMapper.findByStatus(status);
    }

    @Override
    public List<Coupon> getCouponsByPage(String status, String keyword, Integer page, Integer size) {
        return couponMapper.findByPage(status, keyword, page, size);
    }

    @Override
    public int countCoupons(String status, String keyword) {
        return couponMapper.count(status, keyword);
    }

    @Override
    @Transactional
    public boolean createCoupon(Coupon coupon) {
        coupon.setCreateTime(LocalDateTime.now());
        coupon.setUpdateTime(LocalDateTime.now());
        coupon.setUsedCount(0);
        coupon.setStatus("ACTIVE");
        
        return couponMapper.insert(coupon) > 0;
    }

    @Override
    @Transactional
    public boolean updateCoupon(Coupon coupon) {
        coupon.setUpdateTime(LocalDateTime.now());
        return couponMapper.update(coupon) > 0;
    }

    @Override
    @Transactional
    public boolean updateCouponStatus(Long id, String status) {
        return couponMapper.updateStatus(id, status) > 0;
    }

    @Override
    @Transactional
    public boolean deleteCoupon(Long id) {
        return couponMapper.deleteById(id) > 0;
    }

    @Override
    @Transactional
    public boolean receiveCoupon(Long userId, Long couponId) {
        // 获取优惠券详情
        Coupon coupon = couponMapper.findById(couponId);
        if (coupon == null || !coupon.getStatus().equals("ACTIVE")) {
            return false;
        }

        // 检查有效期
        LocalDateTime now = LocalDateTime.now();
        if (now.isBefore(coupon.getStartTime()) || now.isAfter(coupon.getEndTime())) {
            return false;
        }

        // 检查库存
        if (coupon.getTotalCount() > 0 && coupon.getUsedCount() >= coupon.getTotalCount()) {
            return false;
        }

        // 检查每人限领
        int userCouponCount = userCouponMapper.count(userId, null);
        if (coupon.getPerUserLimit() > 0 && userCouponCount >= coupon.getPerUserLimit()) {
            return false;
        }

        // 创建用户优惠券记录
        UserCoupon userCoupon = new UserCoupon();
        userCoupon.setUserId(userId);
        userCoupon.setCouponId(couponId);
        userCoupon.setStatus("AVAILABLE");
        userCoupon.setReceiveTime(now);
        userCoupon.setExpireTime(coupon.getEndTime());

        boolean result = userCouponMapper.insert(userCoupon) > 0;

        // 更新优惠券使用数量
        if (result) {
            coupon.setUsedCount(coupon.getUsedCount() + 1);
            couponMapper.update(coupon);
        }

        return result;
    }

    @Override
    @Transactional
    public boolean useCoupon(Long userCouponId) {
        UserCoupon userCoupon = userCouponMapper.findById(userCouponId);
        if (userCoupon == null || !userCoupon.getStatus().equals("AVAILABLE")) {
            return false;
        }

        // 检查是否已过期
        LocalDateTime now = LocalDateTime.now();
        if (userCoupon.getExpireTime() != null && now.isAfter(userCoupon.getExpireTime())) {
            userCouponMapper.updateStatus(userCouponId, "EXPIRED");
            return false;
        }

        // 更新状态和使用时间
        boolean result = userCouponMapper.updateStatus(userCouponId, "USED") > 0;
        if (result) {
            userCouponMapper.updateUseTime(userCouponId, now.toString());
        }

        return result;
    }

    @Override
    public List<UserCoupon> getUserCoupons(Long userId, String status, Integer page, Integer size) {
        return userCouponMapper.findByPage(userId, status, page, size);
    }

    @Override
    public int countUserCoupons(Long userId, String status) {
        return userCouponMapper.count(userId, status);
    }

    @Override
    public List<UserCoupon> getUserValidCoupons(Long userId) {
        return userCouponMapper.findByUserIdAndStatus(userId, "AVAILABLE");
    }
}