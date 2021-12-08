REM $TITLE: battingStats.bas Version 0.25  08/09/2021 - Last Update: 12/07/2021
_TITLE "battingStats.bas"
' battingStats.bas    Version 1.0  08/09/2021
'-------------------------------------------------------------------------------------
'       PROGRAM: battingStats.bas
'        AUTHOR: George McGinn
'                <gjmcginn@icloud.com>
'
'  DATE WRITTEN: 08/09/2021
'       VERSION: 1.0
'       PROJECT: Baseball/Softball Statistics System
'
'   DESCRIPTION: Process the batting statistics and reporting of the
'                Baseball/Softball Statistics System.
'
' Written by George McGinn
' Copyright (C)2021 by George McGinn - All Rights Reserved.
' Version 1.0 - Created 08/09/2021
'
'
' CHANGE LOG
'-------------------------------------------------------------------------------------
' 08/09/21 v1.00 GJM - New Program.
' 09/18/21 v0.11 GJM - Modified this code to run on Linux only, and to insure that
'                      required software is installed. Also moved some code into SUBs
'                      and FUNCTIONS, centralizing common routines.
' 09/20/21 v0.12 GJM - Added code to accept & process ARGS passed to program. Also 
'                      modified the program to run in stand-a-lone mode if no ARGS
'                      were passed to it. 
' 09/21/21 v0.13 GJM - Updated the Form and source to accept gameID and gamesPlayed,
'                      and create INCLUDE files for shared DIM & SUB/FUNCTIONS.
' 09/27/21 v0.14 GJM - Updated the button labels and added a file clean-up in the
'                      endPROG label and an error handling routine for system errors.
' 09/29/21 v0.15 GJM - Added the token <SQLDB> logic and changed the PRINT/DISPLAY 
'                      Stats routines to a more improved version (as was coded in 
'                      leagueStats).    
' 09/30/21 v0.16 GJM - Updated pipecom based on a change by Zach.
' 10/01/21 v0.17 GJM - Added config file processing and passing ARG values
'                      to this module when called from baseballStats.
' 10/02/21 v0.18 GJM - Added config file value for mysqlTable$ and updates to process
'                      changes to the config file.
' 10/05/21 v0.19 GJM - Added HELP menu and ProgramName$ that is determined in initialization.
' 10/06/21 v0.20 GJM - Updated program to new directory structure & file names
' 10/13/21 v0.21 GJM - Added the HELP system and fixed a logic flow error where the
'                      incorrect screens were being displayed when [CANCEL] was pressed.
' 10/14/21 v0.22 GJM - For some reason the Report code was missing. Added it back in.
' 11/19/21 v0.23 GJM - Cosmetic changes made to display GUI's.
' 11/21/21 v0.24 GJM - Add the output mySQL directory to the config.ini file
'                      and standardized the size of the HELP screen
' 12/07/21 v0.25 GJM - Updated CC licensing
'-------------------------------------------------------------------------------------
'  Copyright (C)2021 by George McGinn.  All Rights Reserved.
'
' battingStats by George McGinn is licensed under a Creative Commons
' Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
'
' Full License Link: https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
'
'-------------------------------------------------------------------------------------
' PROGRAM NOTES
'
'
'-------------------------------------------------------------------------------------


'-------------------------------------------------------------------------------------
' *** Preprocessing Section
'
'$DYNAMIC
$CONSOLE:ONLY
OPTION BASE 1

ON ERROR GOTO ehandler

'-------------------------------------------------------------------------------------
' *** Initialize Section
'
'$INCLUDE: 'include/baseballInit.inc'
PrintReport = FALSE     ' *** Set to TRUE to print to printer, FALSE for testing (display output)
setLeague = FALSE

'----------------------------------------------------------------------------
' *** Process args passed to program (if found):
' *** Split out Value Pairs - qString and pass to StrSplit$ (Delimiter = <:>)
'
'$INCLUDE: 'include/baseballProcessArgs.inc'

'----------------------------------------------------
' *** Determine/set OSType
'
IF INSTR(_OS$, "LINUX") THEN OStype = "LINUX"
IF OStype <> "LINUX" THEN
    PRINT #flog%, "*** (" + ProgramName$ + ") ERROR: Program runs in Linux only. Program Terminated. ***": PRINT #flog%, ""
    GOTO endPROG
END IF


