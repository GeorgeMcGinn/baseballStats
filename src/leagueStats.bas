REM $TITLE: leagueStats.bas Version 0.18  09/28/2021 - Last Update: 12/07/2021
_TITLE "leagueStats.bas"
' leagueStats.bas    Version 1.0  09/28/2021
'-------------------------------------------------------------------------------------
'       PROGRAM: leagueStats.bas
'        AUTHOR: George McGinn
'                <gjmcginn@icloud.com>
'
'  DATE WRITTEN: 09/28/2021
'       VERSION: 1.0
'       PROJECT: Baseball/Softball Statistics System
'
'   DESCRIPTION: Main program that controls the processing of the
'                leauge and team statistics in the Baseball/Softball
'                Statistics System.
'
' Written by George McGinn
' Copyright (C)2021 by George McGinn - All Rights Reserved.
' Version 1.0 - Created 09/28/2021
'
'
' CHANGE LOG
'-------------------------------------------------------------------------------------
' 09/28/21 v1.00 GJM - New Program.
' 09/30/21 v0.10 GJM - Updated pipecom based on a change by Zach.
' 10/01/21 v0.11 GJM - Added config file processing and passing ARG values
'                      to this module when called from baseballStats.
' 10/02/21 v0.12 GJM - Added config file value for mysqlTable$ and updates to process
'                      changes to the config file.
' 10/06/21 v0.13 GJM - Updated program to new directory structure & file names
' 10/10/21 v0.14 GJM - There is an issue with SQL calculating ERA and correctly displaying
'                      innings pitched. Added a function to correct the display of IP
'                      and to calculate ERA correctly. Also added index CONSTANTS so
'                      code is easier to read and work with, especially if new columns
'                      are added. Changes to CONST values instead of code changes.
'                      Also added the format$ to stringFunctions.inc so I can format
'                      variables properly in arrays used by Zenity for displaying.
' 10/14/21 v0.15 GJM - Added the leagueStats files to the deleteWorkFiles include and
'                      tested it (Note: all programs recompiled and tested).
' 10/15/21 v0.16 GJM - Corrected the ERA and IP logic to convert outs pitched now stored
'                      in SQL tables to display correctly. SQL now calculates ERA.
' 11/21/21 v0.17 GJM - Add the output mySQL directory to the config.ini file
' 12/07/21 v0.18 GJM - Added the HELP Screen to this module & updated CC licensing
'-------------------------------------------------------------------------------------
'  Copyright (C)2021 by George McGinn.  All Rights Reserved.
'
' leagueStats by George McGinn is licensed under a Creative Commons
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

DECLARE LIBRARY
    FUNCTION floor## (BYVAL num AS _FLOAT)
END DECLARE

ON ERROR GOTO ehandler

'-------------------------------------------------------------------------------------
' *** Initialize Section
'


'$INCLUDE: 'include/baseballInit.inc'
PrintReport = FALSE ' *** Set to TRUE to print to printer, FALSE for testing (display output)
setLeague = TRUE

'----------------------------------------------------
' *** Determine/set OSType
'
IF INSTR(_OS$, "LINUX") THEN OStype = "LINUX"
IF OStype <> "LINUX" THEN
    PRINT #flog%, "*** ERROR: Program runs in Linux only. Program Terminated. ***": PRINT #flog%, ""
    GOTO endPROG
END IF


'----------------------------------------------------------------------------
' *** Process args passed to program (if found) - Split out Value Pairs
'

'$INCLUDE: 'include/baseballProcessArgs.inc'

IF cntargs = 0 THEN
    result = SystemsCheck
    IF result = FALSE THEN GOTO endPROG
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
    mysqlCMD$ = "mysql -u" + mysql_userid$ + " -p" + mysql_password$ + " " + mysqlDB$ + " -s -e "
    nbrRows = 0: nbrCols = 0

ProcessSQLFile:
    PRINT #flog%, ">>>>> Executing ProcessSQLFile"
    PRINT #flog%, ""
    
