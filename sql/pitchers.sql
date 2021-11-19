DROP TABLE pitching;

CREATE TABLE pitching (
	teamName VARCHAR(50) NOT NULL,
	gameID VARCHAR(10) NOT NULL,
	games INT NOT NULL,
	playerName VARCHAR(100) NOT NULL,
	wins INT NOT NULL,
	loses INT NOT NULL,
	saves INT NOT NULL,
	saveopportunities INT NOT NULL,
	gamesstarted INT NOT NULL,
	completedgames INT NOT NULL,
	inningspitched DEC (4, 1) NOT NULL,
	totalbattersfaced INT NOT NULL,
	hits INT NOT NULL,
	walks INT NOT NULL,
	strikeouts INT NOT NULL,
	runsallowed INT NOT NULL,
	earnedruns INT NOT NULL,
	homeruns INT NOT NULL,
	hitbypitch INT NOT NULL,
	sacrificeflies INT NOT NULL
	);
