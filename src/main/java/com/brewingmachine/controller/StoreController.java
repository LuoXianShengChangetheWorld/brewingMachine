package com.brewingmachine.controller;

import com.brewingmachine.dto.Result;
import com.brewingmachine.entity.Store;
import com.brewingmachine.entity.Category;
import com.brewingmachine.dto.response.StoreDetailResponse;
import com.brewingmachine.dto.response.StoreListResponse;
import com.brewingmachine.dto.response.CategoryListResponse;
import com.brewingmachine.dto.response.CategoryItem;
import com.brewingmachine.service.AuthService;
import com.brewingmachine.service.StoreService;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/apis")
public class StoreController {

    private final StoreService storeService;
    private final AuthService authService;

    public StoreController(StoreService storeService, AuthService authService) {
        this.storeService = storeService;
        this.authService = authService;
    }

    /**
     * 获取店铺详情
     * POST /apis/store/get
     */
    @PostMapping("/store/get")
    public Result<StoreDetailResponse> getStore(@RequestHeader("Authorization") String token,
                                               @RequestBody Map<String, String> request) {
        try {
            authService.getUserIdByToken(token);
            
            String idStr = request.get("id") != null ? request.get("id").toString() : null;
            if (idStr == null || idStr.trim().isEmpty()) {
                return Result.error("店铺ID不能为空");
            }
            
            Long id = Long.parseLong(idStr);
            StoreDetailResponse store = storeService.getStoreDetail(id);
            return Result.success(store);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 店铺列表
     * POST /apis/store/list
     */
    @PostMapping("/store/list")
    public Result<StoreListResponse> getStoreList(@RequestHeader("Authorization") String token,
                                                 @RequestBody Map<String, Object> request) {
        try {
            authService.getUserIdByToken(token);
            
            Integer page = request.get("page") != null ? Integer.parseInt(request.get("page").toString()) : 1;
            Integer size = request.get("size") != null ? Integer.parseInt(request.get("size").toString()) : 10;
            String keyword = request.get("keyword") != null ? request.get("keyword").toString() : null;
            Double latitude = request.get("latitude") != null ? Double.parseDouble(request.get("latitude").toString()) : null;
            Double longitude = request.get("longitude") != null ? Double.parseDouble(request.get("longitude").toString()) : null;
            
            StoreListResponse stores = storeService.getStoreList(page, size, keyword, latitude, longitude);
            return Result.success(stores);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 修改店铺（商家端）
     * POST /apis/store/set (mar_api)
     */
    @PostMapping("/store/set")
    public Result<Void> updateStore(@RequestHeader("Authorization") String token,
                                   @RequestBody Map<String, String> request) {
        try {
            authService.getUserIdByToken(token);
            
            String idStr = request.get("id");
            if (idStr == null || idStr.trim().isEmpty()) {
                return Result.error("店铺ID不能为空");
            }
            
            Long id = Long.parseLong(idStr);
            String name = request.get("name");
            String address = request.get("address");
            String cover = request.get("cover");
            
            storeService.updateStore(id, name, address, cover);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 添加店铺（代理商端）
     * POST /apis/store/add (agent_api)
     */
    @PostMapping("/store/add")
    public Result<Map<String, String>> addStore(@RequestHeader("Authorization") String token,
                                               @RequestBody Map<String, Object> request) {
        try {
            Long userId = authService.getUserIdByToken(token);
            
            String name = request.get("name") != null ? request.get("name").toString() : null;
            String address = request.get("address") != null ? request.get("address").toString() : null;
            if (name == null || name.trim().isEmpty()) {
                return Result.error("店铺名称不能为空");
            }
            if (address == null || address.trim().isEmpty()) {
                return Result.error("店铺地址不能为空");
            }
            
            Double latitude = request.get("latitude") != null ? Double.parseDouble(request.get("latitude").toString()) : null;
            Double longitude = request.get("longitude") != null ? Double.parseDouble(request.get("longitude").toString()) : null;
            if (latitude == null || longitude == null) {
                return Result.error("经纬度不能为空");
            }
            
            Store store = storeService.addStore(name, address, latitude, longitude, userId);
            
            Map<String, String> response = new HashMap<>();
            response.put("id", store.getId().toString());
            response.put("name", store.getName());
            response.put("address", store.getAddress());
            
            return Result.success(response);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 删除店铺（代理商端）
     * POST /apis/store/del (agent_api)
     */
    @PostMapping("/store/del")
    public Result<Void> deleteStore(@RequestHeader("Authorization") String token,
                                   @RequestBody Map<String, String> request) {
        try {
            authService.getUserIdByToken(token);
            
            String idStr = request.get("id");
            if (idStr == null || idStr.trim().isEmpty()) {
                return Result.error("店铺ID不能为空");
            }
            
            Long id = Long.parseLong(idStr);
            storeService.deleteStore(id);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 店铺下拉数据（代理商端）
     * POST /apis/store/dim (agent_api)
     */
    @PostMapping("/store/dim")
    public Result<List<Map<String, String>>> getStoreDropdown(@RequestHeader("Authorization") String token,
                                                            @RequestBody Map<String, Object> request) {
        try {
            Long userId = authService.getUserIdByToken(token);
            
            List<Store> stores = storeService.getStoreDropdown(userId);
            
            List<Map<String, String>> response = new ArrayList<>();
            for (Store store : stores) {
                Map<String, String> item = new HashMap<>();
                item.put("id", store.getId().toString());
                item.put("name", store.getName());
                response.add(item);
            }
            
            return Result.success(response);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 分类列表（商家端）
     * POST /apis/store/category/list (mar_api)
     */
    @PostMapping("/store/category/list")
    public Result<CategoryListResponse> getCategoryList(@RequestHeader("Authorization") String token,
                                                       @RequestBody Map<String, String> request) {
        try {
            authService.getUserIdByToken(token);
            
            String storeIdStr = request.get("storeId");
            Long storeId = storeIdStr != null && !storeIdStr.trim().isEmpty() ? Long.parseLong(storeIdStr) : null;
            
            CategoryListResponse categories = storeService.getCategoryList(storeId);
            return Result.success(categories);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 添加分类（商家端）
     * POST /apis/store/category/add (mar_api)
     */
    @PostMapping("/store/category/add")
    public Result<Map<String, String>> addCategory(@RequestHeader("Authorization") String token,
                                                  @RequestBody Map<String, Object> request) {
        try {
            authService.getUserIdByToken(token);
            
            String name = request.get("name") != null ? request.get("name").toString() : null;
            if (name == null || name.trim().isEmpty()) {
                return Result.error("分类名称不能为空");
            }
            
            Integer sort = request.get("sort") != null ? Integer.parseInt(request.get("sort").toString()) : null;
            
            Category category = storeService.addCategory(name, sort, null);
            
            Map<String, String> response = new HashMap<>();
            response.put("id", category.getId().toString());
            response.put("name", category.getName());
            response.put("sort", category.getSort().toString());
            
            return Result.success(response);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 修改分类（商家端）
     * POST /apis/store/category/set (mar_api)
     */
    @PostMapping("/store/category/set")
    public Result<Void> updateCategory(@RequestHeader("Authorization") String token,
                                      @RequestBody Map<String, Object> request) {
        try {
            authService.getUserIdByToken(token);
            
            String idStr = request.get("id") != null ? request.get("id").toString() : null;
            if (idStr == null || idStr.trim().isEmpty()) {
                return Result.error("分类ID不能为空");
            }
            
            Long id = Long.parseLong(idStr);
            String name = request.get("name") != null ? request.get("name").toString() : null;
            Integer sort = request.get("sort") != null ? Integer.parseInt(request.get("sort").toString()) : null;
            
            storeService.updateCategory(id, name, sort);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 删除分类（商家端）
     * POST /apis/store/category/del (mar_api)
     */
    @PostMapping("/store/category/del")
    public Result<Void> deleteCategory(@RequestHeader("Authorization") String token,
                                      @RequestBody Map<String, String> request) {
        try {
            authService.getUserIdByToken(token);
            
            String idStr = request.get("id");
            if (idStr == null || idStr.trim().isEmpty()) {
                return Result.error("分类ID不能为空");
            }
            
            Long id = Long.parseLong(idStr);
            storeService.deleteCategory(id);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 分类下拉数据（商家端）
     * POST /apis/store/category/dim (mar_api)
     */
    @PostMapping("/store/category/dim")
    public Result<List<Map<String, String>>> getCategoryDropdown(@RequestHeader("Authorization") String token,
                                                                @RequestBody Map<String, String> request) {
        try {
            authService.getUserIdByToken(token);
            
            String storeIdStr = request.get("storeId");
            Long storeId = storeIdStr != null && !storeIdStr.trim().isEmpty() ? Long.parseLong(storeIdStr) : null;
            
            CategoryListResponse categories = storeService.getCategoryList(storeId);
            
            List<Map<String, String>> response = new ArrayList<>();
            for (CategoryItem item : categories.getRecords()) {
                Map<String, String> categoryItem = new HashMap<>();
                categoryItem.put("id", item.getId());
                categoryItem.put("name", item.getName());
                response.add(categoryItem);
            }
            
            return Result.success(response);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}