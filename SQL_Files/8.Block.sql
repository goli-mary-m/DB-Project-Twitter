INSERT INTO `block`(`blocker_username`, `blocking_username`) 
VALUES 
	-- blocker_username
	((SELECT username
      FROM user_account
      WHERE username = 'N.K'),
     
     -- blocking username
     (SELECT username
      FROM user_account
      WHERE username = 'M.G'));