package com.eg;

import com.eg.parser.ConfectioneryParser;
import com.eg.parser.Parser;

import java.io.IOException;

public class Main {

    public static void main(String[] args) {
        Parser parser = new ConfectioneryParser();
        try {
            parser.parse();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
