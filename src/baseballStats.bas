REM $TITLE: baseballStats.bas Version 0.22  09/20/2021 - Last Update: 12/07/2021
_TITLE "baseballStats.bas"
' baseballStats.bas    Version 1.0  09/20/21
'-------------------------------------------------------------------------------
'       PROGRAM: baseballStats.bas
'        AUTHOR: George McGinn
'
'                <gjmcginn@icloud.com>
'
'  DATE WRITTEN: 09/20/2021
'       VERSION: 1.0
'       PROJECT: Baseball/Softball Statistics System
'
'   DESCRIPTION: Main program that controls the processing of the 
'                Baseball/Softball Statistics System. 
'
' Written by George McGinn
' Copyright ©2021 by George McGinn - All Rights Reserved
' Version 1.0 - Created 09/20/2021
'
' CHANGE LOG
'-------------------------------------------------------------------------------
' 09/20/21 v1.0  GJM - New Program.
' 09/21/21 v0.11 GJM - Create INCLUDE files for shared DIM & SUB/FUNCTIONS.
' 09/26/21 v0.12 GJM - Add a Menu to select functionality & process them 
' 09/27/21 v0.13 GJM - Added a file clean-up in the endPROG label and an
'                      error handling routine for system errors.    
' 09/29/21 v0.14 GJM - Added League/Team Stats Menu Item & processing.               
' 09/30/21 v0.14 GJM - Updated pipecom based on a change by Zach. Also added
'                      logic to call the baseballConfig module.
' 10/01/21 v0.15 GJM - Added config file processing and passing ARG values
'                      to programs this module calls.
' 10/02/21 v0.16 GJM - Added first time install/create new SQL environment
'                      and added batting and pitching tables to Config File.
' 10/03/21 v0.17 GJM - Added HELP display to the Main Menu screen.
' 10/05/21 v0.18 GJM - Added ProgramName$ that is determined in initialization.
' 10/06/21 v0.19 GJM - Updated program to new directory structure & file names.
' 10/11/21 v0.20 GJM - Added number of innings to config file processing.
' 11/21/21 v0.21 GJM - Add the output mySQL directory to the config.ini file
'                      and standardized the size of the HELP screen
' 12/07/21 v0.22 GJM - Updated CC licensing
'-------------------------------------------------------------------------------
'  Copyright ©2021 by George McGinn.  All Rights Reserved.
'
' baseballStats by George McGinn is licensed under a Creative Commons
' Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
'
' Full License Link: https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
'
'-------------------------------------------------------------------------------------
' PROGRAM NOTES
' --------------
' 11/21 - Verify that the proper ARGS are being passed. The SQL Output Directory
'         must be in ARG6, or ARG7 for the calls that already use ARG6.
'
'-------------------------------------------------------------------------------


$CONSOLE:ONLY
'$DYNAMIC
OPTION BASE 1

ON ERROR GOTO ehandler

'-------------------------------------------------------------
' *** Initialize Section
'
'$INCLUDE: 'include/baseballInit.inc'


QBMain:
'------------------------------------------------------------
' *** MAIN Program Logic
'

    flog% = FREEFILE
    OPEN "logs/baseballstats.log" FOR OUTPUT AS #flog%
    PRINT #flog%, "*** BaseballStats Log File ***": PRINT #flog%, ""
    PRINT #flog%, ""
    PRINT #flog%, ">>>>> Executing PGM=baseballStats"
    PRINT #flog%, ""

    result = SystemsCheck
    IF result = FALSE THEN GOTO endPROG

' *** If Config File does not exist, Call baseballInstall
	IF NOT _FILEEXISTS(ConfigFile$) THEN
		CallConfigUpdate("INSTALL")
		InstallTables
		CallConfigUpdate("UPDATE")
	END IF

submitMenu:
' *** Displays and processes a menu
'

