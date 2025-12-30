package com.brewingmachine.mapper;

import com.brewingmachine.entity.Goods;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface GoodsMapper {

    Goods findById(Long id);
    
    List<Goods> findAll();
    
    List<Goods> findByPage(@Param("page") Integer page, @Param("size") Integer size, @Param("keyword") String keyword);
    
    int count(@Param("keyword") String keyword);
    
    int insert(Goods goods);
    
    int update(Goods goods);
    
    int deleteById(Long id);
}