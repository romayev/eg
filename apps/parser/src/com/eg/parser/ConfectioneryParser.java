package com.eg.parser;

import com.eg.model.Confectionery;
import com.eg.model.Product;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;
import java.util.*;

/**
 * Created by Alex Romayev on 11/16/16.
 */
public class ConfectioneryParser extends Parser {
    public void parse() throws IOException {
        Set<String> valuePropositions = new TreeSet<String>();
        valuePropositions.add("All");

        Set<String> applications = new TreeSet<String>();
        applications.add("All");
        ArrayList<Product> records = new ArrayList<Product>();

        Reader reader = new BufferedReader(new FileReader("csv/Confectionery_CSV_Macintosh_NotepadPlus.csv"));
        CSVParser parser = new CSVParser(reader, CSVFormat.EXCEL.withHeader().withAllowMissingColumnNames().withIgnoreHeaderCase().withIgnoreEmptyLines(true));

        Map headers = parser.getHeaderMap();
        System.out.println("Headers: " + headers.keySet());

        TreeMap h = new TreeMap(headers);
        Boolean equals = headers.containsKey("Value Proposition");
        System.out.println("equals: " + equals);
        try {
            for (CSVRecord record : parser) {
                // FIXME: withIgnoreEmptyLines(true) isn't ignoring empty lines
                if (record.get(0).isEmpty()) break;

                // Value proposition
                String value = record.get("Value Proposition");
                if (!value.isEmpty()) {
                    valuePropositions.add(value);
                }

                // Application
                value = record.get("Application");
                if (!value.isEmpty()) {
                    applications.add(value);
                }

                // Records
                records.add(new Confectionery(record));
            }
        } finally {
            parser.close();
        }

        // Add "All"
        savePlistArray(valuePropositions, packageName() + "-value-propositions.plist");
        savePlistArray(applications, packageName() + "-applications.plist");
        savePlistProducts(records, packageName() + "-records.plist");
    }

    @Override
    String packageName() {
        return "confectionery";
    }
}
