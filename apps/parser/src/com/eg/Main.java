package com.eg;

import com.eg.parser.BeverageParser;
import com.eg.parser.ConfectioneryParser;
import com.eg.parser.Parser;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class Main {

    public static void main(String[] args) {
        List<Parser> parsers = new ArrayList<Parser>();
        parsers.add(new ConfectioneryParser());
        parsers.add(new BeverageParser());

        for (Parser parser : parsers) {
            try {
                parser.parse();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
