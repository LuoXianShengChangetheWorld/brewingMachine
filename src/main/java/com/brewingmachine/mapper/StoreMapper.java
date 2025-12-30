package com.brewingmachine.mapper;

import com.brewingmachine.entity.Store;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface StoreMapper {

    int insert(Store store);

    Store findById(@Param("id") Long id);

    List<Store> findByUserId(@Param("userId") Long userId);

    List<Store> findList(@Param("page") Integer page, 
                        @Param("size") Integer size, 
                        @Param("keyword") String keyword,
                        @Param("latitude") Double latitude,
                        @Param("longitude") Double longitude);

    int count(@Param("keyword") String keyword);

    int update(Store store);

    int deleteById(@Param("id") Long id);
}