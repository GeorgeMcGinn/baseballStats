REM $TITLE: baseballStats.bas Version 1.0.0  09/20/2021 - Last Update: 05/31/2022
_TITLE "Main Menu Processing Version 1.0.0  09/20/2021 - Last Update: 05/31/2022"
' baseballStats.bas    Version 1.0.0  09/20/21
'--------------------------------------------------------------------------------------
'       PROGRAM: baseballStats.bas
'        AUTHOR: George McGinn
'                <gbytes58@gmail.com>
'
'  DATE WRITTEN: 09/20/2021
'       VERSION: 1.0.0
'       PROJECT: Baseball/Softball Statistics Recordkkeeping System
'
'   DESCRIPTION: Main program that controls the processing of the 
'                Baseball/Softball Statistics System. 
'
' Written by George McGinn
' Copyright ©2021/2022 by George McGinn - All Rights Reserved
' Version 1.0.0 - Created 09/20/2021, Finalized on 05/31/2022
'
' CHANGE LOG
'--------------------------------------------------------------------------------------
' 09/20/2021 v1    $EXEICON:iconfile.ico.0.0  GJM - New Program.
' 09/21/2021 v0.11   GJM - Create INCLUDE files for shared DIM & SUB/FUNCTIONS.
' 09/26/2021 v0.12   GJM - Add a Menu to select functionality & process them 
' 09/27/2021 v0.13   GJM - Added a file clean-up in the endPROG label and an
'                          error handling routine for system errors.    
' 09/29/2021 v0.14   GJM - Added League/Team Stats Menu Item & processing.               
' 09/30/2021 v0.14   GJM - Updated pipecom based on a change by Zach. Also added
'                          logic to call the baseballConfig module.
' 10/01/2021 v0.15   GJM - Added config file processing and passing ARG values
'                          to programs this module calls.
' 10/02/2021 v0.16   GJM - Added first time install/create new SQL environment
'                          and added batting and pitching tables to Config File.
' 10/03/2021 v0.17   GJM - Added HELP display to the Main Menu screen.
' 10/05/2021 v0.18   GJM - Added ProgramName$ that is determined in initialization.
' 10/06/2021 v0.19   GJM - Updated program to new directory structure & file names.
' 10/11/2021 v0.20   GJM - Added number of innings to config file processing.
' 11/21/2021 v0.21   GJM - Add the output mySQL directory to the config.ini file
'                          and standardized the size of the HELP screen
' 12/07/2021 v0.22   GJM - Updated CC licensing
' 12/14/2021 v0.23   GJM - Added the Splash Screen to display two sets - one for
'                          the first run, asking users to agree to license before
'                          setting up the system, and one that displays when the
'                          [ABOUT] button is pressed, or at the start without the
'                          checkbox after the system has been set up. Part of the 
'                          splash screen produces a menu so all the HELP topics can 
'                          be viewed ahead of time, and the other the legal code 
'                          for licensing.
' 04/22/2022 v0.24   GJM - Added direct connect/access to mySQL/mariaDB from a Client
'                          Connector I wrote in C. This will replace pipecom for all
'                          SQL calls, and allow direct access to SQL tables/views.
' 05/31/2022 v0.25   GJM - Fixed bugs in the use of mysqlClient.h and changes to QB64
'                          source to finialize using the mySQL/mariaDB Client Connector.
'                          Also cleaned up code, like nested IF statements. Program is
'                          ready for Release 1.0.
'--------------------------------------------------------------------------------------
'  Copyright ©2021/2022 by George McGinn.  All Rights Reserved.
'
' baseballStats by George McGinn is licensed under a Creative Commons
' Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
'
' Full License Link: https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
'
'--------------------------------------------------------------------------------------
' PROGRAM NOTES
' -------------
' 
' This system will only run on Linux. I have created a InForm version for cross-platform 
' use, but there are still issues with the GUI and some memory leak issues.
'
' A possible change would be to add the ability to select whether to PRINT or DISPLAY
' the report based on a config.ini file switch. This can become v1.0.1, as this change
' would be a system-wide change, but a small one to implement.
'
'--------------------------------------------------------------------------------------

$CONSOLE:ONLY
'$DYNAMIC
OPTION BASE 1

ON ERROR GOTO ehandler

'---------------------------------------------------------------------------
' *** Initialize functions that call mySQL Directly
'
'$INCLUDE: 'include/mysqlDeclarations.inc'

 
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
    PRINT #flog%, "(" + ProgramName$ + "): *** BaseballStats Log File ***" 
    PRINT #flog%, "(" + ProgramName$ + "): "
    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing PGM=baseballStats"
    PRINT #flog%, "(" + ProgramName$ + "): "

	IF INSTR(_OS$, "LINUX") THEN OStype = "LINUX"
	IF OStype <> "LINUX" THEN
		SHELL ("zenity --error --text=" + CHR$(34) + "(" + ProgramName$ + "): failed - Runs on LINUX only. Program Terminated." + CHR$(34) + " --width=175 --height=100")
		PRINT #flog%, "(" + ProgramName$ + "): ERROR: Program runs in Linux only. Program Terminated. ***"
		PRINT #flog%, "(" + ProgramName$ + "): "
		endPROG
	END IF

