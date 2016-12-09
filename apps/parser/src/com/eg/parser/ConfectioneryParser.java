package com.eg.parser;

import com.eg.model.Confectionery;
import com.eg.model.Product;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;

import java.io.*;
import java.nio.charset.Charset;
import java.util.*;

/**
 * Created by Alex Romayev on 11/16/16.
 */
public class ConfectioneryParser extends Parser {

    @Override
    String packageName() {
        return "confectionery";
    }

    @Override
    List<Product> product(CSVRecord record) {
        List<Product> list = new ArrayList<Product>();
        list.add(new Confectionery(record));
        return list;
    }
}
