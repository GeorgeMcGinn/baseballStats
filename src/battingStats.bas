REM $TITLE: battingStats.bas Version 1.0.0  08/09/2021 - Last Update: 06/01/2022
_TITLE "Batting/Fielding Statistics Version 1.0.0  08/09/2021 - Last Update: 06/01/2022"
' battingStats.bas    Version 1.0.0  08/09/2021
'-------------------------------------------------------------------------------------
'       PROGRAM: battingStats.bas
'        AUTHOR: George McGinn
'                <gbytes58@gmail.com>
'
'  DATE WRITTEN: 08/09/2021
'       VERSION: 1.0.0
'       PROJECT: Baseball/Softball Statistics Recordkkeeping System
'
'   DESCRIPTION: Process the batting statistics and reporting of the
'                Baseball/Softball Statistics System.
'
' Written by George McGinn
' Copyright (C)2021/2022 by George McGinn - All Rights Reserved.
' Version 1.0 - Created 08/09/2021, Finalized on 06/01/2022
'
'
' CHANGE LOG
'-------------------------------------------------------------------------------------
' 08/09/2021 v1.0.0 GJM - New Program.
' 09/18/2021 v0.11 	GJM - Modified this code to run on Linux only, and to insure that
'                   	  required software is installed. Also moved some code into SUBs
'                         and FUNCTIONS, centralizing common routines.
' 09/20/2021 v0.12  GJM - Added code to accept & process ARGS passed to program. Also 
'                         modified the program to run in stand-a-lone mode if no ARGS
'                         were passed to it. 
' 09/21/2021 v0.13  GJM - Updated the Form and source to accept gameID and gamesPlayed,
'                         and create INCLUDE files for shared DIM & SUB/FUNCTIONS.
' 09/27/2021 v0.14  GJM - Updated the button labels and added a file clean-up in the
'                         endPROG label and an error handling routine for system errors.
' 09/29/2021 v0.15  GJM - Added the token <SQLDB> logic and changed the PRINT/DISPLAY 
'                         Stats routines to a more improved version (as was coded in 
'                         leagueStats).    
' 09/30/2021 v0.16  GJM - Updated pipecom based on a change by Zach.
' 10/01/2021 v0.17  GJM - Added config file processing and passing ARG values
'                         to this module when called from baseballStats.
' 10/02/2021 v0.18  GJM - Added config file value for mysqlTable$ and updates to process
'                         changes to the config file.
' 10/05/2021 v0.19  GJM - Added HELP menu and ProgramName$ that is determined in initialization.
' 10/06/2021 v0.20  GJM - Updated program to new directory structure & file names
' 10/13/2021 v0.21  GJM - Added the HELP system and fixed a logic flow error where the
'                         incorrect screens were being displayed when [CANCEL] was pressed.
' 10/14/2021 v0.22  GJM - For some reason the Report code was missing. Added it back in.
' 11/19/2021 v0.23  GJM - Cosmetic changes made to display GUI's.
' 11/21/2021 v0.24  GJM - Add the output mySQL directory to the config.ini file
'                         and standardized the size of the HELP screen
' 12/07/2021 v0.25  GJM - Updated CC licensing
' 12/10/2021 v0.26  GJM - Created a screen display when enscript isn't installed (This
'                         is required if application is started from an ICON or directly
'                         from Files or a File Manager).
' 12/14/2021 v0.27  GJM - Modified the text displayed in the display and update screens
'                         so that the intent is clearer. Added the ABOUT button 
'                         (As this module can run stand-a-lone). Fixed logic for 
'                         stand-a-lone execution.
' 04/22/2022 v0.28  GJM - Added direct connect/access to mySQL/mariaDB from a Client
'                         Connector I wrote in C. This will replace pipecom for all
'                         SQL calls, and allow direct access to SQL tables/views.
' 06/01/2022 v0.29  GJM - Fixed bugs in the use of mysqlClient.h and changes to QB64
'                         source to finialize using the mySQL/mariaDB Client Connector.
'                         Also cleaned up code, like nested IF statements. Program is
'                         ready for Release 1.0.
'-------------------------------------------------------------------------------------
'  Copyright (C)2021/2022 by George McGinn.  All Rights Reserved.
'
' battingStats by George McGinn is licensed under a Creative Commons
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
''$CONSOLE:OFF
SCREEN _NEWIMAGE(1300, 600, 32)
$SCREENHIDE
OPTION BASE 1

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
' *** Process args passed to program (if found):
' *** Split out Value Pairs - qString and pass to StrSplit$ (Delimiter = <:>)
'
'$INCLUDE: 'include/baseballProcessArgs.inc'

'----------------------------------------------------
' *** Do systems checks
'
retcode = SystemsCheck
IF retcode = FALSE THEN endPROG


QB64Main:
'-------------------------------------------------------------------------------------
' *** MAIN Logic
'
'	PrintReport = FALSE     ' *** Set to FALSE for testing (display output)
	setLeague = FALSE
	sqlActive = FALSE

mysqlConnection:

' *** Initialize SQL variables for this program execution
	mysqlTable$ = mysql_battingTable$
	nbrRows = 0: nbrCols = 0

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
		retcode = sqlDisonnect
		endPROG
	END IF
	PRINT #flog%, "(" + ProgramName$ + "): Connection to mySQL Server established as [localhost], " + "[" + mysql_userid$ + "], [" + mysqlDB$ + "] " 
	PRINT #flog%, "(" + ProgramName$ + "): "
	sqlActive = TRUE


DisplayMainForm:
' *** Initialize SQL variables and do a SELECT to determine number of columns and
' *** rows for sizing Query array
'
	PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing DisplayMainForm"
	PRINT #flog%, "(" + ProgramName$ + "): "
	'$INCLUDE: 'include/baseballMainForm.inc'
	IF stdbutton = "QUIT" THEN endPROG


ProcessSQLFile:
''	mysqlView$ = NULL
	PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing ProcessSQLFile"
	PRINT #flog%, "(" + ProgramName$ + "): "
	mysqlView$ = teamName + mysqlTable$ + "StatsView"
	PRINT #flog%, "(" + ProgramName$ + "): mysqlView to process: " + mysqlView$
	PRINT #flog%, "(" + ProgramName$ + "): "
	retcode = sqlDropView( mysqlView$+CHR$(0))
	IF retcode <> 0 THEN 
		PRINT #flog%, "(" + ProgramName$ + "): >>>>> DROP of SQL View (" + mysqlView$ + ") Failed."
		endPROG
	END IF
	PRINT #flog%, "(" + ProgramName$ + "): >>>>> DROP of SQL View (" + mysqlView$ + ") Succeeded."


DisplayForm:
' *** Show Box Scores 
	DisplayBoxScores
	lenstr = LEN(stdout)
	stdbutton = LEFT$(stdout, lenstr - 1)
	IF stdbutton = "Report" THEN 
		PrintStats
		GOTO DisplayForm
	END IF
	IF stdbutton = "QUIT" THEN endPROG
	IF retcode =  1 AND stdbutton = NULL THEN GOTO DisplayForm


CheckProcessUpdates:
    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing CheckProcessUpdates"
    PRINT #flog%, "(" + ProgramName$ + "): "
    PRINT #flog%, "(" + ProgramName$ + "): List of Players to Update"

' *** Split out names of selected records into the Query array
	REDIM Query(nbrCols)
	Delim$ = "|"
	qString$ = stdout
	return$ = StrSplit$(qString$, Delim$)
	ix1 = 1
	DO
		PRINT #flog%, "(" + ProgramName$ + "): Query("; ix1; ") = "; Query(ix1)
		ix1 = ix1 + 1
	LOOP UNTIL Query(ix1) = NULL
	PRINT #flog%, "(" + ProgramName$ + "): "
	nbrUpdates = ix1 - 1
    
' *** Process the SQL Updates from Input Form
    retcode = sql_update(nbrUpdates)

	lenstr = LEN(stdout)
	stdbutton = LEFT$(stdout, lenstr - 1)
	IF stdbutton = "Report" THEN 
		PrintStats
		GOTO DisplayForm
	END IF
	IF stdbutton = "QUIT" THEN endPROG
	IF retcode =  1 AND stdbutton = NULL THEN GOTO DisplayForm
	GOTO DisplayForm


ehandler:
'$INCLUDE: 'include/baseballErrhandler.inc'


'--------------------------------------------------------------------------------------
' *** SQL Functions
'


FUNCTION sql_update (nbrUpdates)
'--------------------------------------------------------------
' *** Get the number of total rows based on SELECT COUNT(*) ***
'--------------------------------------------------------------
'
    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing FUNCTION sql_update()"
    PRINT #flog%, "(" + ProgramName$ + "): "


SubmitMenu:

    IF _FILEEXISTS("updatebattingstats.sh") THEN KILL "updatebattingstats.sh"
	f3% = FREEFILE
	cmd = NULL

	OPEN "updatebattingstats.sh" FOR BINARY AS #f3%
	tmp1$ = "###  ": tmp2$ = "#.###  ": idx = 6
	tmpLine$ = "#!/bin/sh" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = " " + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "zenity --list \" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "       --title=" + CHR$(34) + teamName + " Batting Stats Update" + CHR$(34) + " \" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "       --text="+ CHR$(34) + "Update all fields needed, then select all records to update:" + CHR$(34) +  "\" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "       --editable --multiple --print-column=ALL \" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "       --width=1350 --height=700 \" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = 	"      --ok-label=Commit --extra-button=HELP --extra-button=QUIT \" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "       --column=" + CHR$(34) + "S" + CHR$(34) + " --column=" + CHR$(34) + "PLAYER" + CHR$(34) + _
			   " --column=" + CHR$(34) + "GAMEID" + CHR$(34) + " --column=" + CHR$(34) + "GP" + CHR$(34) + " --column=" + CHR$(34) + "AB" + CHR$(34) + _
	           " --column=" + CHR$(34) + "R" + CHR$(34) + " --column=" + CHR$(34) + "H" + CHR$(34) + " --column=" + CHR$(34) + "RBI" + CHR$(34) + _
	           " --column=" + CHR$(34) + "2B" + CHR$(34) + " --column=" + CHR$(34) + "3B" + CHR$(34) + " --column=" + CHR$(34) + "HR" + CHR$(34) + _
	           " --column=" + CHR$(34) + "BB" + CHR$(34) + " --column=" + CHR$(34) + "K" + CHR$(34) + " --column=" + CHR$(34) + "HBP" + CHR$(34) + _
	           " --column=" + CHR$(34) + "SAC" + CHR$(34) + " --column=" + CHR$(34) + "SB" + CHR$(34) + " --column=" + CHR$(34) + "ASB" + CHR$(34) + _
	           " --column=" + CHR$(34) + "PO" + CHR$(34) + " --column=" + CHR$(34) + "AST" + CHR$(34) + " --column=" + CHR$(34) + "E" + CHR$(34) + _
	           " \" + CHR$(10)
	PUT #f3%, , tmpLine$

	FOR x = 1 TO nbrUpdates
		IF Query(x) <> NULL THEN
			playerName = Query(x)
			IF gameID <> NULL THEN
				tmpLine$ = CHR$(34) + "u" + CHR$(34) + CHR$(9) + CHR$(34) + playerName + CHR$(34) + CHR$(9) + CHR$(34) + gameID + CHR$(34) + CHR$(9) + gamesPlayed + "  0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0 \" + CHR$(10)
			ELSE
				tmpLine$ = CHR$(34) + "u" + CHR$(34) + CHR$(9) + CHR$(34) + playerName + CHR$(34) + CHR$(9) + CHR$(34) + "" + CHR$(34)  + CHR$(9) + gamesPlayed + "  0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0 \" + CHR$(10)
			END IF
			PUT #f3%, , tmpLine$
		END IF
	NEXT x
	
	FOR x = 1 TO 25 - nbrUpdates
		tmpLine$ = CHR$(34) + "" + CHR$(34) + CHR$(9) + CHR$(34) + "" + CHR$(34) + CHR$(9) + CHR$(34) + "" + CHR$(34) + "  0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0 \" + CHR$(10)
		PUT #f3%, , tmpLine$
	NEXT x
	
	CLOSE #f3%
	SHELL ("chmod +x updatebattingstats.sh")
	cmd = "./updatebattingstats.sh"
	retcode = pipecom(cmd, stdout, stderr)
	
' *** Save menu selection and/or button pressed   
    lenstr = LEN(stdout): stdout = LEFT$(stdout, lenstr - 1) 
	stdmenu = LTRIM$(stdout)
	stdbutton = stdout
	PRINT #flog%, "(" + ProgramName$ + "): "
	PRINT #flog%, "(" + ProgramName$ + "): stdout = "; stdout
	PRINT #flog%, "(" + ProgramName$ + "): stderr = "; stderr
	PRINT #flog%, "(" + ProgramName$ + "): retcode = "; retcode
	PRINT #flog%, "(" + ProgramName$ + "): "

' *** If X, Cancel or QUIT buttons are pressed, end program
	IF retcode = 1 AND stdbutton = NULL THEN EXIT FUNCTION
	IF retcode = 1 AND stdbutton = "QUIT" THEN EXIT FUNCTION

' *** If HELP button pressed, display the HELP Screen	
    IF retcode = 1 AND stdbutton = "HELP" THEN
        cmd = "zenity --text-info " + _
              " --title=" + CHR$(34) + "HELP: Baseball/Softball Statistics System - v1.0.0" + CHR$(34) + _
              " --width=1000 --height=850 --html --ok-label=" + CHR$(34) + "Return to Menu" + CHR$(34) +  _
              " --filename=" + "help/battingUpdateStats.html" + " 2> /dev/null"
        SHELL (cmd)
        GOTO SubmitMenu
    END IF
        
' *** Loop through stdout, create SQL insert and execute them.
' *** Most teams have 25 or less players. REDIM set for 20 records for each
' *** of the 25 players (20*25) or 500 max array size. (The total number
' *** of updates allowed is set to 25 records)
	REDIM Query(500)
	Delim$ = "|"
	lenstr = LEN(stdout)
	qString$ = LEFT$(stdout, lenstr)
	return$ = StrSplit$(qString$, Delim$)
	nbrUpdates = 1

	IF qString$ = "QUIT" THEN EXIT FUNCTION

	FOR ix1 = 1 TO 500
		IF Query(ix1) = "u" THEN nbrUpdates = nbrUpdates + 1
	NEXT ix1
	PRINT #flog%, "(" + ProgramName$ + "): "
	nbrUpdates = nbrUpdates - 1

' *** Create SQL INSERT Statements and execute each update to table
	factor = 0
	FOR idx = 1 TO nbrUpdates
		IF Query(1 + factor) = "u" THEN
			cmd = (mysqlCMD$ + "INSERT INTO " + mysqlTable$ + " VALUES ('" + teamName + "', ")
            playerName = Query(2 + factor): gameID$ = Query(3 + factor): nbr = VAL(Query(4 + factor))
            tmpLine2$ = "'" + gameID$ + "'": tmpLine3$ = STR$(nbr): tmpLine4$ = "'" + playerName + "'"
            cmd = cmd + tmpLine2$ + ", " + tmpLine3$ + ", " + tmpLine4$ + ", "
            FOR x = (5 + factor) TO (20 + factor)
                nbr = VAL(Query(x))
                IF x = (20 + factor) THEN tmpLine$ = STR$(nbr) ELSE tmpLine$ = STR$(nbr) + ", "
                cmd = cmd + tmpLine$
            NEXT x
            cmd = cmd + ");" 
            factor = factor + 20
			retcode = sqlCMD(cmd + CHR$(0))
            PRINT #flog%, "(" + ProgramName$ + "): "; cmd
            PRINT #flog%, "(" + ProgramName$ + "): retcode = "; retcode
            PRINT #flog%, "(" + ProgramName$ + "): "
			IF retcode <> 0 THEN 
				PRINT #flog%, "(" + ProgramName$ + "): SQL INSERT command failed. Please check output and run again. Return Code ="; retcode
				PRINT #flog%, "(" + ProgramName$ + "): SQL INSERT that failed: "; cmd
				PRINT #flog%, "(" + ProgramName$ + "): "
				endPROG
			END IF
        ELSE
            PRINT #flog%, "(" + ProgramName$ + "): WARNING: Record missing the UPDATE (u) Flag - Record for "; Query(idx + factor); " Ignored."
            factor = factor + 20
        END IF
    NEXT idx
    PRINT #flog%, "(" + ProgramName$ + "): "
    
    sql_update = 0


END FUNCTION

'
' *** End SQL Functions
'-----------------------------------------------------------------------------


SUB CreateSQLViews
    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing CreateSQLView"
    PRINT #flog%, "(" + ProgramName$ + "): "

' *** Delete the <TEAM> battingstats file from mysql-files
    battingfile$ = mysql_outputdir$ + teamName + "-battingstats.file"
    IF _FILEEXISTS(battingfile$) THEN KILL battingfile$
' 04/22/2022 v0.24 GJM - Added direct connect/access to mySQL/mariaDB from a Client
'                        Connector I wrote in C. This will replace pipecom for all
'                        SQL calls, and allow direct access to SQL tables/views.

' *** Load the SQL statements from a file (first record is number of lines in file)
' *** and into an array for processing and execution. 
    sqlstmtfile$ = "sql/createTempBatting.sqlproc"
	'$INCLUDE: 'include/baseballSQLstmt.inc'
    sqlstmtfile$ = "sql/createTeamBatting.sqlproc"
	'$INCLUDE: 'include/baseballSQLstmt.inc'
	sqlstmtfile$ = "sql/createTeamBattingOutfile.sqlproc"
''	IF _FILEEXISTS(sqlstmtfile$) THEN
''		'$INCLUDE: 'include/baseballSQLstmt.inc'
''	END IF

' *** the following code can be commented out/removed, as the program will fetch the
' *** data directly from mySQL/mariaDB if the OUTFILE does not exist. (Used for testing)
''	select_what$ = "*"+CHR$(0)
''	select_from$ = mysqlView$+CHR$(0)
''	select_filename$ = battingfile$+CHR$(0)
''	retcode = sqlCreateOutFile(select_what$, select_from$, select_filename$)
''	IF retcode <> 0 THEN 
''		SHELL ("zenity --error --text=" + CHR$(34) + "battingStats Program failed - sqlCreateOutFile failed for teambattingView. Program Terminated." + CHR$(34) + " --width=175 --height=100")
''		PRINT #flog%, "(" + ProgramName$ + "): sqlCreateOutFile failed for: " + battingfile$
''		PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing endPROG"
''		PRINT #flog%, "(" + ProgramName$ + "): "
''		PRINT #flog%, "(" + ProgramName$ + "): *** battingStats - Terminated Abnormally ***"
''		endPROG
''	END IF

' *** Determine the number of Rows and columns
	nbrRows = sqlNumRows(mysqlView$+CHR$(0))
	nbrCols = sqlNumFields(mysqlView$+CHR$(0))

' *** nbrRows and nbrCols are set, resize arrays and start the SQL Procedure
    REDIM Query(nbrCols)
    REDIM Answer(nbrRows + 1, nbrCols)

END SUB


SUB DisplayBoxScores	

    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing DisplayBoxScores"
    PRINT #flog%, "(" + ProgramName$ + "): "

' *** Create SQL views and batting stats file
	CreateSQLViews

' *** Read Batting Stats file into Answer Array, replace "\N" with 0.000
	getBattingStatsFile

submitMenu:	

' *** Print the box scores from the SQL View File (Zenity or Terminal, Log File)
	IF _FILEEXISTS("battingstats.sh") THEN KILL "battingstats.sh"
		f3% = FREEFILE
	cmd = NULL
	OPEN "battingstats.sh" FOR BINARY AS #f3%
	tmp1$ = "###  ": tmp2$ = "#.###  "
	tmpLine$ = "#!/bin/sh" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = " " + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "zenity --list \" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "       --title=" + CHR$(34) + teamName + " Batting Stats" + CHR$(34) + " \" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "       --text="+ CHR$(34) + "Check all players you wish to update below:" + CHR$(34) +  "\" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "       --width=1350 --height=500 --checklist \" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = 	"      --ok-label=Update --extra-button=Report --extra-button=HELP --extra-button=QUIT \" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = " --column=" + CHR$(34) + "S" + CHR$(34) + " --column=" + CHR$(34) + "PLAYER" + CHR$(34) + _ 
			   " --column=" + CHR$(34) + "GP" + CHR$(34) + " --column=" + CHR$(34) + "AB" + CHR$(34) + _
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
	PRINT #flog%, "(" + ProgramName$ + "): Batting: " + teamName
	PRINT #flog%, "(" + ProgramName$ + "): "
	PRINT #flog%, "(" + ProgramName$ + "): Player Name       GP   AB   R    H   RBI   2B   3B   HR   BB   K   HBP  SAC   SB  ASB   PO  AST   E    AVG    SLUG   OBP    OPS    FPCT"
	PRINT #flog%, "(" + ProgramName$ + "): ---------------- ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  -----  -----  -----  -----  -----"
	FOR x = 1 TO nbrRows
		playerName = Answer(x, 1)
        tmpLine$ = CHR$(34) + "" + CHR$(34) + CHR$(9) + CHR$(34) + playerName + CHR$(34)
        PRINT #flog%, USING "(" + ProgramName$ + "): \               \"; playerName,
        FOR y = HIT.PLAYERNAME+1 TO nbrCols
            nbr = VAL(Answer(x, y))
            tmpLine$ = tmpLine$ + CHR$(9) + Answer(x, y)
            IF y < HIT.AVG THEN
                PRINT #flog%, USING tmp1$; nbr,
            ELSE
                PRINT #flog%, USING tmp2$; nbr,
            END IF
        NEXT y        
        tmpLine$ = tmpLine$ + " \" + CHR$(10)
        PRINT #flog%, NULL
        PUT #f3%, , tmpLine$
	NEXT x        
	CLOSE #f3%
	SHELL ("chmod +x battingstats.sh")
	cmd = "./battingstats.sh"
	retcode = pipecom(cmd, stdout, stderr)

' *** Save menu selection and/or button pressed   
    lenstr = LEN(stdout): stdout = LEFT$(stdout, lenstr - 1) 
	stdmenu = LTRIM$(stdout)
	stdbutton = stdout
	PRINT #flog%, "(" + ProgramName$ + "): "
	PRINT #flog%, "(" + ProgramName$ + "): stdout = "; stdout
	PRINT #flog%, "(" + ProgramName$ + "): stderr = "; stderr
	PRINT #flog%, "(" + ProgramName$ + "): retcode = "; retcode
	PRINT #flog%, "(" + ProgramName$ + "): "

' *** If X, Cancel or QUIT buttons are pressed, end program
	IF retcode = 1 AND stdbutton = NULL THEN GOTO endSUB
	IF retcode = 1 AND stdbutton = "QUIT" THEN GOTO endSUB

' *** If HELP button pressed, display the HELP Screen	
    IF retcode = 1 AND stdbutton = "HELP" THEN
        cmd = "zenity --text-info " + _
              " --title=" + CHR$(34) + "HELP: Baseball/Softball Statistics System - v1.0.0" + CHR$(34) + _
              " --width=1000 --height=850 --html --ok-label=" + CHR$(34) + "Return to Menu" + CHR$(34) +  _
              " --filename=" + "help/battingDisplayStats.html" + " 2> /dev/null"
        SHELL (cmd)
        GOTO SubmitMenu
    END IF
    
' *** If Report button pressed, produce the report on display/printer	
    IF stdbutton = "Report" THEN 
		PrintStats
		GOTO SubmitMenu
	END IF

	EXIT SUB

endSUB:
' *** CLOSE Log File
'

	PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing endSUB (Program Shutdown)"
	PRINT #flog%, "(" + ProgramName$ + "): "

' *** Remove work files if they exist
	'$INCLUDE: 'include/deleteWorkFiles.inc'
	
	IF sqlActive THEN
' *** Perform SQL VIEW Cleanup 
		PRINT #flog%, "(" + ProgramName$ + "): Performing mySQL VIEW cleanup" 
		PRINT #flog%, "(" + ProgramName$ + "): "
		'$INCLUDE: 'include/mysqlCleanup.inc'	
' *** Disconnect from mySQL Server
		PRINT #flog%, "(" + ProgramName$ + "): Disconnecting from mySQL Server" 
		PRINT #flog%, "(" + ProgramName$ + "): "
		retcode = sqlDisonnect
		IF retcode <> 0 THEN 
			PRINT #flog%, "(" + ProgramName$ + "): Disconnecting from server failed. Program terminated. Return Code ="; retcode
			PRINT #flog%, "(" + ProgramName$ + "): *** Program Execution FAILED ***"
			CLOSE #flog%
			SYSTEM 99
		END IF		
		sqlActive = FALSE		
	END IF	

	IF cntargs = 0 THEN
		PRINT #flog%, "(" + ProgramName$ + "): Terminated Normally ***"
	ELSE
		PRINT #flog%, "(" + ProgramName$ + "): Terminated Normally - Return to calling Program ***"
	END IF
	CLOSE #flog%

    IF retcode = 1 AND stdbutton = NULL THEN SYSTEM 1 ELSE SYSTEM

    
END SUB


SUB PrintStats
'-----------------------------------------------------------------------------
' *** Recreate the SQL Views with updated data and produce the stats reports
'

    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing PrintStats"
    PRINT #flog%, "(" + ProgramName$ + "): "
    
' *** Recalculate Rows and Columns from updated Table and View and
' *** create SQL Views for reporting
	nbrRows = sqlNumRows(mysqlView$+CHR$(0))
	nbrCols = sqlNumFields(mysqlView$+CHR$(0))
	
    cmd = NULL
    IF _FILEEXISTS(battingfile$) THEN KILL battingfile$
    PRINT #flog%, "(" + ProgramName$ + "): "
    FOR x = 1 TO nbrLines
        PRINT #flog%, "(" + ProgramName$ + "): "; sqlStmt(x)
        cmd = cmd + sqlStmt(x)
    NEXT x
    PRINT #flog%, "(" + ProgramName$ + "): "
    PRINT #flog%, "(" + ProgramName$ + "): cmd = "; cmd

	retcode = sqlCMD(cmd+CHR$(0))
	IF retcode <> 0 THEN 
		PRINT #flog%, "(" + ProgramName$ + "): SQL Command Failed. Please check output and run again. Return Code ="; retcode
		PRINT #flog%, "(" + ProgramName$ + "): "
		endPROG
	END IF

    REDIM Query(nbrCols)
    REDIM Answer(nbrRows + 1, nbrCols)

' *** Read Batting Stats file into Answer Array, replace "\N" with 0.000
	getBattingStatsFile


' *** Create the report file and send it to the printer,
' *** otherwise, clear the terminal/console and display the report.
    tmp1$ = "###  ": tmp2$ = "#.###  "   
    IF PrintReport THEN
		ReportFile$ = teamName + "battingstats.prn"
		IF _FILEEXISTS(ReportFile$) THEN KILL ReportFile$
		f4% = FREEFILE
		cmd = NULL
		OPEN ReportFile$ FOR OUTPUT AS #f4%
		PRINT #f4%, NULL: PRINT #f4%, NULL
		PRINT #f4%, "Batting: " + teamName
		PRINT #f4%, NULL
		PRINT #f4%, "Player Name       GP   AB   R    H   RBI   2B   3B   HR   BB   K   HBP  SAC   SB  ASB   PO  AST   E    AVG    SLUG   OBP    OPS    FPCT"
		PRINT #f4%, "---------------- ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  -----  -----  -----  -----  -----"
		FOR x = 1 TO nbrRows
			playerName = Answer(x, 1)
			PRINT #f4%, USING "\               \"; playerName,        
			FOR y = HIT.PLAYERNAME+1 TO nbrCols
				nbr = VAL(Answer(x, y))
				IF y < HIT.AVG THEN
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
		PRINT #flog%, "(" + ProgramName$ + "): Batting Report sent to the printer for: " + teamName
		PRINT #flog%, "(" + ProgramName$ + "): "
		EXIT SUB
	END IF
	
	CLS , BGColor
	COLOR FGColor, BGColor
	_TITLE teamName + " Batting/Fielding Statistics"
	_SCREENSHOW
	PRINT: PRINT "  Batting: " + teamName
	PRINT: PRINT
	PRINT "  Player Name       GP   AB   R    H   RBI   2B   3B   HR   BB   K   HBP  SAC   SB  ASB   PO  AST   E    AVG    SLUG   OBP    OPS    FPCT"
	PRINT "  ---------------- ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  -----  -----  -----  -----  -----"
	FOR x = 1 TO nbrRows
		playerName = Answer(x, 1)
		PRINT USING "  \               \"; playerName,
		FOR y = HIT.PLAYERNAME+1 TO nbrCols
			nbr = VAL(Answer(x, y))
			IF y < HIT.AVG THEN
				PRINT USING tmp1$; nbr,
			ELSE
				PRINT USING tmp2$; nbr,
			END IF
		NEXT y
		PRINT
	NEXT x	
	FOR x = 1 to (26 - nbrRows): PRINT: NEXT x
	PRINT "  Press any key to continue ..."
	SLEEP
	PRINT #flog%, "(" + ProgramName$ + "): Batting Report displayed in terminal for: " + teamName
	PRINT #flog%, "(" + ProgramName$ + "): "
	CLS , BGColor
	_SCREENHIDE


END SUB


SUB getBattingStatsFile
'-----------------------------------------------------------------------------
' *** Loads and formats the Team Batting File created from a SQL View 
'

    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing getBattingStatsFile"
    PRINT #flog%, "(" + ProgramName$ + "): "
    
	IF _FILEEXISTS(battingfile$) THEN
		rows = 1: Delim$ = CHR$(9)
		f2% = FREEFILE
		OPEN battingfile$ FOR INPUT AS #f2%
		DO UNTIL EOF(f2%)
			LINE INPUT #f2%, qString$
			return$ = StrSplit$(qString$, Delim$)
			FOR cols = HIT.PLAYERNAME TO nbrCols
				IF Query(cols) = "\N" THEN Query(cols) = "0.000"
				Answer(rows, cols) = Query(cols)
			NEXT cols
			rows = rows + 1
		LOOP
		CLOSE #f2%
		EXIT SUB
	END IF

	retcode = sqlUseResult("SELECT * FROM "+mysqlView$+CHR$(0))
	IF retcode <> 0 THEN
			SHELL ("zenity --error --text=" + CHR$(34) + "battingStats Program failed - sqlUseRsult failed for getBattingStatsFile. Program Terminated." + CHR$(34) + " --width=175 --height=100")
			PRINT #flog%, "(" + ProgramName$ + "): sqlUseResult failed for: " + mysqlView$
			PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing endPROG"
			PRINT #flog%, "(" + ProgramName$ + "): "
			PRINT #flog%, "(" + ProgramName$ + "): *** battingStats - Terminated Abnormally ***"
			endPROG
	END IF
	
	PRINT #flog%, "(" + ProgramName$ + "): Retrieving Rows from SQL: " + mysqlView$
	PRINT #flog%, "(" + ProgramName$ + "): -----------------------------------------------------------------------------------------" 
	PRINT #flog%, "(" + ProgramName$ + "): "
	rows = 1: Delim$ = CHR$(9)
	FOR i = 1 to nbrRows
		qString$ = sqlFetchRow$
		return$ = StrSplit$(qString$, Delim$)
		FOR cols = 1 TO nbrCols
			IF Query(cols) = "\N" THEN Query(cols) = "0.000"
			Answer(rows, cols) = Query(cols)
		NEXT cols
		rows = rows + 1
	NEXT i		
	retcode = sqlFreeFetchRow
	
END SUB


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

