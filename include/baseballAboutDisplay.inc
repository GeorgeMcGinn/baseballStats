SUB DisplayAbout
' *** Displays the ABOUT Splash Screen based on first time use vs
' *** From within an already set up application. Note that you
' *** cannot set up the system without agreeing to the licensing
' *** and terms of conditions.
'

submitAbout:
' *** If first time setting up, process the I AGREE checkbox, else remove it
	IF NOT _FILEEXISTS(ConfigFile$) THEN
        cmd = "zenity --text-info " + _
              " --title=" + CHR$(34) + "ABOUT: Baseball/Softball Statistics System - (Pre-release)" + CHR$(34) + _
              " --width=820 --height=580 --html " + _
              " --ok-label=" + CHR$(34) + "OK" + CHR$(34) +  _
              " --extra-button=" + CHR$(34) + "LICENSE" + CHR$(34) + _
              " --extra-button=" + CHR$(34) + "HELP MENU" + CHR$(34) + _
              " --checkbox=" + CHR$(34) + "I agree with the licensing and conditions set for using this program. (Required for first time use)" + CHR$(34) + _
              " --filename=help/baseballAbout.html 2> /dev/null"
        retcode = pipecom(cmd, stdout, stderr)
    ELSE
        cmd = "zenity --text-info " + _
              " --title=" + CHR$(34) + "ABOUT: Baseball/Softball Statistics System - (Pre-release)" + CHR$(34) + _
              " --width=820 --height=580 --html " + _
              " --ok-label=" + CHR$(34) + "OK" + CHR$(34) +  _
              " --extra-button=" + CHR$(34) + "LICENSE" + CHR$(34) + _
              " --extra-button=" + CHR$(34) + "HELP MENU" + CHR$(34) + _
              " --filename=help/baseballAbout.html 2> /dev/null"
        retcode = pipecom(cmd, stdout, stderr)
	END IF

' *** Save menu selection and/or button pressed   
    lenstr = LEN(stdout): stdout = LEFT$(stdout, lenstr - 1) 
	stdmenu = LTRIM$(stdout)
	stdbutton = stdout

' *** If X, Cancel or QUIT buttons are pressed, end program
	IF retcode = 1 AND stdbutton = NULL THEN 
		IF NOT _FILEEXISTS(ConfigFile$) THEN GOTO endPROG
	END IF
	IF retcode = 1 AND stdbutton = "QUIT" THEN 
		IF NOT _FILEEXISTS(ConfigFile$) THEN GOTO endPROG
	END IF

' *** If LICENSE button pressed, display license and redisplay ABOUT 
    IF retcode = 1 AND stdbutton = "LICENSE" THEN
        cmd = "zenity --text-info " + _
              " --title=" + CHR$(34) + "LICENSE: Baseball/Softball Statistics System - v1.0" + CHR$(34) + _
              " --width=1000 --height=850 --html --ok-label=" + CHR$(34) + "Return to Menu" + CHR$(34) +  _
              " --filename=" + "help/license.html" + " 2> /dev/null"
        SHELL (cmd)
        GOTO submitAbout
    END IF

' *** If HELP MENU button pressed, display the menu showing all the
' *** HELP topics available (This will be processed by a new program)
    IF stdbutton = "HELP MENU" THEN DisplayHelpMenu

	EXIT SUB

endPROG:
' *** CLOSE Log File
'

' *** Remove work files if they exist
'$INCLUDE: '../include/deleteWorkFiles.inc'
	
    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing endPROG"
    PRINT #flog%, "(" + ProgramName$ + "): "

    PRINT #flog%, "(" + ProgramName$ + "): "
    PRINT #flog%, "(" + ProgramName$ + "): Terminated Normally ***"
    CLOSE #flog%
    SYSTEM

END SUB
