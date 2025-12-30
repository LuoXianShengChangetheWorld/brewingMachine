package com.brewingmachine.mapper;

import com.brewingmachine.entity.Device;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface DeviceMapper {

    Device findById(Long id);
    
    Device findBySn(String sn);
    
    List<Device> findByStoreId(Long storeId);
    
    List<Device> findByUserId(Long userId);
    
    List<Device> findAll();
    
    int count(@Param("status") String status, @Param("keyword") String keyword, @Param("storeIds") List<Long> storeIds);
    
    List<Device> findByPage(@Param("status") String status, @Param("keyword") String keyword, 
                           @Param("storeIds") List<Long> storeIds, @Param("limit") int limit, @Param("offset") int offset);
    
    int insert(Device device);
    
    int update(Device device);
    
    int updateOnlineStatus(@Param("id") Long id, @Param("online") Integer online, 
                          @Param("battery") Integer battery, @Param("status") String status);
    
    int deleteById(Long id);
}