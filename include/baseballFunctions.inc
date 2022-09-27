FUNCTION SystemsCheck ()
'-----------------------------------------------------------------------------------
' *** Checks to make sure all the required software is installed and running before
' *** continuing execution.
'
    setupResult = TRUE
    
' *** Start log file process and determine what kind of Linux running on (x86 or ARM (Raspberry Pi))
    PRINT #flog%, "(" + ProgramName$ + "): "
    cmd = "cat /proc/cpuinfo | grep 'Raspberry Pi'"
    retcode = pipecom(cmd, stdout, stderr)
    IF MID$(stdout, 10, 12) = "Raspberry Pi" THEN
        PRINT #flog%, "(" + ProgramName$ + "): *** Running on a LINUX (Raspbian Pi) System " + _OS$ + " ***"
    ELSE
		PRINT #flog%, "(" + ProgramName$ + "): *** Running on a LINUX x86 System " + _OS$ + "***"
    END IF
    PRINT #flog%, "(" + ProgramName$ + "): "

' *** If Zenity is not installed, set setupResult to FALSE
    cmd = "dpkg -l 'zenity' | grep zenity"
    retcode = pipecom(cmd, stdout, stderr)
    IF MID$(stdout, 5, 6) <> "zenity" THEN
		PRINT #flog%, "(" + ProgramName$ + "): ***** Zenity is not installed. Please correct and rerun. Program Terminated. *****"
		setupResult = FALSE
    END IF

' *** If the mysql-server or mariadb-server is not installed, set setupResult to FALSE
' *** NOTE: If running on an armv, then select mariaDB, else mySQL
''    cmd = "arch | grep armv > /dev/null"
    cmd = "cat /proc/cpuinfo | grep 'Raspberry Pi'"
    retcode = pipecom(cmd, stdout, stderr)
    IF MID$(stdout, 10, 12) = "Raspberry Pi" THEN
        cmd = "dpkg -l 'mariadb-server' | grep mariadb-server"
        retcode = pipecom(cmd, stdout, stderr)
        IF MID$(stdout, 5, 14) <> "mariadb-server" THEN
            PRINT #flog%, "(" + ProgramName$ + "): ***** mariadb-server must be installed. Please correct and rerun. Program Terminated. *****"
            setupResult = FALSE
		END IF
    ELSE
        cmd = "dpkg -l 'mysql-server' | grep mysql-server"
        retcode = pipecom(cmd, stdout, stderr)
        IF MID$(stdout, 5, 12) <> "mysql-server" THEN
            PRINT #flog%, "(" + ProgramName$ + "): ***** mysql-server must be installed. Please correct and rerun. Program Terminated. *****"
            setupResult = FALSE
		END IF
    END IF

' *** If the mysql-server (includes mariaDB) is not running, set setupResult to FALSE
	cmd = "mysql --version"
	retcode = pipecom(cmd, stdout, stderr)
	IF LEFT$(stdout, 5) <> "mysql" THEN
        PRINT #flog%, "(" + ProgramName$ + "): ***** mySQL or mariaDB must be running. Please correct and rerun. Program Terminated. *****"
        setupResult = FALSE
    END IF

' *** If the enscript package is not installed, set PrintReport to FALSE (displays report instead of printing)
	IF mysql_printreport$ = "Y" THEN
	    cmd = "dpkg -l 'enscript' | grep enscript"
	    retcode = pipecom(cmd, stdout, stderr)
	    IF MID$(stdout, 5, 8) <> "enscript" THEN
			PRINT #flog%, "(" + ProgramName$ + "): ***** enscript is not installed. Program needs this to print out reports. Program set to display reports. *****"
			PrintReport = FALSE
	    ELSE
			PrintReport = TRUE
	    END IF
	ELSE
	    PrintReport = FALSE
	    PRINT #flog%, "(" + ProgramName$ + "): ***** mysql_printreport flag set to N. [PRINT] button disabled - Output to terminal window. *****"
	END IF

    SystemsCheck = setupResult

END FUNCTION

