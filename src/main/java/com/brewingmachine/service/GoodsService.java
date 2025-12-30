package com.brewingmachine.service;

import com.brewingmachine.entity.Goods;
import com.brewingmachine.entity.GoodsPrice;
import com.brewingmachine.mapper.GoodsMapper;
import com.brewingmachine.mapper.GoodsPriceMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class GoodsService {

    private final GoodsMapper goodsMapper;
    private final GoodsPriceMapper goodsPriceMapper;

    @Transactional
    public GoodsListResponse getGoodsList(Integer page, Integer size, String keyword) {
        // 计算分页参数
        int offset = (page != null && page > 0 ? (page - 1) : 0) * (size != null && size > 0 ? size : 10);
        int limit = size != null && size > 0 ? size : 10;
        
        // 查询商品总数
        int total = goodsMapper.count(keyword);
        
        // 查询商品列表
        List<Goods> goods = goodsMapper.findByPage(page, size, keyword);
        
        // 转换为响应对象
        List<GoodsListItem> items = new ArrayList<>();
        for (Goods good : goods) {
            GoodsListItem item = new GoodsListItem();
            item.setId(good.getId().toString());
            item.setName(good.getName());
            item.setCover(good.getCover());
            item.setDescription(good.getDescription());
            item.setCategoryId(good.getCategoryId() != null ? good.getCategoryId().toString() : null);
            item.setStatus(good.getStatus());
            item.setCreateTime(formatDate(good.getCreateTime()));
            items.add(item);
        }
        
        GoodsListResponse response = new GoodsListResponse();
        response.setRecords(items);
        response.setTotal(total);
        response.setPage(page != null ? page : 1);
        response.setSize(size != null ? size : 10);
        
        return response;
    }

    @Transactional
    public Goods addGoods(String name, String cover, String description, Long categoryId, List<GoodsPriceSpec> specs) {
        Goods goods = new Goods();
        goods.setName(name);
        goods.setCover(cover);
        goods.setDescription(description);
        goods.setCategoryId(categoryId);
        goods.setStatus(1); // 默认启用状态
        goods.setCreateTime(LocalDateTime.now());
        goods.setUpdateTime(LocalDateTime.now());
        
        goodsMapper.insert(goods);
        
        // 添加价格规格
        if (specs != null && !specs.isEmpty()) {
            for (GoodsPriceSpec spec : specs) {
                GoodsPrice price = new GoodsPrice();
                price.setGoodsId(goods.getId());
                price.setCapacity(spec.getCapacity());
                price.setPrice(spec.getPrice() != null ? BigDecimal.valueOf(spec.getPrice()) : null);
                price.setStatus(1); // 默认启用状态
                price.setCreateTime(LocalDateTime.now());
                price.setUpdateTime(LocalDateTime.now());
                goodsPriceMapper.insert(price);
            }
        }
        
        return goods;
    }

    @Transactional
    public void updateGoods(Long id, String name, String cover, String description, Long categoryId, List<GoodsPriceSpec> specs) {
        Goods goods = goodsMapper.findById(id);
        if (goods == null) {
            throw new RuntimeException("商品不存在");
        }
        
        if (name != null) {
            goods.setName(name);
        }
        if (cover != null) {
            goods.setCover(cover);
        }
        if (description != null) {
            goods.setDescription(description);
        }
        if (categoryId != null) {
            goods.setCategoryId(categoryId);
        }
        
        goods.setUpdateTime(LocalDateTime.now());
        goodsMapper.update(goods);
        
        // 更新价格规格
        if (specs != null && !specs.isEmpty()) {
            // 先删除现有的价格规格
            List<GoodsPrice> existingPrices = goodsPriceMapper.findByGoodsId(id);
            for (GoodsPrice existingPrice : existingPrices) {
                goodsPriceMapper.deleteById(existingPrice.getId());
            }
            
            // 添加新的价格规格
            for (GoodsPriceSpec spec : specs) {
                GoodsPrice price = new GoodsPrice();
                price.setGoodsId(id);
                price.setCapacity(spec.getCapacity());
                price.setPrice(spec.getPrice() != null ? BigDecimal.valueOf(spec.getPrice()) : null);
                price.setStatus(1); // 默认启用状态
                price.setCreateTime(LocalDateTime.now());
                price.setUpdateTime(LocalDateTime.now());
                goodsPriceMapper.insert(price);
            }
        }
    }

    @Transactional
    public void deleteGoods(Long id) {
        Goods goods = goodsMapper.findById(id);
        if (goods == null) {
            throw new RuntimeException("商品不存在");
        }
        
        // 删除相关的价格规格
        List<GoodsPrice> prices = goodsPriceMapper.findByGoodsId(id);
        for (GoodsPrice price : prices) {
            goodsPriceMapper.deleteById(price.getId());
        }
        
        goodsMapper.deleteById(id);
    }

    @Transactional
    public GoodsPriceListResponse getGoodsPriceList(Long goodsId) {
        List<GoodsPrice> prices = goodsPriceMapper.findByGoodsId(goodsId);
        
        List<GoodsPriceItem> items = new ArrayList<>();
        for (GoodsPrice price : prices) {
            GoodsPriceItem item = new GoodsPriceItem();
            item.setId(price.getId().toString());
            item.setGoodsId(price.getGoodsId().toString());
            item.setCapacity(price.getCapacity());
            item.setPrice(price.getPrice().doubleValue());
            item.setStatus(price.getStatus());
            item.setCreateTime(formatDate(price.getCreateTime()));
            items.add(item);
        }
        
        GoodsPriceListResponse response = new GoodsPriceListResponse();
        response.setRecords(items);
        
        return response;
    }

    @Transactional
    public void updateGoodsPrice(Long id, Double price) {
        GoodsPrice goodsPrice = goodsPriceMapper.findById(id);
        if (goodsPrice == null) {
            throw new RuntimeException("价格规格不存在");
        }
        
        goodsPrice.setPrice(price != null ? java.math.BigDecimal.valueOf(price) : goodsPrice.getPrice());
        goodsPrice.setUpdateTime(LocalDateTime.now());
        goodsPriceMapper.update(goodsPrice);
    }

    @Transactional
    public void deleteGoodsPrice(Long id) {
        GoodsPrice goodsPrice = goodsPriceMapper.findById(id);
        if (goodsPrice == null) {
            throw new RuntimeException("价格规格不存在");
        }
        
        goodsPriceMapper.deleteById(id);
    }

    private String formatDate(LocalDateTime dateTime) {
        if (dateTime == null) return "";
        return dateTime.toString().substring(0, 19);
    }

    // 内部响应类
    public static class GoodsListResponse {
        private List<GoodsListItem> records;
        private Integer total;
        private Integer page;
        private Integer size;

        // Getters and Setters
        public List<GoodsListItem> getRecords() { return records; }
        public void setRecords(List<GoodsListItem> records) { this.records = records; }
        
        public Integer getTotal() { return total; }
        public void setTotal(Integer total) { this.total = total; }
        
        public Integer getPage() { return page; }
        public void setPage(Integer page) { this.page = page; }
        
        public Integer getSize() { return size; }
        public void setSize(Integer size) { this.size = size; }
    }

    public static class GoodsListItem {
        private String id;
        private String name;
        private String cover;
        private String description;
        private String categoryId;
        private Integer status;
        private String createTime;

        // Getters and Setters
        public String getId() { return id; }
        public void setId(String id) { this.id = id; }
        
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        
        public String getCover() { return cover; }
        public void setCover(String cover) { this.cover = cover; }
        
        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
        
        public String getCategoryId() { return categoryId; }
        public void setCategoryId(String categoryId) { this.categoryId = categoryId; }
        
        public Integer getStatus() { return status; }
        public void setStatus(Integer status) { this.status = status; }
        
        public String getCreateTime() { return createTime; }
        public void setCreateTime(String createTime) { this.createTime = createTime; }
    }

    public static class GoodsPriceListResponse {
        private List<GoodsPriceItem> records;

        // Getters and Setters
        public List<GoodsPriceItem> getRecords() { return records; }
        public void setRecords(List<GoodsPriceItem> records) { this.records = records; }
    }

    public static class GoodsPriceItem {
        private String id;
        private String goodsId;
        private Integer capacity;
        private Double price;
        private Integer status;
        private String createTime;

        // Getters and Setters
        public String getId() { return id; }
        public void setId(String id) { this.id = id; }
        
        public String getGoodsId() { return goodsId; }
        public void setGoodsId(String goodsId) { this.goodsId = goodsId; }
        
        public Integer getCapacity() { return capacity; }
        public void setCapacity(Integer capacity) { this.capacity = capacity; }
        
        public Double getPrice() { return price; }
        public void setPrice(Double price) { this.price = price; }
        
        public Integer getStatus() { return status; }
        public void setStatus(Integer status) { this.status = status; }
        
        public String getCreateTime() { return createTime; }
        public void setCreateTime(String createTime) { this.createTime = createTime; }
    }

    public static class GoodsPriceSpec {
        private Integer capacity;
        private Double price;

        // Getters and Setters
        public Integer getCapacity() { return capacity; }
        public void setCapacity(Integer capacity) { this.capacity = capacity; }
        
        public Double getPrice() { return price; }
        public void setPrice(Double price) { this.price = price; }
    }
}