-- content -> text
SELECT sender_username, receiver_username, send_time, content_type, content_text, content_post_id
FROM message
WHERE sender_username = 'S.V' AND receiver_username = 'M.G' AND content_type = 'text'

UNION

-- content -> post
SELECT sender_username, receiver_username, send_time, content_type, content_text, content_post_id
FROM message, post
WHERE sender_username = 'S.V' AND receiver_username = 'M.G' AND content_type = 'post' AND content_post_id = post_id
      AND (post_username, receiver_username) NOT IN (SELECT blocker_username , blocking_username FROM block)

ORDER BY send_time DESC;