' *** Create SQL views and batting stats file
    CreateSQLViews

ProcessResults:


DisplayLeagueStandings:
' *** Show League Standings/Results
    DisplayLeagueResults
    lenstr = LEN(stdout)
    stdbutton = LEFT$(stdout, lenstr - 1)
    IF stdbutton = "HELP" THEN 
		cmd = "zenity --text-info " + _
              " --title=" + CHR$(34) + "HELP: Baseball/Softball Statistics System - v1.0" + CHR$(34) + _
              " --width=1000 --height=850 --html --ok-label=" + CHR$(34) + "Return to Menu" + CHR$(34) +  _
              " --filename=" + "help/baseballLeague.html" + " 2> /dev/null"
        SHELL (cmd)
        GOTO DisplayLeagueStandings
    END IF
    IF stdbutton = "Report" THEN PrintLeagueStats
    IF stdbutton = "QUIT" THEN GOTO endPROG

DisplayLeagueBatting:    
' *** Show Team Batting Results
    DisplayTeamBattingResults
    lenstr = LEN(stdout)
    stdbutton = LEFT$(stdout, lenstr - 1)
    IF stdbutton = "HELP" THEN 
		cmd = "zenity --text-info " + _
              " --title=" + CHR$(34) + "HELP: Baseball/Softball Statistics System - v1.0" + CHR$(34) + _
              " --width=1000 --height=850 --html --ok-label=" + CHR$(34) + "Return to Menu" + CHR$(34) +  _
              " --filename=" + "help/baseballLeague.html" + " 2> /dev/null"
        SHELL (cmd)
        GOTO DisplayLeagueBatting
    END IF
    IF stdbutton = "Report" THEN PrintTeamBattingStats
    IF stdbutton = "QUIT" THEN GOTO endPROG

DisplayLeaguePitching:    
' *** Show Team Pitching Results
    DisplayTeamPitchingResults
    lenstr = LEN(stdout)
    stdbutton = LEFT$(stdout, lenstr - 1)
    IF stdbutton = "HELP" THEN 
		cmd = "zenity --text-info " + _
              " --title=" + CHR$(34) + "HELP: Baseball/Softball Statistics System - v1.0" + CHR$(34) + _
              " --width=1000 --height=850 --html --ok-label=" + CHR$(34) + "Return to Menu" + CHR$(34) +  _
              " --filename=" + "help/baseballLeague.html" + " 2> /dev/null"
        SHELL (cmd)
        GOTO DisplayLeaguePitching
    END IF
    IF stdbutton = "Report" THEN PrintTeamPitchingStats
    IF stdbutton = "QUIT" THEN GOTO endPROG
    GOTO ProcessResults

endPROG:
' *** CLOSE Log File
'

' *** Process end of program based on how it was called
    IF cntargs = 0 THEN
        PRINT #flog%, ">>>>> Executing endPROG"
        PRINT #flog%, ""
        PRINT #flog%, "": PRINT #flog%, "*** leagueStats - Terminated Normally ***"
        CLOSE #flog%
    ELSE
        PRINT #flog%, ">>>>> Executing (leagueStats) endPROG"
        PRINT #flog%, ""
        PRINT #flog%, "": PRINT #flog%, "*** leagueStats - Terminated Normally - Return to calling Program ***"
        CLOSE #flog%
    END IF

' *** Remove work files if they exist
'$INCLUDE: 'include/deleteWorkFiles.inc'

    SYSTEM


ehandler:
    '$INCLUDE: 'include/baseballErrhandler.inc'


'--------------------------------------------------------------------------------------
' *** SQL Functions
'

'$INCLUDE: 'include/basebalRowsColsSQL.inc'


'
' *** End SQL Functions
'-----------------------------------------------------------------------------


SUB CreateSQLViews
    PRINT #flog%, ">>>>> Executing CreateSQLView"
    PRINT #flog%, ""
    
