-- comment 1
INSERT INTO `post`(`post_content`, `post_username`) 
VALUES ('[comment1 - post 7]','M.G');

INSERT INTO `post_comment`(`post_id`, `comment1_post_id`) 
SELECT main_post.post_id, comment1_post.post_id
FROM post AS main_post, post AS comment1_post
WHERE main_post.post_id = 7 AND comment1_post.post_id = (SELECT MAX(post_id) FROM post)
      AND (main_post.post_username, comment1_post.post_username) NOT IN (SELECT blocker_username , blocking_username FROM block);
      
DELETE FROM `post` 
WHERE post_id = (SELECT MAX(post_id) FROM post) 
      AND NOT EXISTS
      	(
         SELECT main_post.post_id, comment1_post.post_id
		 FROM post AS main_post, post AS comment1_post
		 WHERE main_post.post_id = 7 AND comment1_post.post_id = (SELECT MAX(post_id) FROM post)
               AND (main_post.post_username, comment1_post.post_username) NOT IN (SELECT blocker_username , blocking_username FROM block)
         );
         
         
-- comment 2
INSERT INTO `post`(`post_content`, `post_username`) 
VALUES ('[comment2 - comment1 - post 7]','M.G');

INSERT INTO `post_comment`(`post_id`, `comment1_post_id`, `comment2_post_id`) 
SELECT main_post.post_id, comment1_post.post_id, comment2_post.post_id
FROM post AS main_post, post AS comment1_post, post AS comment2_post
WHERE main_post.post_id = 7 AND comment1_post.post_id = 10 AND comment2_post.post_id = (SELECT MAX(post_id) FROM post)
      AND (comment1_post.post_username, comment2_post.post_username) NOT IN (SELECT blocker_username , blocking_username FROM block);
      
DELETE FROM `post` 
WHERE post_id = (SELECT MAX(post_id) FROM post) 
      AND NOT EXISTS
      	(
         SELECT main_post.post_id, comment1_post.post_id, comment2_post.post_id
		 FROM post AS main_post, post AS comment1_post, post AS comment2_post
		 WHERE main_post.post_id = 7 AND comment1_post.post_id = 10 AND comment2_post.post_id = (SELECT MAX(post_id) FROM post)
               AND (comment1_post.post_username, comment2_post.post_username) NOT IN (SELECT blocker_username , blocking_username FROM block)
         );
