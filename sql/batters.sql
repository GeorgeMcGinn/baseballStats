DROP TABLE batting;

CREATE TABLE batting (
	teamName VARCHAR(50) NOT NULL,
	gameID VARCHAR(10) NOT NULL,
	games INT NOT NULL,
	playerName VARCHAR(100) NOT NULL,
	atbats INT NOT NULL,
	runs INT NOT NULL,
	hits INT NOT NULL,
	rbis INT NOT NULL,
	doubles INT NOT NULL,
	triples INT NOT NULL,
	homeruns INT NOT NULL,
	walks INT NOT NULL,
	strikeouts INT NOT NULL,
	hitbypitch INT NOT NULL,
	sacrifices INT NOT NULL,
	stolenbases INT NOT NULL,
	attstolenbases INT NOT NULL,
	putouts INT NOT NULL,
	assists INT NOT NULL,
	errors INT NOT NULL
	);
