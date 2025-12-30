package com.brewingmachine.dto.request;

import lombok.Data;

@Data
public class WeChatLoginRequest {
    private String code;
}