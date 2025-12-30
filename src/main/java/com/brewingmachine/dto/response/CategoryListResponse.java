package com.brewingmachine.dto.response;

import java.util.List;

public class CategoryListResponse {
    private List<CategoryItem> records;

    // Getters and Setters
    public List<CategoryItem> getRecords() {
        return records;
    }

    public void setRecords(List<CategoryItem> records) {
        this.records = records;
    }
}