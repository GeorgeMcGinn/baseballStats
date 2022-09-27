
SUB LoadConfigFile:
'------------------------------------------------------------
' *** Load Config File Values (File must already exist) and
' *** create ARGx values to pass from baseballStats to other
' *** programs.
'

	PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing SUB LoadConfigFile"
	PRINT #flog%, "(" + ProgramName$ + "): "

' *** Read Config File IF EXISTS. If not, create it with default values
	Delim$ = "="
	f1% = FREEFILE
	IF _FILEEXISTS(ConfigFile$) THEN
		OPEN ConfigFile$ FOR INPUT AS #f1%
		DO UNTIL EOF(f1%)
			LINE INPUT #f1%, qString$
			IF ISNUMERIC(qString$) THEN 
				nbrUpdates = VAL(qString$)
				REDIM Query(2)
			ELSEIF LEFT$(qString$, 2) <> "/*" THEN
				return$ = StrSplit$(qString$, Delim$)
				SELECT CASE Query(1)
					   CASE "SQLDB"
							mySQLDB$ = Query(2)
							ARG1$ = qString$
					   CASE "SQLUSER"
							mysql_userid$ = Query(2)
							ARG2$ = qString$
					   CASE "SQLPWD" 
							mysql_password$ = Query(2)
							ARG3$ = qString$
					   CASE "SQLBATTBL" 
							mysql_battingTable$ = Query(2)
							ARG4$ = qString$
					   CASE "SQLPITCHTBL" 
							mysql_pitchingTable$ = Query(2)
							ARG5$ = qString$
					   CASE "SQLOUTDIR"
							mysql_outputdir$ = Query(2)
							ARG6$ = qString$
					   CASE "SQLOUTFILE" 
							mysql_outfile$ = Query(2)
							ARG7$ = qString$
					   CASE "PRINTREPORT" 
							mysql_printreport$ = Query(2)
							ARG8$ = qString$
					   CASE "INNINGS"
							nbr_innings$ = Query(2)
							ARG9$ = qString$
				END SELECT
			END IF
		LOOP
		CLOSE #f1%
	ELSE
		PRINT #flog%, "(" + ProgramName$ + "): "
		PRINT #flog%, "(" + ProgramName$ + "): ERROR: config.ini File Missing, Program Terminated."
		CLOSE #flog%
		SYSTEM 1
	END IF

END SUB