' *** Display the Splash/About Screen
	DisplayAbout

' *** If Config File does not exist, create it from default values
' *** perform updates and create new Database/Tables if Required
	IF NOT _FILEEXISTS(ConfigFile$) THEN
		CallConfigUpdate("INSTALL")
		InstallTables
		CallConfigUpdate("UPDATE")
	ELSE
	    LoadConfigFile
	END IF
	
    retcode = SystemsCheck
    IF retcode = FALSE THEN endPROG
 

submitMenu:
' *** Displays and processes a menu
'

' *** Display menu selections
	cmd = "zenity --list " + _
		  "       --title=" + CHR$(34) + "Main Menu - Baseball/Softball Statistics System - v1.0.0   " + CHR$(34) + _
		  "       --text=" + CHR$(34) + "Select/Double Click on Option to Process:" + CHR$(34) + _
	  	  "       --width=430 --height=225 --hide-header --column=" + CHR$(34) + "Select One" + CHR$(34) + _
		  "       --extra-button=HELP --extra-button=ABOUT --extra-button=QUIT " + _
		  CHR$(34) + "Boxscores - Add/Update" + CHR$(34) + " \ " + _
		  CHR$(34) + "Batting - Add/Update"  + CHR$(34) + " \ " + _
		  CHR$(34) + "Pitching - Add/Update" + CHR$(34) + " \ " + _
		  CHR$(34) + "League/Team Stats" + CHR$(34) + " \ " + _
		  CHR$(34) + "Create New SQL Region" + CHR$(34) + " \ " + _
		  CHR$(34) + "Config File" + CHR$(34)  

    retcode = pipecom(cmd, stdout, stderr)

' *** Save menu selection and/or button pressed   
    lenstr = LEN(stdout): stdout = LEFT$(stdout, lenstr - 1) 
	stdmenu = LTRIM$(stdout)
	stdbutton = stdout

' *** If X, Cancel or QUIT buttons are pressed, end program
	IF retcode = 1 AND stdbutton = NULL THEN endPROG
	IF retcode = 1 AND stdbutton = "QUIT" THEN endPROG

' *** If HELP button pressed, display the HELP Screen	
    IF retcode = 1 AND stdbutton = "HELP" THEN
        cmd = "zenity --text-info " + _
              " --title=" + CHR$(34) + "HELP: Baseball/Softball Statistics System - v1.0.0" + CHR$(34) + _
              " --width=1000 --height=850 --html --ok-label=" + CHR$(34) + "Return to Menu" + CHR$(34) +  _
              " --filename=" + "help/baseballStats.html" + " 2> /dev/null"
        SHELL (cmd)
        GOTO SubmitMenu
    END IF

' *** If ABOUT button pressed, display the ABOUT Splash Screen	
    IF retcode = 1 AND stdbutton = "ABOUT" THEN DisplayAbout: GOTO submitMenu
    
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
				endPROG
		   CASE ELSE
				GOTO submitMenu
	END SELECT


ehandler:
'$INCLUDE: 'include/baseballErrhandler.inc'


SUB SubmitForm
' ** Submit/process form to capture ARGs to pass to called programs
'

'$INCLUDE: 'include/baseballMainForm.inc'

END SUB


SUB CallBatting
' ** Call the Batting Stats program with ARGs
'

' *** PRINT ARGS to Log File
    PRINT #flog%, "(" + ProgramName$ + "): ARGS to pass to battingStats"
    PRINT #flog%, "(" + ProgramName$ + "): TeamName: "; teamName
    PRINT #flog%, "(" + ProgramName$ + "): GameID: "; gameID
    PRINT #flog%, "(" + ProgramName$ + "): GamesPlayed: "; gamesPlayed
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG1: "; ARG1$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG2: "; ARG2$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG3: "; ARG3$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG4: "; ARG4$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG5: "; ARG5$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG6: "; ARG6$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG7: "; ARG7$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG8: "; ARG8$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG9: "; ARG9$
    PRINT #flog%, "(" + ProgramName$ + "): "

