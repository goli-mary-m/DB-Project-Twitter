SELECT post_content
FROM post
WHERE post_username = 'S.V' AND post_username NOT IN (SELECT blocker_username
                                                      FROM block
                                                      WHERE blocking_username = 'M.G');
