package com.brewingmachine.mapper;

import com.brewingmachine.entity.GoodsPrice;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface GoodsPriceMapper {

    GoodsPrice findById(Long id);
    
    List<GoodsPrice> findByGoodsId(Long goodsId);
    
    List<GoodsPrice> findAll();
    
    int insert(GoodsPrice goodsPrice);
    
    int update(GoodsPrice goodsPrice);
    
    int deleteById(Long id);
}