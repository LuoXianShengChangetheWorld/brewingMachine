package com.brewingmachine.service;

import com.brewingmachine.dto.request.*;
import com.brewingmachine.dto.response.*;

import java.util.List;

/**
 * 订单服务接口
 */
public interface OrderService {

    /**
     * 创建订单
     */
    CreateOrderResponse createOrder(CreateOrderRequest request);

    /**
     * 根据ID查询订单
     */
    OrderDetailResponse getOrderDetail(String orderId);

    /**
     * 查询用户订单列表
     */
    OrderListResponse getUserOrders(GetUserOrdersRequest request);

    /**
     * 查询代理订单列表
     */
    OrderListResponse getAgentOrders(GetAgentOrdersRequest request);

    /**
     * 取消订单
     */
    void cancelOrder(String orderId);

    /**
     * 更新订单状态
     */
    void updateOrderStatus(String orderId, String status);

    /**
     * 退款
     */
    void refundOrder(String orderId);

    /**
     * 支付订单
     */
    void payOrder(String orderId, String payType);
}