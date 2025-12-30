package com.brewingmachine.service;

import com.brewingmachine.entity.Device;
import com.brewingmachine.entity.DeviceSlot;
import com.brewingmachine.entity.Goods;
import com.brewingmachine.entity.GoodsPrice;
import com.brewingmachine.entity.Store;
import com.brewingmachine.mapper.DeviceMapper;
import com.brewingmachine.mapper.DeviceSlotMapper;
import com.brewingmachine.mapper.GoodsMapper;
import com.brewingmachine.mapper.GoodsPriceMapper;
import com.brewingmachine.mapper.StoreMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DeviceService {

    private final DeviceMapper deviceMapper;
    private final DeviceSlotMapper deviceSlotMapper;
    private final GoodsMapper goodsMapper;
    private final GoodsPriceMapper goodsPriceMapper;
    private final StoreMapper storeMapper;

    @Transactional
    public DeviceDetailResponse getDeviceDetail(String sn) {
        Device device = deviceMapper.findBySn(sn);
        if (device == null) {
            throw new RuntimeException("设备不存在");
        }

        // 获取店铺信息
        Store store = device.getStoreId() != null ? storeMapper.findById(device.getStoreId()) : null;
        
        // 获取设备槽位信息
        List<DeviceSlot> slots = deviceSlotMapper.findByDeviceId(device.getId());
        List<DeviceSlotDetail> slotDetails = new ArrayList<>();
        
        for (DeviceSlot slot : slots) {
            Goods goods = slot.getGoodsId() != null ? goodsMapper.findById(slot.getGoodsId()) : null;
            GoodsPrice price = slot.getPriceId() != null ? goodsPriceMapper.findById(slot.getPriceId()) : null;
            
            DeviceSlotDetail slotDetail = new DeviceSlotDetail();
            slotDetail.setId(slot.getId().toString());
            slotDetail.setGoodsName(goods != null ? goods.getName() : "");
            slotDetail.setCapacity(slot.getCapacity());
            slotDetail.setPrice(slot.getPrice().doubleValue());
            slotDetail.setStock(slot.getStock());
            slotDetails.add(slotDetail);
        }

        DeviceDetailResponse response = new DeviceDetailResponse();
        response.setSn(device.getSn());
        response.setName(device.getName());
        response.setOnline(device.getOnline() != null && device.getOnline() == 1);
        response.setBattery(device.getBattery());
        response.setAddress(store != null ? store.getAddress() : "");
        response.setStoreId(device.getStoreId().toString());
        response.setSlots(slotDetails);

        return response;
    }

    @Transactional
    public DeviceListResponse getDeviceList(Integer page, Integer size, String status, String keyword, Long userId) {
        // 计算分页参数
        int offset = (page != null && page > 0 ? (page - 1) : 0) * (size != null && size > 0 ? size : 10);
        int limit = size != null && size > 0 ? size : 10;
        
        // 获取用户的店铺ID列表（如果有的话）
        List<Store> stores = storeMapper.findByUserId(userId);
        List<Long> storeIds = stores.stream().map(Store::getId).collect(Collectors.toList());
        
        // 查询设备总数
        int total = deviceMapper.count(status, keyword, storeIds);
        
        // 查询设备列表
        List<Device> devices = deviceMapper.findByPage(status, keyword, storeIds, limit, offset);
        
        // 转换为响应对象
        List<DeviceListItem> items = new ArrayList<>();
        for (Device device : devices) {
            Store store = device.getStoreId() != null ? storeMapper.findById(device.getStoreId()) : null;
            
            DeviceListItem item = new DeviceListItem();
            item.setSn(device.getSn());
            item.setName(device.getName());
            item.setOnline(device.getOnline() != null && device.getOnline() == 1);
            item.setBattery(device.getBattery());
            item.setStoreName(store != null ? store.getName() : "");
            item.setCreateTime(formatDate(device.getCreateTime()));
            items.add(item);
        }
        
        DeviceListResponse response = new DeviceListResponse();
        response.setRecords(items);
        response.setTotal(total);
        response.setPage(page != null ? page : 1);
        response.setSize(size != null ? size : 10);
        
        return response;
    }

    @Transactional
    public void updateDevice(String sn, String name, Long storeId) {
        Device device = deviceMapper.findBySn(sn);
        if (device == null) {
            throw new RuntimeException("设备不存在");
        }
        
        if (name != null) {
            device.setName(name);
        }
        
        if (storeId != null) {
            // 验证店铺是否存在
            Store store = storeMapper.findById(storeId);
            if (store == null) {
                throw new RuntimeException("店铺不存在");
            }
            device.setStoreId(storeId);
        }
        
        device.setUpdateTime(LocalDateTime.now());
        deviceMapper.update(device);
    }

    @Transactional
    public void bindDevice(String sn, Long storeId) {
        Device device = deviceMapper.findBySn(sn);
        if (device == null) {
            throw new RuntimeException("设备不存在");
        }
        
        // 验证店铺是否存在
        Store store = storeMapper.findById(storeId);
        if (store == null) {
            throw new RuntimeException("店铺不存在");
        }
        
        device.setStoreId(storeId);
        device.setUpdateTime(LocalDateTime.now());
        deviceMapper.update(device);
    }

    @Transactional
    public void unbindDevice(String sn) {
        Device device = deviceMapper.findBySn(sn);
        if (device == null) {
            throw new RuntimeException("设备不存在");
        }
        
        device.setStoreId(null);
        device.setUpdateTime(LocalDateTime.now());
        deviceMapper.update(device);
    }

    @Transactional
    public List<DeviceSlot> getDeviceSlots(String sn) {
        Device device = deviceMapper.findBySn(sn);
        if (device == null) {
            throw new RuntimeException("设备不存在");
        }
        
        return deviceSlotMapper.findByDeviceId(device.getId());
    }

    @Transactional
    public void updateDeviceSlot(String sn, String slotId, Long goodsId, Double price) {
        Device device = deviceMapper.findBySn(sn);
        if (device == null) {
            throw new RuntimeException("设备不存在");
        }
        
        DeviceSlot slot = deviceSlotMapper.findByDeviceIdAndSlotId(device.getId(), slotId);
        if (slot == null) {
            throw new RuntimeException("槽位不存在");
        }
        
        if (goodsId != null) {
            Goods goods = goodsMapper.findById(goodsId);
            if (goods == null) {
                throw new RuntimeException("商品不存在");
            }
            slot.setGoodsId(goodsId);
        }
        
        if (price != null) {
            slot.setPrice(java.math.BigDecimal.valueOf(price));
        }
        
        slot.setUpdateTime(LocalDateTime.now());
        deviceSlotMapper.update(slot);
    }

    @Transactional
    public void lockDeviceSlot(String sn, String slotId) {
        Device device = deviceMapper.findBySn(sn);
        if (device == null) {
            throw new RuntimeException("设备不存在");
        }
        
        DeviceSlot slot = deviceSlotMapper.findByDeviceIdAndSlotId(device.getId(), slotId);
        if (slot == null) {
            throw new RuntimeException("槽位不存在");
        }
        
        slot.setLocked(1);
        slot.setUpdateTime(LocalDateTime.now());
        deviceSlotMapper.update(slot);
    }

    @Transactional
    public void unlockDeviceSlot(String sn, String slotId) {
        Device device = deviceMapper.findBySn(sn);
        if (device == null) {
            throw new RuntimeException("设备不存在");
        }
        
        DeviceSlot slot = deviceSlotMapper.findByDeviceIdAndSlotId(device.getId(), slotId);
        if (slot == null) {
            throw new RuntimeException("槽位不存在");
        }
        
        slot.setLocked(0);
        slot.setUpdateTime(LocalDateTime.now());
        deviceSlotMapper.update(slot);
    }

    private String formatDate(LocalDateTime dateTime) {
        if (dateTime == null) return "";
        return dateTime.toString().substring(0, 19);
    }

    // 内部响应类
    public static class DeviceDetailResponse {
        private String sn;
        private String name;
        private Boolean online;
        private Integer battery;
        private String address;
        private String storeId;
        private List<DeviceSlotDetail> slots;

        // Getters and Setters
        public String getSn() { return sn; }
        public void setSn(String sn) { this.sn = sn; }
        
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        
        public Boolean getOnline() { return online; }
        public void setOnline(Boolean online) { this.online = online; }
        
        public Integer getBattery() { return battery; }
        public void setBattery(Integer battery) { this.battery = battery; }
        
        public String getAddress() { return address; }
        public void setAddress(String address) { this.address = address; }
        
        public String getStoreId() { return storeId; }
        public void setStoreId(String storeId) { this.storeId = storeId; }
        
        public List<DeviceSlotDetail> getSlots() { return slots; }
        public void setSlots(List<DeviceSlotDetail> slots) { this.slots = slots; }
    }

    public static class DeviceSlotDetail {
        private String id;
        private String goodsName;
        private Integer capacity;
        private Double price;
        private Integer stock;

        // Getters and Setters
        public String getId() { return id; }
        public void setId(String id) { this.id = id; }
        
        public String getGoodsName() { return goodsName; }
        public void setGoodsName(String goodsName) { this.goodsName = goodsName; }
        
        public Integer getCapacity() { return capacity; }
        public void setCapacity(Integer capacity) { this.capacity = capacity; }
        
        public Double getPrice() { return price; }
        public void setPrice(Double price) { this.price = price; }
        
        public Integer getStock() { return stock; }
        public void setStock(Integer stock) { this.stock = stock; }
    }

    public static class DeviceListResponse {
        private List<DeviceListItem> records;
        private Integer total;
        private Integer page;
        private Integer size;

        // Getters and Setters
        public List<DeviceListItem> getRecords() { return records; }
        public void setRecords(List<DeviceListItem> records) { this.records = records; }
        
        public Integer getTotal() { return total; }
        public void setTotal(Integer total) { this.total = total; }
        
        public Integer getPage() { return page; }
        public void setPage(Integer page) { this.page = page; }
        
        public Integer getSize() { return size; }
        public void setSize(Integer size) { this.size = size; }
    }

    public static class DeviceListItem {
        private String sn;
        private String name;
        private Boolean online;
        private Integer battery;
        private String storeName;
        private String createTime;

        // Getters and Setters
        public String getSn() { return sn; }
        public void setSn(String sn) { this.sn = sn; }
        
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        
        public Boolean getOnline() { return online; }
        public void setOnline(Boolean online) { this.online = online; }
        
        public Integer getBattery() { return battery; }
        public void setBattery(Integer battery) { this.battery = battery; }
        
        public String getStoreName() { return storeName; }
        public void setStoreName(String storeName) { this.storeName = storeName; }
        
        public String getCreateTime() { return createTime; }
        public void setCreateTime(String createTime) { this.createTime = createTime; }
    }
}