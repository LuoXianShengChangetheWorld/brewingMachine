package com.brewingmachine.controller;

import com.brewingmachine.dto.Result;
import com.brewingmachine.dto.request.*;
import com.brewingmachine.dto.response.*;
import com.brewingmachine.service.AuthService;
import com.brewingmachine.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 订单控制器
 */
@RestController
@RequestMapping("/apis")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;
    private final AuthService authService;

    /**
     * 创建订单
     * POST /apis/order/create
     */
    @PostMapping("/order/create")
    public Result<CreateOrderResponse> createOrder(@RequestHeader("Authorization") String token,
                                                   @RequestBody Map<String, Object> request) {
        try {
            // 验证token
            Long userId = authService.getUserIdByToken(token);
            
            // 验证必要参数
            String sn = (String) request.get("sn");
            Long slotId = Long.valueOf(request.get("slotId").toString());
            Integer quantity = Integer.valueOf(request.get("quantity").toString());
            
            if (sn == null || sn.trim().isEmpty()) {
                return Result.error("设备编号不能为空");
            }
            
            if (slotId == null || slotId <= 0) {
                return Result.error("设备槽位ID不能为空");
            }
            
            if (quantity == null || quantity <= 0) {
                return Result.error("商品数量必须大于0");
            }
            
            // 创建订单请求
            CreateOrderRequest orderRequest = new CreateOrderRequest();
            orderRequest.setUserId(userId);
            orderRequest.setSn(sn);
            orderRequest.setSlotId(slotId);
            orderRequest.setQuantity(quantity);
            orderRequest.setRemark((String) request.get("remark"));
            
            // 创建订单
            CreateOrderResponse orderResponse = orderService.createOrder(orderRequest);
            return Result.success(orderResponse);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取订单详情
     * POST /apis/order/info
     */
    @PostMapping("/order/info")
    public Result<OrderDetailResponse> getOrderInfo(@RequestHeader("Authorization") String token,
                                                    @RequestBody Map<String, String> request) {
        try {
            // 验证token
            authService.getUserIdByToken(token);
            
            String orderId = request.get("orderId");
            if (orderId == null || orderId.trim().isEmpty()) {
                return Result.error("订单ID不能为空");
            }
            
            // 获取订单详情
            OrderDetailResponse orderInfo = orderService.getOrderDetail(orderId);
            return Result.success(orderInfo);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取用户订单列表
     * POST /apis/order/list
     */
    @PostMapping("/order/list")
    public Result<OrderListResponse> getOrderList(@RequestHeader("Authorization") String token,
                                                  @RequestBody Map<String, Object> request) {
        try {
            // 验证token
            Long userId = authService.getUserIdByToken(token);
            
            // 获取查询参数
            String status = (String) request.get("status");
            Integer page = request.get("page") != null ? Integer.valueOf(request.get("page").toString()) : 1;
            Integer size = request.get("size") != null ? Integer.valueOf(request.get("size").toString()) : 10;
            
            // 创建查询请求
            GetUserOrdersRequest ordersRequest = new GetUserOrdersRequest();
            ordersRequest.setUserId(userId);
            ordersRequest.setStatus(status);
            ordersRequest.setPage(page);
            ordersRequest.setSize(size);
            
            // 获取订单列表
            OrderListResponse orderList = orderService.getUserOrders(ordersRequest);
            return Result.success(orderList);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取代理订单列表
     * POST /apis/order/agent/list
     */
    @PostMapping("/order/agent/list")
    public Result<OrderListResponse> getAgentOrderList(@RequestHeader("Authorization") String token,
                                                       @RequestBody Map<String, Object> request) {
        try {
            // 验证token
            Long userId = authService.getUserIdByToken(token);
            
            // 获取查询参数
            String status = (String) request.get("status");
            Long storeId = request.get("storeId") != null ? Long.valueOf(request.get("storeId").toString()) : null;
            String startTime = (String) request.get("startTime");
            String endTime = (String) request.get("endTime");
            Integer page = request.get("page") != null ? Integer.valueOf(request.get("page").toString()) : 1;
            Integer size = request.get("size") != null ? Integer.valueOf(request.get("size").toString()) : 10;
            
            // 创建查询请求
            GetAgentOrdersRequest ordersRequest = new GetAgentOrdersRequest();
            ordersRequest.setUserId(userId);
            ordersRequest.setStoreId(storeId);
            ordersRequest.setStatus(status);
            ordersRequest.setStartTime(startTime);
            ordersRequest.setEndTime(endTime);
            ordersRequest.setPage(page);
            ordersRequest.setSize(size);
            
            // 获取代理订单列表
            OrderListResponse orderList = orderService.getAgentOrders(ordersRequest);
            return Result.success(orderList);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 取消订单
     * POST /apis/order/cancel
     */
    @PostMapping("/order/cancel")
    public Result<String> cancelOrder(@RequestHeader("Authorization") String token,
                                      @RequestBody Map<String, String> request) {
        try {
            // 验证token
            authService.getUserIdByToken(token);
            
            String orderId = request.get("orderId");
            if (orderId == null || orderId.trim().isEmpty()) {
                return Result.error("订单ID不能为空");
            }
            
            // 取消订单
            orderService.cancelOrder(orderId);
            return Result.success("订单取消成功");
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 支付订单
     * POST /apis/order/pay
     */
    @PostMapping("/order/pay")
    public Result<String> payOrder(@RequestHeader("Authorization") String token,
                                   @RequestBody Map<String, String> request) {
        try {
            // 验证token
            authService.getUserIdByToken(token);
            
            String orderId = request.get("orderId");
            String payType = request.get("payType");
            
            if (orderId == null || orderId.trim().isEmpty()) {
                return Result.error("订单ID不能为空");
            }
            
            if (payType == null || payType.trim().isEmpty()) {
                return Result.error("支付方式不能为空");
            }
            
            // 支付订单
            orderService.payOrder(orderId, payType);
            return Result.success("订单支付成功");
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 退款
     * POST /apis/order/refund
     */
    @PostMapping("/order/refund")
    public Result<String> refundOrder(@RequestHeader("Authorization") String token,
                                      @RequestBody Map<String, String> request) {
        try {
            // 验证token
            authService.getUserIdByToken(token);
            
            String orderId = request.get("orderId");
            if (orderId == null || orderId.trim().isEmpty()) {
                return Result.error("订单ID不能为空");
            }
            
            // 退款
            orderService.refundOrder(orderId);
            return Result.success("订单退款成功");
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 确认完成订单
     * POST /apis/order/complete
     */
    @PostMapping("/order/complete")
    public Result<String> completeOrder(@RequestHeader("Authorization") String token,
                                        @RequestBody Map<String, String> request) {
        try {
            // 验证token
            authService.getUserIdByToken(token);
            
            String orderId = request.get("orderId");
            if (orderId == null || orderId.trim().isEmpty()) {
                return Result.error("订单ID不能为空");
            }
            
            // 更新订单状态为已完成
            orderService.updateOrderStatus(orderId, "COMPLETED");
            return Result.success("订单已完成");
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}