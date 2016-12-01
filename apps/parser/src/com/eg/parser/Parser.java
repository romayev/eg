package com.eg.parser;

import com.dd.plist.NSArray;
import com.dd.plist.NSDictionary;
import com.dd.plist.PropertyListParser;
import com.eg.model.Product;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;

import java.io.*;
import java.util.*;

/**
 * Created by Alex Romayev on 11/16/16.
 */
abstract public class Parser {
    abstract public void parse() throws IOException;
    abstract String packageName();

    void savePlistProducts(Collection<Product> products, String fileName) throws IOException {
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
