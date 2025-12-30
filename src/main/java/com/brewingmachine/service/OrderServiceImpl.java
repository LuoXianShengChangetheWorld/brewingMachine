package com.brewingmachine.service;

import com.brewingmachine.dto.request.*;
import com.brewingmachine.dto.response.*;
import com.brewingmachine.entity.*;
import com.brewingmachine.mapper.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * 订单服务实现类
 */
@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderMapper orderMapper;
    private final UserMapper userMapper;
    private final DeviceMapper deviceMapper;
    private final DeviceSlotMapper deviceSlotMapper;
    private final GoodsMapper goodsMapper;
    private final GoodsPriceMapper goodsPriceMapper;
    private final TokenService tokenService;

    @Override
    @Transactional
    public CreateOrderResponse createOrder(CreateOrderRequest request) {
        // 验证用户
        User user = userMapper.findById(request.getUserId());
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        // 验证设备
        Device device = deviceMapper.findBySn(request.getSn());
        if (device == null) {
            throw new RuntimeException("设备不存在");
        }

        // 验证设备槽位
        DeviceSlot slot = deviceSlotMapper.findById(request.getSlotId());
        if (slot == null || !slot.getDeviceId().equals(device.getId())) {
            throw new RuntimeException("设备槽位不存在或不属于该设备");
        }

        // 验证商品
        Goods goods = goodsMapper.findById(slot.getGoodsId());
        if (goods == null) {
            throw new RuntimeException("商品不存在");
        }

        // 验证商品价格规格
        GoodsPrice price = goodsPriceMapper.findById(slot.getPriceId());
        if (price == null) {
            throw new RuntimeException("商品价格规格不存在");
        }

        // 验证库存
        if (slot.getStock() == null || slot.getStock() < request.getQuantity()) {
            throw new RuntimeException("库存不足");
        }

        // 创建订单
        Order order = new Order();
        order.setOrderId(generateOrderId());
        order.setUserId(user.getId());
        order.setDeviceId(device.getId());
        order.setSlotId(slot.getId());
        order.setGoodsId(goods.getId());
        order.setGoodsName(goods.getName());
        order.setCapacity(price.getCapacity());
        order.setPrice(price.getPrice());
        order.setQuantity(request.getQuantity());
        order.setTotalAmount(price.getPrice().multiply(new BigDecimal(request.getQuantity())));
        order.setPayAmount(order.getTotalAmount());
        order.setPayType("WEIXIN"); // 默认支付方式
        order.setStatus("CREATED");
        order.setRemark(request.getRemark());

        orderMapper.insert(order);

        // 扣除库存
        deviceSlotMapper.updateStock(slot.getId(), slot.getStock() - request.getQuantity());

        // 构建响应
        CreateOrderResponse response = new CreateOrderResponse();
        response.setOrderId(order.getOrderId());
        response.setTotalAmount(order.getTotalAmount().doubleValue());
        response.setPayAmount(order.getPayAmount().doubleValue());
        response.setCreateTime(formatDateTime(order.getCreateTime()));

        return response;
    }

    @Override
    public OrderDetailResponse getOrderDetail(String orderId) {
        // 验证订单
        Order order = orderMapper.findByOrderId(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }

        // 构建响应
        OrderDetailResponse response = new OrderDetailResponse();
        response.setOrderId(order.getOrderId());
        response.setStatus(order.getStatus());
        response.setGoodsName(order.getGoodsName());
        response.setCapacity(order.getCapacity());
        response.setPrice(order.getPrice().doubleValue());
        response.setQuantity(order.getQuantity());
        response.setTotalAmount(order.getTotalAmount().doubleValue());
        response.setPayAmount(order.getPayAmount().doubleValue());
        response.setPayType(order.getPayType());
        response.setCreateTime(formatDateTime(order.getCreateTime()));
        
        if (order.getPayTime() != null) {
            response.setPayTime(formatDateTime(order.getPayTime()));
        }
        
        if (order.getCompleteTime() != null) {
            response.setCompleteTime(formatDateTime(order.getCompleteTime()));
        }
        
        response.setRemark(order.getRemark());

        return response;
    }

    @Override
    public OrderListResponse getUserOrders(GetUserOrdersRequest request) {
        // 计算分页参数
        int offset = (request.getPage() != null && request.getPage() > 0 ? (request.getPage() - 1) : 0) * 
                     (request.getSize() != null && request.getSize() > 0 ? request.getSize() : 10);
        int limit = request.getSize() != null && request.getSize() > 0 ? request.getSize() : 10;
        
        // 查询订单总数
        int total = orderMapper.countByUserId(request.getUserId(), request.getStatus());
        
        // 查询订单列表
        List<Order> orders = orderMapper.findByUserIdWithPage(request.getUserId(), request.getStatus(), offset, limit);
        
        // 转换为响应对象
        List<OrderListItem> items = new ArrayList<>();
        for (Order order : orders) {
            OrderListItem item = new OrderListItem();
            item.setOrderId(order.getOrderId());
            item.setStatus(order.getStatus());
            item.setGoodsName(order.getGoodsName());
            item.setPrice(order.getPrice().doubleValue());
            item.setQuantity(order.getQuantity());
            item.setTotalAmount(order.getTotalAmount().doubleValue());
            item.setCreateTime(formatDateTime(order.getCreateTime()));
            
            items.add(item);
        }
        
        // 构建响应
        OrderListResponse response = new OrderListResponse();
        response.setTotal(total);
        response.setItems(items);
        
        return response;
    }

    @Override
    public OrderListResponse getAgentOrders(GetAgentOrdersRequest request) {
        // 计算分页参数
        int offset = (request.getPage() != null && request.getPage() > 0 ? (request.getPage() - 1) : 0) * 
                     (request.getSize() != null && request.getSize() > 0 ? request.getSize() : 10);
        int limit = request.getSize() != null && request.getSize() > 0 ? request.getSize() : 10;
        
        // 查询订单总数
        int total = orderMapper.countByAgent(request.getUserId(), request.getStoreId(), request.getStatus(), 
                                            request.getStartTime(), request.getEndTime());
        
        // 查询订单列表
        List<Order> orders = orderMapper.findByAgentWithPage(request.getUserId(), request.getStoreId(), 
                                                              request.getStatus(), request.getStartTime(), 
                                                              request.getEndTime(), offset, limit);
        
        // 转换为响应对象
        List<OrderListItem> items = new ArrayList<>();
        for (Order order : orders) {
            OrderListItem item = new OrderListItem();
            item.setOrderId(order.getOrderId());
            item.setStatus(order.getStatus());
            item.setGoodsName(order.getGoodsName());
            item.setPrice(order.getPrice().doubleValue());
            item.setQuantity(order.getQuantity());
            item.setTotalAmount(order.getTotalAmount().doubleValue());
            item.setCreateTime(formatDateTime(order.getCreateTime()));
            
            items.add(item);
        }
        
        // 构建响应
        OrderListResponse response = new OrderListResponse();
        response.setTotal(total);
        response.setItems(items);
        
        return response;
    }

    @Override
    @Transactional
    public void cancelOrder(String orderId) {
        // 验证订单
        Order order = orderMapper.findByOrderId(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }
        
        // 检查订单状态
        if (!"CREATED".equals(order.getStatus()) && !"PENDING".equals(order.getStatus())) {
            throw new RuntimeException("订单当前状态不允许取消");
        }
        
        // 更新订单状态
        orderMapper.updateStatus(orderId, "CANCELLED", null);
        
        // 恢复库存
        DeviceSlot slot = deviceSlotMapper.findById(order.getSlotId());
        if (slot != null) {
            deviceSlotMapper.updateStock(slot.getId(), slot.getStock() + order.getQuantity());
        }
    }

    @Override
    @Transactional
    public void updateOrderStatus(String orderId, String status) {
        // 验证订单
        Order order = orderMapper.findByOrderId(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }
        
        // 更新订单状态
        orderMapper.updateStatus(orderId, status, null);
    }

    @Override
    @Transactional
    public void refundOrder(String orderId) {
        // 验证订单
        Order order = orderMapper.findByOrderId(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }
        
        // 检查订单状态
        if (!"PAID".equals(order.getStatus()) && !"COMPLETED".equals(order.getStatus())) {
            throw new RuntimeException("订单当前状态不允许退款");
        }
        
        // 更新订单状态
        orderMapper.updateStatus(orderId, "REFUNDED", null);
    }

    @Override
    @Transactional
    public void payOrder(String orderId, String payType) {
        // 验证订单
        Order order = orderMapper.findByOrderId(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }
        
        // 检查订单状态
        if (!"CREATED".equals(order.getStatus()) && !"PENDING".equals(order.getStatus())) {
            throw new RuntimeException("订单当前状态不允许支付");
        }
        
        // 更新订单状态和支付时间
        orderMapper.updateStatus(orderId, "PAID", LocalDateTime.now());
    }

    /**
     * 生成订单号
     */
    private String generateOrderId() {
        // 格式: YYYYMMDD + 随机字符串
        String date = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String randomStr = UUID.randomUUID().toString().replaceAll("-", "").substring(0, 10).toUpperCase();
        return date + randomStr;
    }
    
    /**
     * 格式化日期时间为字符串
     */
    private String formatDateTime(LocalDateTime dateTime) {
        if (dateTime == null) {
            return null;
        }
        return dateTime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }
}