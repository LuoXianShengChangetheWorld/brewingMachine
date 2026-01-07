package com.brewingmachine.service;

import com.alibaba.fastjson.JSON;
import com.brewingmachine.entity.QrCodeLogin;
import com.brewingmachine.mapper.QrCodeLoginMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * 二维码登录服务
 */
@Slf4j
@Service
public class QrCodeLoginService {

    @Autowired
    private QrCodeLoginMapper qrCodeLoginMapper;

    @Autowired
    private QrCodeService qrCodeService;

    @Autowired
    private AuthService authService;

    @Value("${qr.code.expire-seconds:300}")
    private int expireSeconds;

    /**
     * 生成二维码
     */
    public Map<String, Object> generateQrCode() {
        return generateQrCode(null, null, null, null, null);
    }

    /**
     * 生成带角色和层级信息的二维码
     */
//    @Transactional
    public Map<String, Object> generateQrCode(String role, String province, String city, String district, String street) {
        try {
            // 生成唯一token
            String qrToken = UUID.randomUUID().toString().replace("-", "");
            
            // 创建二维码登录记录
            QrCodeLogin qrCodeLogin = new QrCodeLogin();
            qrCodeLogin.setQrToken(qrToken);
            qrCodeLogin.setStatus(0); // 未扫描
            qrCodeLogin.setRole(role);
            qrCodeLogin.setProvince(province);
            qrCodeLogin.setCity(city);
            qrCodeLogin.setDistrict(district);
            qrCodeLogin.setStreet(street);
            qrCodeLogin.setCreateTime(LocalDateTime.now());
            qrCodeLogin.setExpireTime(LocalDateTime.now().plusSeconds(expireSeconds));
            
            qrCodeLoginMapper.insert(qrCodeLogin);

            // 生成二维码内容（前端扫码后会跳转到这个地址）
            StringBuilder qrContentBuilder = new StringBuilder("brewingmachine://login?token=");
            qrContentBuilder.append(qrToken);
            if (role != null) {
                qrContentBuilder.append("&role=").append(role);
            }
            
            String qrContent = qrContentBuilder.toString();
            
            // 生成二维码图片（Base64）
            String qrCodeImage = qrCodeService.generateQrCodeBase64(qrContent);

            Map<String, Object> result = new HashMap<>();
            result.put("qrToken", qrToken);
            result.put("qrCodeImage", qrCodeImage);
            result.put("expireTime", qrCodeLogin.getExpireTime().toString());

            log.info("生成二维码成功，token: {}, role: {}", qrToken, role);
            return result;

        } catch (Exception e) {
            log.error("生成二维码失败", e);
            throw new RuntimeException("生成二维码失败", e);
        }
    }

    /**
     * 查询二维码状态
     */
    public Map<String, Object> queryQrCodeStatus(String qrToken) {
        QrCodeLogin qrCodeLogin = qrCodeLoginMapper.findByQrToken(qrToken);
        
        Map<String, Object> result = new HashMap<>();
        
        if (qrCodeLogin == null) {
            result.put("status", -1); // 不存在
            result.put("message", "二维码不存在");
            return result;
        }
        
        // 检查是否过期
        if (LocalDateTime.now().isAfter(qrCodeLogin.getExpireTime())) {
            result.put("status", 3); // 已过期
            result.put("message", "二维码已过期");
            return result;
        }

        result.put("status", qrCodeLogin.getStatus());
        
        // 状态说明：0-未扫描，1-已扫描未确认，2-已确认登录，3-已过期
        switch (qrCodeLogin.getStatus()) {
            case 0:
                result.put("message", "等待扫描");
                break;
            case 1:
                result.put("message", "已扫描，等待确认");
                break;
            case 2:
                result.put("message", "登录成功");
                if (qrCodeLogin.getUserInfo() != null) {
                    result.put("userInfo", JSON.parseObject(qrCodeLogin.getUserInfo()));
                }
                result.put("userId", qrCodeLogin.getUserId());
                break;
            default:
                result.put("message", "未知状态");
        }

        return result;
    }

    /**
     * 扫描二维码（移动端调用）
     */
    @Transactional
    public Map<String, Object> scanQrCode(String qrToken) {
        QrCodeLogin qrCodeLogin = qrCodeLoginMapper.findByQrToken(qrToken);
        
        Map<String, Object> result = new HashMap<>();
        
        if (qrCodeLogin == null) {
            result.put("success", false);
            result.put("message", "二维码不存在");
            return result;
        }
        
        // 检查是否过期
        if (LocalDateTime.now().isAfter(qrCodeLogin.getExpireTime())) {
            result.put("success", false);
            result.put("message", "二维码已过期");
            return result;
        }

        // 检查状态
        if (qrCodeLogin.getStatus() != 0) {
            result.put("success", false);
            result.put("message", "二维码已被扫描或已使用");
            return result;
        }

        // 更新为已扫描状态
        int updateCount = qrCodeLoginMapper.scanQrCode(qrToken, LocalDateTime.now());
        
        if (updateCount > 0) {
            result.put("success", true);
            result.put("message", "扫描成功");
            log.info("二维码被扫描，token: {}", qrToken);
        } else {
            result.put("success", false);
            result.put("message", "扫描失败");
        }

        return result;
    }

    /**
     * 确认登录（移动端调用）
     */
    @Transactional
    public Map<String, Object> confirmLogin(String qrToken, Long userId, Map<String, Object> userInfo) {
        QrCodeLogin qrCodeLogin = qrCodeLoginMapper.findByQrToken(qrToken);
        
        Map<String, Object> result = new HashMap<>();
        
        if (qrCodeLogin == null) {
            result.put("success", false);
            result.put("message", "二维码不存在");
            return result;
        }
        
        // 检查是否过期
        if (LocalDateTime.now().isAfter(qrCodeLogin.getExpireTime())) {
            result.put("success", false);
            result.put("message", "二维码已过期");
            return result;
        }

        // 检查状态（必须是已扫描状态）
        if (qrCodeLogin.getStatus() != 1) {
            result.put("success", false);
            result.put("message", "二维码状态不正确，请先扫描");
            return result;
        }

        // 检查是否需要绑定角色
        if (qrCodeLogin.getRole() != null) {
            try {
                // 更新用户角色
                authService.updateUserRole(userId, qrCodeLogin.getRole());
                log.info("用户绑定角色成功，userId: {}, role: {}", userId, qrCodeLogin.getRole());
                result.put("roleBound", true);
                result.put("role", qrCodeLogin.getRole());
                
                // 可以根据需要进一步处理层级信息（province, city, district, street）
                // 例如更新用户的地址信息或创建相关的关系记录
            } catch (Exception e) {
                log.error("用户绑定角色失败，userId: {}, role: {}", userId, qrCodeLogin.getRole(), e);
                result.put("success", false);
                result.put("message", "角色绑定失败");
                return result;
            }
        } else {
            result.put("roleBound", false);
        }

        // 确认登录
        String userInfoJson = JSON.toJSONString(userInfo);
        int updateCount = qrCodeLoginMapper.confirmLogin(qrToken, userId, userInfoJson, LocalDateTime.now());
        
        if (updateCount > 0) {
            result.put("success", true);
            result.put("message", "登录成功");
            log.info("二维码登录确认成功，token: {}, userId: {}", qrToken, userId);
        } else {
            result.put("success", false);
            result.put("message", "登录失败");
        }

        return result;
    }
}

