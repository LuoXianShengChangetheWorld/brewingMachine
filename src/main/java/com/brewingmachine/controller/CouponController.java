package com.brewingmachine.controller;

import com.brewingmachine.dto.Result;
import com.brewingmachine.dto.request.CreateCouponRequest;
import com.brewingmachine.dto.request.UpdateCouponRequest;
import com.brewingmachine.dto.response.CouponDetailResponse;
import com.brewingmachine.dto.response.CouponListResponse;
import com.brewingmachine.entity.Coupon;
import com.brewingmachine.entity.UserCoupon;
import com.brewingmachine.service.AuthService;
import com.brewingmachine.service.CouponService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 优惠券控制器
 */
@RestController
@RequestMapping("/apis")
@RequiredArgsConstructor
public class CouponController {

    private final CouponService couponService;
    private final AuthService authService;

    /**
     * 创建优惠券
     * POST /apis/coupon/create
     */
    @PostMapping("/coupon/create")
    public Result<Long> createCoupon(@RequestHeader("Authorization") String token,
                                     @RequestBody CreateCouponRequest request) {
        try {
            // 验证token和管理员权限
            Long userId = authService.getUserIdByToken(token);
            // TODO: 检查用户是否为管理员
            
            // 创建优惠券
            Coupon coupon = new Coupon();
            BeanUtils.copyProperties(request, coupon);
            boolean success = couponService.createCoupon(coupon);
            
            if (success) {
                return Result.success(coupon.getId());
            } else {
                return Result.error("创建优惠券失败");
            }
        } catch (Exception e) {
            return Result.error("创建优惠券异常: " + e.getMessage());
        }
    }

    /**
     * 更新优惠券
     * POST /apis/coupon/update
     */
    @PostMapping("/coupon/update")
    public Result<Void> updateCoupon(@RequestHeader("Authorization") String token,
                                     @RequestBody UpdateCouponRequest request) {
        try {
            // 验证token和管理员权限
            Long userId = authService.getUserIdByToken(token);
            // TODO: 检查用户是否为管理员
            
            // 更新优惠券
            Coupon coupon = new Coupon();
            BeanUtils.copyProperties(request, coupon);
            boolean success = couponService.updateCoupon(coupon);
            
            if (success) {
                return Result.success();
            } else {
                return Result.error("更新优惠券失败");
            }
        } catch (Exception e) {
            return Result.error("更新优惠券异常: " + e.getMessage());
        }
    }

    /**
     * 删除优惠券
     * POST /apis/coupon/delete
     */
    @PostMapping("/coupon/delete")
    public Result<Void> deleteCoupon(@RequestHeader("Authorization") String token,
                                     @RequestBody Map<String, Object> request) {
        try {
            // 验证token和管理员权限
            Long userId = authService.getUserIdByToken(token);
            // TODO: 检查用户是否为管理员
            
            // 获取优惠券ID
            Long couponId = Long.valueOf(request.get("id").toString());
            
            boolean success = couponService.deleteCoupon(couponId);
            
            if (success) {
                return Result.success();
            } else {
                return Result.error("删除优惠券失败");
            }
        } catch (Exception e) {
            return Result.error("删除优惠券异常: " + e.getMessage());
        }
    }

    /**
     * 获取优惠券详情
     * GET /apis/coupon/detail/{id}
     */
    @GetMapping("/coupon/detail/{id}")
    public Result<CouponDetailResponse> getCouponDetail(@RequestHeader("Authorization") String token,
                                                        @PathVariable Long id) {
        try {
            // 验证token
            authService.getUserIdByToken(token);
            
            Coupon coupon = couponService.getCouponById(id);
            if (coupon == null) {
                return Result.error("优惠券不存在");
            }
            
            CouponDetailResponse response = new CouponDetailResponse();
            BeanUtils.copyProperties(coupon, response);
            
            return Result.success(response);
        } catch (Exception e) {
            return Result.error("获取优惠券详情异常: " + e.getMessage());
        }
    }

    /**
     * 获取优惠券列表
     * GET /apis/coupon/list
     */
    @GetMapping("/coupon/list")
    public Result<List<CouponListResponse>> getCouponList(@RequestHeader("Authorization") String token,
                                                          @RequestParam(required = false) String status,
                                                          @RequestParam(required = false) String keyword,
                                                          @RequestParam(defaultValue = "1") Integer page,
                                                          @RequestParam(defaultValue = "10") Integer size) {
        try {
            // 验证token
            authService.getUserIdByToken(token);
            
            // 计算偏移量
            Integer offset = (page - 1) * size;
            
            List<Coupon> coupons = couponService.getCouponsByPage(status, keyword, offset, size);
            
            List<CouponListResponse> responses = coupons.stream()
                .map(coupon -> {
                    CouponListResponse response = new CouponListResponse();
                    BeanUtils.copyProperties(coupon, response);
                    return response;
                })
                .collect(Collectors.toList());
            
            return Result.success(responses);
        } catch (Exception e) {
            return Result.error("获取优惠券列表异常: " + e.getMessage());
        }
    }

    /**
     * 获取用户优惠券列表
     * GET /apis/coupon/user-list
     */
    @GetMapping("/coupon/user-list")
    public Result<List<UserCoupon>> getUserCoupons(@RequestHeader("Authorization") String token,
                                                   @RequestParam(required = false) String status,
                                                   @RequestParam(defaultValue = "1") Integer page,
                                                   @RequestParam(defaultValue = "10") Integer size) {
        try {
            // 验证token
            Long userId = authService.getUserIdByToken(token);
            
            // 计算偏移量
            Integer offset = (page - 1) * size;
            
            List<UserCoupon> userCoupons = couponService.getUserCoupons(userId, status, offset, size);
            
            return Result.success(userCoupons);
        } catch (Exception e) {
            return Result.error("获取用户优惠券列表异常: " + e.getMessage());
        }
    }

    /**
     * 领取优惠券
     * POST /apis/coupon/receive
     */
    @PostMapping("/coupon/receive")
    public Result<Void> receiveCoupon(@RequestHeader("Authorization") String token,
                                      @RequestBody Map<String, Object> request) {
        try {
            // 验证token
            Long userId = authService.getUserIdByToken(token);
            
            // 获取优惠券ID
            Long couponId = Long.valueOf(request.get("couponId").toString());
            
            boolean success = couponService.receiveCoupon(userId, couponId);
            
            if (success) {
                return Result.success();
            } else {
                return Result.error("领取优惠券失败");
            }
        } catch (Exception e) {
            return Result.error("领取优惠券异常: " + e.getMessage());
        }
    }

    /**
     * 使用优惠券
     * POST /apis/coupon/use
     */
    @PostMapping("/coupon/use")
    public Result<Void> useCoupon(@RequestHeader("Authorization") String token,
                                  @RequestBody Map<String, Object> request) {
        try {
            // 验证token
            Long userId = authService.getUserIdByToken(token);
            
            // 获取用户优惠券ID
            Long userCouponId = Long.valueOf(request.get("userCouponId").toString());
            
            boolean success = couponService.useCoupon(userCouponId);
            
            if (success) {
                return Result.success();
            } else {
                return Result.error("使用优惠券失败");
            }
        } catch (Exception e) {
            return Result.error("使用优惠券异常: " + e.getMessage());
        }
    }
}