' *** Delete the league/team stats file from mysql-files
    leaguefile$ = mysql_outputdir$ + "leaguestats.file"
    IF _FILEEXISTS(leaguefile$) THEN
        cmd = "echo y | rm " + leaguefile$
        SHELL (cmd)
    END IF
    battingfile$ = mysql_outputdir$ + "teambattingstats.file"
    IF _FILEEXISTS(battingfile$) THEN
        cmd = "echo y | rm " + battingfile$
        SHELL (cmd)
    END IF
    pitchingfile$ = mysql_outputdir$ + "teampitchingstats.file"
    IF _FILEEXISTS(pitchingfile$) THEN
        cmd = "echo y | rm " + pitchingfile$
        SHELL (cmd)
    END IF

' *** Load the SQL statements from a file (first record is number of lines in file)
' *** and into an array for processing and execution. nbrLines is used to hold the
' *** the actual number of elements in the array. If you use the check for NULL
' *** lines, then any loop will hold the actual number of elements in the array.
    sqlstmtfile$ = "sql/leaguesqlstmt.sqlproc"

    '$INCLUDE: 'include/baseballSQLstmt.inc'


END SUB


SUB DisplayLeagueResults

' *** Determine the number of Rows and columns, then resize arrays
    mysqlView$ = "leagueView"
    nbrRows = sql_rows
    nbrCols = sql_columns
    REDIM Query(nbrCols)
    REDIM Answer(nbrRows + 1, nbrCols)

' *** Read League Stats file into Answer Array, replace "\N" with 0.000
    getleagueStatsFile
    
' *** Print the box scores from the SQL View File (Zenity or Terminal, Log File)
    IF _FILEEXISTS("leaguestats.sh") THEN KILL "leaguestats.sh"
    f3% = FREEFILE
    cmd = ""
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
    tmpLine$ = "       --width=530 --height=500 \" + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = "       --ok-label=NEXT --extra-button=Report --extra-button=HELP --extra-button=QUIT \" + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = " --column=" + CHR$(34) + "TEAM" + CHR$(34) + _ 
               " --column=" + CHR$(34) + "W" + CHR$(34) + " --column=" + CHR$(34) + "L" + CHR$(34) + _
               " --column=" + CHR$(34) + "ERA" + CHR$(34) + " --column=" + CHR$(34) + "BAVG" + CHR$(34) + _
               " --column=" + CHR$(34) + "SLUG" + CHR$(34) + " --column=" + CHR$(34) + "FPCT" + CHR$(34) + _
               " --column=" + CHR$(34) + "WPCT" + CHR$(34) + " \" + CHR$(10)
    PUT #f3%, , tmpLine$
    PRINT #flog%, "League Standings: "
    PRINT #flog%, ""
    PRINT #flog%, "Team              W    L    ERA   BAVG   SLUG   FPCT   WPCT"
    PRINT #flog%, "---------------- ---  ---  -----  -----  -----  -----  -----"

    FOR x = 1 TO nbrRows
        teamName = Answer(x, 1)
        tmpLine$ = CHR$(34) + teamName + CHR$(34)
        PRINT #flog%, USING "\               \"; teamName,
        FOR y = 2 TO nbrCols
            nbr = VAL(Answer(x, y))
            tmpLine$ = tmpLine$ + CHR$(9) + Answer(x, y)
            IF y < (LEAGUE.ERA - LEAGUE.BYPASS) THEN
                PRINT #flog%, USING tmp1$; nbr,
            ELSE
                IF y = (LEAGUE.ERA - LEAGUE.BYPASS) THEN
                    PRINT #flog%, USING "##.##  "; nbr,
                ELSE
                    PRINT #flog%, USING tmp2$; nbr,
                END IF
            END IF
        NEXT y
        tmpLine$ = tmpLine$ + " \" + CHR$(10): PRINT #flog%, ""
        PUT #f3%, , tmpLine$
    NEXT x
        
    CLOSE #f3%
    SHELL ("chmod +x leaguestats.sh")
    cmd = "./leaguestats.sh"
    result = pipecom(cmd, stdout, stderr)
    PRINT #flog%, ""
    PRINT #flog%, "stdout = "; stdout
    PRINT #flog%, "stderr = "; stderr
    PRINT #flog%, "result = "; result
    PRINT #flog%, ""
    
    
