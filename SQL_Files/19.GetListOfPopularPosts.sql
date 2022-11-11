SELECT like_post.post_id, COUNT(like_username) AS number_of_likes
FROM like_post, post
WHERE like_post.post_id = post.post_id
      AND (post_username, 'M.G') NOT IN  (SELECT blocker_username , blocking_username FROM block)
GROUP BY like_post.post_id
ORDER BY number_of_likes DESC;