SUB mysqlConnect
' *** Connect to the mySQL Server
	PRINT #flog%, "(" + ProgramName$ + "): Connecting to mySQL Server ***" 
	PRINT #flog%, "(" + ProgramName$ + "): "
	PRINT #flog%, "(" + ProgramName$ + "): Values passed: [localhost], " + "[" + mysql_userid$ + "], [" + mysql_password$ + "], [" + mysqlDB$ + "] " 
	retcode = sqlConnect("localhost", mysql_userid$+CHR$(0), mysql_password$+CHR$(0), mysqlDB$+CHR$(0))
	PRINT #flog%, "(" + ProgramName$ + "): SQL Return Code ="; retcode; 
	IF retcode <> 0 THEN
		PRINT #flog%, "(" + ProgramName$ + "): ERROR: Connection to server failed. Please check and run again. Return Code ="; retcode;  " ***"
		PRINT #flog%, "(" + ProgramName$ + "): Values passed: [localhost], " + "[" + mysql_userid$ + "], [" + mysql_password$ + "], [" + mysqlDB$ + "] " 
		PRINT #flog%, "(" + ProgramName$ + "): "
		retcode = sqlDisonnect
		endPROG
	ELSE
		PRINT #flog%, "(" + ProgramName$ + "): Connection to mySQL Server established as [localhost], " + "[" + mysql_userid$ + "], [" + mysqlDB$ + "] " 
		PRINT #flog%, "(" + ProgramName$ + "): "
		sqlActive = True
	END IF

END SUB


SUB mysqlDisconnect
' *** Disconnect from the mySQL Server
	PRINT #flog%, "(" + ProgramName$ + "): Disconnecting from mySQL Server" 
	PRINT #flog%, "(" + ProgramName$ + "): "
	retcode = sqlDisonnect
	IF retcode <> 0 THEN 
		PRINT #flog%, "(" + ProgramName$ + "): Disconnecting from server failed. Program terminated. Return Code ="; retcode
		PRINT #flog%, "(" + ProgramName$ + "): *** Program Execution FAILED ***"
		endPROG
	END IF			
END SUB


SUB mysqlReset
' *** Reset the mySQL Views for next team processing
	mysqlConnect
	PRINT #flog%, "(" + ProgramName$ + "): Performing mySQLReset VIEW cleanup" 
	PRINT #flog%, "(" + ProgramName$ + "): "
	'$INCLUDE: 'mysqlCleanup.inc'
	mysqlDisconnect		
END SUB