END SUB


SUB DisplayTeamBattingResults

' *** Determine the number of Rows and columns, then resize arrays
    mysqlView$ = "teambattingView"
    nbrRows = sql_rows
    nbrCols = sql_columns
    REDIM Query(nbrCols)
    REDIM Answer(nbrRows + 1, nbrCols)

' *** Read Batting Stats file into Answer Array, replace "\N" with 0.000
    getBattingStatsFile
    
' *** Print the box scores from the SQL View File (Zenity or Terminal, Log File)
    IF _FILEEXISTS("teambattingstats.sh") THEN KILL "teambattingstats.sh"
    f3% = FREEFILE
    cmd = ""
    OPEN "teambattingstats.sh" FOR BINARY AS #f3%
    tmp1$ = "#,### ": tmp2$ = "#.###  "
    tmpLine$ = "#!/bin/sh" + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = " " + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = "zenity --list \" + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = "       --title=" + CHR$(34) + "Team Batting Stats" + CHR$(34) + " \" + CHR$(10)
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
    PRINT #flog%, "Batting Stats by Team"
    PRINT #flog%, ""
    PRINT #flog%, "Team              AB   R    H   RBI   2B   3B   HR   BB   K   HBP  SAC   SB  ASB   PO  AST   E    AVG    SLUG   OBP    OPS    FPCT"
    PRINT #flog%, "---------------- ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  -----  -----  -----  -----  -----"

    FOR x = 1 TO nbrRows
        teamName = Answer(x, 1)
        tmpLine$ = CHR$(34) + teamName + CHR$(34)
        PRINT #flog%, USING "\               \"; teamName,
        FOR y = 2 TO nbrCols
            nbr = VAL(Answer(x, y))
            tmpLine$ = tmpLine$ + CHR$(9) + Answer(x, y)
            IF y < 18 THEN
                PRINT #flog%, USING tmp1$; nbr,
            ELSE
                PRINT #flog%, USING tmp2$; nbr,
            END IF
        NEXT y
        tmpLine$ = tmpLine$ + " \" + CHR$(10): PRINT #flog%, ""
        PUT #f3%, , tmpLine$
    NEXT x
        
    CLOSE #f3%
    SHELL ("chmod +x teambattingstats.sh")
    cmd = "./teambattingstats.sh"
    result = pipecom(cmd, stdout, stderr)
    PRINT #flog%, ""
    PRINT #flog%, "stdout = "; stdout
    PRINT #flog%, "stderr = "; stderr
    PRINT #flog%, "result = "; result
    PRINT #flog%, ""
    
END SUB


SUB DisplayTeamPitchingResults

' *** Determine the number of Rows and columns, then resize arrays
    mysqlView$ = "teampitchingView"
    nbrRows = sql_rows
    nbrCols = sql_columns
    REDIM Query(nbrCols)
    REDIM Answer(nbrRows + 1, nbrCols)

' *** Read Pitching Stats file into Answer Array, replace "\N" with 0.000
    getpitchingStatsFile
    
