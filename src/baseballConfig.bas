REM $TITLE: baseballConfig.bas Version 1.0.0  09/30/2021 - Last Update: 06/02/2022
_TITLE "Configuration Management Version 1.0.0  09/30/2021 - Last Update: 06/02/2022"
' baseballConfig.bas    Version 1.0.0  09/30/21
'-------------------------------------------------------------------------------
'       PROGRAM: baseballConfig.bas
'        AUTHOR: George McGinn
'                <gbytes58@gmail.com>
'
'  DATE WRITTEN: 09/30/2021
'       VERSION: 1.0.0
'       PROJECT: Baseball/Softball Statistics Recordkeeping System
'
'   DESCRIPTION: Config File processing of the
'                Baseball/Softball Statistics Recordkeeping System.
'
' Written by George McGinn
' Copyright ©2021/2022 by George McGinn - All Rights Reserved
' Version 1.0.0 - Created 09/30/2021, Finalized on 06/02/2022
'
' CHANGE LOG
'-------------------------------------------------------------------------------
' 09/30/2021 v1.0.0  GJM - New Program.
' 10/02/2021 v0.11   GJM - Added batting and pitching tables to Config File.
' 10/04/2021 v0.12   GJM - Added HELP menu.
' 10/05/2021 v0.13   GJM - Added ProgramName$ that is determined in initialization.
' 10/06/2021 v0.14   GJM - Updated program to new directory structure & file names
' 10/11/2021 v0.15   GJM - Added number of innings to config file
' 11/21/2021 v0.16   GJM - Add the output mySQL directory to the config.ini file
'                          and standardized the size of the HELP screen
' 12/07/2021 v0.17   GJM - Updated CC licensing
' 12/14/2021 v0.18   GJM - Minor adjustment to the way container text displayed
' 04/24/2022 v0.19   GJM - Standardized Log Prints and endPROG with rest of system.
' 05/31/2022 v0.20   GJM - Cleaned up code, like nested IF and CASE statements. 
'                          Also added the changes to mysqlClient.h and its code.
'                          Program is ready for Release 1.0.
' 06/02/2022 v0.21   GJM - Added OUTFILE and PRINT REPORT switches to the config
'                          file processing.
'-------------------------------------------------------------------------------
'  Copyright ©2021/2022 by George McGinn.  All Rights Reserved.
'
' baseballConfig by George McGinn is licensed under a Creative Commons
' Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
'
' Full License Link: https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
'
'-------------------------------------------------------------------------------------
' PROGRAM NOTES
'
' 1) Look into preserving the comments found in the input config.ini file and write them
'    out. This should be done in case the user adds their own comments to the file.
'    right now, the comments are overlaid with the standard ones provided. That is good
'    when creating the config.ini file at install time, but should not be done going
'    forward.
'
'-------------------------------------------------------------------------------


'-------------------------------------------------------------------------------------
' *** Preprocessing Section
'
'$DYNAMIC
$CONSOLE:ONLY
OPTION BASE 1

ON ERROR GOTO ehandler

'---------------------------------------------------------------------------
' *** Initialize functions that call mySQL Directly
'
'$INCLUDE: 'include/mysqlDeclarations.inc'

 
'-------------------------------------------------------------------------------------
' *** Initialize Section
'

'$INCLUDE: 'include/baseballInit.inc'

' *** If not running from Linux, message and exit
IF INSTR(_OS$, "LINUX") THEN OStype = "LINUX"
IF OStype <> "LINUX" THEN
	SHELL ("zenity --error --text=" + CHR$(34) + "(" + ProgramName$ + "): failed - Runs on LINUX only. Program Terminated." + CHR$(34) + " --width=175 --height=100")
	PRINT #flog%, "(" + ProgramName$ + "): ERROR: Program runs in Linux only. Program Terminated. ***"
	PRINT #flog%, "(" + ProgramName$ + "): "
	endPROG
END IF


QB64Main:
'-------------------------------------------------------------------------------------
' *** MAIN Logic
'

