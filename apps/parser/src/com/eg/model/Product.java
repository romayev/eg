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
    private String productNotes;
    private String valueProposition;
    private String application;
    private String region;

    Product(CSVRecord record) {
        this.productName = record.get("Product Name");
        this.productDescription = record.get("Product Description");
        this.productNotes = record.get("Additional Key Features/Benefits/Notes");
        this.valueProposition = record.get("Value Proposition");
        this.application = record.get("Application");
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

    @Override
    public String toString() {
        return "Product{" + "\n" +
                " productName='" + productName + "\n" +
                " productDescription='" + productDescription + "\n" +
                " productNotes='" + productNotes + "\n" +
                " valueProposition='" + valueProposition + "\n" +
                " application='" + application + "\n" +
                " regions=" + region+ "\n" +
                '}';
    }

    public Map<String, Object> plist() {
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("productName", productName);
        map.put("productDescription", productDescription);
        map.put("productNotes", productNotes);
        map.put("valueProposition", valueProposition);
        map.put("application", application);
        map.put("region", region);
        return map;
    }
}
