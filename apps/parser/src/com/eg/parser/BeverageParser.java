package com.eg.parser;

import com.eg.model.Beverage;
import com.eg.model.Product;
import org.apache.commons.csv.CSVRecord;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Alex Romayev on 12/5/16.
 */
public class BeverageParser extends Parser {
    @Override
    String packageName() {
        return "beverages";
    }

    @Override
    List<Product> product(CSVRecord record) {
        List<Product> list = new ArrayList<Product>();
        Beverage beverage = new Beverage(record);
        list.add(beverage);
        List<Product> related = beverage.getRelated();
        if (related != null) {
            list.addAll(related);
        }
        return list;
    }

}
