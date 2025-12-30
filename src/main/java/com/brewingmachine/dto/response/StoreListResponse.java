package com.brewingmachine.dto.response;

import java.util.List;

public class StoreListResponse {
    private List<StoreListItem> records;
    private Integer total;
    private Integer page;
    private Integer size;

    // Getters and Setters
    public List<StoreListItem> getRecords() {
        return records;
    }

    public void setRecords(List<StoreListItem> records) {
        this.records = records;
    }

    public Integer getTotal() {
        return total;
    }

    public void setTotal(Integer total) {
        this.total = total;
    }

    public Integer getPage() {
        return page;
    }

    public void setPage(Integer page) {
        this.page = page;
    }

    public Integer getSize() {
        return size;
    }

    public void setSize(Integer size) {
        this.size = size;
    }
}