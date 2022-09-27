' *** DROP all VIEWS that system created, IF EXISTS (use sqlDropView FUNCTION)
' ***
' *** IF The returning program is not "baseballStats", DROP the team-specific VIEW currently used,
' *** ELSE DROP all possible existing VIEWS that could have been created during execution of system.
' *** (sqlDropView Function performs an "IF EXISTS" and will send back a return code of 0 unless there
' *** there is a system issue, then the Function will produce an error message in a terminal session
' *** and either send a return code > 0, or immediately terminate program).

IF ProgramName$ <> "baseballStats" THEN
	retcode = sqlDropView(mysqlView$+CHR$(0))
	IF retcode <> 0 THEN 
		PRINT #flog%, "(" + ProgramName$ + "): >>>>> DROP of SQL View (" + mysqlView$ + ") Failed."
	ELSE
		PRINT #flog%, "(" + ProgramName$ + "): >>>>> DROP of SQL View (" + mysqlView$ + ") Succeeded."
	END IF
END IF

retcode = sqlDropView("tempbattingStatsView")
IF retcode <> 0 THEN 
	PRINT #flog%, "(" + ProgramName$ + "): >>>>> DROP of SQL View (tempbattingStatsView) Failed."
ELSE
	PRINT #flog%, "(" + ProgramName$ + "): >>>>> DROP of SQL View (tempbattingStatsView) Succeeded."
END IF		
retcode = sqlDropView("temppitchingStatsView")
IF retcode <> 0 THEN 
	PRINT #flog%, "(" + ProgramName$ + "): >>>>> DROP of SQL View (temppitchingStatsView) Failed."
ELSE
	PRINT #flog%, "(" + ProgramName$ + "): >>>>> DROP of SQL View (temppitchingStatsView) Succeeded."
END IF
retcode = sqlDropView("tempteambattingStatsView")
IF retcode <> 0 THEN 
	PRINT #flog%, "(" + ProgramName$ + "): >>>>> DROP of SQL View (tempteambattingStatsView) Failed."
ELSE
	PRINT #flog%, "(" + ProgramName$ + "): >>>>> DROP of SQL View (tempteambattingStatsView) Succeeded."
END IF
retcode = sqlDropView("teambattingView")
IF retcode <> 0 THEN 
	PRINT #flog%, "(" + ProgramName$ + "): >>>>> DROP of SQL View (teambattingView) Failed."
ELSE
	PRINT #flog%, "(" + ProgramName$ + "): >>>>> DROP of SQL View (teambattingView) Succeeded."
END IF
retcode = sqlDropView("tempteampitchingStatsView")
IF retcode <> 0 THEN 
	PRINT #flog%, "(" + ProgramName$ + "): >>>>> DROP of SQL View (tempteampitchingStatsView) Failed."
ELSE
	PRINT #flog%, "(" + ProgramName$ + "): >>>>> DROP of SQL View (tempteampitchingView) Succeeded."
END IF
retcode = sqlDropView("teampitchingView")
IF retcode <> 0 THEN 
	PRINT #flog%, "(" + ProgramName$ + "): >>>>> DROP of SQL View (teampitchingView) Failed."
ELSE
	PRINT #flog%, "(" + ProgramName$ + "): >>>>> DROP of SQL View (teampitchingView) Succeeded."
END IF		
retcode = sqlDropView("leagueView")
IF retcode <> 0 THEN 
	PRINT #flog%, "(" + ProgramName$ + "): >>>>> DROP of SQL View (leagueView) Failed."
ELSE
	PRINT #flog%, "(" + ProgramName$ + "): >>>>> DROP of SQL View (leagueView) Succeeded."
END IF

