SELECT post_comment.comment1_post_id, comment1_post.post_content AS comment_1_post_content
FROM post AS main_post, post AS comment1_post, post_comment
WHERE main_post.post_id = 7 AND main_post.post_id = post_comment.post_id 
      AND comment1_post.post_id = post_comment.comment1_post_id
      AND post_comment.comment2_post_id IS NULL
      AND (main_post.post_username, 'M.G') NOT IN (SELECT blocker_username , blocking_username FROM block)
      AND (comment1_post.post_username, 'M.G') NOT IN (SELECT blocker_username , blocking_username FROM block)