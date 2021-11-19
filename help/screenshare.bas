$CHECKING:OFF
'to use color names
$COLOR:32
SCREEN _NEWIMAGE(500, 500, 32)
dd = _OPENHOST("TCP/IP:80")
crlf$ = CHR$(13) + CHR$(10)
DO
    c = _OPENCONNECTION(dd)
    IF c <> 0 THEN
        addr$ = _CONNECTIONADDRESS(c)
        COLOR White: PRINT "Client connected: ";: COLOR 12: PRINT addr$
     
        GET #c, , x$
     
        a = INSTR(x$, "GET ")
        b = INSTR(a + 5, x$, " ")
        request$ = RIGHT$(LEFT$(x$, b - 1), b - a - 4)
        COLOR Yellow, DarkRed
        PRINT "request = ";
        COLOR Black, Silver: PRINT request$
        IF LEN(request$) = 0 THEN PRINT x$
        COLOR Yellow, Black
     
        SELECT CASE request$
               CASE "/"
                    ff = FREEFILE
                    OPEN "index.html" FOR BINARY AS #ff
                    a$ = SPACE$(LOF(ff))
                    GET #ff, 1, a$
                    CLOSE ff
                    reply$ = "HTTP/1.0 200 OK" + crlf$ + crlf$
                    reply$ = reply$ + a$
               CASE "/screen"
                    SaveImage _COPYIMAGE(0), "screen"
                    ff = FREEFILE
                    OPEN "screen.bmp" FOR BINARY AS #ff
                    a$ = SPACE$(LOF(ff))
                    GET #ff, 1, a$
                    CLOSE ff
                    reply$ = "HTTP/1.0 200 OK" + crlf$
                    reply$ = reply$ + "Content-Length:" + STR$(LEN(a$)) + crlf$
                    reply$ = reply$ + "Content-Type: image/bmp" + crlf$ + crlf$
                    reply$ = reply$ + a$
               CASE ELSE
                    FourOhFour:
                    reply$ = "HTTP/1.0 404 Not found" + crlf$
                    reply$ = reply$ + "Content-Length: 103" + crlf$
                    reply$ = reply$ + "Content-Type: text/html" + crlf$ + crlf$
                    reply$ = reply$ + "<html><head><title>404 Not Found</title></head><body><p>This page does not exist.</p></body></html>" + crlf$ + crlf$
        END SELECT
        PUT #c, , reply$
        CLOSE c
        c = 0
        x$ = ""
        request$ = ""
        reply$ = ""
    END IF
    _LIMIT 30
LOOP
     
SUB SaveImage (image AS LONG, filename AS STRING)
    bytesperpixel& = _PIXELSIZE(image&)
    IF bytesperpixel& = 0 THEN PRINT "Text modes unsupported!": END
    IF bytesperpixel& = 1 THEN bpp& = 8 ELSE bpp& = 24
    x& = _WIDTH(image&)
    y& = _HEIGHT(image&)
    b$ = "BM????QB64????" + MKL$(40) + MKL$(x&) + MKL$(y&) + MKI$(1) + MKI$(bpp&) + MKL$(0) + "????" + STRING$(16, 0) 'partial BMP header info(???? to be filled later)
    IF bytesperpixel& = 1 THEN
        FOR c& = 0 TO 255 ' read BGR color settings from JPG image + 1 byte spacer(CHR$(0))
            cv& = _PALETTECOLOR(c&, image&) ' color attribute to read.
            b$ = b$ + CHR$(_BLUE32(cv&)) + CHR$(_GREEN32(cv&)) + CHR$(_RED32(cv&)) + CHR$(0) 'spacer byte
        NEXT
    END IF
    MID$(b$, 11, 4) = MKL$(LEN(b$)) ' image pixel data offset(BMP header)
    lastsource& = _SOURCE
    _SOURCE image&
    IF ((x& * 3) MOD 4) THEN padder$ = STRING$(4 - ((x& * 3) MOD 4), 0)
    FOR py& = y& - 1 TO 0 STEP -1 ' read JPG image pixel color data
        r$ = ""
        FOR px& = 0 TO x& - 1
            c& = POINT(px&, py&) 'POINT 32 bit values are large LONG values
            IF bytesperpixel& = 1 THEN r$ = r$ + CHR$(c&) ELSE r$ = r$ + LEFT$(MKL$(c&), 3)
        NEXT px&
        d$ = d$ + r$ + padder$
    NEXT py&
    _SOURCE lastsource&
    MID$(b$, 35, 4) = MKL$(LEN(d$)) ' image size(BMP header)
    b$ = b$ + d$ ' total file data bytes to create file
    MID$(b$, 3, 4) = MKL$(LEN(b$)) ' size of data file(BMP header)
    IF LCASE$(RIGHT$(filename$, 4)) <> ".bmp" THEN ext$ = ".bmp"
    f& = FREEFILE
    OPEN filename$ + ext$ FOR OUTPUT AS #f&: CLOSE #f& ' erases an existing file
    OPEN filename$ + ext$ FOR BINARY AS #f&
    PUT #f&, , b$
    CLOSE #f&
END SUB
     
