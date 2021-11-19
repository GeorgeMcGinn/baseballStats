    PRINT #flog%, ""
	PRINT #flog%, USING "(" + ProgramName$ + "): Error ### at line ##### - &"; ERR; _ERRORLINE; _ERRORMESSAGE$ 
    PRINT #flog%, ""
    GOTO endPROG
