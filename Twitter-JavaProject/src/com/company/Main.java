package com.company;

import java.sql.Connection;
import java.util.Scanner;

public class Main {

    public static void main(String[] args){

        SQLConnection sqlConnection = new SQLConnection();
        Connection connection = sqlConnection.getConnection();

        Scanner scanner = new Scanner(System.in);
        String newLine;
        while(true){
            newLine = scanner.nextLine();
            Input input = new Input(newLine, connection);
        }
    }
}