QB64Main:
'-------------------------------------------------------------------------------------
' *** MAIN Logic
'
	IF cntargs = 0 THEN
		result = SystemsCheck
		IF result = FALSE THEN GOTO endPROG
	END IF

DetermineArraySize:
' *** Initialize SQL variables and do a SELECT to determine number of columns and
' *** rows for sizing Query array
'
	PRINT #flog%, ">>>>> Executing DetermineArraySize"
	PRINT #flog%, ""

' *** Initialize SQL variables for this program execution
	mysqlTable$ = mysql_battingTable$
	mysqlCMD$ = "mysql -u" + mysql_userid$ + " -p" + mysql_password$ + " " + mysqlDB$ + " -s -e "
	nbrRows = 0: nbrCols = 0

'$INCLUDE: 'include/baseballMainForm.inc'
	IF stdbutton = "QUIT" THEN GOTO endPROG
''	IF teamName = "" THEN GOTO ProcessTeamForm

ProcessSQLFile:
	PRINT #flog%, ">>>>> Executing ProcessSQLFile"
	PRINT #flog%, ""

	mysqlView$ = teamName + mysqlTable$ + "StatsView"

DisplayForm:
' *** Show Box Scores 
	DisplayBoxScores
	lenstr = LEN(stdout)
	stdbutton = LEFT$(stdout, lenstr - 1)
	IF stdbutton = "Report" THEN 
		PrintStats
		GOTO DisplayForm
	END IF
	IF stdbutton = "QUIT" THEN GOTO endPROG
	IF result =  1 AND stdbutton = "" THEN GOTO DisplayForm


CheckProcessUpdates:
    PRINT #flog%, ">>>>> Executing CheckProcessUpdates"
    PRINT #flog%, ""
    PRINT #flog%, "List of Players to Update"

' *** Split out names of selected records into the Query array
	REDIM Query(nbrCols)
	Delim$ = "|"
	qString$ = stdout
	retcode = StrSplit$(qString$, Delim$)
	ix1 = 1
	DO
		PRINT #flog%, Query(ix1)
		ix1 = ix1 + 1
	LOOP UNTIL Query(ix1) = ""
	PRINT #flog%, ""
	nbrUpdates = ix1 - 1
    
' *** Process the SQL Updates from Input Form
    result = sql_update(nbrUpdates)

	lenstr = LEN(stdout)
	stdbutton = LEFT$(stdout, lenstr - 1)
	IF stdbutton = "Report" THEN 
		PrintStats
		GOTO DisplayForm
	END IF
	IF stdbutton = "QUIT" THEN GOTO endPROG
	IF result =  1 AND stdbutton = "" THEN GOTO DisplayForm
	GOTO DisplayForm


endPROG:
' *** CLOSE Log File
'

' *** Remove work files if they exist
'$INCLUDE: 'include/deleteWorkFiles.inc'

' *** Process end of program based on how it was called
	IF cntargs = 0 THEN
		PRINT #flog%, ">>>>> Executing endPROG"
		PRINT #flog%, ""
		PRINT #flog%, "": PRINT #flog%, "*** battingStats - Terminated Normally ***"
		CLOSE #flog%
	ELSE
		PRINT #flog%, ">>>>> Executing (" + ProgramName$ + ") endPROG"
		PRINT #flog%, ""
		PRINT #flog%, "": PRINT #flog%, "*** " + ProgramName$ + " - Terminated Normally - Return to calling Program ***"
		CLOSE #flog%
	END IF
	
	SYSTEM


ehandler:
'$INCLUDE: 'include/baseballErrhandler.inc'


'--------------------------------------------------------------------------------------
' *** SQL Functions
'

'$INCLUDE: 'include/basebalRowsColsSQL.inc'


FUNCTION sql_update (nbrUpdates)
'--------------------------------------------------------------
' *** Get the number of total rows based on SELECT COUNT(*) ***
'--------------------------------------------------------------
'
    PRINT #flog%, ">>>>> Executing FUNCTION sql_update()"
    PRINT #flog%, ""


