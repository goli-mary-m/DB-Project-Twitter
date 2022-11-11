SELECT like_username
FROM  like_post , post
WHERE like_post.post_id = post.post_id AND like_post.post_id = 7 
	  AND (post_username, 'M.G') NOT IN  (SELECT blocker_username , blocking_username FROM block)
      AND (like_username, 'M.G') NOT IN  (SELECT blocker_username , blocking_username FROM block);