' *** CALL the hittingStats module, passing ARGS
    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Calling: battingStats"
    PRINT #flog%, "(" + ProgramName$ + "): "
    CLOSE #flog%
    SHELL ("./battingStats TEAMNAME:" + teamName + " GAMEID:" + gameID + " GAMES:" + gamesPlayed + " " + ARG1$ + " " + ARG2$ + " " + ARG3$ + " " + ARG4$ + " " + ARG5$ + " " + ARG6$ + " " + ARG7$ + " " + ARG8$+ " " + ARG9$)
    OPEN "logs/baseballstats.log" FOR APPEND AS #flog%
    
END SUB


SUB CallPitching
' ** Call the Pitching Stats program with ARGs
'

' *** PRINT ARGS to Log File
    PRINT #flog%, "(" + ProgramName$ + "): ARGS to pass to pitchingStats"
    PRINT #flog%, "(" + ProgramName$ + "): TeamName: "; teamName
    PRINT #flog%, "(" + ProgramName$ + "): GameID: "; gameID
    PRINT #flog%, "(" + ProgramName$ + "): GamesPlayed: "; gamesPlayed
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG1: "; ARG1$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG2: "; ARG2$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG3: "; ARG3$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG4: "; ARG4$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG5: "; ARG5$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG6: "; ARG6$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG7: "; ARG7$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG8: "; ARG8$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG9: "; ARG9$
    PRINT #flog%, "(" + ProgramName$ + "): "
    
' *** CALL the pitchingStats module, passing ARGS
    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Calling: pitchingStats"
    PRINT #flog%, "(" + ProgramName$ + "): "
    CLOSE #flog%
    SHELL ("./pitchingStats TEAMNAME:" + teamName + " GAMEID:" + gameID + " GAMES:" + gamesPlayed + " " + ARG1$ + " " + ARG2$ + " " + ARG3$ + " " + ARG4$ + " " + ARG5$ + " " + ARG6$ + " " + ARG7$ + " " + ARG8$+ " " + ARG9$)
    OPEN "logs/baseballstats.log" FOR APPEND AS #flog%

END SUB


SUB CallLeagueTeam
' ** Call the League & Team Stats program with ARGs
'

' *** CALL the leagueStats module, passing ARGS
    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Calling: leagueStats"
    PRINT #flog%, "(" + ProgramName$ + "): ARGS to pass to leagueStats"
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG1: "; ARG1$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG2: "; ARG2$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG3: "; ARG3$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG4: "; ARG4$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG5: "; ARG5$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG6: "; ARG6$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG7: "; ARG7$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG8: "; ARG8$
    PRINT #flog%, "(" + ProgramName$ + "): Config ARG9: "; ARG9$
    PRINT #flog%, "(" + ProgramName$ + "): "
    CLOSE #flog%
    SHELL ("./leagueStats " + ARG1$ + " " + ARG2$ + " " + ARG3$ + " " + ARG4$ + " " + ARG5$ + " " + ARG6$ + " " + ARG7$ + " " + ARG8$ + " " + ARG9$)
    OPEN "logs/baseballstats.log" FOR APPEND AS #flog%
    
END SUB


SUB CallConfigUpdate (ARG$)
' *** Call the Configuration File Update program with ARGs
'

' *** CALL the baseballConfig module, passing ARGS
    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Calling: baseballConfig"
    PRINT #flog%, "(" + ProgramName$ + "): "
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
	IF NOT _FILEEXISTS("config.ini") THEN
		SHELL ("zenity --error --text=" + CHR$(34) +  ProgramName$ + CHR$(34) +  " Program failed - missing Configuration File. Program Terminated" + CHR$(34) + " --width=175 --height=100")
		PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing endPROG"
		PRINT #flog%, "(" + ProgramName$ + "): "
		PRINT #flog%, "(" + ProgramName$ + "): Terminated Abnormally ***"
		CLOSE #flog%
		endPROG
	END IF

	OPEN "config.ini" FOR INPUT AS #f1%
	DO UNTIL EOF(f1%)
		LINE INPUT #f1%, qString$
		IF ISNUMERIC(qString$) THEN 
			nbrUpdates = VAL(qString$)
			REDIM Query(2)
		ELSE
			IF LEFT$(qString$, 2) <> "/*" THEN
				return$ = StrSplit$(qString$, Delim$)
				idx = idx + 1
				SELECT CASE Query(1)
					   CASE "SQLDB": mysqlDB$ = Query(2)
                       CASE "SQLUSER": mysql_userid$ = Query(2)
                       CASE "SQLPWD": mysql_password$ = Query(2)
                       CASE "SQLBATTBL": mysql_battingTable$ = Query(2)
                       CASE "SQLPITCHTBL": mysql_pitchingTable$ = Query(2)
                       CASE "SQLOUTDIR": mysql_outputdir$ = Query(2)
                       CASE "SQLOUTFILE": mysql_outfile$ = Query(2)
                       CASE "PRINTREPORT": mysql_printreport$ = Query(2)
                       CASE "INNINGS": nbr_innings$ = Query(2)
                END SELECT
			END IF
		END IF
	LOOP
	CLOSE #f1%