' *** Print the box scores from the SQL View File (Zenity or Terminal, Log File)
    IF _FILEEXISTS("teampitchingstats.sh") THEN KILL "teampitchingstats.sh"
    f3% = FREEFILE
    cmd = ""
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
    tmpLine$ = "       --width=1350 --height=500 \" + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = "       --ok-label=BACK --extra-button=Report --extra-button=HELP --extra-button=QUIT \" + CHR$(10)
    PUT #f3%, , tmpLine$
    tmpLine$ = " --column=" + CHR$(34) + "TEAM" + CHR$(34) + _ 
               " --column=" + CHR$(34) + "W" + CHR$(34) + " --column=" + CHR$(34) + "L" + CHR$(34) + _
               " --column=" + CHR$(34) + "SV" + CHR$(34) + " --column=" + CHR$(34) + "SVO" + CHR$(34) + _
               " --column=" + CHR$(34) + "GP" + CHR$(34) +  _
               " --column=" + CHR$(34) + "GC" + CHR$(34) + " --column=" + CHR$(34) + "IP" + CHR$(34) + _
               " --column=" + CHR$(34) + "TBF" + CHR$(34) + " --column=" + CHR$(34) + "H" + CHR$(34) + _
               " --column=" + CHR$(34) + "BB" + CHR$(34) + " --column=" + CHR$(34) + "K" + CHR$(34) + _
               " --column=" + CHR$(34) + "RA" + CHR$(34) + " --column=" + CHR$(34) + "ER" + CHR$(34) + _
               " --column=" + CHR$(34) + "HR" + CHR$(34) + " --column=" + CHR$(34) + "HBP" + CHR$(34) + _
               " --column=" + CHR$(34) + "SF" + CHR$(34) + " --column=" + CHR$(34) + "ERA" + CHR$(34) + _
               " --column=" + CHR$(34) + "OP-AVG" + CHR$(34) + " --column=" + CHR$(34) + "WHIP" + CHR$(34) + _
               " --column=" + CHR$(34) + "BABIP" + CHR$(34) + " --column=" + CHR$(34) + "FIP" + CHR$(34) + " \" + CHR$(10)
    PUT #f3%, , tmpLine$
    PRINT #flog%, "Team Pitching Stats"
    PRINT #flog%, ""
    PRINT #flog%, "Team              W    L    SV  SVO   GP   GC    IP   TBP   H    BB   K    RA   ER   HR  HBP   SF   ERA   OP-AVG    WHIP   BABIP   FIP "
    PRINT #flog%, "---------------- ---  ---  ---  ---  ---  ---  -----  ---  ---  ---  ---  ---  ---  ---  ---  ---  -----  ------   -----   -----  -----"

' *** Because Zenity interprets the MINUS sign as the start of an option tag,
' *** all numbers must be enclosed in a single quote '' and a space placed
' *** in front of each so negative numbers display properly.
' *** (FIP can be a negative number)
    FOR x = 1 TO nbrRows
        teamName = Answer(x, 1)
        tmpLine$ = CHR$(34) + teamName + CHR$(34)
        PRINT #flog%, USING "\               \"; teamName,
        FOR y = 2 TO nbrCols
            nbr = VAL(Answer(x, y))
            IF nbr < 0 THEN nbr = 0.000: (Answer(x, y)) = "0.00"
            tmpLine$ = tmpLine$ + CHR$(9) + (Answer(x, y))
            IF y = LPITCH.IP THEN
                PRINT #flog%, USING "###.#  "; nbr,
            ELSE
                IF y = LPITCH.ERA OR y = LPITCH.FIP THEN
                    PRINT #flog%, USING "##.##  "; nbr,
                ELSE
                    IF y < LPITCH.ERA THEN
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
    SHELL ("chmod +x teampitchingstats.sh")
    cmd = "./teampitchingstats.sh"
    result = pipecom(cmd, stdout, stderr)
    PRINT #flog%, ""
    PRINT #flog%, "stdout = "; stdout
    PRINT #flog%, "stderr = "; stderr
    PRINT #flog%, "result = "; result
    PRINT #flog%, ""
    
END SUB


