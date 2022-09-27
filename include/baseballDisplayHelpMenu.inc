SUB DisplayHelpMenu
' *** Display and process all the HELP screens
'

submitHELP:
' *** Display menu selections
	cmd = "zenity --list " + _
		  "       --title=" + CHR$(34) + "HELP Menu - Baseball/Softball Statistics System - v1.0   " + CHR$(34) + _
		  "       --text=" + CHR$(34) + "Select/Double Click on Option to Process:" + CHR$(34) + _
	  	  "       --width=450 --height=225 --hide-header --column=" + CHR$(34) + "Select One" + CHR$(34) + _
		  "       --cancel-label=QUIT --extra-button=RETURN " + _
		  CHR$(34) + "Overview" + CHR$(34) + " \ " + _
		  CHR$(34) + "Configuration Processing" + CHR$(34) + " \ " + _
		  CHR$(34) + "Entering Team Name Data" + CHR$(34) + " \ " + _
		  CHR$(34) + "Batting Data Processing" + CHR$(34) + " \ " + _
		  CHR$(34) + "Pitching Data Processing" + CHR$(34) + " \ " + _
		  CHR$(34) + "League/Team Display Statistics" + CHR$(34)  

    retcode = pipecom(cmd, stdout, stderr)

' *** Save menu selection and/or button pressed   
    lenstr = LEN(stdout): stdout = LEFT$(stdout, lenstr - 1) 
	stdmenu = LTRIM$(stdout)
	stdbutton = stdout

' *** If X, Cancel or QUIT buttons are pressed, end program
	IF retcode = 1 AND stdbutton = NULL THEN endPROG
	IF stdbutton = "RETURN" THEN EXIT SUB

    
' *** Process menu selection
	SELECT CASE stdmenu
		   CASE "Overview"
		        cmd = "zenity --text-info " + _
                      " --title=" + CHR$(34) + "HELP: Baseball/Softball Statistics System - v1.0" + CHR$(34) + _
                      " --width=1000 --height=850 --html --ok-label=" + CHR$(34) + "Return to Menu" + CHR$(34) +  _
                      " --filename=" + "help/baseballStats.html" + " 2> /dev/null"
                SHELL (cmd)
		   CASE "Configuration Processing"
		        cmd = "zenity --text-info " + _
                      " --title=" + CHR$(34) + "HELP: Baseball/Softball Statistics System - v1.0" + CHR$(34) + _
                      " --width=1000 --height=850 --html --ok-label=" + CHR$(34) + "Return to Menu" + CHR$(34) +  _
                      " --filename=" + "help/baseballConfig.html" + " 2> /dev/null"
                SHELL (cmd)
		   CASE "Entering Team Name Data"
		        cmd = "zenity --text-info " + _
                      " --title=" + CHR$(34) + "HELP: Baseball/Softball Statistics System - v1.0" + CHR$(34) + _
                      " --width=1000 --height=850 --html --ok-label=" + CHR$(34) + "Return to Menu" + CHR$(34) +  _
                      " --filename=" + "help/baseballTeamInput.html" + " 2> /dev/null"
                SHELL (cmd)
		   CASE "Batting Data Processing"
		        cmd = "zenity --text-info " + _
                      " --title=" + CHR$(34) + "HELP: Baseball/Softball Statistics System - v1.0" + CHR$(34) + _
                      " --width=1000 --height=850 --html --ok-label=" + CHR$(34) + "Return to Menu" + CHR$(34) +  _
                      " --filename=" + "help/battingDisplayStats.html" + " 2> /dev/null"
                SHELL (cmd)
		   CASE "Pitching Data Processing"
		        cmd = "zenity --text-info " + _
                      " --title=" + CHR$(34) + "HELP: Baseball/Softball Statistics System - v1.0" + CHR$(34) + _
                      " --width=1000 --height=850 --html --ok-label=" + CHR$(34) + "Return to Menu" + CHR$(34) +  _
                      " --filename=" + "help/pitchingDisplayStats.html" + " 2> /dev/null"
                SHELL (cmd)
		   CASE "League/Team Display Statistics"
		        cmd = "zenity --text-info " + _
                      " --title=" + CHR$(34) + "HELP: Baseball/Softball Statistics System - v1.0" + CHR$(34) + _
                      " --width=1000 --height=850 --html --ok-label=" + CHR$(34) + "Return to Menu" + CHR$(34) +  _
                      " --filename=" + "help/baseballLeague.html" + " 2> /dev/null"
                SHELL (cmd)
	END SELECT

	GOTO submitHELP

END SUB
