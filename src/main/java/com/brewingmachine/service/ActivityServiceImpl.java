package com.brewingmachine.service;

import com.brewingmachine.entity.Activity;
import com.brewingmachine.mapper.ActivityMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ActivityServiceImpl implements ActivityService {

    @Autowired
    private ActivityMapper activityMapper;

    @Override
    public Activity getActivityById(Long id) {
        return activityMapper.findById(id);
    }

    @Override
    public List<Activity> getAllActiveActivities() {
        return activityMapper.findAllActive();
    }

    @Override
    public List<Activity> getActivitiesByStatus(String status) {
        return activityMapper.findByStatus(status);
    }

    @Override
    public List<Activity> getActivitiesByPage(String status, String keyword, Integer page, Integer size) {
        return activityMapper.findByPage(status, keyword, page, size);
    }

    @Override
    public int countActivities(String status, String keyword) {
        return activityMapper.count(status, keyword);
    }

    @Override
    @Transactional
    public boolean createActivity(Activity activity) {
        activity.setCreateTime(LocalDateTime.now());
        activity.setUpdateTime(LocalDateTime.now());
        activity.setStatus("ACTIVE");
        
        return activityMapper.insert(activity) > 0;
    }

    @Override
    @Transactional
    public boolean updateActivity(Activity activity) {
        activity.setUpdateTime(LocalDateTime.now());
        return activityMapper.update(activity) > 0;
    }

    @Override
    @Transactional
    public boolean updateActivityStatus(Long id, String status) {
        return activityMapper.updateStatus(id, status) > 0;
    }

    @Override
    @Transactional
    public boolean deleteActivity(Long id) {
        return activityMapper.deleteById(id) > 0;
    }
}