package com.company;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class SQLConnection {
    private String url = "jdbc:mysql://localhost:3306/db_phase2";
    private String username = "root";
    private String pass = "";
    private Connection connection;

    public SQLConnection(){
        try{
            Class.forName("com.mysql.jdbc.Driver");
            connection = DriverManager.getConnection(url, username, pass);
            if(connection!=null){
                System.out.println("Success");
            }
        }catch (ClassNotFoundException e){
            e.printStackTrace();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public Connection getConnection() {
        return connection;
    }
}
