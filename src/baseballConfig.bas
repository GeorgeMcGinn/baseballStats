REM $TITLE: baseballConfig.bas Version 1.0  09/30/2021 - Last Update: 10/11/2021
_TITLE "baseballConfig.bas"
' baseballConfig.bas    Version 1.0  09/30/21
'-------------------------------------------------------------------------------
'       PROGRAM: baseballConfig.bas
'        AUTHOR: George McGinn
'
'                <gjmcginn@icloud.com>
'
'  DATE WRITTEN: 09/30/2021
'       VERSION: 1.0
'       PROJECT: Baseball/Softball Statistics System
'
'   DESCRIPTION: Config File processing of the
'                Baseball/Softball Statistics System.
'
' Written by George McGinn
' Copyright ©2021 by George McGinn - All Rights Reserved
' Version 1.0 - Created 09/30/2021
'
' CHANGE LOG
'-------------------------------------------------------------------------------
' 09/30/21 v1.0  GJM - New Program.
' 10/02/21 v0.11 GJM - Added batting and pitching tables to Config File.
' 10/04/21 v0.12 GJM - Added HELP menu.
' 10/05/21 v0.13 GJM - Added ProgramName$ that is determined in initialization.
' 10/06/21 v0.14 GJM - Updated program to new directory structure & file names
' 10/11/21 v0.15 GJM - Added number of innings to config file
'-------------------------------------------------------------------------------
'  Copyright ©2021 by George McGinn.  All Rights Reserved.
'
' baseballConfig.bas by George McGinn is licensed under a Creative Commons
' Attribution-NonCommercial-NoDerivatives 4.0 International. (CC BY-NC-ND 4.0)
'
' Full License Link: https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode
'
'-------------------------------------------------------------------------------------
' PROGRAM NOTES
'
'
'-------------------------------------------------------------------------------


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


QB64Main:
'-------------------------------------------------------------------------------------
' *** MAIN Logic
'

' *** OPEN Log File (_COMMANDCOUNT > 0 only when called by baseballStats module)
    IF _COMMANDCOUNT = 0 THEN
        flog% = FREEFILE
        OPEN "logs/baseballstats.log" FOR OUTPUT AS #flog%
        PRINT #flog%, "*** Baseball Stats Log File ***": PRINT #flog%, ""
    ELSE
        flog% = FREEFILE
        OPEN "logs/baseballstats.log" FOR APPEND AS #flog%
    END IF

' *** Read Config File IF EXISTS. If not, create it with default values
    Delim$ = "=": nbrUpdates = 0: idx = 1
    f1% = FREEFILE
    IF _FILEEXISTS(ConfigFile$) THEN
        OPEN ConfigFile$ FOR INPUT AS #f1%
        DO UNTIL EOF(f1%)
            LINE INPUT #f1%, qString$
            IF ISNUMERIC(qString$) THEN
                nbrUpdates = VAL(qString$)
                REDIM Query(2)
            ELSE
                IF LEFT$(qString$, 2) <> "/*" THEN
                    retcode = StrSplit$(qString$, Delim$)
                    idx = idx + 1
                    IF Query(1) = "SQLDB" THEN mysqlDB$ = Query(2)
                    IF Query(1) = "SQLUSER" THEN mysql_userid$ = Query(2)
                    IF Query(1) = "SQLPWD" THEN mysql_password$ = Query(2)
                    IF Query(1) = "SQLBATTBL" THEN mysql_battingTable$ = Query(2)
                    IF Query(1) = "SQLPITCHTBL" THEN mysql_pitchingTable$ = Query(2)
                    IF Query(1) = "INNINGS" THEN nbr_innings$ = Query(2)
                END IF
            END IF
        LOOP
        CLOSE #f1%
    ELSE
		nbrUpdates = 6
        OPEN ConfigFile$ FOR OUTPUT AS #f1%
        PRINT #f1%, "/* Baseball/Softball Config File"
        PRINT #f1%, "6"
        qString$ = "SQLDB=" + mysqlDB$
        PRINT #f1%, qString$
        qString$ = "SQLUSER=" + mysql_userid$
        PRINT #f1%, qString$
        qString$ = "SQLPWD=" + mysql_password$
        PRINT #f1%, qString$
        qString$ = "SQLBATTBL=" + mysql_battingTable$
        PRINT #f1%, qString$
        qString$ = "SQLPITCHTBL=" + mysql_pitchingTable$
        PRINT #f1%, qString$
        qString$ = "INNINGS=" + nbr_innings$
        PRINT #f1%, qString$
        CLOSE #f1%
    END IF


DisplayForm:

    PRINT #flog%, ">>>>> Executing DisplayForm"
    PRINT #flog%, ""

