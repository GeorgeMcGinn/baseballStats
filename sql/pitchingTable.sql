/*
-- Query: SELECT * FROM baseballTDB.pitching
-- Date: 2021-12-08 16:28
*/

USE baseballTDB;

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
	outspitched INT NOT NULL,
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
	
INSERT INTO pitching 
VALUES ("Redsox","ALE-01",1,"Sale, C",1,0,0,0,1,1,27,44,13,4,14,9,9,3,0,0),
("Rays","ALE-04",1,"Snell, B",0,1,0,0,1,0,21,32,9,3,8,2,2,1,0,0),
("Rays","ALE-04",1,"Drake, O",0,0,0,0,0,0,6,7,1,0,3,0,0,0,0,0),
("Redsox","ALE-07",1,"Price, D",0,0,0,0,1,0,24,30,5,0,11,2,2,2,0,0),
("Redsox","ALE-07",1,"Workman, B",1,0,0,0,0,0,3,7,1,2,2,1,1,0,0,0),
("Yankees","ALE-01",1,"Tanaka, M",0,0,0,0,1,0,18,29,9,3,2,9,9,5,0,0),
("Yankees","ALE-01",1,"Britton, Z",0,1,0,0,0,0,6,8,2,1,3,1,1,1,0,0),
("Yankees","ALE-03",1,"Sabathia, CC",0,1,0,0,1,0,21,33,9,2,7,9,9,4,1,1),
("Yankees","ALE-03",1,"Britton, Z",0,0,0,0,0,0,6,0,0,0,1,0,0,0,0,0),
("Yankees","ALE-06",1,"Happ, JA",0,1,0,0,1,0,16,25,4,5,4,8,7,1,0,0),
("Yankees","ALE-06",1,"Ottavino, A",0,0,0,0,0,0,3,6,3,1,1,3,2,0,0,1),
("Yankees","ALE-06",1,"Britton, Z",0,0,0,0,0,0,9,11,2,1,3,1,1,1,0,0),
("Yankees","ALE-08",1,"Severino, L",1,0,0,0,1,1,27,35,3,4,12,2,2,0,1,0),
("Rays","ALE-02",1,"Morton, C",1,0,0,0,1,1,27,39,6,6,10,1,0,0,1,0),
("Rays","ALE-06",1,"Glasnow, T",1,0,0,0,1,1,27,34,5,2,11,2,2,2,0,0),
("Orioles","ALE-02",1,"Means, J",0,1,0,0,1,0,13,23,8,2,3,5,3,1,0,0),
("Orioles","ALE-02",1,"Kline, B",0,0,0,0,0,0,8,13,5,1,1,1,1,1,0,0),
("Orioles","ALE-02",1,"Givens, M",0,0,0,0,0,0,6,9,1,0,2,2,1,1,0,0),
("Orioles","ALE-05",1,"Bundy, D",0,1,0,0,1,1,27,36,9,4,13,6,6,5,0,0),
("Orioles","ALE-08",1,"Wojciech, A",0,1,0,0,1,0,22,33,8,2,7,3,3,1,0,0),
("Orioles","ALE-08",1,"Castro, M",0,0,0,0,0,0,4,11,4,2,1,4,4,1,1,0),
("Orioles","ALE-08",1,"Givens, M",0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0),
("Bluejays","ALE-03",1,"Shoemaker, M",1,0,0,0,1,1,27,32,4,2,3,0,0,0,0,0),
("Bluejays","ALE-05",1,"Thornton, T",1,0,0,0,1,1,27,35,4,4,10,4,4,2,0,0),
("Bluejays","ALE-07",1,"Stroman, M",1,0,0,0,1,1,27,37,9,4,4,4,4,2,0,1),
("Redsox","ALE-04",1,"Rodriguez, E",1,0,0,0,1,1,27,42,8,3,10,2,2,2,0,0),
("Bluejays","ALE-09",1,"Richard, C",0,1,0,0,1,0,22,42,9,8,4,10,7,0,1,0),
("Bluejays","ALE-09",1,"Boshers, B",0,0,0,0,0,0,2,2,0,0,0,0,0,0,0,0),
("Rays","ALE-09",1,"Drake, O",1,0,0,0,0,0,14,20,2,1,6,0,0,0,1,0),
("Rays","ALE-09",1,"Yarbrough, R",0,0,0,0,1,0,13,20,7,3,2,9,8,2,0,0),
("Rays","ALE-09",1,"Anderson, N",0,0,0,0,0,0,3,0,0,0,2,0,0,0,0,0);
