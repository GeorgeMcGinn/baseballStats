	PRINT #flog%, "(" + ProgramName$ + "):"
	PRINT #flog%, USING "(" + ProgramName$ + "): Error ### at line ##### - &"; ERR; _ERRORLINE; _ERRORMESSAGE$
	PRINT #flog%, "(" + ProgramName$ + "):"
	endPROG
