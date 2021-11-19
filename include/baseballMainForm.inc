
'---------------------------------------------------
' *** If ARGS=0 or teamName is not passed, execute GUI to retrieve all fields

ProcessTeamForm:
	IF cntargs = 0 OR teamName = "" THEN
		stdout = "": stderr = ""
		cmd = "zenity --forms --title=" + CHR$(34) + "Baseball/Softball Statistics System - v1.0" + CHR$(34) + _
			  " --text=" + CHR$(34) + "Enter Team Name For Statisical Review" + CHR$(34) + _
			  " --width=415 " + _
			  " --add-entry=" + CHR$(34) + "Team Name" + CHR$(34) + _
			  " --add-entry=" + CHR$(34) + "Game ID" + CHR$(34) + _
			  " --add-entry=" + CHR$(34) + "Games Played" + CHR$(34) + _
			  " --extra-button=HELP --extra-button=QUIT"
		result = pipecom(cmd, stdout, stderr)
		lenstr = LEN(stdout): stdout = LEFT$(stdout, lenstr - 1)
		stdbutton = LEFT$(stdout, lenstr - 1)
		IF stdbutton = "QUIT" THEN GOTO endPROG
		IF result = 1 AND stdbutton = "HELP" THEN
			cmd = "zenity --text-info " + _
			  	  " --title=" + CHR$(34) + "HELP/ABOUT: Baseball Stats" + CHR$(34) + _
				  " --width=900 --height=800 --html --ok-label=" + CHR$(34) + "Return to Menu" + CHR$(34) +  _
			  	  " --filename=help/baseballTeamInput.html" + " 2> /dev/null"
			SHELL (cmd)
			GOTO ProcessTeamForm
		END IF
		IF result <> 0 THEN
			SHELL ("zenity --error --text=" + CHR$(34) + "(" + ProgramName$ + "): Main Form did not load. Program Terminated." + CHR$(34) + " --width=175 --height=100")
			GOTO endPROG
		END IF		
' *** Split out names of selected records into the Query array
		REDIM Query(3)
		Delim$ = "|"
		qString$ = stdout
		retcode = StrSplit$(qString$, Delim$)		
' *** Populate the variables based on FORM input
		teamName = Query(1)
		gameID = Query(2)
		IF ISNUMERIC(Query(3)) THEN
			gamesPlayed = Query(3)
		ELSE
			gamesPlayed = "1"
		END IF		
	END IF
