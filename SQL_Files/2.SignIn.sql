INSERT INTO `login_users`(`username`)
	SELECT username
    FROM user_account
	WHERE username = 'M.G' AND pass = SHA1('maryam_goli_pass');