' *** Display the Configuration Update form with values from Config File
    IF COMMAND$(1) = "INSTALL" THEN
        cmd = "zenity --forms --title=" + CHR$(34) + "Config File - Baseball/Softball Statistics System - v1.0  " + CHR$(34) + _
              " --text=" + CHR$(34) + "Install/New Region: Enter all fields" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL DATABASE (" + mysqlDB$ + ")" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL USER (" + mysql_userid$ + ")" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL PASSWORD (" + mysql_password$ + ")" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL BATTING TABLE (" + mysql_battingTable$ + ")" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL PITCHING TABLE (" + mysql_pitchingTable$ + ")" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "NBR INNINGS (" + nbr_innings$ + ")" + CHR$(34) + _
              " --width=500 --height=200 --ok-label=CREATE --extra-button=HELP --extra-button=QUIT"
    ELSE
        cmd = "zenity --forms --title=" + CHR$(34) + "Config File - Baseball/Softball Statistics System - v1.0  " + CHR$(34) + _
              " --text=" + CHR$(34) + "Update: Enter new value(s) to change" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL DATABASE (" + mysqlDB$ + ")" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL USER (" + mysql_userid$ + ")" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL PASSWORD (" + mysql_password$ + ")" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL BATTING TABLE (" + mysql_battingTable$ + ")" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL PITCHING TABLE (" + mysql_pitchingTable$ + ")" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "NBR INNINGS (" + nbr_innings$ + ")" + CHR$(34) + _
              " --width=500 --height=200 --ok-label=UPDATE --extra-button=HELP --extra-button=QUIT"
    END IF

    stdout = "": stderr = ""
    result = pipecom(cmd, stdout, stderr)

    lenstr = LEN(stdout)
    stdout = LTRIM$(stdout)
    stdout = LEFT$(stdout, lenstr - 1)
    stdbutton = stdout

    PRINT #flog%, "Result  = "; result
    PRINT #flog%, "stdout  = "; stdout
    PRINT #flog%, "stderr  = "; stderr
    PRINT #flog%, ""

' *** If X, Cancel or QUIT buttons are pressed, end program
	IF result = 1 AND stdbutton = "" THEN GOTO endPROG
	IF result = 1 AND stdbutton = "QUIT" THEN GOTO endPROG

' *** If HELP button pressed, display the HELP Screen	
    IF result = 1 AND stdbutton = "HELP" THEN
        cmd = "zenity --text-info " + _
              " --title=" + CHR$(34) + "HELP: Baseball/Softball Statistics System - v1.0" + CHR$(34) + _
              " --width=900 --height=850 --html --ok-label=" + CHR$(34) + "Return to Menu" + CHR$(34) +  _
              " --filename=" + "help/baseballConfig.html" + " 2> /dev/null"
        SHELL (cmd)
        GOTO DisplayForm
    END IF

' *** Split out names of selected records into the Query array
    REDIM Query(nbrUpdates)
    Delim$ = "|": updates = 0
    retcode = StrSplit$(stdout, Delim$)
    FOR ix1 = 1 TO nbrUpdates
        IF Query(ix1) <> "" THEN
            SELECT CASE ix1
                CASE 1
                    mysqlDB$ = Query(ix1)
                CASE 2
                    mysql_userid$ = Query(ix1)
                CASE 3
                    mysql_password$ = Query(ix1)
                CASE 4
                    mysql_battingTable$ = Query(ix1)
                CASE 5
                    mysql_pitchingTable$ = Query(ix1)
                CASE 6
                    nbr_innings$ = Query(ix1)
            END SELECT
			updates = updates + 1
            PRINT #flog%, "Query - "; ix1; " = "; Query(ix1)
        END IF
    NEXT ix1
    PRINT #flog%, ""
    PRINT #flog%, "Number of updates: "; updates

' *** If "OK" button pressed (result=0) create config file with new values
    IF result = 0 THEN
        PRINT #flog%, "": PRINT #flog%, "Creating Updated Config File": PRINT #flog%, ""
        f1% = FREEFILE
        OPEN ConfigFile$ FOR OUTPUT AS #f1%
        PRINT #f1%, "/* Baseball/Softball Config File": PRINT #flog%, "/* Baseball/Softball Config File"
        qString$ = STR$(nbrUpdates): qString$ = LTRIM$(qString$)
        PRINT #f1%, qString$: PRINT #flog%, qString$ 
        qString$ = "SQLDB=" + mysqlDB$
        PRINT #f1%, qString$: PRINT #flog%, qString$
        qString$ = "SQLUSER=" + mysql_userid$
        PRINT #f1%, qString$: PRINT #flog%, qString$
        qString$ = "SQLPWD=" + mysql_password$
        PRINT #f1%, qString$: PRINT #flog%, qString$
        qString$ = "SQLBATTBL=" + mysql_battingTable$
        PRINT #f1%, qString$: PRINT #flog%, qString$
        qString$ = "SQLPITCHTBL=" + mysql_pitchingTable$
        PRINT #f1%, qString$: PRINT #flog%, qString$
        qString$ = "INNINGS=" + nbr_innings$
        PRINT #f1%, qString$: PRINT #flog%, qString$
        CLOSE #f1%
        PRINT #flog%, ""
        IF COMMAND$(1) = "UPDATE" THEN GOTO DisplayForm ELSE GOTO endPROG
    ELSE
        GOTO DisplayForm
    END IF


ehandler:
'$INCLUDE: 'include/baseballErrhandler.inc'


endPROG:

' *** Remove work files if they exist
'$INCLUDE: 'include/deleteWorkFiles.inc'

' *** Process end of program based on how it was called
    IF _COMMANDCOUNT = 0 THEN
        PRINT #flog%, ">>>>> Executing endPROG"
        PRINT #flog%, "": PRINT #flog%, "*** " + ProgramName$ + " - Terminated Normally ***"
        CLOSE #flog%
    ELSE
        PRINT #flog%, ">>>>> Executing (" + ProgramName$ + ") endPROG"
        PRINT #flog%, "": PRINT #flog%, "*** " + ProgramName$ + " - Terminated Normally - Return to calling Program ***"
        CLOSE #flog%
    END IF
    
    SYSTEM


'-----------------------------------------------------------------------

'$INCLUDE: 'include/stringFunctions.inc'

'$INCLUDE:'include/pipecom.inc'
