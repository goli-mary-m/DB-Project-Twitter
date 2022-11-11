INSERT INTO `like_post`(`like_username`, `post_id`) 
SELECT username, post_id
FROM user_account, post
WHERE username = 'M.G' AND post_id = 7 
      AND (post_username, username) NOT IN (SELECT blocker_username , blocking_username FROM block);