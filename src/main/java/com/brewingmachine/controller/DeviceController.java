package com.brewingmachine.controller;

import com.brewingmachine.dto.Result;
import com.brewingmachine.service.AuthService;
import com.brewingmachine.service.DeviceService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/apis")
@RequiredArgsConstructor
public class DeviceController {

    private final DeviceService deviceService;
    private final AuthService authService;

    /**
     * 获取设备详情
     * POST /apis/device/info
     */
    @PostMapping("/device/info")
    public Result<DeviceService.DeviceDetailResponse> getDeviceInfo(@RequestHeader("Authorization") String token,
                                                                    @RequestBody Map<String, String> request) {
        try {
            // 验证token
            authService.getUserIdByToken(token);
            
            String sn = request.get("sn");
            if (sn == null || sn.trim().isEmpty()) {
                return Result.error("设备编号不能为空");
            }
            
            DeviceService.DeviceDetailResponse deviceInfo = deviceService.getDeviceDetail(sn);
            return Result.success(deviceInfo);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 设备列表（代理商端）
     * POST /apis/device/list (agent_api)
     */
    @PostMapping("/device/list")
    public Result<DeviceService.DeviceListResponse> getDeviceList(@RequestHeader("Authorization") String token,
                                                                  @RequestBody Map<String, Object> request) {
        try {
            Long userId = authService.getUserIdByToken(token);
            
            Integer page = request.get("page") != null ? Integer.parseInt(request.get("page").toString()) : 1;
            Integer size = request.get("size") != null ? Integer.parseInt(request.get("size").toString()) : 10;
            String status = request.get("status") != null ? request.get("status").toString() : null;
            String keyword = request.get("keyword") != null ? request.get("keyword").toString() : null;
            
            DeviceService.DeviceListResponse deviceList = deviceService.getDeviceList(page, size, status, keyword, userId);
            return Result.success(deviceList);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 修改设备（代理商端）
     * POST /apis/device/set (agent_api)
     */
    @PostMapping("/device/set")
    public Result<Void> updateDevice(@RequestHeader("Authorization") String token,
                                    @RequestBody Map<String, String> request) {
        try {
            authService.getUserIdByToken(token);
            
            String sn = request.get("sn");
            if (sn == null || sn.trim().isEmpty()) {
                return Result.error("设备编号不能为空");
            }
            
            String name = request.get("name");
            String storeIdStr = request.get("storeId");
            Long storeId = storeIdStr != null && !storeIdStr.trim().isEmpty() ? Long.parseLong(storeIdStr) : null;
            
            deviceService.updateDevice(sn, name, storeId);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 绑定设备（代理商端）
     * POST /apis/device/bind (agent_api)
     */
    @PostMapping("/device/bind")
    public Result<Void> bindDevice(@RequestHeader("Authorization") String token,
                                  @RequestBody Map<String, String> request) {
        try {
            authService.getUserIdByToken(token);
            
            String sn = request.get("sn");
            if (sn == null || sn.trim().isEmpty()) {
                return Result.error("设备编号不能为空");
            }
            
            String storeIdStr = request.get("storeId");
            if (storeIdStr == null || storeIdStr.trim().isEmpty()) {
                return Result.error("店铺ID不能为空");
            }
            
            Long storeId = Long.parseLong(storeIdStr);
            deviceService.bindDevice(sn, storeId);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 解除绑定设备（代理商端）
     * POST /apis/device/Unbind (agent_api)
     */
    @PostMapping("/device/Unbind")
    public Result<Void> unbindDevice(@RequestHeader("Authorization") String token,
                                    @RequestBody Map<String, String> request) {
        try {
            authService.getUserIdByToken(token);
            
            String sn = request.get("sn");
            if (sn == null || sn.trim().isEmpty()) {
                return Result.error("设备编号不能为空");
            }
            
            deviceService.unbindDevice(sn);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取槽位列表（代理商端）
     * POST /apis/device/slot/list (agent_api)
     */
    @PostMapping("/device/slot/list")
    public Result<Object> getDeviceSlots(@RequestHeader("Authorization") String token,
                                        @RequestBody Map<String, String> request) {
        try {
            authService.getUserIdByToken(token);
            
            String sn = request.get("sn");
            if (sn == null || sn.trim().isEmpty()) {
                return Result.error("设备编号不能为空");
            }
            
            var slots = deviceService.getDeviceSlots(sn);
            return Result.success(slots);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 修改槽位设置（代理商端）
     * POST /apis/device/slot/set (agent_api)
     */
    @PostMapping("/device/slot/set")
    public Result<Void> updateDeviceSlot(@RequestHeader("Authorization") String token,
                                       @RequestBody Map<String, String> request) {
        try {
            authService.getUserIdByToken(token);
            
            String sn = request.get("sn");
            if (sn == null || sn.trim().isEmpty()) {
                return Result.error("设备编号不能为空");
            }
            
            String slotId = request.get("slotId");
            if (slotId == null || slotId.trim().isEmpty()) {
                return Result.error("槽位ID不能为空");
            }
            
            String goodsIdStr = request.get("goodsId");
            Long goodsId = goodsIdStr != null && !goodsIdStr.trim().isEmpty() ? Long.parseLong(goodsIdStr) : null;
            
            String priceStr = request.get("price");
            Double price = priceStr != null && !priceStr.trim().isEmpty() ? Double.parseDouble(priceStr) : null;
            
            deviceService.updateDeviceSlot(sn, slotId, goodsId, price);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 锁定槽位（代理商端）
     * POST /apis/device/slot/lock (agent_api)
     */
    @PostMapping("/device/slot/lock")
    public Result<Void> lockDeviceSlot(@RequestHeader("Authorization") String token,
                                      @RequestBody Map<String, String> request) {
        try {
            authService.getUserIdByToken(token);
            
            String sn = request.get("sn");
            if (sn == null || sn.trim().isEmpty()) {
                return Result.error("设备编号不能为空");
            }
            
            String slotId = request.get("slotId");
            if (slotId == null || slotId.trim().isEmpty()) {
                return Result.error("槽位ID不能为空");
            }
            
            deviceService.lockDeviceSlot(sn, slotId);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 解锁槽位（代理商端）
     * POST /apis/device/slot/unlock (agent_api)
     */
    @PostMapping("/device/slot/unlock")
    public Result<Void> unlockDeviceSlot(@RequestHeader("Authorization") String token,
                                        @RequestBody Map<String, String> request) {
        try {
            authService.getUserIdByToken(token);
            
            String sn = request.get("sn");
            if (sn == null || sn.trim().isEmpty()) {
                return Result.error("设备编号不能为空");
            }
            
            String slotId = request.get("slotId");
            if (slotId == null || slotId.trim().isEmpty()) {
                return Result.error("槽位ID不能为空");
            }
            
            deviceService.unlockDeviceSlot(sn, slotId);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}