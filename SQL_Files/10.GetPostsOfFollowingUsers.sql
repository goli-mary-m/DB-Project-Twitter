SELECT post_content, post_time
FROM post
WHERE 
	post_username IN (SELECT following_username
                      FROM follow 
                      WHERE follower_username = 'M.G')
	AND
    post_username NOT IN (SELECT blocker_username
                          FROM block
                          WHERE blocking_username = 'M.G')
                          
ORDER BY post_time DESC;