mysqlConnection:
' *** Connect to the mySQL Server
	PRINT #flog%, "(" + ProgramName$ + "): Connecting to mySQL Server ***" 
	PRINT #flog%, "(" + ProgramName$ + "): "
	PRINT #flog%, "(" + ProgramName$ + "): Values passed: [localhost], " + "[" + mysql_userid$ + "], [" + mysql_password$ + "], [NULL] " 
	retcode = sqlConnect("localhost", mysql_userid$+CHR$(0), mysql_password$+CHR$(0), NULL+CHR$(0))
	PRINT #flog%, "(" + ProgramName$ + "): SQL Return Code ="; retcode; 
	IF retcode <> 0 THEN
		PRINT #flog%, "(" + ProgramName$ + "): ERROR: Connection to server failed. Please check and run again. Return Code ="; retcode;  " ***"
		PRINT #flog%, "(" + ProgramName$ + "): Values passed: [localhost], " + "[" + mysql_userid$ + "], [" + mysql_password$ + "], [NULL] " 
		PRINT #flog%, "(" + ProgramName$ + "): "
		retcode = sqlDisconnect
		endPROG
	END IF
	PRINT #flog%, "(" + ProgramName$ + "): Connection to mySQL Server established as [localhost], " + "[" + mysql_userid$ + "], [NULL] " 
	PRINT #flog%, "(" + ProgramName$ + "): "
	sqlActive = TRUE

' *** Perform initial SQL setup of Database and Tables
	retcode = sqlCreateDatabase(mysqlDB$+CHR$(0))
	IF retcode <> 0 THEN 
		PRINT #flog%, "(" + ProgramName$ + "): >>>>> Create Database (" + mysqlDB$ + ") Failed."
		endPROG
	END IF
	PRINT #flog%, "(" + ProgramName$ + "): >>>>>Database (" + mysqlDB$ + ") Created."

    retcode = sqlUseDatabase(mysqlDB$+CHR$(0))
	IF retcode <> 0 THEN 
		PRINT #flog%, "(" + ProgramName$ + "): >>>>> Use Database (" + mysqlDB$ + ") Failed."
		endPROG
	END IF
	PRINT #flog%, "(" + ProgramName$ + "): >>>>> Now using (" + mysqlDB$ + ") database."

    retcode = sqlDropTable(mysql_battingTable$+CHR$(0))
	IF retcode <> 0 THEN 
		PRINT #flog%, "(" + ProgramName$ + "): >>>>> Drop Table (" + mysql_battingTable$ + ") Failed."
		endPROG
	END IF

    retcode = sqlDropTable(mysql_pitchingTable$+CHR$(0))
	IF retcode <> 0 THEN 
		PRINT #flog%, "(" + ProgramName$ + "): >>>>> Drop Table (" + mysql_pitchingTable$ + ") Failed."
		endPROG
	END IF

' *** Load the SQL install statement files and execute them
    sqlstmtfile$ = "sql/createBattingTable.sqlproc"
	'$INCLUDE: 'include/baseballSQLstmt.inc'
    sqlstmtfile$ = "sql/createPitchingTable.sqlproc"
	'$INCLUDE: 'include/baseballSQLstmt.inc'

' *** Disconnect from SQL Server
	retcode = sqlDisconnect
	IF retcode <> 0 THEN 
		PRINT #flog%, "(" + ProgramName$ + "): Disconnecting from server failed. Program terminated. Return Code ="; retcode
		PRINT #flog%, "(" + ProgramName$ + "): *** Program Execution FAILED ***"
		CLOSE #flog%
		endPROG
	END IF		
	sqlActive = FALSE		
    
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
    mysql_outfile$ = "N"
	mysql_printreport$ = "N"
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

    retcode = pipecom(cmd, stdout, stderr)

' *** Save menu selection and/or button pressed   
    lenstr = LEN(stdout): stdout = LEFT$(stdout, lenstr - 1) 
	stdmenu = LTRIM$(stdout)
	stdbutton = stdout

	IF retcode = 0 THEN IssueWarning = TRUE ELSE IssueWarning = FALSE

END FUNCTION


'-----------------------------------------------------------------------
' INCLUDES: ------------------------------------------------------------
'
'$INCLUDE: 'include/endPROG.inc'
'$INCLUDE: 'include/baseballAboutDisplay.inc'
'$INCLUDE: 'include/baseballDisplayHelpMenu.inc'
'$INCLUDE: 'include/baseballConfig.inc'
'$INCLUDE: 'include/baseballFunctions.inc'
'$INCLUDE: 'include/stringFunctions.inc'
'$INCLUDE: 'include/pipecom.inc'
