SELECT DISTINCT senders.sender_username 
FROM (SELECT sender_username, send_time
      FROM message
      WHERE receiver_username = 'M.G' AND content_type = 'text'
      
      UNION
      
      SELECT sender_username, send_time
      FROM message, post
      WHERE receiver_username = 'M.G' AND content_type = 'post' AND message.content_post_id = post.post_id
            AND (post_username, receiver_username) NOT IN (SELECT blocker_username , blocking_username FROM block)

      ORDER BY send_time DESC
      ) AS senders;