SUB getleagueStatsFile
'-----------------------------------------------------------------------------
' *** Loads and formats the League Stats File created from a SQL View
'
    IF _FILEEXISTS(leaguefile$) THEN
        rows = 1: Delim$ = CHR$(9)
        touts = 3 * innings
        f2% = FREEFILE
        OPEN leaguefile$ FOR INPUT AS #f2%
        DO UNTIL EOF(f2%)
            LINE INPUT #f2%, qString$
            retcode = StrSplit$(qString$, Delim$)
            cols = 0
            FOR ix1 = 1 TO nbrCols
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
    ELSE
        SHELL ("zenity --error --text=" + CHR$(34) + "leagueStats Program failed - missing League Stats File. Program Terminated" + CHR$(34) + " --width=175 --height=100")
        PRINT #flog%, ">>>>> Executing endPROG"
        PRINT #flog%, ""
        PRINT #flog%, "": PRINT #flog%, "*** leagueStats - Terminated Abnormally ***"
        CLOSE #flog%
        SYSTEM 1
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
        SHELL ("zenity --error --text=" + CHR$(34) + "leagueStats Program failed - missing Team Batting File. Program Terminated" + CHR$(34) + " --width=175 --height=100")
        PRINT #flog%, ">>>>> Executing endPROG"
        PRINT #flog%, ""
        PRINT #flog%, "": PRINT #flog%, "*** leagueStats - Terminated Abnormally ***"
        CLOSE #flog%
        SYSTEM 1
    END IF
    
END SUB

SUB getpitchingStatsFile
'-----------------------------------------------------------------------------
' *** Loads and formats the Team pitching File created from a SQL View
'
    IF _FILEEXISTS(pitchingfile$) THEN
        rows = 1: Delim$ = CHR$(9): outs = 0
        f2% = FREEFILE
        OPEN pitchingfile$ FOR INPUT AS #f2%
        DO UNTIL EOF(f2%)
            LINE INPUT #f2%, qString$
            retcode = StrSplit$(qString$, Delim$)
            FOR cols = 1 TO nbrCols
                IF Query(cols) = "\N" THEN
                    IF cols = LPITCH.ERA THEN Query(cols) = "0.00" ELSE Query(cols) = "0.000"
                END IF
				IF cols = LPITCH.IP THEN
					outs = VAL(Query(cols))
					adjip = adjustIP (outs)
					Query(LPITCH.IP) = format$(STR$(adjip), "#,###.#")
					Answer(rows, cols) = Query(LPITCH.IP)
               ELSE
                    Answer(rows, cols) = Query(cols)
               END IF
            NEXT cols
            rows = rows + 1
        LOOP
        CLOSE #f2%
    ELSE
        SHELL ("zenity --error --text=" + CHR$(34) + "pitchingStats Program failed - missing Team Pitching File. Program Terminated" + CHR$(34) + " --width=175 --height=100")
        PRINT #flog%, ">>>>> Executing endPROG"
        PRINT #flog%, ""
        PRINT #flog%, "": PRINT #flog%, "*** pitchingStats - Terminated Abnormally ***"
        CLOSE #flog%
        SYSTEM 1
    END IF
    
END SUB


SUB PrintLeagueStats
'-----------------------------------------------------------------------------
' *** Produce the League Stats report
'

    PRINT #flog%, ">>>>> Executing PrintLeagueStats"
    PRINT #flog%, ""

' *** Determine the number of Rows and columns, then resize arrays
    mysqlView$ = "leagueView"
    nbrRows = sql_rows
    nbrCols = sql_columns
    REDIM Query(nbrCols)
    REDIM Answer(nbrRows + 1, nbrCols)

' *** Read Batting Stats file into Answer Array, replace "\N" with 0.000
    getleagueStatsFile