SubmitMenu:

    IF _FILEEXISTS("updatebattingstats.sh") THEN KILL "updatebattingstats.sh"
	f3% = FREEFILE
	cmd = ""

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
	tmpLine$ = "       --editable --multiple --print-column=ALL \" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "       --width=1350 --height=700 \" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = 	"      --ok-label=Commit --extra-button=HELP --extra-button=QUIT \" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "       --column=" + CHR$(34) + "S" + CHR$(34) + " --column=" + CHR$(34) + "PLAYER" + CHR$(34) + " --column=" + CHR$(34) + "GAMEID" + CHR$(34) + " --column=" + CHR$(34) + "GP" + CHR$(34) + " --column=" + CHR$(34) + "AB" + CHR$(34) + " --column=" + CHR$(34) + "R" + CHR$(34) + " --column=" + CHR$(34) + "H" + CHR$(34) + " --column=" + CHR$(34) + "RBI" + CHR$(34) + " --column=" + CHR$(34) + "2B" + CHR$(34) + " --column=" + CHR$(34) + "3B" + CHR$(34) + " --column=" + CHR$(34) + "HR" + CHR$(34) + " --column=" + CHR$(34) + "BB" + CHR$(34) + " --column=" + CHR$(34) + "K" + CHR$(34) + " --column=" + CHR$(34) + "HBP" + CHR$(34) + " --column=" + CHR$(34) + "SAC" + CHR$(34) + " --column=" + CHR$(34) + "SB" + CHR$(34) + " --column=" + CHR$(34) + "ASB" + CHR$(34) + " --column=" + CHR$(34) + "PO" + CHR$(34) + " --column=" + CHR$(34) + "AST" + CHR$(34) + " --column=" + CHR$(34) + "E" + CHR$(34) + " \" + CHR$(10)
	PUT #f3%, , tmpLine$

	FOR x = 1 TO nbrUpdates
		IF Query(x) <> "" THEN
			playerName = Query(x)
			IF gameID <> "" THEN
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
	result = pipecom(cmd, stdout, stderr)
	PRINT #flog%, ""
	PRINT #flog%, "stdout = "; stdout
	PRINT #flog%, "stderr = "; stderr
	PRINT #flog%, "result = "; result
	PRINT #flog%, ""
	
	
' *** Save menu selection and/or button pressed   
    lenstr = LEN(stdout): stdout = LEFT$(stdout, lenstr - 1) 
	stdmenu = LTRIM$(stdout)
	stdbutton = stdout

' *** If X, Cancel or QUIT buttons are pressed, end program
	IF result = 1 AND stdbutton = "" THEN EXIT FUNCTION
	IF result = 1 AND stdbutton = "QUIT" THEN EXIT FUNCTION

' *** If HELP button pressed, display the HELP Screen	
    IF result = 1 AND stdbutton = "HELP" THEN
        cmd = "zenity --text-info " + _
              " --title=" + CHR$(34) + "HELP: Baseball/Softball Statistics System - v1.0" + CHR$(34) + _
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
	retcode = StrSplit$(qString$, Delim$)
	nbrUpdates = 1

	IF qString$ = "QUIT" THEN EXIT FUNCTION

	FOR ix1 = 1 TO 500
		IF Query(ix1) = "u" THEN nbrUpdates = nbrUpdates + 1
	NEXT ix1
	PRINT #flog%, ""
	nbrUpdates = nbrUpdates - 1

' *** Create SQL INSERT Statements and execute each update to table
	factor = 0
	FOR idx = 1 TO nbrUpdates
		IF Query(1 + factor) = "u" THEN
			cmd = (mysqlCMD$ + CHR$(34) + "INSERT INTO " + mysqlTable$ + " VALUES ('" + teamName + "', ")
            playerName = Query(2 + factor): gameID$ = Query(3 + factor): nbr = VAL(Query(4 + factor))
            tmpLine2$ = "'" + gameID$ + "'": tmpLine3$ = STR$(nbr): tmpLine4$ = "'" + playerName + "'"
            cmd = cmd + tmpLine2$ + ", " + tmpLine3$ + ", " + tmpLine4$ + ", "
            FOR x = (5 + factor) TO (20 + factor)
                nbr = VAL(Query(x))
                IF x = (20 + factor) THEN tmpLine$ = STR$(nbr) ELSE tmpLine$ = STR$(nbr) + ", "
                cmd = cmd + tmpLine$
            NEXT x
            cmd = cmd + ");" + CHR$(34)
            factor = factor + 20
            result = pipecom(cmd, stdout, stderr)
            PRINT #flog%, cmd
            PRINT #flog%, "stdout = "; stdout
            PRINT #flog%, "stderr = "; stderr
            PRINT #flog%, "result = "; result
            PRINT #flog%, ""
        ELSE
            PRINT #flog%, "WARNING (" + ProgramName$ + "): Record missing the UPDATE (u) Flag - Record for "; Query(idx + factor); " Ignored."
            factor = factor + 20
        END IF
    NEXT idx
    PRINT #flog%, ""
    
    sql_update = 0


