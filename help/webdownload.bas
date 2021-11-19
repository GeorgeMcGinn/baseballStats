IF Download("www.qb64.org/portal/wp-content/uploads/2020/02/TAGLINE-QB64-1-3-logo-transparency.png", "qb64logo.png", 10) THEN ' timelimit = 10 seconds
    img& = _LOADIMAGE("qb64logo.png", 32)
    IF img& < -1 THEN
        SCREEN _NEWIMAGE(_WIDTH(img&), _HEIGHT(img&), 32)
        _PUTIMAGE (0, 0), img&
    END IF
ELSE: PRINT "Couldn't download QB64 logo."
END IF
SLEEP
SYSTEM
' ---------- program end -----------

FUNCTION Download (url$, file$, timelimit) ' returns -1 if successful, 0 if not
url2$ = url$
x = INSTR(url2$, "/")
IF x THEN url2$ = LEFT$(url$, x - 1)
client = _OPENCLIENT("TCP/IP:80:" + url2$)
IF client = 0 THEN EXIT FUNCTION
e$ = CHR$(13) + CHR$(10) ' end of line characters
url3$ = RIGHT$(url$, LEN(url$) - x + 1)
x$ = "GET " + url3$ + " HTTP/1.1" + e$
x$ = x$ + "Host: " + url2$ + e$ + e$
PUT #client, , x$
t! = TIMER ' start time
DO
    _DELAY 0.05 ' 50ms delay (20 checks per second)
    GET #client, , a2$
    a$ = a$ + a2$
    i = INSTR(a$, "Content-Length:")
    IF i THEN
      i2 = INSTR(i, a$, e$)
      IF i2 THEN
      l = VAL(MID$(a$, i + 15, i2 - i - 14))
      i3 = INSTR(i2, a$, e$ + e$)
        IF i3 THEN
          i3 = i3 + 4 'move i3 to start of data
          IF (LEN(a$) - i3 + 1) = l THEN
            CLOSE client ' CLOSE CLIENT
            d$ = MID$(a$, i3, l)
            fh = FREEFILE
            OPEN file$ FOR OUTPUT AS #fh: CLOSE #fh 'Warning! Clears data from existing file
            OPEN file$ FOR BINARY AS #fh
            PUT #fh, , d$
            CLOSE #fh
            Download = -1 'indicates download was successfull
            EXIT FUNCTION
          END IF ' availabledata = l
        END IF ' i3
      END IF ' i2
    END IF ' i
LOOP UNTIL TIMER > t! + timelimit ' (in seconds)
CLOSE client
END FUNCTION

