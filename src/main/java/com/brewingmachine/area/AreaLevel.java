package com.brewingmachine.area;

/**
 * <h2>地区级别</h2>
 *
 * @since 1.0
 * @author 云上的云
 * @formatter:off
 */
public enum AreaLevel {
    PROVINCE(1, "省级"),
    CITY(2, "市级"),
    COUNTY(3, "县级"),
    TOWN(4, "镇级"),
    VILLAGE(5, "村级");

    /**
     * <p>
     *     层级数值权重.
     * </p>
     */
    private final int value;
    /**
     * <p>
     *     层级名称描述.
     * </p>
     */
    private final String description;

    AreaLevel(int value, String description) {
        this.value = value;
        this.description = description;
    }

    public int getValue() {
        return this.value;
    }

    public String getDescription() {
        return this.description;
    }
}