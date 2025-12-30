package com.brewingmachine.service;

import com.brewingmachine.entity.Category;
import com.brewingmachine.entity.Device;
import com.brewingmachine.entity.Store;
import com.brewingmachine.mapper.CategoryMapper;
import com.brewingmachine.mapper.DeviceMapper;
import com.brewingmachine.mapper.StoreMapper;
import com.brewingmachine.dto.response.CategoryItem;
import com.brewingmachine.dto.response.CategoryListResponse;
import com.brewingmachine.dto.response.StoreDetailResponse;
import com.brewingmachine.dto.response.StoreListItem;
import com.brewingmachine.dto.response.StoreListResponse;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class StoreService {

    private final StoreMapper storeMapper;
    private final DeviceMapper deviceMapper;
    private final CategoryMapper categoryMapper;

    public StoreService(StoreMapper storeMapper, DeviceMapper deviceMapper, CategoryMapper categoryMapper) {
        this.storeMapper = storeMapper;
        this.deviceMapper = deviceMapper;
        this.categoryMapper = categoryMapper;
    }

    @Transactional
    public StoreDetailResponse getStoreDetail(Long id) {
        Store store = storeMapper.findById(id);
        if (store == null) {
            throw new RuntimeException("店铺不存在");
        }

        // 获取店铺设备数量
        List<Device> devices = deviceMapper.findByStoreId(id);
        int deviceCount = devices != null ? devices.size() : 0;

        StoreDetailResponse response = new StoreDetailResponse();
        response.setId(store.getId().toString());
        response.setName(store.getName());
        response.setAddress(store.getAddress());
        response.setLatitude(store.getLatitude() != null ? store.getLatitude().doubleValue() : null);
        response.setLongitude(store.getLongitude() != null ? store.getLongitude().doubleValue() : null);
        response.setCover(store.getCover());
        response.setStatus(store.getStatus());
        response.setDeviceCount(deviceCount);
        response.setCreateTime(formatDate(store.getCreateTime()));
        response.setUpdateTime(formatDate(store.getUpdateTime()));

        return response;
    }

    @Transactional
    public StoreListResponse getStoreList(Integer page, Integer size, String keyword, Double latitude, Double longitude) {
        // 计算分页参数
        int offset = (page != null && page > 0 ? (page - 1) : 0) * (size != null && size > 0 ? size : 10);
        int limit = size != null && size > 0 ? size : 10;
        
        // 查询店铺总数
        int total = storeMapper.count(keyword);
        
        // 查询店铺列表
        List<Store> stores = storeMapper.findList(page, size, keyword, latitude, longitude);
        
        // 转换为响应对象
        List<StoreListItem> items = new ArrayList<>();
        for (Store store : stores) {
            StoreListItem item = new StoreListItem();
            item.setId(store.getId().toString());
            item.setName(store.getName());
            item.setAddress(store.getAddress());
            item.setCover(store.getCover());
            item.setLatitude(store.getLatitude() != null ? store.getLatitude().doubleValue() : null);
            item.setLongitude(store.getLongitude() != null ? store.getLongitude().doubleValue() : null);
            item.setCreateTime(formatDate(store.getCreateTime()));
            items.add(item);
        }
        
        StoreListResponse response = new StoreListResponse();
        response.setRecords(items);
        response.setTotal(total);
        response.setPage(page != null ? page : 1);
        response.setSize(size != null ? size : 10);
        
        return response;
    }

    @Transactional
    public void updateStore(Long id, String name, String address, String cover) {
        Store store = storeMapper.findById(id);
        if (store == null) {
            throw new RuntimeException("店铺不存在");
        }
        
        if (name != null) {
            store.setName(name);
        }
        if (address != null) {
            store.setAddress(address);
        }
        if (cover != null) {
            store.setCover(cover);
        }
        
        store.setUpdateTime(LocalDateTime.now());
        storeMapper.update(store);
    }

    @Transactional
    public Store addStore(String name, String address, Double latitude, Double longitude, Long userId) {
        Store store = new Store();
        store.setName(name);
        store.setAddress(address);
        store.setLatitude(latitude != null ? java.math.BigDecimal.valueOf(latitude) : null);
        store.setLongitude(longitude != null ? java.math.BigDecimal.valueOf(longitude) : null);
        store.setOwnerId(userId);
        store.setStatus(1); // 默认启用状态
        store.setCreateTime(LocalDateTime.now());
        store.setUpdateTime(LocalDateTime.now());
        
        storeMapper.insert(store);
        return store;
    }

    @Transactional
    public void deleteStore(Long id) {
        Store store = storeMapper.findById(id);
        if (store == null) {
            throw new RuntimeException("店铺不存在");
        }
        
        // 检查是否有设备绑定
        List<Device> devices = deviceMapper.findByStoreId(id);
        if (devices != null && !devices.isEmpty()) {
            throw new RuntimeException("店铺下有设备，不能删除");
        }
        
        storeMapper.deleteById(id);
    }

    @Transactional
    public List<Store> getStoreDropdown(Long userId) {
        if (userId != null) {
            return storeMapper.findByUserId(userId);
        } else {
            return storeMapper.findList(null, null, null, null, null);
        }
    }

    @Transactional
    public CategoryListResponse getCategoryList(Long storeId) {
        List<Category> categories = storeId != null ? categoryMapper.findByStoreId(storeId) : categoryMapper.findAll();
        
        List<CategoryItem> items = new ArrayList<>();
        for (Category category : categories) {
            CategoryItem item = new CategoryItem();
            item.setId(category.getId().toString());
            item.setName(category.getName());
            item.setSort(category.getSort());
            item.setStatus(category.getStatus());
            item.setCreateTime(formatDate(category.getCreateTime()));
            items.add(item);
        }
        
        CategoryListResponse response = new CategoryListResponse();
        response.setRecords(items);
        return response;
    }

    @Transactional
    public Category addCategory(String name, Integer sort, Long storeId) {
        Category category = new Category();
        category.setName(name);
        category.setSort(sort != null ? sort : 0);
        category.setStatus(1); // 默认启用状态
        category.setCreateTime(LocalDateTime.now());
        category.setUpdateTime(LocalDateTime.now());
        
        categoryMapper.insert(category);
        return category;
    }

    @Transactional
    public void updateCategory(Long id, String name, Integer sort) {
        Category category = categoryMapper.findById(id);
        if (category == null) {
            throw new RuntimeException("分类不存在");
        }
        
        if (name != null) {
            category.setName(name);
        }
        if (sort != null) {
            category.setSort(sort);
        }
        
        category.setUpdateTime(LocalDateTime.now());
        categoryMapper.update(category);
    }

    @Transactional
    public void deleteCategory(Long id) {
        Category category = categoryMapper.findById(id);
        if (category == null) {
            throw new RuntimeException("分类不存在");
        }
        
        categoryMapper.deleteById(id);
    }

    private String formatDate(LocalDateTime dateTime) {
        if (dateTime == null) return "";
        return dateTime.toString().substring(0, 19);
    }

}