' *** Display menu selections
	cmd = "zenity --list " + _
		  "       --title=" + CHR$(34) + "Main Menu - Baseball/Softball Statistics System - v1.0   " + CHR$(34) + _
		  "       --text=" + CHR$(34) + "Select/Double Click on Option to Process:" + CHR$(34) + _
	  	  "       --width=430 --height=225 --hide-header --column=" + CHR$(34) + "Select One" + CHR$(34) + _
		  "       --extra-button=HELP --extra-button=QUIT " + _
		  CHR$(34) + "Boxscores - Add/Update" + CHR$(34) + " \ " + _
		  CHR$(34) + "Batting - Add/Update"  + CHR$(34) + " \ " + _
		  CHR$(34) + "Pitching - Add/Update" + CHR$(34) + " \ " + _
		  CHR$(34) + "League/Team Stats" + CHR$(34) + " \ " + _
		  CHR$(34) + "Create New SQL Region" + CHR$(34) + " \ " + _
		  CHR$(34) + "Config File" + CHR$(34)  

    result = pipecom(cmd, stdout, stderr)

' *** Save menu selection and/or button pressed   
    lenstr = LEN(stdout): stdout = LEFT$(stdout, lenstr - 1) 
	stdmenu = LTRIM$(stdout)
	stdbutton = stdout

' *** If X, Cancel or QUIT buttons are pressed, end program
	IF result = 1 AND stdbutton = "" THEN GOTO endPROG
	IF result = 1 AND stdbutton = "QUIT" THEN GOTO endPROG

' *** If HELP button pressed, display the HELP Screen	
    IF result = 1 AND stdbutton = "HELP" THEN
        cmd = "zenity --text-info " + _
              " --title=" + CHR$(34) + "HELP: Baseball/Softball Statistics System - v1.0" + CHR$(34) + _
              " --width=1000 --height=850 --html --ok-label=" + CHR$(34) + "Return to Menu" + CHR$(34) +  _
              " --filename=" + "help/baseballStats.html" + " 2> /dev/null"
        SHELL (cmd)
        GOTO SubmitMenu
    END IF

' *** Process menu selection
	SELECT CASE stdmenu
		   CASE "Boxscores - Add/Update"
		   		SubmitForm
		   		IF stdbutton = "QUIT" THEN GOTO submitMenu
		   		LoadConfigFile
		   		CallBatting
				CallPitching
				GOTO submitMenu
		   CASE "Batting - Add/Update"
				SubmitForm
		   		IF stdbutton = "QUIT" THEN GOTO submitMenu
				LoadConfigFile
				CallBatting
				GOTO submitMenu
		   CASE "Pitching - Add/Update"
				SubmitForm
		   		IF stdbutton = "QUIT" THEN GOTO submitMenu
				LoadConfigFile
				CallPitching
				GOTO submitMenu
		   CASE "League/Team Stats"
				LoadConfigFile
				CallLeagueTeam
				GOTO submitMenu
		   CASE "Create New SQL Region"
				IF IssueWarning THEN
					ResetSystem
					CallConfigUpdate("INSTALL")
					InstallTables
					CallConfigUpdate("UPDATE")
				END IF
				GOTO submitMenu
		   CASE "Config File"
				CallConfigUpdate("UPDATE")
				GOTO submitMenu
		   CASE "QUIT"
				GOTO endPROG
		   CASE ELSE
				GOTO submitMenu
	END SELECT


endPROG:
' *** CLOSE Log File
'

' *** Remove work files if they exist
'$INCLUDE: 'include/deleteWorkFiles.inc'
	
    PRINT #flog%, ">>>>> Executing endPROG"
    PRINT #flog%, ""

    PRINT #flog%, "": PRINT #flog%, "*** " + ProgramName$ + " - Terminated Normally ***"
    CLOSE #flog%
    SYSTEM


ehandler:
'$INCLUDE: 'include/baseballErrhandler.inc'


SUB SubmitForm
' ** Submit/process form to capture ARGs to pass to called programs
'

'$INCLUDE: 'include/baseballMainForm.inc'

EXIT SUB


endPROG:
' *** CLOSE Log File
'

' *** Remove work files if they exist
'$INCLUDE: 'include/deleteWorkFiles.inc'

	
''    PRINT #flog%, ">>>>> Executing endPROG"
''    PRINT #flog%, ""
''    PRINT #flog%, "": PRINT #flog%, "*** " + ProgramName$ + " - Terminated Normally ***"
''    CLOSE #flog%
''    SYSTEM

END SUB

'*** 11/21 (GJM)- Verify that the proper ARGS are being passed. The SQL Output Directory
'***              must be in ARG6, or ARG7 for the calls that already use ARG6.


