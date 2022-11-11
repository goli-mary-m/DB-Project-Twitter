INSERT INTO `post_hashtag`(`hashtag_content`, `post_id`) 
VALUES 
	('#smile', (SELECT post_id
                FROM post
                WHERE post_id = 1 AND post_username = 'M.G'));
     
INSERT INTO `hashtag`(`content`) 
SELECT hashtag_content 
FROM post_hashtag 
WHERE hashtag_content = '#smile' AND hashtag_content NOT IN (SELECT content FROM hashtag)
	  AND EXISTS (SELECT post_id
                  FROM post
                  WHERE post_id = 1 AND post_username = 'M.G');