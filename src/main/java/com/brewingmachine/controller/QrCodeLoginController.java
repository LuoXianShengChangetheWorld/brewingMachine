package com.brewingmachine.controller;

import com.brewingmachine.service.QrCodeLoginService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 二维码登录控制器
 */
@Slf4j
@RestController
@RequestMapping("/qr/login")
@CrossOrigin(origins = "*")
public class QrCodeLoginController {

    @Autowired
    private QrCodeLoginService qrCodeLoginService;

    /**
     * 生成二维码
     */
    @PostMapping("/generate")
    public Map<String, Object> generateQrCode() {
        try {
            return qrCodeLoginService.generateQrCode();
        } catch (Exception e) {
            log.error("生成二维码失败", e);
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "生成二维码失败：" + e.getMessage());
            return result;
        }
    }

    /**
     * 查询二维码状态（前端轮询调用）
     */
    @GetMapping("/status/{qrToken}")
    public Map<String, Object> queryStatus(@PathVariable String qrToken) {
        return qrCodeLoginService.queryQrCodeStatus(qrToken);
    }

    /**
     * 扫描二维码（移动端调用）
     */
    @PostMapping("/scan")
    public Map<String, Object> scanQrCode(@RequestParam String qrToken) {
        return qrCodeLoginService.scanQrCode(qrToken);
    }

    /**
     * 确认登录（移动端调用）
     */
    @PostMapping("/confirm")
    public Map<String, Object> confirmLogin(@RequestBody Map<String, Object> params) {
        String qrToken = (String) params.get("qrToken");
        Long userId = Long.valueOf(params.get("userId").toString());
        
        @SuppressWarnings("unchecked")
        Map<String, Object> userInfo = (Map<String, Object>) params.get("userInfo");
        
        if (userInfo == null) {
            userInfo = new HashMap<>();
            userInfo.put("userId", userId);
            userInfo.put("username", params.get("username"));
        }
        
        return qrCodeLoginService.confirmLogin(qrToken, userId, userInfo);
    }
}

