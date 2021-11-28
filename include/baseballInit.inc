'-------------------------------------------------------------------------------------
' *** Baseball Stats Initialize Section
'
DIM SHARED AS INTEGER TRUE, FALSE
TRUE = -1: FALSE = 0

'---------------------------------------------------
' *** Variables for SQL Queries
'
DIM SHARED AS STRING Query(100), sqlStmt(100)
DIM SHARED AS STRING Answer(1000, 1000)
DIM SHARED mysqlCMD$, mysqlTable$, mysqlView$, mysqlDB$, mysql_userid$, mysql_password$, mysql_outputdir$
DIM SHARED qString$, battingfile$, pitchingfile$, leaguefile$, ReportFile$, ConfigFile$
DIM SHARED mysql_battingTable$, mysql_pitchingTable$
DIM SHARED AS INTEGER result, cntargs, PrintReport, setLeague
DIM SHARED AS STRING retcode, OStype
DIM SHARED flog%
DIM SHARED AS INTEGER lenstr, nbrRows, nbrCols, nbrLines, nbrUpdates
DIM SHARED Delim$, ARG1$, ARG2$, ARG3$, ARG4$, ARG5$, ARG6$, ARG7$, ProgramName$

'----------------------------------------------------
' *** Variables for Baseball Stats
'
DIM SHARED AS STRING teamName, gameID, playerName, gamesPlayed
DIM SHARED AS INTEGER innings
DIM SHARED nbr_innings$
 
'----------------------------------------------------
' *** Variables for pipecom
'
DIM SHARED AS STRING cmd, stdout, stderr, stdbutton, stdmenu


'----------------------------------------------------
' *** Setup NUMERIC Check Table
'
DIM SHARED numeric(255)
FOR I = 48 TO 57
    numeric(I) = -1
NEXT I

'-----------------------------------------------------
' *** Initialize GLOBAL Variables
'
nbrRows = 0: nbrCols = 0

'----------------------------------------------------
' *** DEFINE GLOBAL CONSTANT PITCHING HEADER POINTERS
'
CONST PITCH.TEAM = 1
CONST PITCH.W = 2
CONST PITCH.L = 3
CONST PITCH.SV = 4
CONST PITCH.SVO = 5
CONST PITCH.GP = 6
CONST PITCH.GS = 7
CONST PITCH.GC = 8
CONST PITCH.IP = 9
CONST PITCH.TBF = 10
CONST PITCH.H = 11
CONST PITCH.BB = 12
CONST PITCH.K = 13
CONST PITCH.RA = 14
CONST PITCH.ER = 15
CONST PITCH.HR = 16
CONST PITCH.HBP = 17
CONST PITCH.SF = 18
CONST PITCH.ERA = 19
CONST PITCH.OPPAVG = 20
CONST PITCH.WHIP = 1
CONST PITCH.BABIP = 22
CONST PITCH.FIP = 23

'------------------------------------------------------------
' *** DEFINE GLOBAL CONSTANT LEAGUE PITCHING HEADER POINTERS
'
CONST LPITCH.TEAM = 1
CONST LPITCH.W = 2
CONST LPITCH.L = 3
CONST LPITCH.SV = 4
CONST LPITCH.SVO = 5
CONST LPITCH.GP = 6
CONST LPITCH.GC = 7
CONST LPITCH.IP = 8
CONST LPITCH.TBF = 9
CONST LPITCH.H = 10
CONST LPITCH.BB = 11
CONST LPITCH.K = 12
CONST LPITCH.RA = 13
CONST LPITCH.ER = 14
CONST LPITCH.HR = 15
CONST LPITCH.HBP = 16
CONST LPITCH.SF = 17
CONST LPITCH.ERA = 18
CONST LPITCH.OPPAVG = 19
CONST LPITCH.WHIP = 20
CONST LPITCH.BABIP = 21
CONST LPITCH.FIP = 22

'----------------------------------------------------
' *** DEFINE GLOBAL CONSTANT LEAGUE HEADER POINTERS
'
CONST LEAGUE.TEAM = 1
CONST LEAGUE.W = 2
CONST LEAGUE.L = 3
CONST LEAGUE.IP = 4
CONST LEAGUE.ER = 5
CONST LEAGUE.ERA = 6
CONST LEAGUE.AVG = 7
CONST LEAGUE.SLUG = 8
CONST LEAGUE.FPCT = 9
CONST LEAGUE.WPCT = 10
CONST LEAGUE.BYPASS = 2

'-----------------------------------------------------
' *** Initialize SQL Variables with DEFAULT Values
' *** (Used when first time run for install)
'
ConfigFile$ = "config.ini"
mysqlDB$ = "*** PLEASE UPDATE ***"
mysql_userid$ = "*** PLEASE UPDATE ***"
mysql_password$ = "*** PLEASE UPDATE ***"
mysql_battingTable$ = "*** PLEASE UPDATE ***"
mysql_pitchingTable$ = "*** PLEASE UPDATE ***"
mysql_outputdir$ = "/var/lib/mysql-files/"    
nbr_innings$ = "*** PLEASE UPDATE ***"

' *** Populate ProgramName$
ProgramName$ = MID$(COMMAND$(0), _INSTRREV(COMMAND$(0), "/") + 1)



