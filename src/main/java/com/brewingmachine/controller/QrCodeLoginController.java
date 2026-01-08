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
     * 生成普通二维码
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
     * 生成带角色和层级信息的授权二维码
     */
    @PostMapping("/generate/authorized")
    public Map<String, Object> generateAuthorizedQrCode(@RequestBody Map<String, Object> params) {
        try {
            String role = (String) params.get("role");
            String province = (String) params.get("province");
            String city = (String) params.get("city");
            String district = (String) params.get("district");
            String street = (String) params.get("street");
            
            if (role == null || role.isEmpty()) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", false);
                result.put("message", "角色信息不能为空");
                return result;
            }
            
            return qrCodeLoginService.generateQrCode(role, province, city, district, street);
        } catch (Exception e) {
            log.error("生成授权二维码失败", e);
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "生成授权二维码失败：" + e.getMessage());
            return result;
        }
    }
    
    /**
     * 生成角色绑定二维码（纯角色绑定，与登录无关）
     */
    @PostMapping("/generate/role-bind")
    public Map<String, Object> generateRoleBindQrCode(@RequestBody Map<String, Object> params) {
        try {
            String role = (String) params.get("role");
            String province = (String) params.get("province");
            String city = (String) params.get("city");
            String district = (String) params.get("district");
            String street = (String) params.get("street");
            
            if (role == null || role.isEmpty()) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", false);
                result.put("message", "角色信息不能为空");
                return result;
            }
            
            return qrCodeLoginService.generateRoleBindQrCode(role, province, city, district, street);
        } catch (Exception e) {
            log.error("生成角色绑定二维码失败", e);
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "生成角色绑定二维码失败：" + e.getMessage());
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
        }
        
        return qrCodeLoginService.confirmLogin(qrToken, userId, userInfo);
    }
    
    /**
     * 确认角色绑定（移动端调用，纯角色绑定，与登录无关）
     */
    @PostMapping("/confirm/role-bind")
    public Map<String, Object> confirmRoleBind(@RequestBody Map<String, Object> params) {
        String qrToken = (String) params.get("qrToken");
        Long userId = Long.valueOf(params.get("userId").toString());
        
        return qrCodeLoginService.confirmRoleBind(qrToken, userId);
    }
}

