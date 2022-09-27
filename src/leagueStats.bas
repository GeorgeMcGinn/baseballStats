REM $TITLE: leagueStats.bas Version 1.0.0  09/28/2021 - Last Update: 05/31/2022
_TITLE "League Display Statistics - Version 1.0.0  09/28/2021 - Last Update: 05/31/2022"
' leagueStats.bas    Version 1.0.0  09/28/2021
'-------------------------------------------------------------------------------------
'       PROGRAM: leagueStats.bas
'        AUTHOR: George McGinn
'                <gbytes58@gmail.com>
'
'  DATE WRITTEN: 09/28/2021v1
'       VERSION: 1.0.0
'       PROJECT: Baseball/Softball Statistics System
'
'   DESCRIPTION: Main program that controls the processing of the
'                leauge and team statistics in the Baseball/Softball
'                Statistics System.
'
' Written by George McGinn
' Copyright (C)2021/2022 by George McGinn - All Rights Reserved.
' Version 1.0.0 - Created 09/28/2021, Finalized on 05/31/2022
'
'
' CHANGE LOG
'-------------------------------------------------------------------------------------
' 09/28/2021 v1.0.0 GJM - New Program.
' 09/30/2021 v0.10  GJM - Updated pipecom based on a change by Zach.
' 10/01/2021 v0.11  GJM - Added config file processing and passing ARG values
'                         to this module when called from baseballStats.
' 10/02/2021 v0.12  GJM - Added config file value for mysqlTable$ and updates to process
'                         changes to the config file.
' 10/06/2021 v0.13  GJM - Updated program to new directory structure & file names
' 10/10/2021 v0.14  GJM - There is an issue with SQL calculating ERA and correctly displaying
'                         innings pitched. Added a function to correct the display of IP
'                         and to calculate ERA correctly. Also added index CONSTANTS so
'                         code is easier to read and work with, especially if new columns
'                         are added. Changes to CONST values instead of code changes.
'                         Also added the strFormat$ to stringFunctions.inc so I can format
'                         variables properly in arrays used by Zenity for displaying.
' 10/14/2021 v0.15  GJM - Added the leagueStats files to the deleteWorkFiles include and
'                         tested it (Note: all programs recompiled and tested).
' 10/15/2021 v0.16  GJM - Corrected the ERA and IP logic to convert outs pitched now stored
'                         in SQL tables to display correctly. SQL now calculates ERA.
' 11/21/2021 v0.17  GJM - Add the output mySQL directory to the config.ini file
' 12/07/2021 v0.18  GJM - Added the HELP Screen to this module & updated CC licensing
' 12/11/2021 v0.19  GJM - Created a screen display when enscript isn't installed (This
'                         is required if application is started from an ICON or directly
'                         from Files or a File Manager).
' 12/14/2021 v0.20  GJM - Modified the text displayed in the display and update screens
'                         so that the intent is clearer. Added the ABOUT button 
'                         (As this module can run stand-a-lone). Fixed logic for 
'                         stand-a-lone execution.
' 04/23/2022 v0.21  GJM - Added direct connect/access to mySQL/mariaDB from a Client
'                         Connector I wrote in C. This will replace pipecom for all
'                         SQL calls, and allow direct access to SQL tables/views.
' 05/30/2022 v0.22  GJM - Fixed bugs in the use of mysqlClient.h and changes to QB64
'                         source to finialize using the mySQL/mariaDB Client Connector.
'                         Also cleaned up code, like nested IF statements. Program is
'                         ready for Release 1.0.
'-------------------------------------------------------------------------------------
'  Copyright (C)2021/2022 by George McGinn.  All Rights Reserved.
'
' leagueStats by George McGinn is licensed under a Creative Commons
' Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
'
' Full License Link: https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
'
'-------------------------------------------------------------------------------------
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
'-------------------------------------------------------------------------------------



'-------------------------------------------------------------------------------------
' *** Preprocessing Section
'
'$DYNAMIC
''$CONSOLE:ONLY
OPTION BASE 1
SCREEN _NEWIMAGE(1300, 600, 32)
$SCREENHIDE

DECLARE LIBRARY
    FUNCTION floor## (BYVAL num AS _FLOAT)
END DECLARE

ON ERROR GOTO ehandler

'-------------------------------------------------------------------------------------
' *** Initialize Section
'


'$INCLUDE: 'include/baseballInit.inc'

'---------------------------------------------------------------------------
' *** Initialize functions that call mySQL Directly
'
'$INCLUDE: 'include/mysqlDeclarations.inc'


'----------------------------------------------------------------------------
' *** Process args passed to program (if found) - Split out Value Pairs
'     NOTE: Process Args opens the log file, regardless of whether or not
'           any args are passed.
'
'$INCLUDE: 'include/baseballProcessArgs.inc'
innings = VAL(nbr_innings$)
PRINT #flog%, "(" + ProgramName$ + "): "
PRINT #flog%, "(" + ProgramName$ + "): *** variable innings = "; innings
PRINT #flog%, "(" + ProgramName$ + "): "

' *** Do systems checks
retcode = SystemsCheck
IF retcode = FALSE THEN endPROG


QB64Main:
'-------------------------------------------------------------------------------------
' *** MAIN Logic
'
'	PrintReport = FALSE          ' *** Set to FALSE for testing (display output)
	setLeague = TRUE
	sqlActive = FALSE

' *** Initialize SQL variables and do a SELECT to determine number of columns and
' *** rows for sizing Query array
'

mysqlConnection:
' *** Connect to the mySQL Server
	PRINT #flog%, "(" + ProgramName$ + "): Connecting to mySQL Server ***" 
	PRINT #flog%, "(" + ProgramName$ + "): "
	PRINT #flog%, "(" + ProgramName$ + "): Values passed: [localhost], " + "[" + mysql_userid$ + "], [" + mysql_password$ + "], [" + mysqlDB$ + "] " 
	retcode = sqlConnect("localhost", mysql_userid$+CHR$(0), mysql_password$+CHR$(0), mysqlDB$+CHR$(0))
	PRINT #flog%, "(" + ProgramName$ + "): SQL Return Code ="; retcode; 
	IF retcode <> 0 THEN
		PRINT #flog%, "(" + ProgramName$ + "): ERROR: Connection to server failed. Please check and run again. Return Code ="; retcode;  " ***"
		PRINT #flog%, "(" + ProgramName$ + "): Values passed: [localhost], " + "[" + mysql_userid$ + "], [" + mysql_password$ + "], [" + mysqlDB$ + "] " 
		PRINT #flog%, "(" + ProgramName$ + "): "
		retcode = sqlDisconnect
		endPROG
	END IF
	PRINT #flog%, "(" + ProgramName$ + "): Connection to mySQL Server established as [localhost], " + "[" + mysql_userid$ + "], [" + mysqlDB$ + "] " 
	PRINT #flog%, "(" + ProgramName$ + "): "
	sqlActive = TRUE

ProcessSQLFile:
    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing ProcessSQLFile"
    PRINT #flog%, "(" + ProgramName$ + "): "
 
' *** Initialize SQL variables for this program execution
	nbrRows = 0: nbrCols = 0
   
' *** Create SQL views and batting stats file
    CreateSQLViews


DisplayLeagueStandings:
' *** Show League Standings/Results
    DisplayLeagueResults
    lenstr = LEN(stdout)
    stdbutton = LEFT$(stdout, lenstr - 1)
    IF retcode = 1 AND stdbutton = NULL THEN endPROG
    IF stdbutton = "HELP" THEN 
		cmd = "zenity --text-info " + _
              " --title=" + CHR$(34) + "HELP: Baseball/Softball Statistics System - v1.0.0" + CHR$(34) + _
              " --width=1000 --height=850 --html --ok-label=" + CHR$(34) + "Return to Menu" + CHR$(34) +  _
              " --filename=" + "help/baseballLeague.html" + " 2> /dev/null"
        SHELL (cmd)
        GOTO DisplayLeagueStandings
    END IF
    IF stdbutton = "Report" THEN PrintLeagueStats: GOTO DisplayLeagueStandings	
    IF stdbutton = "ABOUT" THEN DisplayAbout: GOTO DisplayLeagueStandings
    IF stdbutton = "QUIT" THEN endPROG

DisplayLeagueBatting:    
' *** Show Team Batting Results
    DisplayTeamBattingResults
    lenstr = LEN(stdout)
    stdbutton = LEFT$(stdout, lenstr - 1)
    IF retcode = 1 AND stdbutton = NULL THEN endPROG
    IF stdbutton = "HELP" THEN 
		cmd = "zenity --text-info " + _
              " --title=" + CHR$(34) + "HELP: Baseball/Softball Statistics System - v1.0.0" + CHR$(34) + _
              " --width=1000 --height=850 --html --ok-label=" + CHR$(34) + "Return to Menu" + CHR$(34) +  _
              " --filename=" + "help/baseballLeague.html" + " 2> /dev/null"
        SHELL (cmd)
        GOTO DisplayLeagueBatting
    END IF
    IF stdbutton = "Report" THEN PrintTeamBattingStats: GOTO DisplayLeagueBatting
    IF stdbutton = "ABOUT" THEN DisplayAbout: GOTO DisplayLeagueBatting
    IF stdbutton = "QUIT" THEN endPROG

DisplayLeaguePitching:    
' *** Show Team Pitching Results
    DisplayTeamPitchingResults
    lenstr = LEN(stdout)
    stdbutton = LEFT$(stdout, lenstr - 1)
    IF retcode = 1 AND stdbutton = NULL THEN endPROG
    IF stdbutton = "HELP" THEN 
		cmd = "zenity --text-info " + _
              " --title=" + CHR$(34) + "HELP: Baseball/Softball Statistics System - v1.0.0" + CHR$(34) + _
              " --width=1000 --height=850 --html --ok-label=" + CHR$(34) + "Return to Menu" + CHR$(34) +  _
              " --filename=" + "help/baseballLeague.html" + " 2> /dev/null"
        SHELL (cmd)
        GOTO DisplayLeaguePitching
    END IF
    IF stdbutton = "Report" THEN PrintTeamPitchingStats: GOTO DisplayLeaguePitching
    IF stdbutton = "ABOUT" THEN DisplayAbout: GOTO DisplayLeaguePitching
    IF stdbutton = "QUIT" THEN endPROG
    GOTO DisplayLeagueStandings

ehandler:
'$INCLUDE: 'include/baseballErrhandler.inc'


'--------------------------------------------------------------------------------------
' *** SQL Functions
'

SUB CreateSQLViews

    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing CreateSQLView"
    PRINT #flog%, "(" + ProgramName$ + "): "
    
' *** Delete the league/team stats file from mysql-files
    leaguefile$ = mysql_outputdir$ + "leaguestats.file"
    IF _FILEEXISTS(leaguefile$) THEN KILL leaguefile$
    battingfile$ = mysql_outputdir$ + "teambattingstats.file"
    IF _FILEEXISTS(battingfile$) THEN KILL battingfile$
    pitchingfile$ = mysql_outputdir$ + "teampitchingstats.file"
    IF _FILEEXISTS(pitchingfile$) THEN KILL pitchingfile$

' *** Load the SQL statements from a file (first record is number of lines in file)
' *** and into an array for processing and execution.

' *** Create League Team Batting Views
    sqlstmtfile$ = "sql/createLeagueTempBatting.sqlproc"
	'$INCLUDE: 'include/baseballSQLstmt.inc'
    sqlstmtfile$ = "sql/createLeagueTeamBatting.sqlproc"   
	'$INCLUDE: 'include/baseballSQLstmt.inc'
	IF mysql_outfile$ = "Y" THEN
		select_what$ = "*"+CHR$(0)
		select_from$ = "teambattingView"+CHR$(0)
		select_filename$ = battingfile$+CHR$(0)
		retcode = sqlCreateOutFile(select_what$, select_from$, select_filename$)
		IF retcode <> 0 THEN 
			SHELL ("zenity --error --text=" + CHR$(34) + "leagueStats Program failed - sqlCreateOutFile failed for teambattingView. Program Terminated." + CHR$(34) + " --width=175 --height=100")
			PRINT #flog%, "(" + ProgramName$ + "): sqlCreateOutFile failed for: " + battingfile$
			PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing endPROG"
			PRINT #flog%, "(" + ProgramName$ + "): "
			PRINT #flog%, "(" + ProgramName$ + "): *** leagueStats - Terminated Abnormally ***"
			endPROG
		END IF
	END IF
    
' *** Create League Team Pitching Views
    sqlstmtfile$ = "sql/createLeagueTempPitching.sqlproc"
	'$INCLUDE: 'include/baseballSQLstmt.inc'
    sqlstmtfile$ = "sql/createLeagueTeamPitching.sqlproc"
	'$INCLUDE: 'include/baseballSQLstmt.inc'
   	IF mysql_outfile$ = "Y" THEN
		select_what$ = "*"+CHR$(0)
		select_from$ = "teampitchingView"+CHR$(0)
		select_filename$ = pitchingfile$+CHR$(0)
		retcode = sqlCreateOutFile(select_what$, select_from$, select_filename$)
		IF retcode <> 0 THEN 
			SHELL ("zenity --error --text=" + CHR$(34) + "leagueStats Program failed - sqlCreateOutFile failed for teampitchingView. Program Terminated." + CHR$(34) + " --width=175 --height=100")
			PRINT #flog%, "(" + ProgramName$ + "): sqlCreateOutFile failed for: " + pitchingfile$
			PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing endPROG"
			PRINT #flog%, "(" + ProgramName$ + "): "
			PRINT #flog%, "(" + ProgramName$ + "): *** leagueStats - Terminated Abnormally ***"
			endPROG
		END IF
	END IF

' *** Create League Team Standings Views
    sqlstmtfile$ = "sql/createLeagueView.sqlproc"
	'$INCLUDE: 'include/baseballSQLstmt.inc'
	IF mysql_outfile$ = "Y" THEN
		select_what$ = "*"+CHR$(0)
		select_from$ = "leagueView"+CHR$(0)
		select_filename$ = leaguefile$+CHR$(0)
		retcode = sqlCreateOutFile(select_what$, select_from$, select_filename$)
		IF retcode <> 0 THEN 
			SHELL ("zenity --error --text=" + CHR$(34) + "leagueStats Program failed - sqlCreateOutFile failed for teampitchingView. Program Terminated." + CHR$(34) + " --width=175 --height=100")
			PRINT #flog%, "(" + ProgramName$ + "): sqlCreateOutFile failed for: " + pitchingfile$
			PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing endPROG"
			PRINT #flog%, "(" + ProgramName$ + "): "
			PRINT #flog%, "(" + ProgramName$ + "): *** leagueStats - Terminated Abnormally ***"
			endPROG
		END IF
	END IF


END SUB


SUB DisplayLeagueResults

    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing DisplayLeagueResults"
    PRINT #flog%, "(" + ProgramName$ + "): "

' *** Determine the number of Rows and columns, then resize arrays
    mysqlView$ = "leagueView"
	nbrRows = sqlNumRows(mysqlView$+CHR$(0))
	nbrCols = sqlNumFields(mysqlView$+CHR$(0))
    REDIM Query(nbrCols)
    REDIM Answer(nbrRows + 1, nbrCols)

' *** Read League Stats file into Answer Array, replace "\N" with 0.000
    getLeagueStatsFile
    
' *** Print the box scores from the SQL View File (Zenity or Terminal, Log File)
    IF _FILEEXISTS("leaguestats.sh") THEN KILL "leaguestats.sh"
    f3% = FREEFILE
    cmd = NULL
    OPEN "leaguestats.sh" FOR BINARY AS #f3%
    tmp1$ = "###  ": tmp2$ = "#.###  "
    tmpLine$ = "#!/bin/sh" + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = " " + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = "zenity --list \" + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = "       --title=" + CHR$(34) + "League Standings" + CHR$(34) + " \" + CHR$(10)
    PUT #f3%, , tmpLine$
	tmpLine$ = "       --text="+ CHR$(34) + "Teams Ranked by Win Percentage (WPCT)" + CHR$(34) +  "\" + CHR$(10)
	PUT #f3%, , tmpLine$
    tmpLine$ = "       --width=530 --height=500 \" + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = "       --ok-label=NEXT --extra-button=Report --extra-button=HELP --extra-button=ABOUT --extra-button=QUIT \" + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = " --column=" + CHR$(34) + "TEAM" + CHR$(34) + _ 
               " --column=" + CHR$(34) + "W" + CHR$(34) + " --column=" + CHR$(34) + "L" + CHR$(34) + _
               " --column=" + CHR$(34) + "ERA" + CHR$(34) + " --column=" + CHR$(34) + "BAVG" + CHR$(34) + _
               " --column=" + CHR$(34) + "SLUG" + CHR$(34) + " --column=" + CHR$(34) + "FPCT" + CHR$(34) + _
               " --column=" + CHR$(34) + "WPCT" + CHR$(34) + " \" + CHR$(10)
    PUT #f3%, , tmpLine$
    PRINT #flog%, "(" + ProgramName$ + "): League Standings: "
    PRINT #flog%, "(" + ProgramName$ + "): "
    PRINT #flog%, "(" + ProgramName$ + "): Team              W    L    ERA   BAVG   SLUG   FPCT   WPCT"
    PRINT #flog%, "(" + ProgramName$ + "): ---------------- ---  ---  -----  -----  -----  -----  -----"

    FOR x = 1 TO nbrRows
        teamName = Answer(x, 1)
        tmpLine$ = CHR$(34) + teamName + CHR$(34)
        PRINT #flog%, USING "(" + ProgramName$ + "): \               \"; teamName,
        FOR y = LEAGUE.TEAM+1 TO nbrCols
            nbr = VAL(Answer(x, y))
            tmpLine$ = tmpLine$ + CHR$(9) + Answer(x, y)
            IF y < (LEAGUE.ERA - LEAGUE.BYPASS) THEN
                PRINT #flog%, USING tmp1$; nbr,
            ELSEIF y = (LEAGUE.ERA - LEAGUE.BYPASS) THEN
                PRINT #flog%, USING "##.##  "; nbr,
            ELSE
                PRINT #flog%, USING tmp2$; nbr,
            END IF
        NEXT y
        tmpLine$ = tmpLine$ + " \" + CHR$(10): PRINT #flog%, NULL
        PUT #f3%, , tmpLine$
    NEXT x
        
    CLOSE #f3%
    SHELL ("chmod +x leaguestats.sh")
    cmd = "./leaguestats.sh"
    retcode = pipecom(cmd, stdout, stderr)
    lenstr = LEN(stdout): pstdout = LEFT$(stdout, lenstr - 1) 
    PRINT #flog%, "(" + ProgramName$ + "): "
    PRINT #flog%, "(" + ProgramName$ + "): stdout = "; pstdout
    PRINT #flog%, "(" + ProgramName$ + "): stderr = "; stderr
    PRINT #flog%, "(" + ProgramName$ + "): retcode = "; retcode
    PRINT #flog%, "(" + ProgramName$ + "): " 
    
END SUB


SUB DisplayTeamBattingResults

    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing DisplayTeamBattingResults"
    PRINT #flog%, "(" + ProgramName$ + "): "

' *** Determine the number of Rows and columns, then resize arrays
    mysqlView$ = "teambattingView"
	nbrRows = sqlNumRows(mysqlView$+CHR$(0))
	nbrCols = sqlNumFields(mysqlView$+CHR$(0))
    REDIM Query(nbrCols)
    REDIM Answer(nbrRows + 1, nbrCols)

' *** Read Batting Stats file into Answer Array, replace "\N" with 0.000
    getBattingStatsFile
    
' *** Print the box scores from the SQL View File (Zenity or Terminal, Log File)
    IF _FILEEXISTS("teambattingstats.sh") THEN KILL "teambattingstats.sh"
    f3% = FREEFILE
    cmd = NULL
    OPEN "teambattingstats.sh" FOR BINARY AS #f3%
    tmp1$ = "###  ": tmp2$ = "#.###  "
    tmpLine$ = "#!/bin/sh" + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = " " + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = "zenity --list \" + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = "       --title=" + CHR$(34) + "Team Batting Stats" + CHR$(34) + " \" + CHR$(10)
    PUT #f3%, , tmpLine$
	tmpLine$ = "       --text="+ CHR$(34) + "Teams Ranked by Onbase Plus Slugging (OPS)" + CHR$(34) +  "\" + CHR$(10)
	PUT #f3%, , tmpLine$
    tmpLine$ = "       --width=1250 --height=500 \" + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = "       --ok-label=NEXT --extra-button=Report --extra-button=HELP --extra-button=QUIT \" + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = " --column=" + CHR$(34) + "TEAM" + CHR$(34) + " --column=" + CHR$(34) + "AB" + CHR$(34) + _
               " --column=" + CHR$(34) + "R" + CHR$(34) + " --column=" + CHR$(34) + "H" + CHR$(34) + _
               " --column=" + CHR$(34) + "RBI" + CHR$(34) + " --column=" + CHR$(34) + "2B" + CHR$(34) + _
               " --column=" + CHR$(34) + "3B" + CHR$(34) + " --column=" + CHR$(34) + "HR" + CHR$(34) + _
               " --column=" + CHR$(34) + "BB" + CHR$(34) + " --column=" + CHR$(34) + "K" + CHR$(34) + _
               " --column=" + CHR$(34) + "HBP" + CHR$(34) + " --column=" + CHR$(34) + "SAC" + CHR$(34) + _
               " --column=" + CHR$(34) + "SB" + CHR$(34) + " --column=" + CHR$(34) + "ASB" + CHR$(34) + _
               " --column=" + CHR$(34) + "PO" + CHR$(34) + " --column=" + CHR$(34) + "AST" + CHR$(34) + _
               " --column=" + CHR$(34) + "E" + CHR$(34) + " --column=" + CHR$(34) + "AVG" + CHR$(34) + _
               " --column=" + CHR$(34) + "SLUG" + CHR$(34) + " --column=" + CHR$(34) + "OBP" + CHR$(34) + _
               " --column=" + CHR$(34) + "OPS" + CHR$(34) + " --column=" + CHR$(34) + "FPCT" + CHR$(34) + " \" + CHR$(10)
    PUT #f3%, , tmpLine$
    PRINT #flog%, "(" + ProgramName$ + "): Batting Stats by Team"
    PRINT #flog%, "(" + ProgramName$ + "): "
    PRINT #flog%, "(" + ProgramName$ + "): Team              AB   R    H   RBI   2B   3B   HR   BB   K   HBP  SAC   SB  ASB   PO  AST   E    AVG    SLUG   OBP    OPS    FPCT"
    PRINT #flog%, "(" + ProgramName$ + "): ---------------- ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  -----  -----  -----  -----  -----"

    FOR x = 1 TO nbrRows
        teamName = Answer(x, 1)
        tmpLine$ = CHR$(34) + teamName + CHR$(34)
        PRINT #flog%, USING "(" + ProgramName$ + "): \               \"; teamName,
        FOR y = LHIT.TEAM+1 TO nbrCols
            nbr = VAL(Answer(x, y))
            tmpLine$ = tmpLine$ + CHR$(9) + Answer(x, y)
            IF y < LHIT.AVG THEN
                PRINT #flog%, USING tmp1$; nbr,
            ELSE
                PRINT #flog%, USING tmp2$; nbr,
            END IF
        NEXT y
        tmpLine$ = tmpLine$ + " \" + CHR$(10): PRINT #flog%, NULL
        PUT #f3%, , tmpLine$
    NEXT x
        
    CLOSE #f3%
    SHELL ("chmod +x teambattingstats.sh")
    cmd = "./teambattingstats.sh"
    retcode = pipecom(cmd, stdout, stderr)
    lenstr = LEN(stdout): pstdout = LEFT$(stdout, lenstr - 1) 
    PRINT #flog%, "(" + ProgramName$ + "): "
    PRINT #flog%, "(" + ProgramName$ + "): stdout = "; pstdout
    PRINT #flog%, "(" + ProgramName$ + "): stderr = "; stderr
    PRINT #flog%, "(" + ProgramName$ + "): retcode = "; retcode
    PRINT #flog%, "(" + ProgramName$ + "): "
    
END SUB


SUB DisplayTeamPitchingResults

    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing DisplayTeamPitchingResults"
    PRINT #flog%, "(" + ProgramName$ + "): "

' *** Determine the number of Rows and columns, then resize arrays
    mysqlView$ = "teampitchingView"
	nbrRows = sqlNumRows(mysqlView$+CHR$(0))
	nbrCols = sqlNumFields(mysqlView$+CHR$(0))
    REDIM Query(nbrCols)
    REDIM Answer(nbrRows + 1, nbrCols)

' *** Read Pitching Stats file into Answer Array, replace "\N" with 0.000
    getPitchingStatsFile
    
' *** Print the box scores from the SQL View File (Zenity or Terminal, Log File)
    IF _FILEEXISTS("teampitchingstats.sh") THEN KILL "teampitchingstats.sh"
    f3% = FREEFILE
    cmd = NULL
    OPEN "teampitchingstats.sh" FOR BINARY AS #f3%
    tmp1$ = "###  ": tmp2$ = "##.###  "
    tmpLine$ = "#!/bin/sh" + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = " " + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = "zenity --list \" + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = "       --title=" + CHR$(34) + "Team Pitching Stats" + CHR$(34) + " \" + CHR$(10)
    PUT #f3%, , tmpLine$
	tmpLine$ = "       --text="+ CHR$(34) + "Teams Ranked by Wins, Losses (W, L)" + CHR$(34) +  "\" + CHR$(10)
	PUT #f3%, , tmpLine$
    tmpLine$ = "       --width=1350 --height=500 \" + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = "       --ok-label=BACK --extra-button=Report --extra-button=HELP --extra-button=QUIT \" + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = " --column=" + CHR$(34) + "TEAM" + CHR$(34) + _ 
               " --column=" + CHR$(34) + "W" + CHR$(34) + " --column=" + CHR$(34) + "L" + CHR$(34) + _
               " --column=" + CHR$(34) + "SV" + CHR$(34) + " --column=" + CHR$(34) + "SVO" + CHR$(34) + _
               " --column=" + CHR$(34) + "GP" + CHR$(34) + _
               " --column=" + CHR$(34) + "GC" + CHR$(34) + " --column=" + CHR$(34) + "IP" + CHR$(34) + _
               " --column=" + CHR$(34) + "TBF" + CHR$(34) + " --column=" + CHR$(34) + "H" + CHR$(34) + _
               " --column=" + CHR$(34) + "BB" + CHR$(34) + " --column=" + CHR$(34) + "K" + CHR$(34) + _
               " --column=" + CHR$(34) + "RA" + CHR$(34) + " --column=" + CHR$(34) + "ER" + CHR$(34) + _
               " --column=" + CHR$(34) + "HR" + CHR$(34) + " --column=" + CHR$(34) + "HBP" + CHR$(34) + _
               " --column=" + CHR$(34) + "SF" + CHR$(34) + " --column=" + CHR$(34) + "DRA" + CHR$(34) + _
               " --column=" + CHR$(34) + "ERA" + CHR$(34) + " --column=" + CHR$(34) + "OP-AVG" + CHR$(34) + _
               " --column=" + CHR$(34) + "WHIP" + CHR$(34) + " --column=" + CHR$(34) + "BABIP" + CHR$(34) + _
               " --column=" + CHR$(34) + "FIP" + CHR$(34) + " \" + CHR$(10)
    PUT #f3%, , tmpLine$
    PRINT #flog%, "(" + ProgramName$ + "): Team Pitching Stats"
    PRINT #flog%, "(" + ProgramName$ + "): "
    PRINT #flog%, "(" + ProgramName$ + "): Team              W    L    SV  SVO   GP   GC    IP   TBP   H    BB   K    RA   ER   HR  HBP   SF   DRA    ERA   OP-AVG    WHIP   BABIP   FIP "
    PRINT #flog%, "(" + ProgramName$ + "): ---------------- ---  ---  ---  ---  ---  ---  -----  ---  ---  ---  ---  ---  ---  ---  ---  ---  -----  -----  ------   -----   -----  -----"

' *** Because Zenity interprets the MINUS sign as the start of an option tag,
' *** all numbers must be enclosed in a single quote '' and a space placed
' *** in front of each so negative numbers display properly.
' *** (FIP can be a negative number)
    FOR x = 1 TO nbrRows
        teamName = Answer(x, 1)
        tmpLine$ = CHR$(34) + teamName + CHR$(34)
        PRINT #flog%, USING "(" + ProgramName$ + ") \               \"; teamName,
        FOR y = LPITCH.TEAM+1 TO nbrCols
            nbr = VAL(Answer(x, y))
            IF nbr < 0 THEN nbr = 0.000: (Answer(x, y)) = "0.00"
            tmpLine$ = tmpLine$ + CHR$(9) + (Answer(x, y))
            IF y = LPITCH.IP THEN
                PRINT #flog%, USING "###.#  "; nbr,
            ELSEIF y = LPITCH.DRA OR y = LPITCH.ERA OR y = LPITCH.FIP THEN
                PRINT #flog%, USING "##.##  "; nbr,
            ELSEIF y < LPITCH.DRA THEN
                PRINT #flog%, USING tmp1$; nbr,
            ELSE
                PRINT #flog%, USING tmp2$; nbr,
            END IF
        NEXT y
        tmpLine$ = tmpLine$ + " \" + CHR$(10)
        PUT #f3%, , tmpLine$
        PRINT #flog%, NULL
    NEXT x      
    CLOSE #f3%
    SHELL ("chmod +x teampitchingstats.sh")
    cmd = "./teampitchingstats.sh"
    retcode = pipecom(cmd, stdout, stderr)
    lenstr = LEN(stdout): pstdout = LEFT$(stdout, lenstr - 1) 
    PRINT #flog%, "(" + ProgramName$ + "): "
    PRINT #flog%, "(" + ProgramName$ + "): stdout = "; pstdout
    PRINT #flog%, "(" + ProgramName$ + "): stderr = "; stderr
    PRINT #flog%, "(" + ProgramName$ + "): retcode = "; retcode
    PRINT #flog%, "(" + ProgramName$ + "): "
    
END SUB


SUB getLeagueStatsFile
'-----------------------------------------------------------------------------
' *** Loads and formats the League Stats File created from a SQL View
'
    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing getLeagueStatsFile"
    PRINT #flog%, "(" + ProgramName$ + "): "

    IF NOT _FILEEXISTS(leaguefile$) THEN
		mysqlView$ = "leagueView"
		nbrRows = sqlNumRows(mysqlView$+CHR$(0))
		nbrCols = sqlNumFields(mysqlView$+CHR$(0))	
		retcode = sqlUseResult("SELECT * FROM "+mysqlView$+CHR$(0))
		IF retcode = 0 THEN
			PRINT #flog%, "(" + ProgramName$ + "): Retrieving Rows from SQL: " + mysqlView$
			PRINT #flog%, "(" + ProgramName$ + "): -----------------------------------------------------------------------------------------" 
			PRINT #flog%, "(" + ProgramName$ + "): "
			rows = 1: Delim$ = CHR$(9)
			FOR i = 1 to nbrRows
				qString$ = sqlFetchRow$
				return$ = StrSplit$(qString$, Delim$)
				cols = 0
				FOR ix1 = LPITCH.TEAM TO nbrCols
					IF ix1 <> LEAGUE.IP AND ix1 <> LEAGUE.ER THEN
						cols = cols + 1
						IF Query(ix1) = "\N" THEN Query(ix1) = "0.000"
						Answer(rows, cols) = Query(ix1)
					END IF
				NEXT ix1
				rows = rows + 1
			NEXT i
			nbrCols = LEAGUE.WPCT - LEAGUE.BYPASS		
		ELSE
			SHELL ("zenity --error --text=" + CHR$(34) + "leagueStats Program failed - sqlUseRsult failed for getLeagueStatsFile. Program Terminated." + CHR$(34) + " --width=175 --height=100")
			PRINT #flog%, "(" + ProgramName$ + "): sqlUseResult failed for: " + mysqlView$
			PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing endPROG"
			PRINT #flog%, "(" + ProgramName$ + "): "
			PRINT #flog%, "(" + ProgramName$ + "): *** leagueStats - Terminated Abnormally ***"
			endPROG
		END IF
		retcode = sqlFreeFetchRow
		EXIT SUB
    END IF
   
	PRINT #flog%, "(" + ProgramName$ + "): Retrieving Rows from SQL OUTFILE: " + leaguefile$
	PRINT #flog%, "(" + ProgramName$ + "): -----------------------------------------------------------------------------------------" 
	PRINT #flog%, "(" + ProgramName$ + "): "
	rows = 1: Delim$ = CHR$(9)
	touts = 3 * innings
    f2% = FREEFILE
	OPEN leaguefile$ FOR INPUT AS #f2%
	DO UNTIL EOF(f2%)
		LINE INPUT #f2%, qString$
		return$ = StrSplit$(qString$, Delim$)
		cols = 0
		FOR ix1 = LEAGUE.TEAM TO nbrCols
			IF ix1 <> LEAGUE.IP AND ix1 <> LEAGUE.ER THEN
				cols = cols + 1
				IF Query(ix1) = "\N" THEN Query(ix1) = "0.000"
				Answer(rows, cols) = Query(ix1)
			END IF
		NEXT ix1
		rows = rows + 1
	LOOP
	nbrCols = LEAGUE.WPCT - LEAGUE.BYPASS
	CLOSE #f2%
 
END SUB


SUB getBattingStatsFile
'-----------------------------------------------------------------------------
' *** Loads and formats the Team Batting File created from a SQL View
'
    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing getBattingStatsFile"
    PRINT #flog%, "(" + ProgramName$ + "): "

    IF NOT _FILEEXISTS(battingfile$) THEN
		mysqlView$ = "teambattingView"
		retcode = sqlUseResult("SELECT * FROM "+mysqlView$+CHR$(0))
		IF retcode = 0 THEN
			PRINT #flog%, "(" + ProgramName$ + "): Retrieving Rows from SQL: " + mysqlView$
			PRINT #flog%, "(" + ProgramName$ + "): -----------------------------------------------------------------------------------------" 
			PRINT #flog%, "(" + ProgramName$ + "): "
			rows = 1: Delim$ = CHR$(9)
			FOR i = 1 to nbrRows
				qString$ = sqlFetchRow$
				return$ = StrSplit$(qString$, Delim$)
				FOR cols = LHIT.TEAM TO nbrCols
					IF Query(cols) = "\N" THEN Query(cols) = "0.000"
					Answer(rows, cols) = Query(cols)
				NEXT cols
				rows = rows + 1
			NEXT i		
		ELSE
			SHELL ("zenity --error --text=" + CHR$(34) + "leagueStats Program failed - sqlUseRsult failed for getBattingStatsFile. Program Terminated." + CHR$(34) + " --width=175 --height=100")
			PRINT #flog%, "(" + ProgramName$ + "): sqlUseResult failed for: " + mysqlView$
			PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing endPROG"
			PRINT #flog%, "(" + ProgramName$ + "): "
			PRINT #flog%, "(" + ProgramName$ + "): *** leagueStats - Terminated Abnormally ***"
			endPROG
		END IF
		retcode = sqlFreeFetchRow
		EXIT SUB
    END IF
    
	PRINT #flog%, "(" + ProgramName$ + "): Retrieving Rows from SQL OUTFILE: " + battingfile$
	PRINT #flog%, "(" + ProgramName$ + "): -----------------------------------------------------------------------------------------" 
	PRINT #flog%, "(" + ProgramName$ + "): "
	rows = 1: Delim$ = CHR$(9)
	f2% = FREEFILE
	OPEN battingfile$ FOR INPUT AS #f2%
	DO UNTIL EOF(f2%)
		LINE INPUT #f2%, qString$
		return$ = StrSplit$(qString$, Delim$)
		FOR cols = 1 TO nbrCols
			IF Query(cols) = "\N" THEN Query(cols) = "0.000"
			Answer(rows, cols) = Query(cols)
		NEXT cols
		rows = rows + 1
	LOOP
	CLOSE #f2%
	    
END SUB


SUB getPitchingStatsFile
'-----------------------------------------------------------------------------
' *** Loads and formats the Team pitching File created from a SQL View
'
    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing getPitchingStatsFile"
    PRINT #flog%, "(" + ProgramName$ + "): "

    IF NOT _FILEEXISTS(pitchingfile$) THEN
		retcode = sqlUseResult("SELECT * FROM "+mysqlView$+CHR$(0))
		IF retcode = 0 THEN
			PRINT #flog%, "(" + ProgramName$ + "): Retrieving Rows from SQL: " + mysqlView$
			PRINT #flog%, "(" + ProgramName$ + "): -----------------------------------------------------------------------------------------" 
			PRINT #flog%, "(" + ProgramName$ + "): "
			Delim$ = CHR$(9)
			FOR rows = 1 to nbrRows
				qString$ = sqlFetchRow$
				return$ = StrSplit$(qString$, Delim$)
				FOR cols = LPITCH.TEAM TO nbrCols
					IF Query(cols) = "\N" THEN
						IF (cols = LPITCH.ERA OR cols = LPITCH.DRA) THEN Query(cols) = "0.00" ELSE Query(cols) = "0.000"
					END IF
					IF cols = LPITCH.IP THEN
						outs = VAL(Query(cols))
						adjip = adjustIP (outs)
						Query(LPITCH.IP) = strFormat$(STR$(adjip), "#,###.#")
						Answer(rows, cols) = Query(LPITCH.IP)
					ELSE
						Answer(rows, cols) = Query(cols)
					END IF
				NEXT cols
			NEXT rows		
		ELSE
			SHELL ("zenity --error --text=" + CHR$(34) + "leagueStats Program failed - sqlUseRsult failed for getPitchingStatsFile. Program Terminated." + CHR$(34) + " --width=175 --height=100")
			PRINT #flog%, "(" + ProgramName$ + "): sqlUseResult failed for: " + mysqlView$
			PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing endPROG"
			PRINT #flog%, "(" + ProgramName$ + "): "
			PRINT #flog%, "(" + ProgramName$ + "): *** leagueStats - Terminated Abnormally ***"
			endPROG
		END IF
		retcode = sqlFreeFetchRow
		EXIT SUB
    END IF

	PRINT #flog%, "(" + ProgramName$ + "): Retrieving Rows from SQL OUTFILE: " + pitchingfile$
	PRINT #flog%, "(" + ProgramName$ + "): -----------------------------------------------------------------------------------------" 
	PRINT #flog%, "(" + ProgramName$ + "): "
    rows = 1: Delim$ = CHR$(9): outs = 0
    f2% = FREEFILE
    OPEN pitchingfile$ FOR INPUT AS #f2%
    DO UNTIL EOF(f2%)
        LINE INPUT #f2%, qString$
        return$ = StrSplit$(qString$, Delim$)
        FOR cols = LPITCH.TEAM TO nbrCols
            IF Query(cols) = "\N" THEN
                IF (cols = LPITCH.DRA OR cols = LPITCH.ERA) THEN Query(cols) = "0.00" ELSE Query(cols) = "0.000"
			END IF
			IF cols = LPITCH.IP THEN
				outs = VAL(Query(cols))
				adjip = adjustIP (outs)
				Query(LPITCH.IP) = strFormat$(STR$(adjip), "#,###.#")
				Answer(rows, cols) = Query(LPITCH.IP)
            ELSE
                Answer(rows, cols) = Query(cols)
            END IF
        NEXT cols
		rows = rows + 1
    LOOP
    CLOSE #f2%
    
END SUB


SUB PrintLeagueStats
'-----------------------------------------------------------------------------
' *** Produce the League Stats report
'

    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing PrintLeagueStats"
    PRINT #flog%, "(" + ProgramName$ + "): "

' *** Determine the number of Rows and columns, then resize arrays
    mysqlView$ = "leagueView"
	nbrRows = sqlNumRows(mysqlView$+CHR$(0))
	nbrCols = sqlNumFields(mysqlView$+CHR$(0))
    REDIM Query(nbrCols)
    REDIM Answer(nbrRows + 1, nbrCols)

' *** Read Batting Stats file into Answer Array, replace "\N" with 0.000
    getLeagueStatsFile

' *** Create the report file and send it to the printer,
' *** otherwise, clear the terminal/console and display the report.
    tmp1$ = "###  ": tmp2$ = "#.###  "
    IF PrintReport THEN
        ReportFile$ = "leaguestats.prn"
        IF _FILEEXISTS(ReportFile$) THEN KILL ReportFile$
        f4% = FREEFILE
        cmd = NULL
        OPEN ReportFile$ FOR OUTPUT AS #f4%
        PRINT #f4%, NULL: PRINT #f4%, NULL
        PRINT #f4%, "League Standings: "
        PRINT #f4%, NULL
        PRINT #f4%, "Team              W    L    ERA   BAVG   SLUG   FPCT   WPCT"
        PRINT #f4%, "---------------- ---  ---  -----  -----  -----  -----  -----"
        FOR x = 1 TO nbrRows
            teamName = Answer(x, 1)
            PRINT #f4%, USING "\               \"; teamName,
            FOR y = LEAGUE.TEAM+1 TO nbrCols
                nbr = VAL(Answer(x, y))
                IF y < (LEAGUE.ERA - LEAGUE.BYPASS) THEN
                    PRINT #f4%, USING tmp1$; nbr,
                ELSEIF y = (LEAGUE.ERA - LEAGUE.BYPASS) THEN
					PRINT #f4%, USING "##.##  "; nbr,
				ELSE
					PRINT #f4%, USING tmp2$; nbr,
                END IF
            NEXT y
            PRINT #f4%, NULL
        NEXT x
        CLOSE #f4%
        cmd = "enscript -B " + ReportFile$
        SHELL (cmd)
        EXIT SUB
    END IF
    
	SCREEN _NEWIMAGE(600, 600, 32) 
	f& = _LOADFONT(fontfile$, 17, style$)
	_FONT f& 
	CLS , BGColor
	COLOR FGColor, BGColor
	_TITLE "League Standings"
	_SCREENSHOW
	PRINT: PRINT "  League Standings"
	PRINT: PRINT
	PRINT "  Team              W    L    ERA   BAVG   SLUG   FPCT   WPCT"
	PRINT "  ---------------- ---  ---  -----  -----  -----  -----  -----"
	FOR x = 1 TO nbrRows
		cols = 0
		teamName = Answer(x, 1)
		PRINT USING "  \               \"; teamName,
		FOR y = LEAGUE.TEAM+1 TO nbrCols
			nbr = VAL(Answer(x, y))
            IF y < (LEAGUE.ERA - LEAGUE.BYPASS) THEN
				PRINT USING tmp1$; nbr,
			ELSEIF y = (LEAGUE.ERA - LEAGUE.BYPASS) THEN
				PRINT USING "##.##  "; nbr,
			ELSE
				PRINT USING tmp2$; nbr,
			END IF
		NEXT y
		PRINT NULL
	NEXT x
	FOR x = 1 to (26 - nbrRows): PRINT: NEXT x
	PRINT "  Press any key to continue ..."
	SLEEP
	CLS , BGColor
	_SCREENHIDE

END SUB


SUB PrintTeamBattingStats
'-----------------------------------------------------------------------------
' *** Produce the Team Batting Stats report
'

    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing PrintTeamBattingStats"
    PRINT #flog%, "(" + ProgramName$ + "): "

' *** Determine the number of Rows and columns, then resize arrays
    mysqlView$ = "teambattingView"
	nbrRows = sqlNumRows(mysqlView$+CHR$(0))
	nbrCols = sqlNumFields(mysqlView$+CHR$(0))
    REDIM Query(nbrCols)
    REDIM Answer(nbrRows + 1, nbrCols)

' *** Read Batting Stats file into Answer Array, replace "\N" with 0.000
    getBattingStatsFile
    
' *** Create the report file and send it to the printer,
' *** otherwise, clear the terminal/console and display the report.
    tmp1$ = "###  ": tmp2$ = "#.###  "
    IF PrintReport THEN
        ReportFile$ = "teambattingstats.prn"
        IF _FILEEXISTS(ReportFile$) THEN KILL ReportFile$
        f4% = FREEFILE
        cmd = NULL
        OPEN ReportFile$ FOR OUTPUT AS #f4%
        PRINT #f4%, "Batting Stats by Team"
        PRINT #f4%, NULL
        PRINT #f4%, "Team              AB   R    H   RBI   2B   3B   HR   BB   K   HBP  SAC   SB  ASB   PO  AST   E    AVG    SLUG   OBP    OPS    FPCT"
        PRINT #f4%, "---------------- ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  -----  -----  -----  -----  -----"
        FOR x = 1 TO nbrRows
            teamName = Answer(x, 1)
            PRINT #f4%, USING "\               \"; teamName,
            FOR y = LHIT.TEAM+1 TO nbrCols
                nbr = VAL(Answer(x, y))
                IF y < LHIT.AVG THEN
                    PRINT #f4%, USING tmp1$; nbr,
                ELSE
                    PRINT #f4%, USING tmp2$; nbr,
                END IF
            NEXT y
            PRINT #f4%, NULL
        NEXT x
        CLOSE #f4%
        cmd = "enscript -B -r -fCourier8 " + ReportFile$
        SHELL (cmd)
		EXIT SUB
    END IF

	SCREEN _NEWIMAGE(1250, 600, 32) 
	f& = _LOADFONT(fontfile$, 17, style$)
	_FONT f& 
	CLS , BGColor
	COLOR FGColor, BGColor
	_TITLE "League Standings - Batting/Fielding Statistics by Team"
	_SCREENSHOW
	PRINT: PRINT "  Batting/Fielding Stats by Team"
	PRINT: PRINT
	PRINT "  Team              AB   R    H   RBI   2B   3B   HR   BB   K   HBP  SAC   SB  ASB   PO  AST   E    AVG    SLUG   OBP    OPS    FPCT"
	PRINT "  ---------------- ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  -----  -----  -----  -----  -----"
	FOR x = 1 TO nbrRows
		teamName = Answer(x, 1)
		PRINT USING "  \               \"; teamName,
		FOR y = LHIT.TEAM+1 TO nbrCols
			nbr = VAL(Answer(x, y))
			IF y < LHIT.AVG THEN
				PRINT USING tmp1$; nbr,
			ELSE
				PRINT USING tmp2$; nbr,
			END IF
		NEXT y
		PRINT NULL
	NEXT x
	FOR x = 1 to (26 - nbrRows): PRINT: NEXT x
	PRINT "  Press any key to continue ..."
	SLEEP
	CLS , BGColor
	_SCREENHIDE

END SUB


SUB PrintTeamPitchingStats
'-----------------------------------------------------------------------------
' *** Produce the Team Pitching Stats report
'

    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing PrintTeamPitchingStats"
    PRINT #flog%, "(" + ProgramName$ + "): "

' *** Determine the number of Rows and columns, then resize arrays
    mysqlView$ = "teampitchingView"
	nbrRows = sqlNumRows(mysqlView$+CHR$(0))
	nbrCols = sqlNumFields(mysqlView$+CHR$(0))
	PRINT "nbrRows = "; nbrRows
	PRINT "nbrCols = "; nbrCols
    REDIM Query(nbrCols)
    REDIM Answer(nbrRows + 1, nbrCols)

' *** Read Pitching Stats file into Answer Array, replace "\N" with 0.000
    getPitchingStatsFile
    
' *** Create the report file and send it to the printer,
' *** otherwise, clear the terminal/console and display the report.
    tmp1$ = "###  ": tmp2$ = " #.###  "
    IF PrintReport THEN
        ReportFile$ = "teampitchingstats.prn"
        IF _FILEEXISTS(ReportFile$) THEN KILL ReportFile$
        f4% = FREEFILE
        cmd = NULL
        OPEN ReportFile$ FOR OUTPUT AS #f4%
        PRINT #f4%, "Pitching Stats by Team "
        PRINT #f4%, NULL
		PRINT #f4%, "Team              W    L    SV  SVO   GP   GC    IP   TBP   H    BB   K    RA   ER   HR  HBP   SF   DRA    ERA   OP-AVG    WHIP   BABIP   FIP "
		PRINT #f4%, "---------------- ---  ---  ---  ---  ---  ---  -----  ---  ---  ---  ---  ---  ---  ---  ---  ---  -----  -----  ------   -----   -----  -----"
        FOR x = 1 TO nbrRows
            teamName = Answer(x, 1)
            PRINT #f4%, USING "\               \"; teamName,
            FOR y = LPITCH.TEAM+1 TO nbrCols
                nbr = VAL(Answer(x, y))
                IF nbr < 0 THEN nbr = 0.000: (Answer(x, y)) = "0.00"
                IF y = LPITCH.IP THEN
                    PRINT #f4%, USING "###.#  "; nbr,
                ELSEIF y = LPITCH.DRA OR y = LPITCH.ERA OR y = LPITCH.FIP THEN
                    PRINT #f4%, USING "##.##  "; nbr,
                ELSEIF y < LPITCH.ERA THEN
                    PRINT #f4%, USING tmp1$; nbr,
                ELSE
                    PRINT #f4%, USING tmp2$; nbr,
                END IF
            NEXT y
            PRINT #f4%, NULL
        NEXT x
        CLOSE #f4%
        cmd = "enscript -B -r -fCourier8 " + ReportFile$
        SHELL (cmd)
        EXIT SUB
    END IF
    
	SCREEN _NEWIMAGE(1375, 600, 32) 
	f& = _LOADFONT(fontfile$, 17, style$)
	_FONT f& 
	CLS , BGColor
	COLOR FGColor, BGColor
	_TITLE "League Standings - Pitching Statistics by Team"
	_SCREENSHOW
	PRINT: PRINT "  Pitching Stats by Team "
	PRINT: PRINT
	PRINT "  Team              W    L    SV  SVO   GP   GC    IP   TBP   H    BB   K    RA   ER   HR  HBP   SF   DRA    ERA   OP-AVG    WHIP   BABIP   FIP "
	PRINT "  ---------------- ---  ---  ---  ---  ---  ---  -----  ---  ---  ---  ---  ---  ---  ---  ---  ---  -----  -----  ------   -----   -----  -----"
	FOR x = 1 TO nbrRows
		teamName = Answer(x, 1)
		PRINT USING "  \               \"; teamName,
		FOR y = LPITCH.TEAM+1 TO nbrCols
			nbr = VAL(Answer(x, y))
			IF nbr < 0 THEN nbr = 0.000: (Answer(x, y)) = "0.00"
			IF y = LPITCH.IP THEN
				PRINT USING "###.#  "; nbr,
			ELSEIF y = LPITCH.DRA OR y = LPITCH.ERA OR y = LPITCH.FIP THEN
				PRINT USING "##.##  "; nbr,
			ELSEIF y < LPITCH.DRA THEN
				PRINT USING tmp1$; nbr,
			ELSE
				PRINT USING tmp2$; nbr,
			END IF
		NEXT y
		PRINT NULL
	NEXT x
	FOR x = 1 to (26 - nbrRows): PRINT: NEXT x
	PRINT "  Press any key to continue ..."
	SLEEP
	CLS , BGColor
	_SCREENHIDE

END SUB


FUNCTION adjustIP (outs)
'-----------------------------------------------------------------------------
' *** Correct the display of IP 
'

    DIM AS INTEGER whole, fraction
    whole = floor(outs / 3)
    fraction = INT(((outs / 3) - whole) * 10 + .5)
    IF fraction >= 3 THEN part = fraction / 3
    adjip = whole + (part * .1)
    adjustIP = adjip 
    
END FUNCTION


'-----------------------------------------------------------------------
' INCLUDES: ------------------------------------------------------------
'
'$INCLUDE: 'include/endPROG.inc'
'$INCLUDE: 'include/baseballAboutDisplay.inc'
'$INCLUDE: 'include/baseballDisplayHelpMenu.inc'
'$INCLUDE: 'include/baseballConfig.inc'
'$INCLUDE: 'include/stringFunctions.inc'
'$INCLUDE: 'include/baseballFunctions.inc'
'$INCLUDE: 'include/pipecom.inc'

