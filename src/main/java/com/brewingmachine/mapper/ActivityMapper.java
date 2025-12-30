package com.brewingmachine.mapper;

import com.brewingmachine.entity.Activity;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ActivityMapper {

    Activity findById(Long id);

    List<Activity> findAllActive();

    List<Activity> findByStatus(@Param("status") String status);

    List<Activity> findByPage(@Param("status") String status, @Param("keyword") String keyword,
                             @Param("page") Integer page, @Param("size") Integer size);

    int count(@Param("status") String status, @Param("keyword") String keyword);

    int insert(Activity activity);

    int update(Activity activity);

    int updateStatus(@Param("id") Long id, @Param("status") String status);

    int deleteById(Long id);
}