package com.brewingmachine.mapper;

import com.brewingmachine.entity.Category;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface CategoryMapper {

    Category findById(Long id);
    
    List<Category> findAll();
    
    List<Category> findByStoreId(Long storeId);
    
    int insert(Category category);
    
    int update(Category category);
    
    int deleteById(Long id);
}