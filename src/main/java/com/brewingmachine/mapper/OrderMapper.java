package com.brewingmachine.mapper;

import com.brewingmachine.entity.Order;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface OrderMapper {

    Order findById(Long id);
    
    Order findByOrderId(String orderId);
    
    List<Order> findByUserId(Long userId);
    
    List<Order> findByUserIdWithPage(@Param("userId") Long userId, @Param("status") String status,
                                    @Param("page") Integer page, @Param("size") Integer size);
    
    List<Order> findByAgentWithPage(@Param("userId") Long userId, @Param("storeId") Long storeId, 
                                   @Param("status") String status, @Param("startTime") String startTime,
                                   @Param("endTime") String endTime, @Param("page") Integer page, @Param("size") Integer size);
    
    int countByUserId(@Param("userId") Long userId, @Param("status") String status);
    
    int countByAgent(@Param("userId") Long userId, @Param("storeId") Long storeId, 
                    @Param("status") String status, @Param("startTime") String startTime,
                    @Param("endTime") String endTime);
    
    int insert(Order order);
    
    int update(Order order);
    
    int updateStatus(@Param("orderId") String orderId, @Param("status") String status, 
                    @Param("payTime") LocalDateTime payTime);
    
    int deleteById(Long id);
}