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
    public void parse() throws IOException {
        ArrayList<Product> records = new ArrayList<Product>();

        File file = new File("csv/Confectionery.csv");
        CSVParser parser = CSVParser.parse(file, Charset.forName("x-MacRoman"), CSVFormat.EXCEL.withHeader().withAllowMissingColumnNames().withIgnoreHeaderCase().withIgnoreEmptyLines(true));

        Map<String, Integer> headers = parser.getHeaderMap();
        System.out.println("Headers: " + headers.keySet());
        try {
            for (CSVRecord record : parser) {
                // FIXME: withIgnoreEmptyLines(true) isn't ignoring empty lines
                if (record.get(0).isEmpty()) break;

                // Records
                records.add(new Confectionery(record));
            }
        } finally {
            parser.close();
        }

        // Add "All"
        savePlistProducts(records, packageName() + ".plist");
    }

    @Override
    String packageName() {
        return "confectionery";
    }
}
