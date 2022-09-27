SUB endPROG
' *** Disconnect from SQL Server, delete all work files and SQL VIEWS, and close log file
'

    PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing endPROG"
    PRINT #flog%, "(" + ProgramName$ + "): "


	IF sqlActive THEN
' *** Perform SQL VIEW Cleanup 
		PRINT #flog%, "(" + ProgramName$ + "): Performing mySQL VIEW cleanup" 
		PRINT #flog%, "(" + ProgramName$ + "): "
		'$INCLUDE: 'mysqlCleanup.inc'		
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
	ELSE
		PRINT #flog%, "(" + ProgramName$ + "): SQL Server is not Active ***"
		PRINT #flog%, "(" + ProgramName$ + "): "	
	END IF

' *** Remove work files if they exist
	'$INCLUDE: 'deleteWorkFiles.inc'

' *** Process end of program based on how it was called
	IF cntargs = 0 THEN
		PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing endPROG"
		PRINT #flog%, "(" + ProgramName$ + "): "
		PRINT #flog%, "(" + ProgramName$ + "): *** Terminated Normally ***"
		CLOSE #flog%
	ELSE
		PRINT #flog%, "(" + ProgramName$ + "): >>>>> Executing (" + ProgramName$ + "): endPROG"
		PRINT #flog%, "(" + ProgramName$ + "): Terminated Normally - Return to calling Program"
		PRINT #flog%, "(" + ProgramName$ + "): "
		CLOSE #flog%
	END IF

   SYSTEM 0

END SUB



