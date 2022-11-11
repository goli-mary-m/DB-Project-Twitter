-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 16, 2021 at 12:14 AM
-- Server version: 10.4.18-MariaDB
-- PHP Version: 8.0.5

SET FOREIGN_KEY_CHECKS=0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_phase2`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_hashtag` (IN `in_post_id` INT, IN `in_hashtag_content` CHAR(6))  BEGIN
    	CALL get_current_user (@current_username);
        
        INSERT INTO `post_hashtag`(`hashtag_content`, `post_id`) 
		VALUES 
		(in_hashtag_content, (SELECT post_id
                              FROM post
                              WHERE post_id = in_post_id 
                                    AND post_username = @current_username));
     
		INSERT INTO `hashtag`(`content`) 
		SELECT hashtag_content 
		FROM post_hashtag 
		WHERE hashtag_content = in_hashtag_content 
              AND hashtag_content NOT IN (SELECT content FROM hashtag)
	          AND EXISTS (SELECT post_id
                          FROM post
                          WHERE post_id = in_post_id 
                                AND post_username = @current_username);
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `block_user` (IN `in_blocking_username` VARCHAR(20))  BEGIN 
    	CALL get_current_user (@current_username);
        
        INSERT INTO `block`(`blocker_username`, `blocking_username`) 
		VALUES 
		-- blocker_username
		((SELECT username
      	  FROM user_account
          WHERE username = @current_username),
     
     	-- blocking username
     	(SELECT username
         FROM user_account
         WHERE username = in_blocking_username));
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `commenting` (IN `in_post_id` INT, IN `comment_type` INT, IN `comment1_content` VARCHAR(256), IN `in_comment1_id` INT, IN `comment2_content` VARCHAR(256))  BEGIN
    	CALL get_current_user (@current_username);
        
        IF comment_type = 1 THEN
        	-- comment 1
			INSERT INTO `post`(`post_content`, `post_username`) 
			VALUES (comment1_content, @current_username);

			INSERT INTO `post_comment`(`post_id`, `comment1_post_id`) 
			SELECT main_post.post_id, comment1_post.post_id
			FROM post AS main_post, post AS comment1_post
			WHERE main_post.post_id = in_post_id 
                  AND comment1_post.post_id = (SELECT MAX(post_id) FROM post)
      			  AND (main_post.post_username, comment1_post.post_username) 
                      NOT IN (SELECT blocker_username , blocking_username FROM block);
      
			DELETE FROM `post` 
			WHERE post_id = (SELECT MAX(post_id) FROM post) 
      			  AND NOT EXISTS
      					(
         				SELECT main_post.post_id, comment1_post.post_id
		 				FROM post AS main_post, post AS comment1_post
						WHERE main_post.post_id = in_post_id 
                              AND comment1_post.post_id = (SELECT MAX(post_id) FROM post)
               				  AND (main_post.post_username, comment1_post.post_username) 
                                   NOT IN (SELECT blocker_username , blocking_username FROM block)
         				);
         
         
         ELSEIF comment_type = 2 THEN
			-- comment 2
			INSERT INTO `post`(`post_content`, `post_username`) 
			VALUES (comment2_content, @current_username);

			INSERT INTO `post_comment`(`post_id`, `comment1_post_id`, `comment2_post_id`) 
			SELECT main_post.post_id, comment1_post.post_id, comment2_post.post_id
			FROM post AS main_post, post AS comment1_post, post AS comment2_post
			WHERE main_post.post_id = in_post_id AND comment1_post.post_id = in_comment1_id 
                  AND comment2_post.post_id = (SELECT MAX(post_id) FROM post)
      			  AND (comment1_post.post_username, comment2_post.post_username) 
                       NOT IN (SELECT blocker_username , blocking_username FROM block);
      
			DELETE FROM `post` 
			WHERE post_id = (SELECT MAX(post_id) FROM post) 
      			  AND NOT EXISTS
      					(
         				SELECT main_post.post_id, comment1_post.post_id, comment2_post.post_id
		 				FROM post AS main_post, post AS comment1_post, post AS comment2_post
		 				WHERE main_post.post_id = in_post_id AND comment1_post.post_id = in_comment1_id 
                              AND comment2_post.post_id = (SELECT MAX(post_id) FROM post)
               			      AND (comment1_post.post_username, comment2_post.post_username) 
                                   NOT IN (SELECT blocker_username , blocking_username FROM block)
         				);
                        
		END IF;

    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_an_account` (IN `firstname` VARCHAR(20), IN `lastname` VARCHAR(20), IN `username` VARCHAR(20), IN `pass` VARCHAR(128), IN `birth_date` DATE, IN `biography` VARCHAR(64))  BEGIN
    	INSERT INTO `user_account` (`first_name`, `last_name`, `username`, `pass`, `birth_date`, `biography`) 
		VALUES    
      	(firstname, lastname, username, SHA1(pass), birth_date, biography);
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `follow_user` (IN `in_following_username` VARCHAR(20))  BEGIN
    	CALL get_current_user (@current_username);
        
        INSERT INTO `follow`(`follower_username`, `following_username`) 
		VALUES 
		-- follower_username
		((SELECT username 
      	  FROM user_account 
      	  WHERE username = @current_username),
     
     	-- following_username
     	(SELECT username 
         FROM user_account 
         WHERE username = in_following_username));
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_comments` (IN `in_post_id` INT)  BEGIN
    	CALL get_current_user (@current_username);
        
        SELECT post_comment.comment1_post_id, comment1_post.post_content AS comment_1_post_content
		FROM post AS main_post, post AS comment1_post, post_comment
		WHERE main_post.post_id = in_post_id AND main_post.post_id = post_comment.post_id 
      		  AND comment1_post.post_id = post_comment.comment1_post_id
              AND post_comment.comment2_post_id IS NULL
              AND (main_post.post_username, @current_username) 
                   NOT IN (SELECT blocker_username , blocking_username FROM block)
              AND (comment1_post.post_username, @current_username) 
                  NOT IN (SELECT blocker_username , blocking_username FROM block);
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_current_user` (OUT `out_username` VARCHAR(20))  BEGIN
    	SELECT username INTO out_username 
        FROM login_users
        ORDER BY login_time DESC
        LIMIT 1;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_following_activities` ()  BEGIN
    	CALL get_current_user (@current_username);
        
        SELECT post_content, post_time
		FROM post
		WHERE 
			post_username IN (SELECT following_username
                      		  FROM follow 
                              WHERE follower_username = @current_username)
			AND
    		post_username NOT IN (SELECT blocker_username
                          		  FROM block
                                  WHERE blocking_username = @current_username)
                          
		ORDER BY post_time DESC;

    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_list_of_like_username` (IN `in_post_id` INT)  BEGIN
    	CALL get_current_user (@current_username);
        
        SELECT like_username
		FROM  like_post , post
		WHERE like_post.post_id = post.post_id 
              AND like_post.post_id = in_post_id
	          AND (post_username, @current_username) 
                   NOT IN  (SELECT blocker_username , blocking_username FROM block)
              AND (like_username, @current_username) 
                   NOT IN  (SELECT blocker_username , blocking_username FROM block);
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_list_of_popular_posts` ()  BEGIN
    	CALL get_current_user (@current_username);
        
        SELECT like_post.post_id, COUNT(like_username) AS number_of_likes
		FROM like_post, post
		WHERE like_post.post_id = post.post_id
      		  AND (post_username, @current_username) 
                   NOT IN  (SELECT blocker_username , blocking_username FROM block)
		GROUP BY like_post.post_id
		ORDER BY number_of_likes DESC;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_list_of_received_message_from_user` (IN `in_username` VARCHAR(20))  BEGIN
    	CALL get_current_user (@current_username);
        
        -- content -> text
		SELECT send_time, content_type, content_text, content_post_id
		FROM message
		WHERE sender_username = in_username 
              AND receiver_username = @current_username 
              AND content_type = 'text'

		UNION

		-- content -> post
		SELECT send_time, content_type, content_text, content_post_id
		FROM message, post
		WHERE sender_username = in_username 
              AND receiver_username = @current_username 
              AND content_type = 'post' 
              AND content_post_id = post_id
      		  AND (post_username, receiver_username) 
                   NOT IN (SELECT blocker_username , blocking_username FROM block)

		ORDER BY send_time DESC;
        
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_list_of_sender_username` ()  BEGIN
    	CALL get_current_user (@current_username);
        
        SELECT DISTINCT senders.sender_username 
		FROM (SELECT sender_username, send_time
      		  FROM message
              WHERE receiver_username = @current_username AND content_type = 'text'
      
      		  UNION
      
      		  SELECT sender_username, send_time
      	      FROM message, post
      	      WHERE receiver_username = @current_username AND content_type = 'post' 
                    AND message.content_post_id = post.post_id
                    AND (post_username, receiver_username) 
                         NOT IN (SELECT blocker_username , blocking_username FROM block)

      	      ORDER BY send_time DESC
      	      ) AS senders;

    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_number_of_likes` (IN `in_post_id` INT)  BEGIN
    	CALL get_current_user (@current_username);
        
        SELECT COUNT(like_username) AS number_of_likes
		FROM  like_post , post
		WHERE like_post.post_id = post.post_id 
              AND like_post.post_id = in_post_id
	          AND (post_username, @current_username) 
                   NOT IN  (SELECT blocker_username , blocking_username FROM block);
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_posts_with_specific_hashtag` (IN `in_hashtag_content` CHAR(6))  BEGIN
    	CALL get_current_user (@current_username);
        
        SELECT post.post_id, post.post_content, post.post_username, post.post_time
		FROM post_hashtag, post
		WHERE post_hashtag.post_id = post.post_id 
              AND hashtag_content = in_hashtag_content
              AND (post_username, @current_username) 
                   NOT IN (SELECT blocker_username , blocking_username FROM block)
		ORDER BY post_time DESC;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_user_activities` (IN `in_username` VARCHAR(20))  BEGIN
    	CALL get_current_user (@current_username);
        
        SELECT post_content
		FROM post
		WHERE post_username = in_username 
              AND post_username 
              	  NOT IN (SELECT blocker_username
                          FROM block
                          WHERE blocking_username = @current_username);

    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_user_logins` ()  BEGIN
    	CALL get_current_user (@out_username);
        
    	SELECT login_time
		FROM login_users
		WHERE username = @out_username
		ORDER BY login_time  DESC;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_user_posts` ()  BEGIN
    	CALL get_current_user (@current_username);
        
        SELECT post_id, post_content
		FROM post
		WHERE post_username = @current_username;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `like_posts` (IN `in_post_id` INT)  BEGIN
    	CALL get_current_user (@current_username);
        
        INSERT INTO `like_post`(`like_username`, `post_id`) 
		SELECT username, post_id
		FROM user_account, post
		WHERE username = @current_username AND post_id = in_post_id
     		  AND (post_username, username) 
                   NOT IN (SELECT blocker_username , blocking_username FROM block);
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `login` (IN `in_username` VARCHAR(20), IN `in_pass` VARCHAR(128))  BEGIN
    	INSERT INTO `login_users`(`username`)
			SELECT username
   			FROM user_account
			WHERE username = in_username AND pass = SHA1(in_pass);
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `new_post` (IN `in_content` VARCHAR(256))  BEGIN
    	CALL get_current_user (@current_username);
        
    	INSERT INTO `post`(`post_content`, `post_username`) 
		VALUES
		(in_content, @current_username);			
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `send_message` (IN `in_receiver_username` VARCHAR(20), IN `in_content_type` INT, IN `in_text` VARCHAR(256), IN `in_post_id` INT)  BEGIN
    	CALL get_current_user (@current_username);
        
        IF in_content_type = 0 THEN
        	-- message -> text
			INSERT INTO `message`(`sender_username`, `receiver_username`, `content_type`, `content_text`) 
			SELECT sender.username, receiver.username, 'text', in_text
			FROM user_account AS sender, user_account AS receiver
			WHERE sender.username = @current_username AND receiver.username = in_receiver_username
     			  AND (receiver.username, sender.username) 
                       NOT IN (SELECT blocker_username , blocking_username FROM block);
      
		ELSEIF in_content_type = 1 THEN
			-- message -> post
			INSERT INTO `message`(`sender_username`, `receiver_username`, `content_type`, `content_post_id`) 
			SELECT sender.username, receiver.username, 'post', post_id
			FROM user_account AS sender, user_account AS receiver, post
			WHERE sender.username = @current_username AND receiver.username = in_receiver_username 
                  AND post_id = in_post_id
      	      	  AND (receiver.username, sender.username) 
                       NOT IN (SELECT blocker_username , blocking_username FROM block)
              	  AND (post_username, sender.username) 
                       NOT IN (SELECT blocker_username , blocking_username FROM block);
     
		END IF;
        
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `unblock_user` (IN `in_blocking_username` VARCHAR(20))  BEGIN
    	CALL get_current_user (@current_username);
        
        DELETE FROM `block` 
		WHERE blocker_username = @current_username 
              AND blocking_username = in_blocking_username;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `unfollow_user` (IN `in_following_username` VARCHAR(20))  BEGIN
    	CALL get_current_user (@current_username);
        
        DELETE FROM `follow` 
		WHERE follower_username = @current_username 
              AND following_username = in_following_username;

    END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `block`
--

CREATE TABLE `block` (
  `id` int(10) UNSIGNED NOT NULL,
  `blocker_username` varchar(20) NOT NULL,
  `blocking_username` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- RELATIONSHIPS FOR TABLE `block`:
--   `blocker_username`
--       `user_account` -> `username`
--   `blocking_username`
--       `user_account` -> `username`
--

--
-- Dumping data for table `block`
--

INSERT INTO `block` (`id`, `blocker_username`, `blocking_username`) VALUES
(1, 'N.K', 'M.G');

-- --------------------------------------------------------

--
-- Table structure for table `follow`
--

CREATE TABLE `follow` (
  `id` int(10) UNSIGNED NOT NULL,
  `follower_username` varchar(20) NOT NULL,
  `following_username` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- RELATIONSHIPS FOR TABLE `follow`:
--   `follower_username`
--       `user_account` -> `username`
--   `following_username`
--       `user_account` -> `username`
--

--
-- Dumping data for table `follow`
--

INSERT INTO `follow` (`id`, `follower_username`, `following_username`) VALUES
(2, 'M.G', 'N.K'),
(1, 'M.G', 'S.V');

-- --------------------------------------------------------

--
-- Table structure for table `hashtag`
--

CREATE TABLE `hashtag` (
  `content` char(6) NOT NULL CHECK (`content` like '#_____')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- RELATIONSHIPS FOR TABLE `hashtag`:
--

--
-- Dumping data for table `hashtag`
--

INSERT INTO `hashtag` (`content`) VALUES
('#apple'),
('#smile');

-- --------------------------------------------------------

--
-- Table structure for table `like_post`
--

CREATE TABLE `like_post` (
  `id` int(10) UNSIGNED NOT NULL,
  `like_username` varchar(20) NOT NULL,
  `post_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- RELATIONSHIPS FOR TABLE `like_post`:
