INSERT INTO `post`(`post_content`, `post_username`) 
VALUES
	('[post 1 - M.G]', (SELECT username FROM user_account WHERE username = 'M.G'));

				