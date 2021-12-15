REM $TITLE: pitchingStats.bas Version 0.26  09/22/2021 - Last Update: 12/14/2021
_TITLE "Pitching Statistics Version 0.26  09/22/2021 - Last Update: 12/14/2021"
' pitchingStats.bas    Version 1.0  09/22/2021
'-------------------------------------------------------------------------------------
'       PROGRAM: pitchingStats.bas
'        AUTHOR: George McGinn
'                <gjmcginn@icloud.com>
'
'  DATE WRITTEN: 09/22/2021
'       VERSION: 1.0
'       PROJECT: Baseball/Softball Statistics System
'
'   DESCRIPTION: Process the pitching statistics and reporting of the
'                Baseball/Softball Statistics System.
'
' Written by George McGinn
' Copyright (C)2021 by George McGinn - All Rights Reserved.
' Version 1.0 - Created 09/22/2021
'
'
' CHANGE LOG
'-------------------------------------------------------------------------------------
' 09/22/21 v1.00 GJM - New Program.
' 09/27/21 v0.10 GJM - Updated the button labels and added a file clean-up in the
'                      endPROG label and an error handling routine for system errors.  
' 09/29/21 v0.11 GJM - Added the token <SQLDB> logic and changed the PRINT/DISPLAY 
'                      Stats routines to a more improved version (as was coded in 
'                      leagueStats).      
' 09/30/21 v0.12 GJM - Updated pipecom based on a change by Zach.
' 10/01/21 v0.13 GJM - Added config file processing and passing ARG values
'                      to this module when called from baseballStats.
' 10/02/21 v0.14 GJM - Added config file value for mysqlTable$ and updates to process
'                      changes to the config file.
' 10/06/21 v0.17 GJM - Updated program to new directory structure & file names
' 10/10/21 v0.18 GJM - There is an issue with SQL calculating ERA and correctly displaying
'                      innings pitched. Added a function to correct the display of IP
'                      and to calculate ERA correctly. Also added index CONSTANTS so
'                      code is easier to read and work with, especially if new columns
'                      are added. Changes to CONST values instead of code changes.
'                      Also added the format$ to stringFunctions.inc so I can format
'                      variables properly in arrays used by Zenity for displaying.
'                      Also fixed a logic flow error where the incorrect screens 
'                      were being displayed when [CANCEL] was pressed.
' 10/14/21 v0.19 GJM - For some reason the Report code was missing. Added it back in.
' 10/15/21 v0.20 GJM - Corrected the ERA and IP logic to convert outs pitched now stored
'                      in SQL tables to display correctly. SQL now calculates ERA.
'					   Added the logic to convert innings pitched into total outs for
'                      SQL updates.
' 11/19/21 v0.21 GJM - Cosmetic changes made to display GUI's.
' 11/20/21 v0.22 GJM - Added the HELP system for this module. Also added the missing
'                      logic to process button clicks when doing updates.
' 11/21/21 v0.23 GJM - Add the output mySQL directory to the config.ini file
'                      and standardized the size of the HELP screen
' 12/07/21 v0.24 GJM - Updated CC licensing
' 12/10/21 v0.25 GJM - Created a screen display when enscript isn't installed (This
'                      is required if application is started from an ICON or directly
'                      from Files or a File Manager).
' 12/14/21 v0.26 GJM - Modified the text displayed in the display and update screens
'                      so that the intent is clearer. Added the ABOUT button 
'                      (As this module can run stand-a-lone). Fixed logic for 
'                      stand-a-lone execution.
'-------------------------------------------------------------------------------------
'  Copyright (C)2021 by George McGinn.  All Rights Reserved.
'
' pitchingStats by George McGinn is licensed under a Creative Commons
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
''$CONSOLE:ONLY
OPTION BASE 1
SCREEN _NEWIMAGE(1300, 600, 32)
$SCREENHIDE

DECLARE LIBRARY
    FUNCTION floor## (BYVAL num AS _FLOAT)
	FUNCTION ceil## (BYVAL num AS _FLOAT)
END DECLARE

ON ERROR GOTO ehandler

'-------------------------------------------------------------------------------------
' *** Initialize Section
'

'$INCLUDE: 'include/baseballInit.inc'
'PrintReport = FALSE     ' *** Set to FALSE for testing (display output)
setLeague = FALSE

'----------------------------------------------------
' *** Determine/set OSType
'


'----------------------------------------------------------------------------
' *** Process args passed to program (if found) - Split out Value Pairs 
'
'$INCLUDE: 'include/baseballProcessArgs.inc'


'----------------------------------------------------
' *** If started from this program, do systems checks
'
IF INSTR(_OS$, "LINUX") THEN OStype = "LINUX"
IF OStype <> "LINUX" THEN
	PRINT #flog%, "*** (" + ProgramName$ + ") ERROR: Program runs in Linux only. Program Terminated. ***": PRINT #flog%, ""
	GOTO endPROG
END IF

result = SystemsCheck
IF result = FALSE THEN GOTO endPROG

IF cntargs = 0 THEN
	DisplayAbout
    LoadConfigFile
END IF
innings = VAL(nbr_innings$)

PRINT #flog%, "": PRINT #flog%, "*** variable innings = "; innings
PRINT #flog%, ""

QB64Main:
'-------------------------------------------------------------------------------------
' *** MAIN Logic
'

' *** Initialize SQL variables and do a SELECT to determine number of columns and
' *** rows for sizing Query array
'
	mysqlTable$ = mysql_pitchingTable$
	mysqlCMD$ = "mysql -u" + mysql_userid$ + " -p" + mysql_password$ + " " + mysqlDB$ + " -s -e "
	nbrRows = 0: nbrCols = 0

'$INCLUDE: 'include/baseballMainForm.inc'


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
		GOTO QB64Main
	END IF
	IF stdbutton = "QUIT" THEN GOTO endPROG


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

' *** Clean-up: Remove work files if they exist
'$INCLUDE: 'include/deleteWorkFiles.inc'


' *** Process end of program based on how it was called
	IF cntargs = 0 THEN
		PRINT #flog%, ">>>>> Executing endPROG"
		PRINT #flog%, ""
		PRINT #flog%, "": PRINT #flog%, "*** " + ProgramName$ + " - Terminated Normally ***"
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

    IF _FILEEXISTS("updatepitchingstats.sh") THEN KILL "updatepitchingstats.sh"
	f3% = FREEFILE
	cmd = ""

	OPEN "updatepitchingstats.sh" FOR BINARY AS #f3%
	tmp1$ = "###  ": tmp2$ = "#.###  ": idx = 6
	tmpLine$ = "#!/bin/sh" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = " " + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "zenity --list \" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "       --title=" + CHR$(34) + teamName + " Pitching Stats Update" + CHR$(34) + " \" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "       --text="+ CHR$(34) + "Update all fields needed, then select all records to update:" + CHR$(34) +  "\" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "       --editable --multiple --print-column=ALL \" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "       --width=1350 --height=700 \" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = 	"      --ok-label=Commit --extra-button=HELP --extra-button=QUIT \" + CHR$(10)
	PUT #f3%, , tmpLine$	
	tmpLine$ = " --column=" + CHR$(34) + "S" + CHR$(34) + " --column=" + CHR$(34) + "PLAYER" + CHR$(34) + _ 
	           " --column=" + CHR$(34) + "GAMEID" + CHR$(34) + " --column=" + CHR$(34) + "GP" + CHR$(34) + _ 
	           " --column=" + CHR$(34) + "W" + CHR$(34) + " --column=" + CHR$(34) + "L" + CHR$(34) + _
	           " --column=" + CHR$(34) + "SV" + CHR$(34) + " --column=" + CHR$(34) + "SVO" + CHR$(34) + _ 
	           " --column=" + CHR$(34) + "GS" + CHR$(34) + " --column=" + CHR$(34) + "GC" + CHR$(34) + _ 
	           " --column=" + CHR$(34) + "IP" + CHR$(34) + " --column=" + CHR$(34) + "TBF" + CHR$(34) + _
	           " --column=" + CHR$(34) + "H" + CHR$(34) + " --column=" + CHR$(34) + "BB" + CHR$(34) + _
	           " --column=" + CHR$(34) + "K" + CHR$(34) + " --column=" + CHR$(34) + "RA" + CHR$(34) + _
	           " --column=" + CHR$(34) + "ER" + CHR$(34) + " --column=" + CHR$(34) + "HR" + CHR$(34) + _
	           " --column=" + CHR$(34) + "HBP" + CHR$(34) + " --column=" + CHR$(34) + "SF" + CHR$(34) +  " \" + CHR$(10)
	PUT #f3%, , tmpLine$

	FOR x = 1 TO nbrUpdates
		IF Query(x) <> "" THEN
			playerName = Query(x)
			IF gameID <> "" THEN 
				tmpLine$ = CHR$(34) + "u" + CHR$(34) + CHR$(9) + CHR$(34) + playerName + CHR$(34) + CHR$(9) + CHR$(34) + gameID + CHR$(34) + CHR$(9) + gamesPlayed + "  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 \" + CHR$(10)
			ELSE
				tmpLine$ = CHR$(34) + "u" + CHR$(34) + CHR$(9) + CHR$(34) + playerName + CHR$(34) + CHR$(9) + CHR$(34) + "" + CHR$(34)  + CHR$(9) + gamesPlayed +    "  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 \" + CHR$(10)
			END IF
			PUT #f3%, , tmpLine$
		END IF
	NEXT x
	
	FOR x = 1 TO 25 - nbrUpdates
		tmpLine$ = CHR$(34) + "" + CHR$(34) + CHR$(9) + CHR$(34) + "" + CHR$(34) + CHR$(9) + CHR$(34) + "" + CHR$(34) + "  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 \" + CHR$(10)
		PUT #f3%, , tmpLine$
	NEXT x
	
	CLOSE #f3%
	SHELL ("chmod +x updatepitchingstats.sh")
	cmd = "./updatepitchingstats.sh"
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
              " --filename=" + "help/pitchingUpdateStats.html" + " 2> /dev/null"
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
            playerName = Query(2 + factor): gameID$ = Query(3 + factor)
            nbr = VAL(Query(4 + factor))                     
            tmpLine2$ = "'" + gameID$ + "'": tmpLine3$ = STR$(nbr): tmpLine4$ = "'" + playerName + "'"           
            cmd = cmd + tmpLine2$ + ", " + tmpLine3$ + ", " + tmpLine4$ + ", "
            FOR x = (5 + factor) TO (20 + factor)				
                nbr = VAL(Query(x))
                IF x = (PITCH.IP + 2) THEN nbr = convertOUTS (nbr)
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

' *** Delete the <TEAM> pitchingstats file from mysql-files
    pitchingfile$ = mysql_outputdir$ + teamName + "-pitchingstats.file"
    IF _FILEEXISTS(pitchingfile$) THEN
        cmd = "echo y | rm " + pitchingfile$
        SHELL (cmd)
    END IF

' *** Load the SQL statements from a file (first record is number of lines in file)
' *** and into an array for processing and execution. nbrLines is used to hold the
' *** the actual number of elements in the array. If you use the check for NULL
' *** lines, then any loop will hold the actual number of elements in the array.
    sqlstmtfile$ = "sql/pitchingsqlstmt.sqlproc"
    rows = 0: nbrLines = 0: idx = 1

'$INCLUDE: 'include/baseballSQLstmt.inc'

' *** Determine the number of Rows and Columns
	nbrRows = sql_rows
    nbrCols = sql_columns

' *** nbrRows and nbrCols are set, resize arrays and start the SQL Procedure
    REDIM Query(nbrCols)
    REDIM Answer(nbrRows + 1, nbrCols)

END SUB


SUB DisplayBoxScores	

' *** Create SQL views and pitching stats file
	CreateSQLViews

' *** Read pitching Stats file into Answer Array, replace "\N" with 0.000
	getpitchingStatsFile

submitMenu:		
' *** Print the box scores from the SQL View File (Zenity or Terminal, Log File)
	IF _FILEEXISTS("pitchingstats.sh") THEN KILL "pitchingstats.sh"
	f3% = FREEFILE
	cmd = ""
	OPEN "pitchingstats.sh" FOR BINARY AS #f3%
	tmp1$ = "###  ": tmp2$ = "##.###  "
	tmpLine$ = "#!/bin/sh" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = " " + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "zenity --list \" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "       --title=" + CHR$(34) + teamName + " Pitching Stats" + CHR$(34) + " \" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "       --text="+ CHR$(34) + "Check all players you wish to update below:" + CHR$(34) +  "\" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = "       --width=1350 --height=500 --checklist \" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = 	"      --ok-label=Update --extra-button=Report --extra-button=HELP --extra-button=QUIT \" + CHR$(10)
	PUT #f3%, , tmpLine$
	tmpLine$ = " --column=" + CHR$(34) + "S" + CHR$(34) + " --column=" + CHR$(34) + "PLAYER" + CHR$(34) + _ 
			   " --column=" + CHR$(34) + "W" + CHR$(34) + " --column=" + CHR$(34) + "L" + CHR$(34) + _
			   " --column=" + CHR$(34) + "SV" + CHR$(34) + " --column=" + CHR$(34) + "SVO" + CHR$(34) + _
			   " --column=" + CHR$(34) + "GP" + CHR$(34) + " --column=" + CHR$(34) + "GS" + CHR$(34) + _
			   " --column=" + CHR$(34) + "GC" + CHR$(34) + " --column=" + CHR$(34) + "IP" + CHR$(34) + _
			   " --column=" + CHR$(34) + "TBF" + CHR$(34) + " --column=" + CHR$(34) + "H" + CHR$(34) + _
			   " --column=" + CHR$(34) + "BB" + CHR$(34) + " --column=" + CHR$(34) + "K" + CHR$(34) + _
			   " --column=" + CHR$(34) + "RA" + CHR$(34) + " --column=" + CHR$(34) + "ER" + CHR$(34) + _
			   " --column=" + CHR$(34) + "HR" + CHR$(34) + " --column=" + CHR$(34) + "HBP" + CHR$(34) + _
			   " --column=" + CHR$(34) + "SF" + CHR$(34) + " --column=" + CHR$(34) + "ERA" + CHR$(34) + _
			   " --column=" + CHR$(34) + "OPP-AVG" + CHR$(34) + " --column=" + CHR$(34) + "WHIP" + CHR$(34) + _
			   " --column=" + CHR$(34) + "BABIP" + CHR$(34) + " --column=" + CHR$(34) + "FIP" + CHR$(34) + " \" + CHR$(10)
	PUT #f3%, , tmpLine$
	PRINT #flog%, "Pitching: " + teamName
	PRINT #flog%, ""
	PRINT #flog%, "Player Name       W    L    SV  SVO   GP   GS   GC    IP   TBF   H    BB   K    RA   ER   HR  HBP   SF   ERA     AVG     WHIP   BABIP   FIP "
	PRINT #flog%, "---------------- ---  ---  ---  ---  ---  ---  ---  -----  ---  ---  ---  ---  ---  ---  ---  ---  ---  -----   -----   -----   -----  -----"

' *** Because Zenity interprets the MINUS sign as the start of an option tag,
' *** all numbers must be enclosed in a single quote '' and a space placed 
' *** in front of each so negative numbers display properly. 
' *** (FIP can be a negative number)
	FOR x = 1 TO nbrRows
		playerName = Answer(x, 1)
        tmpLine$ = CHR$(34) + "" + CHR$(34) + CHR$(9) + CHR$(34) + playerName + CHR$(34)
        PRINT #flog%, USING "\               \"; playerName,
        FOR y = 2 TO nbrCols
        	nbr = VAL(Answer(x, y))
        	IF nbr < 0 THEN nbr = 0.000: (Answer(x, y)) = "0.00"
			tmpLine$ = tmpLine$ + CHR$(9) + (Answer(x, y))
			IF y = PITCH.IP THEN
				PRINT #flog%, USING "###.#  "; nbr,
			ELSE
				IF y = PITCH.ERA OR y = PITCH.FIP THEN
					PRINT #flog%, USING "##.##  "; nbr,
				ELSE
					IF y < PITCH.ERA THEN
						PRINT #flog%, USING tmp1$; nbr,
					ELSE
						PRINT #flog%, USING tmp2$; nbr,
					END IF								
				END IF			
            END IF
        NEXT y
        tmpLine$ = tmpLine$ + " \" + CHR$(10)
        PUT #f3%, , tmpLine$
        PRINT #flog%, ""
	NEXT x
        
	CLOSE #f3%
	SHELL ("chmod +x pitchingstats.sh")
	cmd = "./pitchingstats.sh"
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
              " --filename=" + "help/pitchingDisplayStats.html" + " 2> /dev/null"
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
		PRINT #flog%, "": PRINT #flog%, "*** " + ProgramName$ + " - Terminated Normally ***"
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

' *** Read pitching Stats file into Answer Array, replace "\N" with 0.000
	getpitchingStatsFile


' *** Create the report file and send it to the printer,
' *** otherwise, clear the terminal/console and display the report.
    tmp1$ = "###  ": tmp2$ = "##.### "
    IF PrintReport THEN
		ReportFile$ = teamName + "pitchingstats.prn"
		IF _FILEEXISTS(ReportFile$) THEN KILL ReportFile$
		f4% = FREEFILE
		cmd = ""
		OPEN ReportFile$ FOR OUTPUT AS #f4%
		PRINT #f4%, "": PRINT #f4%, ""
		PRINT #f4%, "Pitching: " + teamName
		PRINT #f4%, ""
		PRINT #f4%, "Player Name       W    L    SV  SVO   GP   GS   GC    IP   TBF   H    BB   K    RA   ER   HR  HBP   SF   ERA     AVG    WHIP  BABIP  FIP "
		PRINT #f4%, "---------------- ---  ---  ---  ---  ---  ---  ---  -----  ---  ---  ---  ---  ---  ---  ---  ---  ---  -----   -----  -----  ----- -----"
		FOR x = 1 TO nbrRows
			playerName = Answer(x, 1)
			PRINT #f4%, USING "\               \"; playerName,        
			FOR y = 2 TO nbrCols
				nbr = VAL(Answer(x, y))
				IF nbr < 0 THEN nbr = 0.000
				IF y = PITCH.IP THEN
					PRINT #f4%, USING "###.#  "; nbr,
				ELSE
					IF y = PITCH.ERA OR y = PITCH.FIP THEN
						PRINT #f4%, USING "##.##  "; nbr,
					ELSE
						IF y < PITCH.ERA THEN
							PRINT #f4%, USING tmp1$; nbr,
						ELSE
							PRINT #f4%, USING tmp2$; nbr,
						END IF								
					END IF			
				END IF
			NEXT y
			PRINT #f4%, ""
		NEXT x   
		CLOSE #f4%
		cmd = "enscript -B -r -fCourier8 " + ReportFile$
		SHELL (cmd)
	ELSE
		CLS , BGColor
		COLOR FGColor, BGColor
		_TITLE teamName + " Pitching Statistics"
		_SCREENSHOW
		PRINT: PRINT "  Pitching: " + teamName
		PRINT
		PRINT "  Player Name       W    L    SV  SVO   GP   GS   GC    IP   TBF   H    BB   K    RA   ER   HR  HBP   SF   ERA     AVG    WHIP  BABIP  FIP "
		PRINT "  ---------------- ---  ---  ---  ---  ---  ---  ---  -----  ---  ---  ---  ---  ---  ---  ---  ---  ---  -----   -----  -----  ----- -----"
		FOR x = 1 TO nbrRows
			playerName = Answer(x, 1)
			PRINT USING "  \               \"; playerName,
			FOR y = 2 TO nbrCols
				nbr = VAL(Answer(x, y))
				IF nbr < 0 THEN nbr = 0.000
				IF y = PITCH.IP THEN
					PRINT USING "###.#  "; nbr,
				ELSE
					IF y < PITCH.ERA THEN
						PRINT USING tmp1$; nbr,
					ELSE
						IF y = PITCH.ERA OR y = PITCH.FIP THEN
							PRINT USING "##.##  "; nbr,
						ELSE
							PRINT USING tmp2$; nbr,
						END IF
					END IF
				END IF
			NEXT y
			PRINT ""
		NEXT x	
		FOR x = 1 to (26 - nbrRows): PRINT: NEXT x
		PRINT "  Press any key to continue ..."
		SLEEP
		CLS , BGColor
		_SCREENHIDE
	END IF

END SUB


SUB getpitchingStatsFile
'-----------------------------------------------------------------------------
' *** Loads and formats the Team pitching File created from a SQL View 
'
	IF _FILEEXISTS(pitchingfile$) THEN
		rows = 1: Delim$ = CHR$(9)
		touts = 3 * innings       
		f2% = FREEFILE
		OPEN pitchingfile$ FOR INPUT AS #f2%
		DO UNTIL EOF(f2%)
			LINE INPUT #f2%, qString$
			retcode = StrSplit$(qString$, Delim$)
			FOR cols = 1 TO nbrCols
				IF Query(cols) = "\N" THEN 
					IF cols = PITCH.ERA THEN Query(cols) = "0.00" ELSE Query(cols) = "0.000"
				END IF		
				IF cols = PITCH.IP THEN
					outs = VAL(Query(PITCH.IP))
					adjip = convertIP (outs)
					Query(PITCH.IP) = format$(STR$(adjip), "###.#")
					Answer(rows, PITCH.IP) = Query(PITCH.IP)					
				ELSE
					Answer(rows, cols) = Query(cols)
				END IF
			NEXT cols
			rows = rows + 1
		LOOP
		CLOSE #f2%
	ELSE
		SHELL ("zenity --error --text=" + CHR$(34) + ProgramName$ + " Program failed - missing Team pitching File. Program Terminated" + CHR$(34) + " --width=175 --height=100")
		PRINT #flog%, ">>>>> Executing endPROG"
		PRINT #flog%, ""
		PRINT #flog%, "": PRINT #flog%, "*** " + ProgramName$ + " - Terminated Abnormally ***"
		CLOSE #flog%
		SYSTEM 1
	END IF
	
END SUB


FUNCTION convertIP (outs)
'-----------------------------------------------------------------------------
' *** Convert OUTS to IP
'
    DIM AS INTEGER whole, fraction
    whole = floor(outs / 3)
    fraction = INT(((outs / 3) - whole) * 10 + .5)
    IF fraction >= 3 THEN
        part = fraction / 3
    END IF
    adjip = whole + (part * .1)
    convertIP = adjip
    
END FUNCTION


FUNCTION convertOUTS (ip)
'-----------------------------------------------------------------------------
' *** Convert IP to Total Outs
'
    DIM AS INTEGER whole, fraction
    whole = INT(ip)
    part = ceil((ip - whole) * 10)
    adjouts = (whole * 3) + part
    convertOUTS = adjouts
    
END FUNCTION 


'$INCLUDE: 'include/baseballAboutDisplay.inc'

'$INCLUDE: 'include/baseballDisplayHelpMenu.inc'

'$INCLUDE: 'include/baseballConfig.inc'

'$INCLUDE: 'include/stringFunctions.inc'

'$INCLUDE: 'include/baseballFunctions.inc'

'$INCLUDE: 'include/pipecom.inc'

