package com.brewingmachine.controller;

import com.brewingmachine.dto.Result;
import com.brewingmachine.dto.request.CreateActivityRequest;
import com.brewingmachine.dto.request.UpdateActivityRequest;
import com.brewingmachine.dto.response.ActivityDetailResponse;
import com.brewingmachine.dto.response.ActivityListResponse;
import com.brewingmachine.entity.Activity;
import com.brewingmachine.service.AuthService;
import com.brewingmachine.service.ActivityService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 活动控制器
 */
@RestController
@RequestMapping("/apis")
@RequiredArgsConstructor
public class ActivityController {

    private final ActivityService activityService;
    private final AuthService authService;

    /**
     * 创建活动
     * POST /apis/activity/create
     */
    @PostMapping("/activity/create")
    public Result<Long> createActivity(@RequestHeader("Authorization") String token,
                                      @RequestBody CreateActivityRequest request) {
        try {
            // 验证token和管理员权限
            Long userId = authService.getUserIdByToken(token);
            // TODO: 检查用户是否为管理员
            
            // 创建活动
            Activity activity = new Activity();
            BeanUtils.copyProperties(request, activity);
            boolean success = activityService.createActivity(activity);
            
            if (success) {
                return Result.success(activity.getId());
            } else {
                return Result.error("创建活动失败");
            }
        } catch (Exception e) {
            return Result.error("创建活动异常: " + e.getMessage());
        }
    }

    /**
     * 更新活动
     * POST /apis/activity/update
     */
    @PostMapping("/activity/update")
    public Result<Void> updateActivity(@RequestHeader("Authorization") String token,
                                      @RequestBody UpdateActivityRequest request) {
        try {
            // 验证token和管理员权限
            Long userId = authService.getUserIdByToken(token);
            // TODO: 检查用户是否为管理员
            
            // 更新活动
            Activity activity = new Activity();
            BeanUtils.copyProperties(request, activity);
            boolean success = activityService.updateActivity(activity);
            
            if (success) {
                return Result.success();
            } else {
                return Result.error("更新活动失败");
            }
        } catch (Exception e) {
            return Result.error("更新活动异常: " + e.getMessage());
        }
    }

    /**
     * 删除活动
     * POST /apis/activity/delete
     */
    @PostMapping("/activity/delete")
    public Result<Void> deleteActivity(@RequestHeader("Authorization") String token,
                                      @RequestBody Map<String, Object> request) {
        try {
            // 验证token和管理员权限
            Long userId = authService.getUserIdByToken(token);
            // TODO: 检查用户是否为管理员
            
            // 获取活动ID
            Long activityId = Long.valueOf(request.get("id").toString());
            
            boolean success = activityService.deleteActivity(activityId);
            
            if (success) {
                return Result.success();
            } else {
                return Result.error("删除活动失败");
            }
        } catch (Exception e) {
            return Result.error("删除活动异常: " + e.getMessage());
        }
    }

    /**
     * 获取活动详情
     * GET /apis/activity/detail/{id}
     */
    @GetMapping("/activity/detail/{id}")
    public Result<ActivityDetailResponse> getActivityDetail(@RequestHeader("Authorization") String token,
                                                          @PathVariable Long id) {
        try {
            // 验证token
            authService.getUserIdByToken(token);
            
            Activity activity = activityService.getActivityById(id);
            if (activity == null) {
                return Result.error("活动不存在");
            }
            
            ActivityDetailResponse response = new ActivityDetailResponse();
            BeanUtils.copyProperties(activity, response);
            
            return Result.success(response);
        } catch (Exception e) {
            return Result.error("获取活动详情异常: " + e.getMessage());
        }
    }

    /**
     * 获取活动列表
     * GET /apis/activity/list
     */
    @GetMapping("/activity/list")
    public Result<List<ActivityListResponse>> getActivityList(@RequestHeader("Authorization") String token,
                                                             @RequestParam(required = false) String status,
                                                             @RequestParam(required = false) String keyword,
                                                             @RequestParam(defaultValue = "1") Integer page,
                                                             @RequestParam(defaultValue = "10") Integer size) {
        try {
            // 验证token
            authService.getUserIdByToken(token);
            
            // 计算偏移量
            Integer offset = (page - 1) * size;
            
            List<Activity> activities = activityService.getActivitiesByPage(status, keyword, offset, size);
            
            List<ActivityListResponse> responses = activities.stream()
                .map(activity -> {
                    ActivityListResponse response = new ActivityListResponse();
                    BeanUtils.copyProperties(activity, response);
                    return response;
                })
                .collect(Collectors.toList());
            
            return Result.success(responses);
        } catch (Exception e) {
            return Result.error("获取活动列表异常: " + e.getMessage());
        }
    }
}