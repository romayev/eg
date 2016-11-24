package com.eg.model;

import org.apache.commons.csv.CSVRecord;

import java.util.Map;

/**
 * Created by Alex Romayev on 11/16/16.
 */
public class Confectionery extends Product {
    private String selectionCriteria;
    private String suggestedUsageLevelInFormulations;
    private String recommendedMaxUsage;
    private String labelDeclaration;

    public Confectionery(CSVRecord record) {
        super(record);
        selectionCriteria = record.get("Selection criteria");
        suggestedUsageLevelInFormulations = record.get("Suggested % usage level in formulations");
        recommendedMaxUsage = record.get("Recommended max usage %");
        labelDeclaration = record.get("Label declaration");
    }

    @Override
    public Map<String, Object> plist() {
        Map<String, Object> map = super.plist();
        map.put("selectionCriteria", selectionCriteria);
        map.put("suggestedUsageLevelInFormulations", suggestedUsageLevelInFormulations);
        map.put("recommendedMaxUsage", recommendedMaxUsage);
        map.put("labelDeclaration", labelDeclaration);
        return map;
    }

    @Override
    public String toString() {
        return  super.toString() + "\n" +
                "Confectionery{" +
                " selectionCriteria='" + selectionCriteria + '\'' + "\n" +
                " suggestedUsageLevelInFormulations='" + suggestedUsageLevelInFormulations + '\'' + "\n" +
                " recommendedMaxUsage='" + recommendedMaxUsage + '\'' + "\n" +
                " labelDeclaration='" + labelDeclaration + '\'' +
                "\n" +
                "} ";
    }
}
