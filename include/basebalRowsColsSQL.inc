FUNCTION sql_columns ()
'--------------------------------------------------------------------------------------
' *** Execute a SQL Table Search & return the number of columns in the table
'--------------------------------------------------------------------------------------
'

' *** SQL View Name: baseballDB.<teamName>pitchingStatsView
    PRINT #flog%, ">>>>> Executing FUNCTION sql_columns()"
    PRINT #flog%, ""
    cmd = (mysqlCMD$ + CHR$(34) + "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE table_schema='" + mysqlDB$ + "' AND table_name='" + mysqlView$ + "'" + CHR$(34))
    
    PRINT #flog%, cmd: PRINT #flog%, ""
    result = pipecom(cmd, stdout, stderr)    
    PRINT #flog%, "stdout = "; stdout
	PRINT #flog%, "stderr = "; stderr
	PRINT #flog%, "result = "; result
	PRINT #flog%, ""

    nbrCols = VAL(stdout)
    PRINT #flog%, "The number of Columns: "; nbrCols: PRINT #flog%, ""

    sql_columns = nbrCols
    
END FUNCTION


FUNCTION sql_rows ()
'--------------------------------------------------------------
' *** Get the number of total rows based on SELECT COUNT(*) ***
'--------------------------------------------------------------
'

	PRINT #flog%, ">>>>> Executing FUNCTION sql_rows()"
	PRINT #flog%, ""

	IF setLeague THEN
		PRINT #flog%, "League Selected"
		cmd = mysqlCMD$ + CHR$(34) + "SELECT COUNT(distinct TEAM) FROM " + mysqlView$ + CHR$(34)
	ELSE
		PRINT #flog%, "Team Selected = "; teamName
		cmd = (mysqlCMD$ + CHR$(34) + "SELECT COUNT(distinct playerName) FROM " + mysqlTable$ + " WHERE teamName='" + teamName + "'" + CHR$(34))
	END IF
	PRINT #flog%, cmd
	result = pipecom(cmd, stdout, stderr)
    PRINT #flog%, "stdout = "; stdout
	PRINT #flog%, "stderr = "; stderr
	PRINT #flog%, "result = "; result
	PRINT #flog%, ""	
	
	nbrRows = VAL(stdout)
	PRINT #flog%, "The number of rows to process: "; nbrRows: PRINT #flog%, ""
	
    sql_rows = nbrRows

END FUNCTION
