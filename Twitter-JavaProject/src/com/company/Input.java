package com.company;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class Input {

    private String input;
    private String[] partsOfInput;
    private String function;
    private String[] data;

    private Connection connection;
    private String query;
    private String str_tmp;
    private boolean flagQuery;
    private ResultSet result;
    private boolean resultFlag;

    public Input(String newInput, Connection connection){
        input = newInput;
        partsOfInput = input.split(":");
        function = partsOfInput[0].toLowerCase();
        if(partsOfInput.length > 1) {
            data = partsOfInput[1].split(" ");
        }

        this.connection = connection;
        flagQuery = true;
        resultFlag = false;
        str_tmp = "";

        checkRequest();
    }

    public void checkRequest(){
        // help
        if(function.equals("help")){
            printHelpList();
            flagQuery = false;


            // create an account
        }else if(function.equals("create_an_account")){
            str_tmp  = "";
            for (int i = 0; i < data.length; i++) {
                if(i >= 6){
                    str_tmp = str_tmp + data[i] + " ";
                }
            }
            query = "CALL create_an_account ('" + data[1] + "', '" + data[2] + "', '" + data[3] + "', '" + data[4] + "', '"+ data[5] + "', '" + str_tmp + "');" ;


            // login
        }else if(function.equals("login")){
            query = "CALL login ('" + data[1] + "', '" + data[2] + "');" ;


            // get user logins
        }else if(function.equals("get_user_logins")){
            resultFlag = true;
            query = "CALL get_user_logins ();" ;


            // new post
        }else if(function.equals("new_post")){
            str_tmp = "";
            for (int i = 0; i < data.length; i++) {
                if(i >= 1){
                    str_tmp = str_tmp + data[i] + " ";
                }
            }
            query = "CALL new_post ('" + str_tmp + "');" ;



            // get current-user posts
        }else if(function.equals("get_user_posts")){
            resultFlag = true;
            query = "CALL get_user_posts ();" ;


            // follow user
        }else if(function.equals("follow_user")){
            query = "CALL follow_user ('" + data[1] + "');" ;


            // unfollow user
        }else if(function.equals("unfollow_user")){
            query = "CALL unfollow_user ('" + data[1] + "');" ;


            // block user
        }else if(function.equals("block_user")){
            query = "CALL block_user ('" + data[1] + "');" ;


            // unblock user
        }else if(function.equals("unblock_user")){
            query = "CALL unblock_user ('" + data[1] + "');" ;


            // get following activities
        }else if(function.equals("get_following_activities")){
            resultFlag = true;
            query = "CALL get_following_activities ();" ;


            // get user activities
        }else if(function.equals("get_user_activities")){
            resultFlag = true;
            query = "CALL get_user_activities ('" + data[1] + "');" ;


            // commenting
        }else if(function.equals("commenting")){
            // comment 1
            if(data[2].equals("1")){
                str_tmp  = "";
                for (int i = 0; i < data.length-2; i++) {
                    if(i >= 3){
                        str_tmp = str_tmp + data[i] + " ";
                    }
                }

                query = "CALL commenting (" + data[1] + ", " + data[2] + ", '" + str_tmp + "', " + data[data.length-2] + ", "+ data[data.length-1] + ");" ;

                // comment 2
            }else if(data[2].equals("2")){
                str_tmp  = "";
                for (int i = 0; i < data.length; i++) {
                    if(i >= 5){
                        str_tmp = str_tmp + data[i] + " ";
                    }
                }
                query = "CALL commenting (" + data[1] + ", " + data[2] + ", " + data[3] + ", " + data[4] + ", '" + str_tmp + "');" ;

            }else{
                System.out.println("invalid content-type!");
            }


            // get comments
        }else if(function.equals("get_comments")){
            resultFlag = true;
            query = "CALL get_comments (" + data[1] + ");" ;


            // add hahtag
        }else if(function.equals("add_hashtag")){
            query = "CALL add_hashtag (" + data[1] + ", '" + data[2] + "');";


            // get posts with specific hashtag
        }else if(function.equals("get_posts_with_specific_hashtag")){
            resultFlag = true;
            query = "CALL get_posts_with_specific_hashtag ('" + data[1] + "');" ;


            // like posts
        }else if(function.equals("like_posts")){
            query = "CALL like_posts (" + data[1] + ");" ;


            // get number of likes
        }else if(function.equals("get_number_of_likes")){
            resultFlag = true;
            query = "CALL get_number_of_likes (" + data[1] + ");" ;


            // get list of like username
        }else if(function.equals("get_list_of_like_username")){
            resultFlag = true;
            query = "CALL get_list_of_like_username (" + data[1] + ");" ;


            // get list of popular posts
        }else if(function.equals("get_list_of_popular_posts")){
            resultFlag = true;
            query = "CALL get_list_of_popular_posts ();" ;


            // send message
        }else if(function.equals("send_message")){
            str_tmp  = "";
            for (int i = 0; i < data.length-1; i++) {
                if(i >= 3){
                    str_tmp = str_tmp + data[i] + " ";
                }
            }
            // text
            if(data[2].equals("0")){
                query = "CALL send_message ('" + data[1] + "', " + data[2] + ", '" + str_tmp + "', " + data[data.length-1] +  ");" ;
                // post
            }else if(data[2].equals("1")){
                query = "CALL send_message ('" + data[1] + "', " + data[2] + ", " + str_tmp + ", " + data[data.length-1] +  ");" ;
            }else{
                System.out.println("invalid message-type!");
            }


            // get list of received message from user
        }else if(function.equals("get_list_of_received_message_from_user")){
            resultFlag = true;
            query = "CALL get_list_of_received_message_from_user ('" + data[1] + "');" ;


            // get list of sender username
        }else if(function.equals("get_list_of_sender_username")){
            resultFlag = true;
            query = "CALL get_list_of_sender_username ();" ;


            // invalid statements
        }else{
            System.err.println("Invalid statement!");
            flagQuery = false;
        }

        if(flagQuery == true){
            try {
                System.out.println(query);
                System.out.println();

                Statement statement = connection.createStatement();
                if(resultFlag == false){
                    statement.execute(query);
                }else{
                    result = statement.executeQuery(query);
                    printResult(function, result);
                }

            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    public void printHelpList () {
        System.out.println(
                "\u25B7 List of statements : " + "\n" +
                        "   \u25B8 help:  => show list of statements and arguments" + "\n\n" +
                        "   \u25B8 create_an_account: <first_name> <last_name> <username> <pass> <birth_date> <biography>" + "\n" +
                        "   \u25B8 login: <username> <pass> " + "\n" +
                        "   \u25B8 get_user_logins: " + "\n" +
                        "   \u25B8 new_post: <post_content>" + "\n" +
                        "   \u25B8 get_user_posts:" + "\n" +
                        "   \u25B8 follow_user: <following_username>" + "\n" +
                        "   \u25B8 unfollow_user: <following_username>" + "\n" +
                        "   \u25B8 block_user: <blocking_username>" + "\n" +
                        "   \u25B8 unblock_user: <blocking_username>" + "\n" +
                        "   \u25B8 get_following_activities:" + "\n" +
                        "   \u25B8 get_user_activities: <username>" + "\n" +
                        "   \u25B8 commenting: <main_post_id> <type> <comment1_content> <comment1_id> <comment2_content>" + "\n" +
                        "   \u25B8 get_comments: <post_id>" + "\n" +
                        "   \u25B8 add_hashtag: <post_id> <hashtag_content>" + "\n" +
                        "   \u25B8 get_posts_with_specific_hashtag: <hashtag_content>" + "\n" +
                        "   \u25B8 like_posts: <post_id>" + "\n" +
                        "   \u25B8 get_number_of_likes: <post_id>" + "\n" +
                        "   \u25B8 get_list_of_like_username: <post_id>" + "\n" +
                        "   \u25B8 get_list_of_popular_posts:" + "\n" +
                        "   \u25B8 send_message: <receiver_username> <content_type> <text> <post_id>" + "\n" +
                        "   \u25B8 get_list_of_received_message_from_user: <username>" + "\n" +
                        "   \u25B8 get_list_of_sender_username:" + "\n"
        );
    }

    public void printResult(String function, ResultSet result) throws SQLException {

        // get user logins
        if(function.equals("get_user_logins")){
            System.out.println("<login_time>");
            System.out.println("-------------");
            while (result.next()){
                String login_time = String.valueOf(result.getTimestamp(1));
                System.out.println(login_time);
            }

            // get current-user posts
        }else if(function.equals("get_user_posts")){
            System.out.println("<post_id> - <post_content>");
            System.out.println("---------------------------");
            while (result.next()){
                String post_id = String.valueOf(result.getString(1));
                String post_content = String.valueOf(result.getString(2));
                if(post_id.length() == 1){
                    System.out.println(post_id + "   ||  " + post_content);
                }else if(post_id.length() == 2){
                    System.out.println(post_id + "  ||  " + post_content);
                }
            }

            // get following activities
        }else if(function.equals("get_following_activities")){
            System.out.println("<post_time> - <post_content>");
            System.out.println("-----------------------------");
            while (result.next()){
                String post_content = String.valueOf(result.getString(1));
                String post_time = String.valueOf(result.getTimestamp(2));
                System.out.println(post_time + "  ||  " + post_content);
            }
            // get user activities
        }else if(function.equals("get_user_activities")){
            System.out.println("<post_content>");
            System.out.println("--------------");
            while (result.next()){
                String post_content = String.valueOf(result.getString(1));
                System.out.println(post_content);
            }

            // get comments
        }else if(function.equals("get_comments")){
            System.out.println("<comment1_post_id> - <comment1_post_content>");
            System.out.println("--------------------------------------------");
            while (result.next()){
                String c1_post_id = String.valueOf(result.getString(1));
                String c1_post_content = String.valueOf(result.getString(2));
                if(c1_post_id.length() == 1){
                    System.out.println(c1_post_id + "   ||  " + c1_post_content);
                }else if(c1_post_id.length() == 2){
                    System.out.println(c1_post_id + "  ||  " + c1_post_content);
                }
            }

            // get posts with specific hashtag
        }else if(function.equals("get_posts_with_specific_hashtag")){
            System.out.println("<post_id> - <post_time> - <post_username> - <post_content>");
            System.out.println("----------------------------------------------------------");
            while (result.next()){
                String post_id = String.valueOf(result.getString(1));
                String post_content = String.valueOf(result.getString(2));
                String post_username = String.valueOf(result.getString(3));
                String post_time = String.valueOf(result.getTimestamp(4));
                if(post_id.length() == 1){
                    System.out.println(post_id + "   ||  " + post_time + "   ||  " + post_username+ "   ||  " + post_content);
                }else if(post_id.length() == 2){
                    System.out.println(post_id + "  ||  " + post_time + "   ||  " + post_username + "   ||  " + post_content);
                }
            }

            // get number of likes
        }else if(function.equals("get_number_of_likes")){
            System.out.println("<number_of_likes>");
            System.out.println("-----------------");
            while (result.next()){
                String n_likes = String.valueOf(result.getString(1));
                System.out.println(n_likes);
            }

            // get list of like username
        }else if(function.equals("get_list_of_like_username")){
            System.out.println("<like_username>");
            System.out.println("---------------");
            while (result.next()){
                String like_username = String.valueOf(result.getString(1));
                System.out.println(like_username);
            }

            // get list of popular posts
        }else if(function.equals("get_list_of_popular_posts")){
            System.out.println("<post_id> - <number_of_likes>");
            System.out.println("-----------------------------");
            while (result.next()){
                String post_id = String.valueOf(result.getString(1));
                String n_likes = String.valueOf(result.getString(2));
                if(post_id.length() == 1){
                    System.out.println(post_id + "   ||  " + n_likes);
                }else if(post_id.length() == 2){
                    System.out.println(post_id + "  ||  " + n_likes);
                }
            }

            // get list of received message from user
        }else if(function.equals("get_list_of_received_message_from_user")){
            System.out.println("<send_time> - <content_type> - <content_text> - <content_post_id>");
            System.out.println("-----------------------------------------------------------------");
            while (result.next()){
                String send_time = String.valueOf(result.getTimestamp(1));
                String type = String.valueOf(result.getString(2));
                String text = String.valueOf(result.getString(3));
                String post_id = String.valueOf(result.getString(4));
                System.out.println(send_time + "   ||  " + type + "   ||  " + text + "   ||  " + post_id);
            }

            // get list of sender username
        }else if(function.equals("get_list_of_sender_username")) {
            System.out.println("<sender_username>");
            System.out.println("-----------------");
            while (result.next()){
                String sender_username = String.valueOf(result.getString(1));
                System.out.println(sender_username);
            }
        }

        System.out.println();
    }

}
