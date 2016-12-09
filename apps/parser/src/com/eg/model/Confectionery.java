package com.eg.model;

import org.apache.commons.csv.CSVRecord;

import java.util.Map;

/**
 * Created by Alex Romayev on 11/16/16.
 */
public class Confectionery extends Product {
    private String application;
    private String selectionCriteria;
    private String suggestedUsageLevelInFormulations;
    private String recommendedMaxUsage;
    private String features;

    public Confectionery(CSVRecord record) {
        super(record);
        application = get(record, "Application");
        selectionCriteria = get(record, "Selection criteria");
        suggestedUsageLevelInFormulations = get(record, "Suggested % usage level in formulations");
        recommendedMaxUsage = get(record, "Recommended max usage %");
        features = get(record, "Additional Key Features/Benefits/Notes");
        readValueProposition(record);
    }

    @Override
    public Map<String, Object> plist() {
        Map<String, Object> map = super.plist();
        map.put("application", application);
        map.put("selectionCriteria", selectionCriteria);
        map.put("suggestedUsageLevelInFormulations", suggestedUsageLevelInFormulations);
        map.put("recommendedMaxUsage", recommendedMaxUsage);
        map.put("features", features);
        return map;
    }

    @Override
    public String toString() {
        return  super.toString() + "\n" +
                "Confectionery{" +
                " application='" + application + "\n" +
                " selectionCriteria='" + selectionCriteria + '\'' + "\n" +
                " suggestedUsageLevelInFormulations='" + suggestedUsageLevelInFormulations + '\'' + "\n" +
                " recommendedMaxUsage='" + recommendedMaxUsage + '\'' + "\n" +
                " features='" + features + "\n" +
                "\n" +
                "} ";
    }
}