' *** OPEN Log File (_COMMANDCOUNT > 0 only when called by baseballStats module)
    IF _COMMANDCOUNT = 0 THEN
        flog% = FREEFILE
        OPEN "logs/baseballstats.log" FOR OUTPUT AS #flog%
        PRINT #flog%, "(" + ProgramName$ + "): *** Baseball Stats Log File ***"
        PRINT #flog%, "(" + ProgramName$ + "): "
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
                    return$ = StrSplit$(qString$, Delim$)
                    idx = idx + 1
					SELECT CASE Query(1)
						   CASE "SQLDB": mysqlDB$ = Query(2)
                           CASE "SQLUSER": mysql_userid$ = Query(2)
                           CASE "SQLPWD": mysql_password$ = Query(2)
                           CASE "SQLBATTBL": mysql_battingTable$ = Query(2)
                           CASE "SQLPITCHTBL": mysql_pitchingTable$ = Query(2)
                           CASE "SQLOUTFILE": mysql_outfile$ = Query(2)
                           CASE "SQLOUTDIR": mysql_outputdir$ = Query(2)
                           CASE "PRINTREPORT": mysql_printreport$ = Query(2)
                           CASE "INNINGS": nbr_innings$ = Query(2)
                    END SELECT
                END IF
            END IF
        LOOP
        CLOSE #f1%
        PRINT #flog%, "(" + ProgramName$ + "): "
        PRINT #flog%, "(" + ProgramName$ + "): *** LOAD Baseball Stats Configuration File ***"
        PRINT #flog%, "(" + ProgramName$ + "): ----------------------------------------------"
    ELSE
		nbrUpdates = 9
        OPEN ConfigFile$ FOR OUTPUT AS #f1%
        PRINT #f1%, "/* Baseball/Softball Config File"
        PRINT #f1%, "9"
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
        qString$ = "SQLOUTFILE=" + mysql_outfile$
        PRINT #f1%, qString$
        qString$ = "SQLOUTDIR=" + mysql_outputdir$
        PRINT #f1%, qString$
        qString$ = "PRINTREPORT=" + mysql_printreport$
        PRINT #f1%, qString$
        qString$ = "INNINGS=" + nbr_innings$
        PRINT #f1%, qString$
        CLOSE #f1%
        PRINT #flog%, "(" + ProgramName$ + "): "
        PRINT #flog%, "(" + ProgramName$ + "): *** CREATE Baseball Stats Configuration File ***"
        PRINT #flog%, "(" + ProgramName$ + "): ------------------------------------------------"
    END IF
	PRINT #flog%, "(" + ProgramName$ + "): " + mysqlDB$ 
	PRINT #flog%, "(" + ProgramName$ + "): " + mysql_userid$
	PRINT #flog%, "(" + ProgramName$ + "): " + mysql_password$ 
	PRINT #flog%, "(" + ProgramName$ + "): " + mysql_battingTable$ 
	PRINT #flog%, "(" + ProgramName$ + "): " + mysql_pitchingTable$ 
	PRINT #flog%, "(" + ProgramName$ + "): " + mysql_outputdir$ 
	PRINT #flog%, "(" + ProgramName$ + "): " + mysql_outfile$ 
	PRINT #flog%, "(" + ProgramName$ + "): " + mysql_printreport$ 
	PRINT #flog%, "(" + ProgramName$ + "): " + nbr_innings$ 
	PRINT #flog%, "(" + ProgramName$ + "): "


DisplayForm:

    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing DisplayForm"
    PRINT #flog%, "(" + ProgramName$ + "): "

