package com.brewingmachine.mapper;

import com.brewingmachine.entity.QrCodeLogin;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;

/**
 * 二维码登录Mapper接口
 */
@Mapper
public interface QrCodeLoginMapper {

    /**
     * 插入二维码登录记录
     */
    int insert(QrCodeLogin qrCodeLogin);

    /**
     * 根据token查询
     */
    QrCodeLogin findByQrToken(@Param("qrToken") String qrToken);

    /**
     * 更新二维码状态
     */
    int updateStatusByToken(@Param("qrToken") String qrToken, @Param("status") Integer status);

    /**
     * 确认登录
     */
    int confirmLogin(@Param("qrToken") String qrToken, 
                     @Param("userId") Long userId, 
                     @Param("userInfo") String userInfo, 
                     @Param("confirmTime") LocalDateTime confirmTime);

    /**
     * 扫描二维码
     */
    int scanQrCode(@Param("qrToken") String qrToken, @Param("scanTime") LocalDateTime scanTime);

    /**
     * 清理过期数据
     */
    int deleteExpiredQrCodes(@Param("now") LocalDateTime now);
}

