package com.brewingmachine.dto.request;

import lombok.Data;

@Data
public class BasicLoginRequest {
    private String username;
    private String password;
}