' *** Display the Configuration Update form with values from Config File
    IF COMMAND$(1) = "INSTALL" THEN
        cmd = "zenity --forms --title=" + CHR$(34) + "Config File - Baseball/Softball Statistics System - v1.0.0  " + CHR$(34) + _
              " --text=" + CHR$(34) + "Install/New Region: Enter all fields  " + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL DATABASE [" + mysqlDB$ + "]" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL USER [" + mysql_userid$ + "]" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL PASSWORD [" + mysql_password$ + "]" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL BATTING TABLE [" + mysql_battingTable$ + "]" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL PITCHING TABLE [" + mysql_pitchingTable$ + "]" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL OUTPUT DIRECTORY [" + mysql_outputdir$ + "]" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "CREATE SQL OUTFILE (Y/N) [" + mysql_outfile$ + "]" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "PRINT REPORT (Y/N) [" + mysql_printreport$ + "]" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "NBR INNINGS [" + nbr_innings$ + "]" + CHR$(34) + _
              " --width=500 --height=230 --ok-label=CREATE --extra-button=HELP --extra-button=QUIT"
    ELSE
        cmd = "zenity --forms --title=" + CHR$(34) + "Config File - Baseball/Softball Statistics System - v1.0.0  " + CHR$(34) + _
              " --text=" + CHR$(34) + "Update: Enter new value(s) to change  " + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL DATABASE [" + mysqlDB$ + "]" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL USER [" + mysql_userid$ + "]" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL PASSWORD [" + mysql_password$ + "]" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL BATTING TABLE [" + mysql_battingTable$ + "]" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL PITCHING TABLE [" + mysql_pitchingTable$ + "]" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "SQL OUTPUT DIRECTORY [" + mysql_outputdir$ + "]" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "CREATE SQL OUTFILE (Y/N) [" + mysql_outfile$ + "]" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "PRINT REPORT (Y/N) [" + mysql_printreport$ + "]" + CHR$(34) + _
              " --add-entry=" + CHR$(34) + "NBR INNINGS [" + nbr_innings$ + "]" + CHR$(34) + _
              " --width=500 --height=230 --ok-label=UPDATE --extra-button=HELP --extra-button=QUIT"
    END IF

    stdout = NULL: stderr = NULL
    retcode = pipecom(cmd, stdout, stderr)

    lenstr = LEN(stdout)
    stdout = LTRIM$(stdout)
    stdout = LEFT$(stdout, lenstr - 1)
    stdbutton = stdout

    PRINT #flog%, "(" + ProgramName$ + "): Result  = "; retcode
    PRINT #flog%, "(" + ProgramName$ + "): stdout  = "; stdout
    PRINT #flog%, "(" + ProgramName$ + "): stderr  = "; stderr
    PRINT #flog%, "(" + ProgramName$ + "): "

' *** If X, Cancel or QUIT buttons are pressed, end program
	IF retcode = 1 AND stdbutton = NULL THEN endPROG
	IF retcode = 1 AND stdbutton = "QUIT" THEN endPROG

' *** If HELP button pressed, display the HELP Screen	
    IF stdbutton = "HELP" THEN
        cmd = "zenity --text-info " + _
              " --title=" + CHR$(34) + "HELP: Baseball/Softball Statistics System - v1.0.0" + CHR$(34) + _
              " --width=1000 --height=850 --html --ok-label=" + CHR$(34) + "Return to Menu" + CHR$(34) +  _
              " --filename=" + "help/baseballConfig.html" + " 2> /dev/null"
        SHELL (cmd)
        GOTO DisplayForm
    END IF

' *** Split out names of selected records into the Query array
    REDIM Query(nbrUpdates)
    Delim$ = "|": updates = 0
    return$ = StrSplit$(stdout, Delim$)
    FOR ix1 = 1 TO nbrUpdates
        IF Query(ix1) <> NULL THEN
            SELECT CASE ix1
                CASE 1: mysqlDB$ = Query(ix1)
                CASE 2: mysql_userid$ = Query(ix1)
                CASE 3: mysql_password$ = Query(ix1)
                CASE 4: mysql_battingTable$ = Query(ix1)
                CASE 5: mysql_pitchingTable$ = Query(ix1)
                CASE 6: mysql_outputdir$ = Query(ix1)
                CASE 7: mysql_outfile$ = UCASE$(Query(ix1))
                CASE 8: mysql_printreport$ = UCASE$(Query(ix1))
                CASE 9: nbr_innings$ = Query(ix1)
            END SELECT
			updates = updates + 1
            PRINT #flog%, "(" + ProgramName$ + "): Query - "; ix1; " = "; Query(ix1)
        END IF
    NEXT ix1
    PRINT #flog%, "(" + ProgramName$ + "): "
    PRINT #flog%, "(" + ProgramName$ + "): Number of updates: "; updates

