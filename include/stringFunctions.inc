

FUNCTION TokenReplace$ (qString$, Token$, TokReplace$)
'-----------------------------------------------------------------------------
' *** Replace a provided token in a strink with a provided value
' *** (case sensitive)
'
    lenstr = LEN(qString$): startpos = 1
    DO
        findpos% = INSTR(findpos% + 1, qString$, Token$) ' find another occurance
        IF findpos% THEN
            nbrbytes = findpos% - startpos
            startpos = findpos% + 1
            Tokenlen = LEN(Token$)
            qString$ = LEFT$(qString$, findpos% - 1) + TokReplace$ + RIGHT$(qString$, lenstr - (nbrbytes + Tokenlen))
            startpos = 1: findpos% = -1: lenstr = LEN(qString$)
        END IF
    LOOP UNTIL findpos% = 0
    
    TokenReplace$ = qString$

END FUNCTION


FUNCTION StrRemove$ (myString$, whatToRemove$) 'noncase sensitive
'-----------------------------------------------------------------------------
' *** String Remove - remove text from a string value
' *** (noncase sensitive)
'
    a$ = myString$
    b$ = LCASE$(whatToRemove$)
    i = INSTR(LCASE$(a$), b$)
    DO WHILE i
        a$ = LEFT$(a$, i - 1) + RIGHT$(a$, LEN(a$) - i - LEN(b$) + 1)
        i = INSTR(LCASE$(a$), b$)
    LOOP
    StrRemove$ = a$
END FUNCTION


FUNCTION StrReplace$ (myString$, find$, replaceWith$) 
'-----------------------------------------------------------------------------
' *** Replace a provided string with a provided value
' *** (noncase sensitive)
'
    IF LEN(myString$) = 0 THEN EXIT FUNCTION
    a$ = myString$
    b$ = LCASE$(find$)
    basei = 1
    i = INSTR(basei, LCASE$(a$), b$)
    DO WHILE i
        a$ = LEFT$(a$, i - 1) + replaceWith$ + RIGHT$(a$, LEN(a$) - i - LEN(b$) + 1)
        basei = i + LEN(replaceWith$)
        i = INSTR(basei, LCASE$(a$), b$)
    LOOP
    StrReplace$ = a$
END FUNCTION


FUNCTION StrSplit$ (qString$, Delim$)
'-----------------------------------------------------------------------------
' *** Split a STRING based on provided Delimiter
' ***      qString$ and Delim$ are passed to this function
'
	lenstr = LEN(qString$)
	idx = 1
	startpos = 1
	DO
		findpos% = INSTR(findpos% + 1, qString$, Delim$) ' find another occurance
		IF findpos% THEN
			nbrbytes = findpos% - startpos
			Query(idx) = MID$(qString$, startpos, nbrbytes)
			startpos = findpos% + 1
			idx = idx + 1
		END IF
	LOOP UNTIL findpos% = 0
	nbrbytes = lenstr - startpos + 1
	Query(idx) = MID$(qString$, startpos, nbrbytes)
	
	StrSplit$ = "0"

END FUNCTION


FUNCTION strFormat$ (text AS STRING, template AS STRING)
'-----------------------------------------------------------------------------
' *** Return a formatted string to a variable
'
    d = _DEST: s = _SOURCE
    n = _NEWIMAGE(80, 80, 0)
    _DEST n: _SOURCE n
    PRINT USING template; VAL(text)
    FOR i = 1 TO 79
        t$ = t$ + CHR$(SCREEN(1, i))
    NEXT
    IF LEFT$(t$, 1) = "%" THEN t$ = MID$(t$, 2)
    strFormat$ = _TRIM$(t$)
    _DEST d: _SOURCE s
    _FREEIMAGE n
END FUNCTION


FUNCTION ISNUMERIC (A$)
'-----------------------------------------------------------------------------
' *** Numeric Check of a STRING
'
	lenstr = LEN(A$)
	FOR I = 1 TO lenstr
		ACODE = ASC(A$, I)
		IF numeric(ACODE) THEN
			ISNUMERIC = TRUE
		ELSE
			ISNUMERIC = FALSE
			EXIT FUNCTION
		END IF
	NEXT I
	
END FUNCTION

