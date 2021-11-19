CREATE OR REPLACE VIEW baseballDB.tempteamStatsView AS 
SELECT  teamName AS 'TEAM', 
SUM(atbats) AS 'AB',  
SUM(runs) AS 'R',  
SUM(hits) AS 'H',  
SUM(rbis) AS 'RBI',  
SUM(doubles) AS '2B', 
SUM(triples) AS '3B', 
SUM(homeruns) AS 'HR', 
SUM(walks) AS 'BB', 
SUM(strikeouts) AS 'K', 
SUM(hitbypitch) AS 'HBP', 
SUM(sacrifices) AS 'SAC',
SUM(stolenbases) AS 'SB',
SUM(attstolenbases) AS 'ASB', 
SUM(putouts) AS 'PO', 
SUM(assists) AS 'AST', 
SUM(errors) AS 'E' 
FROM baseballDB.batting  
GROUP BY teamName; 
CREATE OR REPLACE VIEW baseballDB.tempteambattingView AS 
SELECT TEAM, AB, R, H, RBI, 2B, 3B, HR, BB, K, HBP, SAC, SB, ASB, PO, AST, E, 
FORMAT(AVG(H/AB), 3) AS 'AVG', 
FORMAT((((H-(2B+3B+HR))+(2B*2)+(3B*3)+(HR*4))/AB) ,3) AS 'SLUG', 
FORMAT((H+BB+HBP)/(AB+BB+HBP+SAC) ,3) AS 'OBP', 
FORMAT(((((H-(2B+3B+HR))+(2B*2)+(3B*3)+(HR*4))/AB)+((H+BB+HBP)/(AB+BB+HBP+SAC))), 3) AS 'OPS', 
FORMAT(((PO+AST)/(PO+AST+E)), 3) AS 'FPCT'
FROM baseballDB.tempteamStatsView 
GROUP BY TEAM;
SELECT * FROM baseballDB.tempteambattingView INTO OUTFILE '/var/lib/mysql-files/teambattingstats.file';
