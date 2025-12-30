package com.brewingmachine.service;

import com.brewingmachine.entity.Activity;

import java.util.List;

public interface ActivityService {

    /**
     * 根据ID获取活动详情
     */
    Activity getActivityById(Long id);

    /**
     * 获取所有有效的活动
     */
    List<Activity> getAllActiveActivities();

    /**
     * 根据状态获取活动列表
     */
    List<Activity> getActivitiesByStatus(String status);

    /**
     * 分页查询活动
     */
    List<Activity> getActivitiesByPage(String status, String keyword, Integer page, Integer size);

    /**
     * 统计活动数量
     */
    int countActivities(String status, String keyword);

    /**
     * 创建活动
     */
    boolean createActivity(Activity activity);

    /**
     * 更新活动
     */
    boolean updateActivity(Activity activity);

    /**
     * 更新活动状态
     */
    boolean updateActivityStatus(Long id, String status);

    /**
     * 删除活动
     */
    boolean deleteActivity(Long id);
}