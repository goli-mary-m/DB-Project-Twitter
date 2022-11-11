INSERT INTO `follow`(`follower_username`, `following_username`) 
VALUES 
	-- follower_username
	((SELECT username 
      FROM user_account 
      WHERE username = 'M.G'),
     
     -- following_username
     (SELECT username 
      FROM user_account 
      WHERE username = 'S.V'));