--   `like_username`
--       `user_account` -> `username`
--   `post_id`
--       `post` -> `post_id`
--

--
-- Dumping data for table `like_post`
--

INSERT INTO `like_post` (`id`, `like_username`, `post_id`) VALUES
(3, 'H.K', 8),
(4, 'H.K', 10),
(1, 'M.G', 7),
(2, 'M.G', 8),
(5, 'N.K', 8);

-- --------------------------------------------------------

--
-- Table structure for table `login_users`
--

CREATE TABLE `login_users` (
  `id` int(10) UNSIGNED NOT NULL,
  `username` varchar(20) NOT NULL,
  `login_time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- RELATIONSHIPS FOR TABLE `login_users`:
--   `username`
--       `user_account` -> `username`
--

--
-- Dumping data for table `login_users`
--

INSERT INTO `login_users` (`id`, `username`, `login_time`) VALUES
(1, 'M.G', '2021-07-15 20:27:43'),
(2, 'N.K', '2021-07-15 20:30:00'),
(3, 'M.G', '2021-07-15 20:32:30'),
(4, 'M.S', '2021-07-15 20:36:53'),
(5, 'H.K', '2021-07-15 20:38:10'),
(6, 'S.V', '2021-07-15 20:39:17'),
(7, 'N.K', '2021-07-15 20:40:14'),
(8, 'M.G', '2021-07-15 20:48:56'),
(9, 'N.K', '2021-07-15 21:19:27'),
(10, 'M.S', '2021-07-15 21:21:08'),
(11, 'M.G', '2021-07-15 21:24:29'),
(12, 'H.K', '2021-07-15 21:26:20'),
(13, 'S.V', '2021-07-15 21:35:51'),
(14, 'M.G', '2021-07-15 21:38:59'),
(15, 'H.K', '2021-07-15 21:44:05'),
(16, 'N.K', '2021-07-15 21:45:17'),
(17, 'S.V', '2021-07-15 21:51:14'),
(18, 'M.S', '2021-07-15 21:51:14'),
(19, 'M.S', '2021-07-15 21:54:01');

-- --------------------------------------------------------

--
-- Table structure for table `message`
--

CREATE TABLE `message` (
  `id` int(10) UNSIGNED NOT NULL,
  `sender_username` varchar(20) NOT NULL,
  `receiver_username` varchar(20) NOT NULL,
  `send_time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `content_type` char(4) NOT NULL,
  `content_text` varchar(256) DEFAULT NULL,
  `content_post_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- RELATIONSHIPS FOR TABLE `message`:
--   `sender_username`
--       `user_account` -> `username`
--   `receiver_username`
--       `user_account` -> `username`
--

--
-- Dumping data for table `message`
--

INSERT INTO `message` (`id`, `sender_username`, `receiver_username`, `send_time`, `content_type`, `content_text`, `content_post_id`) VALUES
(1, 'H.K', 'M.G', '2021-07-15 21:33:25', 'text', 'salam maryam!', NULL),
(2, 'H.K', 'M.G', '2021-07-15 21:34:06', 'post', NULL, 6),
(3, 'S.V', 'M.G', '2021-07-15 21:36:38', 'text', 'salam maryam!', NULL),
(4, 'S.V', 'M.G', '2021-07-15 21:37:14', 'post', NULL, 8),
(5, 'S.V', 'M.G', '2021-07-15 21:38:28', 'post', NULL, 4),
(6, 'M.G', 'S.V', '2021-07-15 21:40:04', 'text', 'salam!', NULL),
(7, 'M.G', 'S.V', '2021-07-15 21:40:04', 'post', NULL, 1);

-- --------------------------------------------------------

--
-- Table structure for table `post`
--

CREATE TABLE `post` (
  `post_id` int(10) UNSIGNED NOT NULL,
  `post_content` varchar(256) NOT NULL,
  `post_username` varchar(20) NOT NULL,
  `post_time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- RELATIONSHIPS FOR TABLE `post`:
--

--
-- Dumping data for table `post`
--

INSERT INTO `post` (`post_id`, `post_content`, `post_username`, `post_time`) VALUES
(1, 'post - M.G - 1', 'M.G', '2021-07-15 20:33:47'),
(3, 'post - M.G - 2', 'M.G', '2021-07-15 20:35:03'),
(4, 'post - M.S - 1', 'M.S', '2021-07-15 20:36:53'),
(5, 'post - M.S - 2', 'M.S', '2021-07-15 20:36:53'),
(6, 'post - H.K - 1', 'H.K', '2021-07-15 20:38:10'),
(7, 'post - H.K - 2', 'H.K', '2021-07-15 20:38:10'),
(8, 'post - S.V - 1', 'S.V', '2021-07-15 20:39:17'),
(9, 'post - S.V - 2', 'S.V', '2021-07-15 20:39:18'),
(10, 'post - N.K - 1', 'N.K', '2021-07-15 20:40:14'),
(11, 'c1->post8 - M.G', 'M.G', '2021-07-15 21:13:25'),
(12, 'c1->post8 - N.K', 'N.K', '2021-07-15 21:19:27'),
(13, 'c1->post8 - M.S', 'M.S', '2021-07-15 21:21:08'),
(14, 'c2->c1 13->post8 - M.G', 'M.G', '2021-07-15 21:24:29'),
(15, 'c1->post10 - H.K', 'H.K', '2021-07-15 21:26:20'),
(16, 'post&hashtag  #smile#nazanin#apple', 'N.K', '2021-07-15 21:48:41'),
(18, 'post&hashtag #apple', 'S.V', '2021-07-15 21:52:50'),
(19, 'post&hashtag #apple#mina', 'M.S', '2021-07-15 21:54:33');

--
-- Triggers `post`
--
DELIMITER $$
CREATE TRIGGER `hashtag_trigger` AFTER INSERT ON `post` FOR EACH ROW BEGIN
        	DECLARE p_content VARCHAR(256);
            DECLARE tmp VARCHAR(256);
            DECLARE p_content_length INT;
            DECLARE h_index INT;
            DECLARE h_index_curr INT;
            DECLARE h_index_next INT;
            DECLARE h_content CHAR(6);
            
            SET p_content = NEW.post_content;        
            SELECT LENGTH (p_content) INTO p_content_length;
             
            SELECT INSTR(p_content, '#') INTO h_index;
            IF h_index > 0 THEN
            	WHILE (p_content_length > 0 AND p_content_length IS NOT NULL) DO
            		SELECT INSTR(p_content, '#') INTO h_index_curr;
                	SELECT SUBSTR(p_content, h_index_curr+1) INTO tmp;
                	SELECT INSTR(tmp, '#') INTO h_index_next;
                	IF h_index_next = 0 THEN
                		SET h_index_next = p_content_length;
                	END IF;
                
                	IF (h_index_next = 6) THEN
                		-- valid hashtag
                		SELECT SUBSTR(p_content, h_index_curr, 6) INTO h_content;
                    	CALL add_hashtag (NEW.post_id, h_content);
					END IF;
                
                	SELECT SUBSTR(p_content, h_index_curr+h_index_next) INTO p_content;
               	 	SELECT LENGTH (p_content) INTO p_content_length;
                
				END WHILE;
			END IF;
            
        END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `log_new_post` AFTER INSERT ON `post` FOR EACH ROW BEGIN
        	INSERT INTO `table_new_post`(`post_id`, `post_username`, `post_time`) 
            VALUES (NEW.post_id, NEW.post_username, NEW.post_time);
        END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `post_comment`
--

CREATE TABLE `post_comment` (
  `id` int(10) UNSIGNED NOT NULL,
  `post_id` int(10) UNSIGNED NOT NULL,
  `comment1_post_id` int(10) UNSIGNED NOT NULL,
  `comment2_post_id` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- RELATIONSHIPS FOR TABLE `post_comment`:
--   `post_id`
--       `post` -> `post_id`
--   `comment1_post_id`
--       `post` -> `post_id`
--   `comment2_post_id`
--       `post` -> `post_id`
--

--
-- Dumping data for table `post_comment`
--

INSERT INTO `post_comment` (`id`, `post_id`, `comment1_post_id`, `comment2_post_id`) VALUES
(1, 8, 11, NULL),
(2, 8, 12, NULL),
(3, 8, 13, NULL),
(4, 8, 13, 14),
(5, 10, 15, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `post_hashtag`
--

CREATE TABLE `post_hashtag` (
  `id` int(10) UNSIGNED NOT NULL,
  `hashtag_content` char(6) NOT NULL CHECK (`hashtag_content` like '#_____'),
  `post_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- RELATIONSHIPS FOR TABLE `post_hashtag`:
--   `post_id`
--       `post` -> `post_id`
--

--
-- Dumping data for table `post_hashtag`
--

INSERT INTO `post_hashtag` (`id`, `hashtag_content`, `post_id`) VALUES
(1, '#smile', 16),
(2, '#apple', 16),
(3, '#apple', 18),
(4, '#apple', 19);

-- --------------------------------------------------------

--
-- Table structure for table `table_create_an_account`
--

CREATE TABLE `table_create_an_account` (
  `username` varchar(20) NOT NULL,
  `reg_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- RELATIONSHIPS FOR TABLE `table_create_an_account`:
--

--
-- Dumping data for table `table_create_an_account`
--

INSERT INTO `table_create_an_account` (`username`, `reg_date`) VALUES
('F.K', '2021-07-15 20:22:50'),
('H.K', '2021-07-15 20:22:50'),
('M.G', '2021-07-15 20:26:24'),
('M.S', '2021-07-15 20:22:50'),
('N.K', '2021-07-15 20:22:50'),
('S.V', '2021-07-15 20:22:50');

-- --------------------------------------------------------

--
-- Table structure for table `table_new_post`
--

CREATE TABLE `table_new_post` (
  `post_id` int(10) UNSIGNED NOT NULL,
  `post_username` varchar(20) NOT NULL,
  `post_time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- RELATIONSHIPS FOR TABLE `table_new_post`:
--

--
-- Dumping data for table `table_new_post`
--

INSERT INTO `table_new_post` (`post_id`, `post_username`, `post_time`) VALUES
(1, 'M.G', '2021-07-15 20:33:47'),
(2, 'M.G', '2021-07-15 20:33:48'),
(3, 'M.G', '2021-07-15 20:35:03'),
(4, 'M.S', '2021-07-15 20:36:53'),
(5, 'M.S', '2021-07-15 20:36:53'),
(6, 'H.K', '2021-07-15 20:38:10'),
(7, 'H.K', '2021-07-15 20:38:10'),
(8, 'S.V', '2021-07-15 20:39:17'),
(9, 'S.V', '2021-07-15 20:39:18'),
(10, 'N.K', '2021-07-15 20:40:14'),
(11, 'M.G', '2021-07-15 21:13:25'),
(12, 'N.K', '2021-07-15 21:19:27'),
(13, 'M.S', '2021-07-15 21:21:08'),
(14, 'M.G', '2021-07-15 21:24:29'),
(15, 'H.K', '2021-07-15 21:26:20'),
(16, 'N.K', '2021-07-15 21:48:41'),
(17, 'S.V', '2021-07-15 21:51:14'),
(18, 'S.V', '2021-07-15 21:51:14'),
(19, 'M.S', '2021-07-15 21:54:33');

-- --------------------------------------------------------

--
-- Table structure for table `user_account`
--

CREATE TABLE `user_account` (
  `first_name` varchar(20) NOT NULL,
  `last_name` varchar(20) NOT NULL,
  `username` varchar(20) NOT NULL,
  `pass` varchar(128) NOT NULL,
  `birth_date` date NOT NULL,
  `reg_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `biography` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- RELATIONSHIPS FOR TABLE `user_account`:
--

--
-- Dumping data for table `user_account`
--

INSERT INTO `user_account` (`first_name`, `last_name`, `username`, `pass`, `birth_date`, `reg_date`, `biography`) VALUES
('Fatemeh', 'Kaboodanian', 'F.K', '4580fbe74de4575bcd4f7735c09fafd457285ebb', '2005-05-05', '2021-07-15 20:22:50', 'Fatemeh Kaboodanian'),
('Hosna', 'Kelaye', 'H.K', 'c17d9e4fec93305af9d91ac9cea64972b4175bc4', '2003-03-03', '2021-07-15 20:22:50', 'Hosna Kelaye'),
('Maryam', 'Goli', 'M.G', '0415bf2866cd432f2073fcdec1ca76eae09d7747', '2001-01-01', '2021-07-15 20:26:24', 'Maryam Goli'),
('Mina', 'Sadat', 'M.S', '3a53e37068411cb0f4984ce26c265bc7182c94ad', '2004-04-04', '2021-07-15 20:22:50', 'Mina Sadat'),
('Nazanin', 'Keshtkaran', 'N.K', '2936120a079fa6493fec1bda8cf09f2bf7e5d8d6', '2006-06-06', '2021-07-15 20:22:50', 'Nazanin Keshtkaran'),
('Sepideh', 'Vakili', 'S.V', 'b53cec24108de21086b22b57b276775368695c89', '2002-02-02', '2021-07-15 20:22:50', 'Sepideh Vakili');

--
-- Triggers `user_account`
--
DELIMITER $$
CREATE TRIGGER `log_create_an_account` AFTER INSERT ON `user_account` FOR EACH ROW BEGIN
        	INSERT INTO `table_create_an_account`(`username`, `reg_date`) 
            VALUES (NEW.username, NEW.reg_date);
        END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `block`
--
ALTER TABLE `block`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `blocker_username` (`blocker_username`,`blocking_username`),
  ADD KEY `blocking_username` (`blocking_username`);

--
-- Indexes for table `follow`
--
ALTER TABLE `follow`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `follower_username` (`follower_username`,`following_username`),
  ADD KEY `following_username` (`following_username`);

--
-- Indexes for table `hashtag`
--
ALTER TABLE `hashtag`
  ADD PRIMARY KEY (`content`);

--
-- Indexes for table `like_post`
--
ALTER TABLE `like_post`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `like_username` (`like_username`,`post_id`),
  ADD KEY `post_id` (`post_id`);

--
-- Indexes for table `login_users`
--
ALTER TABLE `login_users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `username` (`username`);

--
-- Indexes for table `message`
--
ALTER TABLE `message`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sender_username` (`sender_username`),
  ADD KEY `receiver_username` (`receiver_username`);

--
-- Indexes for table `post`
--
ALTER TABLE `post`
  ADD PRIMARY KEY (`post_id`);

--
-- Indexes for table `post_comment`
--
ALTER TABLE `post_comment`
  ADD PRIMARY KEY (`id`),
  ADD KEY `post_id` (`post_id`),
  ADD KEY `comment1_post_id` (`comment1_post_id`),
  ADD KEY `comment2_post_id` (`comment2_post_id`);

--
-- Indexes for table `post_hashtag`
--
ALTER TABLE `post_hashtag`
  ADD PRIMARY KEY (`id`),
  ADD KEY `post_id` (`post_id`);

--
-- Indexes for table `table_create_an_account`
--
ALTER TABLE `table_create_an_account`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `table_new_post`
--
ALTER TABLE `table_new_post`
  ADD PRIMARY KEY (`post_id`);

--
-- Indexes for table `user_account`
--
ALTER TABLE `user_account`
  ADD PRIMARY KEY (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `block`
--
ALTER TABLE `block`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `follow`
--
ALTER TABLE `follow`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `like_post`
--
ALTER TABLE `like_post`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `login_users`
--
ALTER TABLE `login_users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `message`
--
ALTER TABLE `message`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `post`
--
ALTER TABLE `post`
  MODIFY `post_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `post_comment`
--
ALTER TABLE `post_comment`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `post_hashtag`
--
ALTER TABLE `post_hashtag`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `block`
--
ALTER TABLE `block`
  ADD CONSTRAINT `block_ibfk_1` FOREIGN KEY (`blocker_username`) REFERENCES `user_account` (`username`),
  ADD CONSTRAINT `block_ibfk_2` FOREIGN KEY (`blocking_username`) REFERENCES `user_account` (`username`);

--
-- Constraints for table `follow`
--
ALTER TABLE `follow`
  ADD CONSTRAINT `follow_ibfk_1` FOREIGN KEY (`follower_username`) REFERENCES `user_account` (`username`),
  ADD CONSTRAINT `follow_ibfk_2` FOREIGN KEY (`following_username`) REFERENCES `user_account` (`username`);

--
-- Constraints for table `like_post`
--
ALTER TABLE `like_post`
  ADD CONSTRAINT `like_post_ibfk_1` FOREIGN KEY (`like_username`) REFERENCES `user_account` (`username`),
  ADD CONSTRAINT `like_post_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `post` (`post_id`);

--
-- Constraints for table `login_users`
--
ALTER TABLE `login_users`
  ADD CONSTRAINT `login_users_ibfk_1` FOREIGN KEY (`username`) REFERENCES `user_account` (`username`);

--
-- Constraints for table `message`
--
ALTER TABLE `message`
  ADD CONSTRAINT `message_ibfk_1` FOREIGN KEY (`sender_username`) REFERENCES `user_account` (`username`),
  ADD CONSTRAINT `message_ibfk_2` FOREIGN KEY (`receiver_username`) REFERENCES `user_account` (`username`);

--
-- Constraints for table `post_comment`
--
ALTER TABLE `post_comment`
  ADD CONSTRAINT `post_comment_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `post` (`post_id`),
  ADD CONSTRAINT `post_comment_ibfk_2` FOREIGN KEY (`comment1_post_id`) REFERENCES `post` (`post_id`),
  ADD CONSTRAINT `post_comment_ibfk_3` FOREIGN KEY (`comment2_post_id`) REFERENCES `post` (`post_id`);

--
-- Constraints for table `post_hashtag`
--
ALTER TABLE `post_hashtag`
  ADD CONSTRAINT `post_hashtag_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `post` (`post_id`);
SET FOREIGN_KEY_CHECKS=1;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