' *** Create the report file and send it to the printer,
' *** otherwise, clear the terminal/console and display the report.
    tmp1$ = "###  ": tmp2$ = "#.###  "
    IF PrintReport THEN
        ReportFile$ = "leaguestats.prn"
        IF _FILEEXISTS(ReportFile$) THEN KILL ReportFile$
        f4% = FREEFILE
        cmd = ""
        OPEN ReportFile$ FOR OUTPUT AS #f4%
        PRINT #f4%, "": PRINT #f4%, ""
        PRINT #f4%, "League Standings: "
        PRINT #f4%, ""
        PRINT #f4%, "Team              W    L    ERA   BAVG   SLUG   FPCT   WPCT"
        PRINT #f4%, "---------------- ---  ---  -----  -----  -----  -----  -----"
        FOR x = 1 TO nbrRows
            teamName = Answer(x, 1)
            PRINT #f4%, USING "\               \"; teamName,
            FOR y = 2 TO nbrCols
                nbr = VAL(Answer(x, y))
                IF y < (LEAGUE.ERA - LEAGUE.BYPASS) THEN
                    PRINT #f4%, USING tmp1$; nbr,
                ELSE
                    IF y = (LEAGUE.ERA - LEAGUE.BYPASS) THEN
                        PRINT #f4%, USING "##.##  "; nbr,
                    ELSE
                        PRINT #f4%, USING tmp2$; nbr,
                    END IF
                END IF
            NEXT y
            PRINT #f4%, ""
        NEXT x
        CLOSE #f4%
        cmd = "enscript -B " + ReportFile$
        SHELL (cmd)
    ELSE
        CLS
        PRINT "League Standings: "
        PRINT ""
        PRINT "Team              W    L    ERA   BAVG   SLUG   FPCT   WPCT"
        PRINT "---------------- ---  ---  -----  -----  -----  -----  -----"
        FOR x = 1 TO nbrRows
            cols = 0
            teamName = Answer(x, 1)
            PRINT USING "\               \"; teamName,
            FOR y = 2 TO nbrCols
                nbr = VAL(Answer(x, cols))
                IF y < (LEAGUE.ERA - LEAGUE.BYPASS) THEN
                    PRINT USING tmp1$; nbr,
                ELSE
                    IF y = (LEAGUE.ERA - LEAGUE.BYPASS) THEN
                        PRINT USING "##.##  "; nbr,
                    ELSE
                        PRINT USING tmp2$; nbr,
                    END IF
                END IF
            NEXT y
            PRINT ""
        NEXT x
    END IF

END SUB


SUB PrintTeamBattingStats
'-----------------------------------------------------------------------------
' *** Produce the Team Batting Stats report
'

' *** Determine the number of Rows and columns, then resize arrays
    mysqlView$ = "teambattingView"
    nbrRows = sql_rows
    nbrCols = sql_columns
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
        cmd = ""
        OPEN ReportFile$ FOR OUTPUT AS #f4%
        PRINT #f4%, "Batting Stats by Team"
        PRINT #f4%, ""
        PRINT #f4%, "Team              AB   R    H   RBI   2B   3B   HR   BB   K   HBP  SAC   SB  ASB   PO  AST   E    AVG    SLUG   OBP    OPS    FPCT"
        PRINT #f4%, "---------------- ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  -----  -----  -----  -----  -----"
        FOR x = 1 TO nbrRows
            teamName = Answer(x, 1)
            PRINT #f4%, USING "\               \"; teamName,
            FOR y = 2 TO nbrCols
                nbr = VAL(Answer(x, y))
                IF y < 18 THEN
                    PRINT #f4%, USING tmp1$; nbr,
                ELSE
                    PRINT #f4%, USING tmp2$; nbr,
                END IF
            NEXT y
            PRINT #f4%, ""
        NEXT x
        CLOSE #f4%
        cmd = "enscript -B -r -fCourier8 " + ReportFile$
        SHELL (cmd)
    ELSE
        CLS
        PRINT "Batting Stats by Team"
        PRINT ""
        PRINT "Team              AB   R    H   RBI   2B   3B   HR   BB   K   HBP  SAC   SB  ASB   PO  AST   E    AVG    SLUG   OBP    OPS    FPCT"
        PRINT "---------------- ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  ---  -----  -----  -----  -----  -----"
        FOR x = 1 TO nbrRows
            teamName = Answer(x, 1)
            PRINT USING "\               \"; teamName,
            FOR y = 2 TO nbrCols
                nbr = VAL(Answer(x, y))
                IF y < 18 THEN
                    PRINT USING tmp1$; nbr,
                ELSE
                    PRINT USING tmp2$; nbr,
                END IF
            NEXT y
            PRINT ""
        NEXT x
    END IF


END SUB


SUB PrintTeamPitchingStats
'-----------------------------------------------------------------------------
' *** Produce the Team Pitching Stats report
'

