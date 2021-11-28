
SUB LoadConfigFile:
'------------------------------------------------------------
' *** Load Config File Values (File must already exist) and
' *** create ARGx values to pass from baseballStats to other
' *** programs.
'

	PRINT #flog%, ">>>>> Executing SUB LoadConfigFile": PRINT #flog%, ""

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
			ELSE
				IF LEFT$(qString$, 1) <> ";" THEN
					retcode = StrSplit$(qString$, Delim$)
					IF Query(1) = "SQLDB" THEN 
						mySQLDB$ = Query(2)
						ARG1$ = qString$
					END IF
					IF Query(1) = "SQLUSER" THEN 
						mysql_userid$ = Query(2)
						ARG2$ = qString$
					END IF
					IF Query(1) = "SQLPWD" THEN 
						mysql_password$ = Query(2)
						ARG3$ = qString$
					END IF
					IF Query(1) = "SQLBATTBL" THEN 
						mysql_battingTable$ = Query(2)
						ARG4$ = qString$
					END IF
					IF Query(1) = "SQLPITCHTBL" THEN 
						mysql_pitchingTable$ = Query(2)
						ARG5$ = qString$
					END IF
					IF Query(1) = "SQLOUTDIR" THEN 
						mysql_outputdir$ = Query(2)
						ARG6$ = qString$
					END IF
					IF Query(1) = "INNINGS" THEN 
						nbr_innings$ = Query(2)
						ARG7$ = qString$
					END IF
				END IF
			END IF
		LOOP
		CLOSE #f1%
	ELSE
		PRINT #flog%, ""
		PRINT #flog%, "*** " + ProgramName$ + " ERROR: config.ini File Missing, Program Terminated."
		CLOSE #flog%
		SYSTEM 1
	END IF

END SUB
