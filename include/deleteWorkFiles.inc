	IF _FILEEXISTS("updatebattingstats.sh") THEN KILL "updatebattingstats.sh"
	IF _FILEEXISTS("battingstats.sh") THEN KILL "battingstats.sh"	
	IF _FILEEXISTS("updatepitchingstats.sh") THEN KILL "updatepitchingstats.sh"
	IF _FILEEXISTS("pitchingstats.sh") THEN KILL "pitchingstats.sh"
    IF _FILEEXISTS("leaguestats.sh") THEN KILL "leaguestats.sh"
    IF _FILEEXISTS("teambattingstats.sh") THEN KILL "teambattingstats.sh"
    IF _FILEEXISTS("teampitchingstats.sh") THEN KILL "teampitchingstats.sh"
    IF _FILEEXISTS("leaguestats.prn") THEN KILL "leaguestats.prn"
    IF teamName <> "" THEN 
		ReportFile$ = teamName + "battingstats.prn"	
		IF _FILEEXISTS(ReportFile$) THEN KILL ReportFile$
		ReportFile$ = teamName + "pitchingstats.prn"	
		IF _FILEEXISTS(ReportFile$) THEN KILL ReportFile$
		battingfile$ = "/var/lib/mysql-files/" + teamName + "-battingstats.file"
		IF _FILEEXISTS(battingfile$) THEN
			cmd = "echo y | rm " + battingfile$
			SHELL (cmd)
		END IF
		pitchingfile$ = "/var/lib/mysql-files/" + teamName + "-pitchingstats.file"
		IF _FILEEXISTS(pitchingfile$) THEN
			cmd = "echo y | rm " + pitchingfile$
			SHELL (cmd)
		END IF
	END IF
    leaguefile$ = "/var/lib/mysql-files/leaguestats.file"
    IF _FILEEXISTS(leaguefile$) THEN
        cmd = "echo y | rm " + leaguefile$
        SHELL (cmd)
    END IF
    battingfile$ = "/var/lib/mysql-files/teambattingstats.file"
    IF _FILEEXISTS(battingfile$) THEN
        cmd = "echo y | rm " + battingfile$
        SHELL (cmd)
    END IF
    pitchingfile$ = "/var/lib/mysql-files/teampitchingstats.file"
    IF _FILEEXISTS(pitchingfile$) THEN
        cmd = "echo y | rm " + pitchingfile$
        SHELL (cmd)
    END IF
	IF _FILEEXISTS("pipestderr") THEN KILL "pipestderr"    