END FUNCTION

'
' *** End SQL Functions
'-----------------------------------------------------------------------------


SUB CreateSQLViews
    PRINT #flog%, ">>>>> Executing CreateSQLView"
    PRINT #flog%, ""

' *** Delete the <TEAM> battingstats file from mysql-files
' *** Cannot use KILL here as this file expects a "y" response to delete
    battingfile$ = mysql_outputdir$ + teamName + "-battingstats.file"
    IF _FILEEXISTS(battingfile$) THEN
        cmd = "echo y | rm " + battingfile$
        SHELL (cmd)
    END IF

' *** Load the SQL statements from a file (first record is number of lines in file)
' *** and into an array for processing and execution. 
    sqlstmtfile$ = "sql/battingsqlstmt.sqlproc"

'$INCLUDE: 'include/baseballSQLstmt.inc'

' *** Determine the number of Rows and columns
	nbrRows = sql_rows
    nbrCols = sql_columns

' *** nbrRows and nbrCols are set, resize arrays and start the SQL Procedure
    REDIM Query(nbrCols)
    REDIM Answer(nbrRows + 1, nbrCols)

END SUB


SUB DisplayBoxScores	

' *** Create SQL views and batting stats file
	CreateSQLViews

' *** Read Batting Stats file into Answer Array, replace "\N" with 0.000
	getBattingStatsFile

submitMenu:	
' *** Print the box scores from the SQL View File (Zenity or Terminal, Log File)
	IF _FILEEXISTS("battingstats.sh") THEN KILL "battingstats.sh"
	f3% = FREEFILE
	cmd = ""
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
	PRINT #flog%, "Batting: " + teamName
	PRINT #flog%, ""
	PRINT #flog%, "Player Name       GP   AB   R    H   RBI   2B   3B   HR   BB   K   HBP  SAC   SB  ASB   PO  AST   E    AVG    SLUG   OBP    OPS    FPCT"
	PRINT #flog%, "---------------- ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  -----  -----  -----  -----  -----"

	FOR x = 1 TO nbrRows
		playerName = Answer(x, 1)
        tmpLine$ = CHR$(34) + "" + CHR$(34) + CHR$(9) + CHR$(34) + playerName + CHR$(34)
        PRINT #flog%, USING "\               \"; playerName,
        FOR y = 2 TO nbrCols
            nbr = VAL(Answer(x, y))
            tmpLine$ = tmpLine$ + CHR$(9) + Answer(x, y)
            IF y < 19 THEN
                PRINT #flog%, USING tmp1$; nbr,
            ELSE
                PRINT #flog%, USING tmp2$; nbr,
            END IF
        NEXT y
        tmpLine$ = tmpLine$ + " \" + CHR$(10): PRINT #flog%, ""
        PUT #f3%, , tmpLine$
	NEXT x
        
	CLOSE #f3%
	SHELL ("chmod +x battingstats.sh")
	cmd = "./battingstats.sh"
	result = pipecom(cmd, stdout, stderr)
	PRINT #flog%, ""
	PRINT #flog%, "stdout = "; stdout
	PRINT #flog%, "stderr = "; stderr
	PRINT #flog%, "result = "; result
	PRINT #flog%, ""

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

endPROG:
' *** CLOSE Log File
'

' *** Remove work files if they exist
'$INCLUDE: 'include/deleteWorkFiles.inc'
	
	IF cntargs = 0 THEN
		PRINT #flog%, ">>>>> Executing endPROG"
		PRINT #flog%, ""
		PRINT #flog%, "": PRINT #flog%, "*** battingStats - Terminated Normally ***"
		CLOSE #flog%
	ELSE
		PRINT #flog%, ">>>>> Executing (" + ProgramName$ + ") endPROG"
		PRINT #flog%, ""
		PRINT #flog%, "": PRINT #flog%, "*** " + ProgramName$ + " - Terminated Normally - Return to calling Program ***"
		CLOSE #flog%
	END IF

    IF result = 1 AND stdbutton = "" THEN SYSTEM 1 ELSE SYSTEM

    
END SUB


SUB PrintStats
'-----------------------------------------------------------------------------
' *** Recreate the SQL Views with updated data and produce the stats reports
'

    PRINT #flog%, ">>>>> Executing PrintStats"
    PRINT #flog%, ""
    
