package com.brewingmachine.mapper;

import com.brewingmachine.entity.DeviceSlot;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface DeviceSlotMapper {

    DeviceSlot findById(Long id);
    
    List<DeviceSlot> findByDeviceId(Long deviceId);
    
    DeviceSlot findByDeviceIdAndSlotId(@Param("deviceId") Long deviceId, @Param("slotId") String slotId);
    
    List<DeviceSlot> findByGoodsId(Long goodsId);
    
    List<DeviceSlot> findAll();
    
    int insert(DeviceSlot deviceSlot);
    
    int update(DeviceSlot deviceSlot);
    
    int updateStock(@Param("id") Long id, @Param("stock") Integer stock);
    
    int deleteById(Long id);
}