' *** If "OK" button pressed (retcode=0) create config file with new values
    IF retcode = 0 THEN
        PRINT #flog%, "(" + ProgramName$ + "): "
        PRINT #flog%, "(" + ProgramName$ + "): Creating Updated Config File"
        PRINT #flog%, "(" + ProgramName$ + "): "
        f1% = FREEFILE
        OPEN ConfigFile$ FOR OUTPUT AS #f1%
		PRINT #f1%, "/* Baseball/Softball Config File": PRINT #flog%, "(" + ProgramName$ + "): /* Baseball/Softball Config File"
		PRINT #f1%, "/*": PRINT #flog%, "(" + ProgramName$ + "): /*"
		PRINT #f1%, "/* SQLDB is the name of the mySQL Database": PRINT #flog%, "(" + ProgramName$ + "): /* SQLDB is the name of the mySQL Database"
		PRINT #f1%, "/* SQLUSER is the userid to sign into mySQL": PRINT #flog%, "(" + ProgramName$ + "): /* SQLUSER is the userid to sign into mySQL"
		PRINT #f1%, "/* SQLPWD is the password for the mySQL userid": PRINT #flog%, "(" + ProgramName$ + "): /* SQLPWD is the password for the mySQL userid"
		PRINT #f1%, "/* SQLBATTBL is the batting table in the mySQL Database": PRINT #flog%, "(" + ProgramName$ + "): /* SQLBATTBL is the batting table in the mySQL Database"
		PRINT #f1%, "/* SQLPITCHTBL is the pitching table in the mySQL Database": PRINT #flog%, "(" + ProgramName$ + "): /* SQLPITCHTBL is the pitching table in the mySQL Database"
		PRINT #f1%, "/* SQLOUTDIR is the directory to write mySQL OUTFILE datasets, if SQLOUTFILE switch is Y": PRINT #flog%, "(" + ProgramName$ + "): /* SQLOUTDIR is the directory to write mySQL OUTFILE datasets, if SQLOUTFILE switch is Y"
		PRINT #f1%, "/* SQLOUTFILE is the switch to tell the system to create the mySQL OUTFILES (Y=Yes, N=No)": PRINT #flog%, "(" + ProgramName$ + "): /* SQLOUTFILE is the switch to tell the system to create the mySQL OUTFILES (Y=Yes, N=No)"
		PRINT #f1%, "/* PRINTREPORT is the switch to tell the system whether to send reports to the PRINTER (Y=Yes, N=No)": PRINT #flog%, "(" + ProgramName$ + "): /* PRINTREPORT is the switch to tell the system whether to send reports to the PRINTER (Y=Yes, N=No)"
		PRINT #f1%, "/* INNINGS is the number of innings a standard game is (usually 6, 7 or 9)": PRINT #flog%, "(" + ProgramName$ + "): /* INNINGS is the number of innings a standard game is (usually 6, 7 or 9)"
        qString$ = STR$(nbrUpdates): qString$ = LTRIM$(qString$)
        PRINT #f1%, qString$: PRINT #flog%, "(" + ProgramName$ + "): " + qString$ 
        qString$ = "SQLDB=" + mysqlDB$
        PRINT #f1%, qString$: PRINT #flog%, "(" + ProgramName$ + "): " + qString$ 
        qString$ = "SQLUSER=" + mysql_userid$
        PRINT #f1%, qString$: PRINT #flog%, "(" + ProgramName$ + "): " + qString$ 
        qString$ = "SQLPWD=" + mysql_password$
        PRINT #f1%, qString$: PRINT #flog%, "(" + ProgramName$ + "): " + qString$ 
        qString$ = "SQLBATTBL=" + mysql_battingTable$
        PRINT #f1%, qString$: PRINT #flog%, "(" + ProgramName$ + "): " + qString$ 
        qString$ = "SQLPITCHTBL=" + mysql_pitchingTable$
        PRINT #f1%, qString$: PRINT #flog%, "(" + ProgramName$ + "): " + qString$ 
        qString$ = "SQLOUTDIR=" + mysql_outputdir$
        PRINT #f1%, qString$: PRINT #flog%, "(" + ProgramName$ + "): " + qString$ 
        qString$ = "SQLOUTFILE=" + mysql_outfile$
        PRINT #f1%, qString$: PRINT #flog%, "(" + ProgramName$ + "): " + qString$ 
        qString$ = "PRINTREPORT=" + mysql_printreport$
        PRINT #f1%, qString$: PRINT #flog%, "(" + ProgramName$ + "): " + qString$ 
        qString$ = "INNINGS=" + nbr_innings$
        PRINT #f1%, qString$: PRINT #flog%, "(" + ProgramName$ + "): " + qString$ 
        CLOSE #f1%
        PRINT #flog%, "(" + ProgramName$ + "): " + NULL
''        IF COMMAND$(1) = "UPDATE" THEN GOTO DisplayForm ELSE endPROG
    END IF
    GOTO DisplayForm


ehandler:
'$INCLUDE: 'include/baseballErrhandler.inc'


'-----------------------------------------------------------------------

'-----------------------------------------------------------------------
' INCLUDES: ------------------------------------------------------------
'
'$INCLUDE: 'include/endPROG.inc'
'$INCLUDE: 'include/stringFunctions.inc'
'$INCLUDE: 'include/pipecom.inc'