' *** Recalculate Rows and Columns from updated Table and View and
' *** create SQL Views for reporting
    result = sql_rows
    cmd = ""
    cmd = cmd + mysqlCMD$ + CHR$(34)
    PRINT #flog%, "": PRINT #flog%, ""
    FOR x = 1 TO nbrLines
        PRINT #flog%, sqlStmt(x)
        cmd = cmd + sqlStmt(x)
    NEXT x
    cmd = cmd + CHR$(34)
    PRINT #flog%, "": PRINT #flog%, "": PRINT #flog%, "cmd = "; cmd
    result = pipecom(cmd, stdout, stderr)
    PRINT #flog%, "stdout = "; stdout
    PRINT #flog%, "stderr = "; stderr
    PRINT #flog%, "result = "; result
    PRINT #flog%, ""
    result = sql_columns
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
		cmd = ""
		OPEN ReportFile$ FOR OUTPUT AS #f4%
		PRINT #f4%, "": PRINT #f4%, ""
		PRINT #f4%, "Batting: " + teamName
		PRINT #f4%, ""
		PRINT #f4%, "Player Name       GP   AB   R    H   RBI   2B   3B   HR   BB   K   HBP  SAC   SB  ASB   PO  AST   E    AVG    SLUG   OBP    OPS    FPCT"
		PRINT #f4%, "---------------- ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  -----  -----  -----  -----  -----"
		FOR x = 1 TO nbrRows
			playerName = Answer(x, 1)
			PRINT #f4%, USING "\               \"; playerName,        
			PRINT #flog%, USING "\               \"; playerName,
			FOR y = 2 TO nbrCols
				nbr = VAL(Answer(x, y))
				IF y < 19 THEN
					PRINT #flog%, USING tmp1$; nbr,
					PRINT #f4%, USING tmp1$; nbr,
				ELSE
					PRINT #flog%, USING tmp2$; nbr,
					PRINT #f4%, USING tmp2$; nbr,
				END IF
			NEXT y
			PRINT #f4%, ""
		NEXT x    
		CLOSE #f4%
		cmd = "enscript -B -r -fCourier8 " + ReportFile$
		SHELL (cmd)
	ELSE
		PRINT "Batting: " + teamName
		PRINT
		PRINT "Player Name       GP   AB   R    H   RBI   2B   3B   HR   BB   K   HBP  SAC   SB  ASB   PO  AST   E    AVG    SLUG   OBP    OPS    FPCT"
		PRINT "---------------- ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  -----  -----  -----  -----  -----"
		FOR x = 1 TO nbrRows
			playerName = Answer(x, 1)
			PRINT USING "\               \"; playerName,
			FOR y = 2 TO nbrCols
				nbr = VAL(Answer(x, y))
				IF y < 19 THEN
					PRINT USING tmp1$; nbr,
				ELSE
					PRINT USING tmp2$; nbr,
				END IF
			NEXT y
			PRINT
		NEXT x	
	END IF

END SUB


SUB getBattingStatsFile
'-----------------------------------------------------------------------------
' *** Loads and formats the Team Batting File created from a SQL View 
'
	IF _FILEEXISTS(battingfile$) THEN
		rows = 1: Delim$ = CHR$(9)
		f2% = FREEFILE
		OPEN battingfile$ FOR INPUT AS #f2%
		DO UNTIL EOF(f2%)
			LINE INPUT #f2%, qString$
			retcode = StrSplit$(qString$, Delim$)
			FOR cols = 1 TO nbrCols
				IF Query(cols) = "\N" THEN Query(cols) = "0.000"
				Answer(rows, cols) = Query(cols)
			NEXT cols
			rows = rows + 1
		LOOP
		CLOSE #f2%
	ELSE
		SHELL ("zenity --error --text=" + CHR$(34) + ProgramName$ + " Program failed - missing Team Batting File. Program Terminated" + CHR$(34) + " --width=175 --height=100")
		PRINT #flog%, ">>>>> Executing endPROG"
		PRINT #flog%, ""
		PRINT #flog%, "": PRINT #flog%, "*** " + ProgramName$ + " - Terminated Abnormally ***"
		CLOSE #flog%
		SYSTEM	
	END IF
	
END SUB

'$INCLUDE: 'include/baseballConfig.inc'

'$INCLUDE: 'include/stringFunctions.inc'

'$INCLUDE: 'include/baseballFunctions.inc'

'$INCLUDE: 'include/pipecom.inc'