SUB CallBatting
' ** Call the Batting Stats program with ARGs
'

' *** PRINT ARGS to Log File
    PRINT #flog%, "ARGS to pass to battingStats"
    PRINT #flog%, "TeamName: "; teamName
    PRINT #flog%, "GameID: "; gameID
    PRINT #flog%, "GamesPlayed: "; gamesPlayed
    PRINT #flog%, "Config ARG1: "; ARG1$
    PRINT #flog%, "Config ARG2: "; ARG2$
    PRINT #flog%, "Config ARG3: "; ARG3$
    PRINT #flog%, "Config ARG4: "; ARG4$
    PRINT #flog%, "Config ARG5: "; ARG5$
    PRINT #flog%, "Config ARG6: "; ARG6$
    PRINT #flog%, "Config ARG7: "; ARG7$
    PRINT #flog%, ""

' *** CALL the hittingStats module, passing ARGS
    PRINT #flog%, ">>>>> Calling: battingStats"
    PRINT #flog%, ""
    CLOSE #flog%
    SHELL ("./battingStats TEAMNAME:" + teamName + " GAMEID:" + gameID + " GAMES:" + gamesPlayed + " " + ARG1$ + " " + ARG2$ + " " + ARG3$ + " " + ARG4$ + " " + ARG5$ + " " + ARG6$)
    OPEN "logs/baseballstats.log" FOR APPEND AS #flog%
    
END SUB


SUB CallPitching
' ** Call the Pitching Stats program with ARGs
'

' *** PRINT ARGS to Log File
    PRINT #flog%, "ARGS to pass to pitchingStats"
    PRINT #flog%, "TeamName: "; teamName
    PRINT #flog%, "GameID: "; gameID
    PRINT #flog%, "GamesPlayed: "; gamesPlayed
    PRINT #flog%, "Config ARG1: "; ARG1$
    PRINT #flog%, "Config ARG2: "; ARG2$
    PRINT #flog%, "Config ARG3: "; ARG3$
    PRINT #flog%, "Config ARG4: "; ARG4$
    PRINT #flog%, "Config ARG5: "; ARG5$
    PRINT #flog%, "Config ARG6: "; ARG6$
    PRINT #flog%, "Config ARG7: "; ARG7$
    PRINT #flog%, ""
    
' *** CALL the pitchingStats module, passing ARGS
    PRINT #flog%, ">>>>> Calling: pitchingStats"
    PRINT #flog%, ""
    CLOSE #flog%
    SHELL ("./pitchingStats TEAMNAME:" + teamName + " GAMEID:" + gameID + " GAMES:" + gamesPlayed + " " + ARG1$ + " " + ARG2$ + " " + ARG3$ + " " + ARG4$ + " " + ARG5$ + " " + ARG6$ + " " + ARG7$)
    OPEN "logs/baseballstats.log" FOR APPEND AS #flog%

END SUB


SUB CallLeagueTeam
' ** Call the League & Team Stats program with ARGs
'

' *** CALL the leagueStats module, passing ARGS
    PRINT #flog%, ">>>>> Calling: leagueStats"
    PRINT #flog%, "ARGS to pass to leagueStats"
    PRINT #flog%, "Config ARG1: "; ARG1$
    PRINT #flog%, "Config ARG2: "; ARG2$
    PRINT #flog%, "Config ARG3: "; ARG3$
    PRINT #flog%, "Config ARG4: "; ARG4$
    PRINT #flog%, "Config ARG5: "; ARG5$
    PRINT #flog%, "Config ARG6: "; ARG6$
    PRINT #flog%, "Config ARG7: "; ARG7$
    PRINT #flog%, ""
    CLOSE #flog%
    SHELL ("./leagueStats " + ARG1$ + " " + ARG2$ + " " + ARG3$ + " " + ARG4$ + " " + ARG5$ + " " + ARG6$ + " " + ARG7$)
    OPEN "logs/baseballstats.log" FOR APPEND AS #flog%
    
END SUB


SUB CallConfigUpdate (ARG$)
' *** Call the Configuration File Update program with ARGs
'

