' *** OPEN Log File

 
IF _COMMANDCOUNT = 0 THEN
	flog% = FREEFILE
	OPEN "logs/baseballstats.log" FOR OUTPUT AS #flog%
	PRINT #flog%, "(" + ProgramName$ + "): *** Baseball/Softball Statistical Recordkeeping System Log File ***"
	PRINT #flog%, "(" + ProgramName$ + "): 
	PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing PGM=" + ProgramName$
	PRINT #flog%, "(" + ProgramName$ + "): "
    DisplayAbout
	LoadConfigFile
ELSE
	flog% = FREEFILE
	OPEN "logs/baseballstats.log" FOR APPEND AS #flog%
	PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing PGM=" + ProgramName$
	PRINT #flog%, "(" + ProgramName$ + "): "
END IF

' *** If not running from Linux, message and exit
IF INSTR(_OS$, "LINUX") THEN OStype = "LINUX"
IF OStype <> "LINUX" THEN
	SHELL ("zenity --error --text=" + CHR$(34) + "(" + ProgramName$ + "): failed - Runs on LINUX only. Program Terminated." + CHR$(34) + " --width=175 --height=100")
	PRINT #flog%, "(" + ProgramName$ + "): ERROR: Program runs in Linux only. Program Terminated. ***"
	PRINT #flog%, "(" + ProgramName$ + "): "
	endPROG
END IF

' *** Process args passed to program (if found):
cntargs = _COMMANDCOUNT
PRINT #flog%, "(" + ProgramName$ + "): Number of ARGS: "; cntargs
FOR c = 1 TO cntargs
	PRINT #flog%, "(" + ProgramName$ + "): ARGS Passed: "; COMMAND$(c) 		'print commands sent
NEXT c
PRINT #flog%, "(" + ProgramName$ + "): 

IF cntargs > 0 THEN
	rows = cntargs: cols = 2
	REDIM AS STRING Query(1 TO cols)
	REDIM AS STRING Answer(1 TO rows, 1 TO cols)
	Delim$ = "=": TokReplace$ = ":": nbrRows = 0

	FOR x = 1 TO cntargs
		qString$ = COMMAND$(x)
		IF LEN(qString$) <> 0 THEN
			nbrRows = nbrRows + 1
			return$ = TokenReplace$ (qString$, TokReplace$, Delim$)
			return$ = StrSplit$(qString$, Delim$)
		END IF
		Answer(nbrRows, 1) = Query(1)
		Answer(nbrRows, 2) = Query(2)
		PRINT #flog%, "(" + ProgramName$ + "): TOKEN: "; Query(1)
		PRINT #flog%, "(" + ProgramName$ + "): VALUE: "; Query(2)
	NEXT x
' *** Validate/populate SELECT args
	FOR x = 1 TO cntargs
		SELECT CASE Answer(x, 1)
			   CASE "TEAMNAME"
					teamName = Answer(x, 2)
               CASE "GAMEID"
					gameID = Answer(x, 2)
			   CASE "GAMES"
					IF ISNUMERIC(Answer(x, 2)) THEN
						gamesPlayed = Answer(x, 2)
					ELSE
						gamesPlayed = "1"
					END IF
              CASE "SQLDB"
					mysqlDB$ = Answer(x, 2)
			   CASE "SQLUSER"
					mysql_userid$ = Answer(x, 2)
			   CASE "SQLPWD" 
					mysql_password$ = Answer(x, 2)
			   CASE "SQLBATTBL" 
					mysql_battingTable$ = Answer(x, 2)
			   CASE "SQLPITCHTBL" 
					mysql_pitchingTable$ = Answer(x, 2)
			   CASE "SQLOUTDIR" 
					mysql_outputdir$ = Answer(x, 2)
			   CASE "SQLOUTFILE" 
					mysql_outfile$ = Answer(x, 2)
			   CASE "PRINTREPORT" 					
					mysql_printreport$ = Answer(x, 2)
			   CASE "INNINGS" 
					nbr_innings$ = Answer(x, 2)
		END SELECT
	NEXT x
END IF
PRINT #flog%, "(" + ProgramName$ + "): "
