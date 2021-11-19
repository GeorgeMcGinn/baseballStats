FUNCTION SystemsCheck ()
'-----------------------------------------------------------------------------------
' *** Checks to make sure all the required software is installed and running before
' *** continuing execution.
'
    setupResult = TRUE
    
    PRINT #flog%, "": PRINT #flog%, "*** Running on a LINUX System ***": PRINT #flog%, ""

' *** If the mysql-server is not installed, set setupResult to FALSE
    cmd = "dpkg -l 'mysql-server' | grep mysql-server"
    result = pipecom(cmd, stdout, stderr)
    IF MID$(stdout, 5, 12) <> "mysql-server" THEN
        PRINT "***** mySQL must be installed and running. Please correct and rerun. Program Terminated. *****"
        PRINT #flog%, "***** mySQL must be installed and running. Please correct and rerun. Program Terminated. *****"
        setupResult = FALSE
    END IF

' *** If the mysql-server is not running, set setupResult to FALSE
	cmd = "mysql --version"
	result = pipecom(cmd, stdout, stderr)
	IF LEFT$(stdout, 5) <> "mysql" THEN
		PRINT "***** mySQL must be running. Please correct and rerun. Program Terminated. *****"
        PRINT #flog%, "***** mySQL must be running. Please correct and rerun. Program Terminated. *****"
        setupResult = FALSE
    END IF

' *** If the enscript package is not installed, set PrintReport to FALSE (displays report instead of printing)
	cmd = "dpkg -l 'enscript' | grep enscript"
	result = pipecom(cmd, stdout, stderr)
	IF MID$(stdout, 5, 8) <> "enscript" THEN
		PRINT "***** enscript is not installed. Program needs this to print out reports. Program set to display reports. *****"
		PRINT #flog%, "***** enscript is not installed. Program needs this to print out reports. Program set to display reports. *****"
		PrintReport = FALSE
	END IF

' *** If Zenity is not installed, set setupResult to FALSE
	cmd = "dpkg -l 'zenity' | grep zenity"
	result = pipecom(cmd, stdout, stderr)
	IF MID$(stdout, 5, 6) <> "zenity" THEN
		PRINT "***** Zenity is not installed. Program will use generic console/terminal for Input/Output. *****"
		PRINT #flog%, "***** Zenity is not installed. Program will use generic console/terminal for Input/Output. *****"
		setupResult = FALSE
    END IF

    SystemsCheck = setupResult

END FUNCTION


