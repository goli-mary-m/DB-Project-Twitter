-- message -> text
INSERT INTO `message`(`sender_username`, `receiver_username`, `content_type`, `content_text`) 
SELECT sender.username, receiver.username, 'text', 'salam!'
FROM user_account AS sender, user_account AS receiver
WHERE sender.username = 'M.G' AND receiver.username = 'S.V'
      AND (receiver.username, sender.username) NOT IN (SELECT blocker_username , blocking_username FROM block);
      
-- message -> post
INSERT INTO `message`(`sender_username`, `receiver_username`, `content_type`, `content_post_id`) 
SELECT sender.username, receiver.username, 'post', post_id
FROM user_account AS sender, user_account AS receiver, post
WHERE sender.username = 'M.G' AND receiver.username = 'S.V' AND post_id = 1
      AND (receiver.username, sender.username) NOT IN (SELECT blocker_username , blocking_username FROM block)
      AND (post_username, sender.username) NOT IN (SELECT blocker_username , blocking_username FROM block);
      
