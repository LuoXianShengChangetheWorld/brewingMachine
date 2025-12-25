package com.brewingmachine.area;

import java.io.Serial;
import java.io.Serializable;

/**
 * <h2>地区</h2>
 *
 * @since 1.0
 * @author 云上的云
 * @formatter:off
 */
public class Area
        implements Serializable {
    @Serial
    private static final long serialVersionUID = -6849794470754667710L;
    private final String name;
    private final String regionCode12;
    private final String regionCode6;
    private final String parentCode12;
    private final String parentCode6;
    private final String typeCode;
    private final int level;

    public Area(String name, String regionCode12, String regionCode6, String parentCode12, String parentCode6, String typeCode, AreaLevel level) {
        this.name = name;
        this.regionCode12 = regionCode12;
        this.regionCode6 = regionCode6;
        this.parentCode12 = parentCode12;
        this.parentCode6 = parentCode6;
        this.typeCode = typeCode;
        this.level = level.getValue();
    }

    public String getName() {
        return this.name;
    }

    public String getRegionCode12() {
        return this.regionCode12;
    }

    public String getRegionCode6() {
        return this.regionCode6;
    }

    public String getParentCode12() {
        return this.parentCode12;
    }

    public String getParentCode6() {
        return this.parentCode6;
    }

    public String getTypeCode() {
        return this.typeCode;
    }

    public int getLevel() {
        return this.level;
    }
}