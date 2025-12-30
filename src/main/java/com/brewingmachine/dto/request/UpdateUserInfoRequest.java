package com.brewingmachine.dto.request;

import lombok.Data;

@Data
public class UpdateUserInfoRequest {
    private String nickName;
    private String avatar;
}