    rows = 0: nbrLines = 0: idx = 1

	IF _FILEEXISTS(sqlstmtfile$) THEN
		f1% = FREEFILE
		OPEN sqlstmtfile$ FOR INPUT AS #f1%
		DO UNTIL EOF(f1%)
			LINE INPUT #f1%, qString$
			IF rows = 0 THEN
				rows = VAL(qString$)
				REDIM AS STRING sqlStmt(1 TO rows)
			ELSE
				IF LEN(qString$) <> 0 THEN
					nbrLines = nbrLines + 1
					sqlStmt(idx) = qString$
					idx = idx + 1
				END IF
			END IF
		LOOP
		CLOSE #f1%
	ELSE
		SHELL ("zenity --error --text=" + COMMAND$(0) + CHR$(34) + " Program (" + ProgramName$ + "): failed - missing " + CHR$(34) + sqlstmtfile$ + CHR$(34) + " SQL Statement File. Program Terminated" + CHR$(34) + " --width=175 --height=100")
		PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing endPROG"
		PRINT #flog%, "(" + ProgramName$ + "): "
		PRINT #flog%, "(" + ProgramName$ + "): - Terminated Abnormally ***"
		CLOSE #flog%
		SYSTEM 1
	END IF

' *** Replace the token <SQLDB> with mysqlDB$ 
	Token$ = "<SQLDB>"
    FOR x = 1 TO nbrLines
        qString$ = sqlStmt(x)
        sqlStmt(x) = TokenReplace$(qString$, Token$, mysqlDB$)
    NEXT x

' *** Replace the token <BATSQLTBL> with battingTable$ inputted from Config File
	Token$ = "<BATSQLTBL>"
    FOR x = 1 TO nbrLines
        qString$ = sqlStmt(x)
        sqlStmt(x) = TokenReplace$(qString$, Token$, mysql_battingTable$)
    NEXT x

' *** Replace the token <PITCHSQLTBL> with pitchingTable$ inputted from Config File
	Token$ = "<PITCHSQLTBL>"
    FOR x = 1 TO nbrLines
        qString$ = sqlStmt(x)
        sqlStmt(x) = TokenReplace$(qString$, Token$, mysql_pitchingTable$)
    NEXT x
    
' *** Replace the token <SQLOUTDIR> with SQL Output Directory inputted from Config File
	Token$ = "<SQLOUTDIR>"
    FOR x = 1 TO nbrLines
        qString$ = sqlStmt(x)
        sqlStmt(x) = TokenReplace$(qString$, Token$, mysql_outputdir$)
    NEXT x

' *** Replace the token <TEAMNAME> with teamName inputted from console input
	Token$ = "<TEAMNAME>"
    FOR x = 1 TO nbrLines
        qString$ = sqlStmt(x)
        sqlStmt(x) = TokenReplace$(qString$, Token$, teamName)
    NEXT x

' *** Replace the token <INNINGS> with innings from the Config File
	Token$ = "<INNINGS>"
    FOR x = 1 TO nbrLines
        qString$ = sqlStmt(x)
        sqlStmt(x) = TokenReplace$(qString$, Token$, nbr_innings$)
    NEXT x

' *** Create the SQL command to execute Create the SQL Database/Tables in pipecom
    cmd = NULL
    FOR x = 1 TO nbrLines
        PRINT #flog%, "(" + ProgramName$ + "): "; sqlStmt(x)
        cmd = cmd + sqlStmt(x) + " "
    NEXT x
    PRINT #flog%, "(" + ProgramName$ + "): "  
    PRINT #flog%, "(" + ProgramName$ + "): cmd = "; cmd
	PRINT #flog%, "(" + ProgramName$ + "): "
	
' *** Execute the SQL statements using pipecom to create the SQL Database/Tables
	retcode = sqlCMD(cmd + CHR$(0))
	IF retcode <> 0 THEN
		PRINT #flog%, "(" + ProgramName$ + " - baseballSQLstmt.inc): SQL Command Failed. Please check output and run again. Return Code ="; retcode
		retcode = sqlDisonnect
		SYSTEM 99
	ELSE
		PRINT #flog%, "(" + ProgramName$ + " - baseballSQLstmt.inc): SQL Command executed normally"
	END IF