' *** CALL the baseballConfig module, passing ARGS
    PRINT #flog%, ">>>>> Calling: baseballConfig"
    PRINT #flog%, ""
    CLOSE #flog%
    SHELL ("./baseballConfig " + ARG$)
    OPEN "logs/baseballstats.log" FOR APPEND AS #flog%
    
END SUB


SUB InstallTables
' *** Install/Setup Subroutine
' *** Create the SQL Database and Tables
'

' *** Read Config File IF EXISTS. If not, exit system
	Delim$ = "=": nbrUpdates = 0: idx = 1
	f1% = FREEFILE
	IF _FILEEXISTS("config.ini") THEN
		OPEN "config.ini" FOR INPUT AS #f1%
		DO UNTIL EOF(f1%)
			LINE INPUT #f1%, qString$
			IF ISNUMERIC(qString$) THEN 
				nbrUpdates = VAL(qString$)
				REDIM Query(2)
			ELSE
				IF LEFT$(qString$, 2) <> "/*" THEN
					retcode = StrSplit$(qString$, Delim$)
					idx = idx + 1
					SELECT CASE Query(1)
						   CASE "SQLDB": mysqlDB$ = Query(2)
                           CASE "SQLUSER": mysql_userid$ = Query(2)
                           CASE "SQLPWD": mysql_password$ = Query(2)
                           CASE "SQLBATTBL": mysql_battingTable$ = Query(2)
                           CASE "SQLPITCHTBL": mysql_pitchingTable$ = Query(2)
                           CASE "MSQLOUTDIR": mysql_outputdir$ = Query(2)
                           CASE "INNINGS": nbr_innings$ = Query(2)
                    END SELECT
				END IF
			END IF
		LOOP
		CLOSE #f1%
	ELSE
		SHELL ("zenity --error --text=" + CHR$(34) +  ProgramName$ + CHR$(34) +  " Program failed - missing Configuration File. Program Terminated" + CHR$(34) + " --width=175 --height=100")
		PRINT #flog%, ">>>>> Executing endPROG"
		PRINT #flog%, ""
		PRINT #flog%, "": PRINT #flog%, "*** " + ProgramName$ + " - Terminated Abnormally ***"
		CLOSE #flog%
		SYSTEM 1
	END IF

' *** Load the SQL install statement file
	mysqlCMD$ = "mysql -u" + mysql_userid$ + " -p" + mysql_password$ + " -s -e "
    sqlstmtfile$ = "sql/installsqlstmt.sqlproc"

'$INCLUDE: 'include/baseballSQLstmt.inc'
    
END SUB


SUB ResetSystem
' *** Reset the system to create/process a new region
'
	mySQLDB$ = "*** PLEASE UPDATE ***"
	mysql_userid$ = "*** PLEASE UPDATE ***"
	mysql_password$ = "*** PLEASE UPDATE ***"
	mysql_battingTable$ = "*** PLEASE UPDATE ***"
	mysql_pitchingTable$ = "*** PLEASE UPDATE ***"
	mysql_outputdir$ = "/var/lib/mysql-files/"
	nbr_innings$ = "*** PLEASE UPDATE ***"

	IF _FILEEXISTS(ConfigFile$) THEN KILL ConfigFile$

END SUB


FUNCTION IssueWarning
' *** Issue a warning that the config.ini file will be erased and give an
' *** option to abort
'

	cmd = "zenity --warning \ " + _
          "       --width=200 --height=60 \ " + _
          "       --extra-button=NO --ok-label=YES" + _ 
		  "       --text=" + CHR$(34) + "Continuing will erase the current config.ini file. Are you sure you wish to proceed?" + CHR$(34)

    result = pipecom(cmd, stdout, stderr)

' *** Save menu selection and/or button pressed   
    lenstr = LEN(stdout): stdout = LEFT$(stdout, lenstr - 1) 
	stdmenu = LTRIM$(stdout)
	stdbutton = stdout

	IF result = 0 THEN IssueWarning = TRUE ELSE IssueWarning = FALSE

END FUNCTION


'-----------------------------------------------------------------------

'$INCLUDE: 'include/baseballConfig.inc'

'$INCLUDE: 'include/baseballFunctions.inc'

'$INCLUDE: 'include/stringFunctions.inc'

'$INCLUDE: 'include/pipecom.inc'