' *** Determine the number of Rows and columns, then resize arrays
    mysqlView$ = "teambattingView"
    nbrRows = sql_rows
    nbrCols = sql_columns
    REDIM Query(nbrCols)
    REDIM Answer(nbrRows + 1, nbrCols)

' *** Read Pitching Stats file into Answer Array, replace "\N" with 0.000
    getpitchingStatsFile
    
' *** Create the report file and send it to the printer,
' *** otherwise, clear the terminal/console and display the report.
    tmp1$ = "###  ": tmp2$ = "#.###  "
    IF PrintReport THEN
        ReportFile$ = "teampitchingstats.prn"
        IF _FILEEXISTS(ReportFile$) THEN KILL ReportFile$
        f4% = FREEFILE
        cmd = ""
        OPEN ReportFile$ FOR OUTPUT AS #f4%
        PRINT #f4%, "Pitching Stats by Team "
        PRINT #f4%, ""
        PRINT #f4%, "Team              W    L    SV  SVO   GP   GC    IP   TBP   H    BB   K    RA   ER   HR  HBP   SF   ERA  OP-AVG   WHIP  BABIP   FIP "
        PRINT #f4%, "---------------- ---  ---  ---  ---  ---  ---  -----  ---  ---  ---  ---  ---  ---  ---  ---  ---  ----- ------  -----  -----  -----"
        FOR x = 1 TO nbrRows
            teamName = Answer(x, 1)
            PRINT #f4%, USING "\               \"; teamName,
            FOR y = 2 TO nbrCols
                nbr = VAL(Answer(x, y))
                IF nbr < 0 THEN nbr = 0.000: (Answer(x, y)) = "0.00"
                IF y = LPITCH.IP THEN
                    PRINT #f4%, USING "###.#  "; nbr,
                ELSE
                    IF y = LPITCH.ERA OR y = LPITCH.FIP THEN
                        PRINT #f4%, USING "##.##  "; nbr,
                    ELSE
                        IF y < LPITCH.ERA THEN
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
        CLS
        PRINT "Pitching Stats by Team "
        PRINT ""
        PRINT "Team              W    L    SV  SVO   GP   GC    IP   TBP   H    BB   K    RA   ER   HR  HBP   SF   ERA  OP-AVG   WHIP  BABIP   FIP "
        PRINT "---------------- ---  ---  ---  ---  ---  ---  -----  ---  ---  ---  ---  ---  ---  ---  ---  ---  ----- ------  -----  -----  -----"
        FOR x = 1 TO nbrRows
            teamName = Answer(x, 1)
            PRINT USING "\               \"; teamName,
            FOR y = 2 TO nbrCols
                nbr = VAL(Answer(x, y))
                IF nbr < 0 THEN nbr = 0.000: (Answer(x, y)) = "0.00"
                IF y = LPITCH.IP THEN
                    PRINT USING "###.#  "; nbr,
                ELSE
                    IF y = LPITCH.ERA OR y = LPITCH.FIP THEN
                        PRINT USING "##.##  "; nbr,
                    ELSE
                        IF y < LPITCH.ERA THEN
                            PRINT USING tmp1$; nbr,
                        ELSE
                            PRINT USING tmp2$; nbr,
                        END IF
                    END IF
                END IF
            NEXT y
            PRINT ""
        NEXT x
    END IF

END SUB


FUNCTION adjustIP (outs)
'-----------------------------------------------------------------------------
' *** Correct the display of IP 
'

    DIM AS INTEGER whole, fraction
    whole = floor(outs / 3)
    fraction = INT(((outs / 3) - whole) * 10 + .5)
    IF fraction >= 3 THEN
        part = fraction / 3
    END IF
    adjip = whole + (part * .1)
    adjustIP = adjip 
    
END FUNCTION


'$INCLUDE: 'include/baseballConfig.inc'

'$INCLUDE: 'include/stringFunctions.inc'

'$INCLUDE: 'include/baseballFunctions.inc'

'$INCLUDE: 'include/pipecom.inc'

