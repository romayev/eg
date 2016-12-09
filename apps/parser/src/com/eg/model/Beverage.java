package com.eg.model;

import org.apache.commons.csv.CSVRecord;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Created by Alex Romayev on 12/5/16.
 */
public class Beverage extends Product {
    private String segment;
    private String base;
    private String starchUseLabel;
    private String fatContent;
    private String proteinContent;
    private String features;
    private String productDescription;
    private List<Product> related;

    public Beverage(CSVRecord record) {
        super(record);
        segment = get(record, "Segment");
        base = get(record, "Base");
        starchUseLabel = get(record, "% Starch use level");
        fatContent = get(record, "Fat content");
        proteinContent = get(record, "Protein Content");
        productDescription = get(record, "Product Description");
        features = get(record, "Features");
        readValueProposition(record);
    }

    @Override
    void readValueProposition(CSVRecord record) {
        valueProposition = get(record, "Value Proposition 1");
        String valueProposition2 = get(record, "Value Proposition 2");
        addRelated(valueProposition2);

        String valueProposition3 = get(record, "Value Proposition 3");
        addRelated(valueProposition3);
    }

    private Beverage(Beverage other) {
        super(other);
        segment = other.segment;
        base = other.base;
        starchUseLabel = other.starchUseLabel;
        fatContent = other.fatContent;
        proteinContent = other.proteinContent;
        features = other.features;
        productDescription = other.productDescription;
    }

    private void addRelated (String valueProposition) {
        if (valueProposition != null && valueProposition.length() > 0) {
            if (related == null) {
                related = new ArrayList<Product>();
            }
            Beverage other = new Beverage(this);
            other.valueProposition = valueProposition;
            related.add(other);
        }
    }

    public List<Product> getRelated() {
        return related;
    }

    @Override
    public Map<String, Object> plist() {
        Map<String, Object> map = super.plist();
        map.put("segment", segment);
        map.put("base", base);
        map.put("starchUseLabel", starchUseLabel);
        map.put("fatContent", fatContent);
        map.put("proteinContent", proteinContent);
        map.put("features", features);
        map.put("productDescription", productDescription);
        return map;
    }
}
