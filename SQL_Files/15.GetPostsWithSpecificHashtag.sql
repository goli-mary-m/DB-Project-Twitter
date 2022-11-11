SELECT post.post_id, post.post_content, post.post_username, post.post_time
FROM post_hashtag, post
WHERE post_hashtag.post_id = post.post_id AND hashtag_content = '#smile'
      AND (post_username, 'M.G') NOT IN (SELECT blocker_username , blocking_username FROM block)
ORDER BY post_time DESC;
