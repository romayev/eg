package com.eg.parser;

import com.dd.plist.NSArray;
import com.dd.plist.PropertyListParser;
import com.eg.model.Product;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;

import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;

/**
 * Created by Alex Romayev on 11/16/16.
 */
abstract public class Parser {
    abstract String packageName();
    abstract List<Product> product(CSVRecord record);

    public void parse() throws IOException {
        ArrayList<Product> records = new ArrayList<Product>();

        File file = new File("csv/" + packageName() + ".csv");
        CSVParser parser = CSVParser.parse(file, Charset.forName("x-MacRoman"), CSVFormat.EXCEL.withHeader()
                .withAllowMissingColumnNames().withIgnoreHeaderCase().withIgnoreEmptyLines(true).withTrim(true));

        Map<String, Integer> headers = parser.getHeaderMap();
        System.out.println("Headers: " + headers.keySet());
        try {
            for (CSVRecord record : parser) {
                // FIXME: withIgnoreEmptyLines(true) isn't ignoring empty lines
                if (record.get(0).isEmpty()) break;

                // Records
                records.addAll(product(record));
            }
        } finally {
            parser.close();
        }

        // Add "All"
        savePlistProducts(records, packageName() + ".plist");
    }

    private void savePlistProducts(Collection<Product> products, String fileName) throws IOException {
        NSArray array = new NSArray(products.size());
        int i = 0;
        for (Product product: products) {
            array.setValue(i++, product.plist());
        }

        File file = getFile(fileName);
        PropertyListParser.saveAsXML(array, file);
    }

    private File getFile(String fileName) throws IOException {
        File dir = new File("plist");
        if (!dir.exists()) {
            if (!dir.mkdirs()) {
                System.out.println("ERROR: failed to create directories");
            }
        }

        File file = new File(dir, fileName);
        if (!file.exists()) {
            if (!file.createNewFile()) {
                System.out.println("ERROR: failed to create file: " + fileName);
            }
        }
        return file;
    }

}
