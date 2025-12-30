package com.brewingmachine.dto.request;

import lombok.Data;

@Data
public class BindPhoneRequest {
    private String phone;
    private String code;
}