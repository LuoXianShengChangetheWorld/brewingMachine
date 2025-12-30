package com.brewingmachine.controller;

import com.brewingmachine.dto.Result;
import com.brewingmachine.entity.Goods;
import com.brewingmachine.entity.GoodsPrice;
import com.brewingmachine.service.AuthService;
import com.brewingmachine.service.GoodsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/apis")
@RequiredArgsConstructor
public class GoodsController {

    private final GoodsService goodsService;
    private final AuthService authService;

    /**
     * 商品列表（商家端）
     * GET /apis/goods/list (mar_api)
     */
    @GetMapping("/goods/list")
    public Result<GoodsService.GoodsListResponse> getGoodsList(@RequestHeader("Authorization") String token,
                                                              @RequestParam(required = false) Integer page,
                                                              @RequestParam(required = false) Integer size,
                                                              @RequestParam(required = false) String keyword) {
        try {
            authService.getUserIdByToken(token);
            
            page = page != null ? page : 1;
            size = size != null ? size : 10;
            
            GoodsService.GoodsListResponse goods = goodsService.getGoodsList(page, size, keyword);
            return Result.success(goods);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 添加商品（商家端）
     * POST /apis/goods/add (mar_api)
     */
    @PostMapping("/goods/add")
    public Result<Map<String, String>> addGoods(@RequestHeader("Authorization") String token,
                                               @RequestBody Map<String, Object> request) {
        try {
            authService.getUserIdByToken(token);
            
            String name = request.get("name") != null ? request.get("name").toString() : null;
            if (name == null || name.trim().isEmpty()) {
                return Result.error("商品名称不能为空");
            }
            
            String cover = request.get("cover") != null ? request.get("cover").toString() : null;
            String description = request.get("description") != null ? request.get("description").toString() : null;
            String categoryIdStr = request.get("categoryId") != null ? request.get("categoryId").toString() : null;
            Long categoryId = null;
            if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
                try {
                    categoryId = Long.parseLong(categoryIdStr);
                } catch (NumberFormatException e) {
                    return Result.error("分类ID格式错误");
                }
            }
            
            // 处理价格规格
            List<GoodsService.GoodsPriceSpec> specs = new ArrayList<>();
            if (request.get("specs") != null && request.get("specs") instanceof List) {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> specsList = (List<Map<String, Object>>) request.get("specs");
                for (Map<String, Object> specMap : specsList) {
                    GoodsService.GoodsPriceSpec spec = new GoodsService.GoodsPriceSpec();
                    if (specMap.get("capacity") != null) {
                        spec.setCapacity(Integer.parseInt(specMap.get("capacity").toString()));
                    }
                    if (specMap.get("price") != null) {
                        spec.setPrice(Double.parseDouble(specMap.get("price").toString()));
                    }
                    specs.add(spec);
                }
            }
            
            Goods goods = goodsService.addGoods(name, cover, description, categoryId, specs);
            
            Map<String, String> response = new HashMap<>();
            response.put("id", goods.getId().toString());
            response.put("name", goods.getName());
            
            return Result.success(response);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 修改商品（商家端）
     * POST /apis/goods/set (mar_api)
     */
    @PostMapping("/goods/set")
    public Result<Void> updateGoods(@RequestHeader("Authorization") String token,
                                   @RequestBody Map<String, Object> request) {
        try {
            authService.getUserIdByToken(token);
            
            String idStr = request.get("id") != null ? request.get("id").toString() : null;
            if (idStr == null || idStr.trim().isEmpty()) {
                return Result.error("商品ID不能为空");
            }
            
            Long id = Long.parseLong(idStr);
            String name = request.get("name") != null ? request.get("name").toString() : null;
            String cover = request.get("cover") != null ? request.get("cover").toString() : null;
            String description = request.get("description") != null ? request.get("description").toString() : null;
            String categoryIdStr = request.get("categoryId") != null ? request.get("categoryId").toString() : null;
            Long categoryId = categoryIdStr != null && !categoryIdStr.trim().isEmpty() ? Long.parseLong(categoryIdStr) : null;
            
            // 处理价格规格
            List<GoodsService.GoodsPriceSpec> specs = new ArrayList<>();
            if (request.get("specs") != null && request.get("specs") instanceof List) {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> specsList = (List<Map<String, Object>>) request.get("specs");
                for (Map<String, Object> specMap : specsList) {
                    GoodsService.GoodsPriceSpec spec = new GoodsService.GoodsPriceSpec();
                    if (specMap.get("capacity") != null) {
                        spec.setCapacity(Integer.parseInt(specMap.get("capacity").toString()));
                    }
                    if (specMap.get("price") != null) {
                        spec.setPrice(Double.parseDouble(specMap.get("price").toString()));
                    }
                    specs.add(spec);
                }
            }
            
            goodsService.updateGoods(id, name, cover, description, categoryId, specs);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 删除商品（商家端）
     * POST /apis/goods/del (mar_api)
     */
    @PostMapping("/goods/del")
    public Result<Void> deleteGoods(@RequestHeader("Authorization") String token,
                                   @RequestBody Map<String, String> request) {
        try {
            authService.getUserIdByToken(token);
            
            String idStr = request.get("id") != null ? request.get("id").toString() : null;
            if (idStr == null || idStr.trim().isEmpty()) {
                return Result.error("商品ID不能为空");
            }
            
            Long id = Long.parseLong(idStr);
            goodsService.deleteGoods(id);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 价格规格列表（商家端）
     * GET /apis/goods/price/list (mar_api)
     */
    @GetMapping("/goods/price/list")
    public Result<GoodsService.GoodsPriceListResponse> getGoodsPriceList(@RequestHeader("Authorization") String token,
                                                                        @RequestParam String goodsId) {
        try {
            authService.getUserIdByToken(token);
            
            if (goodsId == null || goodsId.trim().isEmpty()) {
                return Result.error("商品ID不能为空");
            }
            
            Long id = Long.parseLong(goodsId);
            GoodsService.GoodsPriceListResponse prices = goodsService.getGoodsPriceList(id);
            return Result.success(prices);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 修改价格规格（商家端）
     * POST /apis/goods/price/set (mar_api)
     */
    @PostMapping("/goods/price/set")
    public Result<Void> updateGoodsPrice(@RequestHeader("Authorization") String token,
                                        @RequestBody Map<String, Object> request) {
        try {
            authService.getUserIdByToken(token);
            
            String idStr = request.get("id") != null ? request.get("id").toString() : null;
            if (idStr == null || idStr.trim().isEmpty()) {
                return Result.error("价格规格ID不能为空");
            }
            
            Long id = Long.parseLong(idStr);
            String priceStr = request.get("price") != null ? request.get("price").toString() : null;
            if (priceStr == null || priceStr.trim().isEmpty()) {
                return Result.error("价格不能为空");
            }
            
            Double price = Double.parseDouble(priceStr);
            goodsService.updateGoodsPrice(id, price);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 删除价格规格（商家端）
     * POST /apis/goods/price/del (mar_api)
     */
    @PostMapping("/goods/price/del")
    public Result<Void> deleteGoodsPrice(@RequestHeader("Authorization") String token,
                                        @RequestBody Map<String, String> request) {
        try {
            authService.getUserIdByToken(token);
            
            String idStr = request.get("id");
            if (idStr == null || idStr.trim().isEmpty()) {
                return Result.error("价格规格ID不能为空");
            }
            
            Long id = Long.parseLong(idStr);
            goodsService.deleteGoodsPrice(id);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}