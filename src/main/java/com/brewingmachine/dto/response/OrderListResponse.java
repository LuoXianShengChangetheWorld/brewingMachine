package com.brewingmachine.dto.response;

import lombok.Data;
import java.util.List;

@Data
public class OrderListResponse {
    private Integer total;
    private List<OrderListItem> items;
}