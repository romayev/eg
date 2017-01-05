package com.eg.model;

import org.apache.commons.csv.CSVRecord;

import java.nio.charset.Charset;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by Alex Romayev on 11/16/16.
 */
public class Product {
    private String productName;
    private String productDescription;
    String valueProposition;
    private String region;
    private String priority;
    private String labelDeclaration;

    Product(Product other) {
        productName = other.productName;
        productDescription = other.productDescription;
        valueProposition = other.valueProposition;
        region = other.region;
        priority = other.priority;
        labelDeclaration = other.labelDeclaration;
    }

    Product(CSVRecord record) {
        productName = get(record, "Product Name");
        productDescription = get(record, "Product Description");
        priority = get(record, "Priority");
        labelDeclaration = get(record, "Label declaration");

        String region;
        if (!record.get("APAC").isEmpty()) {
            region = "APAC";
        } else if (!record.get("EMEA").isEmpty()) {
            region = "EMEA";
        } else if (!record.get("MEX").isEmpty()) {
            region = "MEX";
        } else if (!record.get("SA").isEmpty()) {
            region = "SA";
        } else {
            region = "US & Canada";
        }
        this.region = region;
    }

    void readValueProposition(CSVRecord record) {
        valueProposition = get(record, "Value Proposition");
    }

    String get(CSVRecord record, String column) {
        try {
            String text = record.get(column).trim();
            text = text.replace("\n", " ").replace("\r", " ");
            return text;
        } catch (Exception ignored) {
            System.out.println("WARN: Column not found: " + column);
        }
        return null;
    }

    public Map<String, Object> plist() {
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("productName", productName);
        map.put("productDescription", productDescription);
        map.put("valueProposition", valueProposition);
        map.put("region", region);
        map.put("priority", priority);
        map.put("labelDeclaration", labelDeclaration);
        return map;
    }

    @Override
    public String toString() {
        return "Product{" + "\n" +
                " productName='" + productName + "\n" +
                " productDescription='" + productDescription + "\n" +
                " labelDeclaration='" + labelDeclaration + '\'' +
                " valueProposition='" + valueProposition + "\n" +
                " regions=" + region+ "\n" +
                '}';
    }
}
