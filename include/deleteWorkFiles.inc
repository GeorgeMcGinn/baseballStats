	IF _FILEEXISTS("updatebattingstats.sh") THEN KILL "updatebattingstats.sh"
	IF _FILEEXISTS("battingstats.sh") THEN KILL "battingstats.sh"	
	IF _FILEEXISTS("updatepitchingstats.sh") THEN KILL "updatepitchingstats.sh"
	IF _FILEEXISTS("pitchingstats.sh") THEN KILL "pitchingstats.sh"
	IF _FILEEXISTS("leaguestats.sh") THEN KILL "leaguestats.sh"
	IF _FILEEXISTS("teambattingstats.sh") THEN KILL "teambattingstats.sh"
	IF _FILEEXISTS("teampitchingstats.sh") THEN KILL "teampitchingstats.sh"
	IF _FILEEXISTS("leaguestats.prn") THEN KILL "leaguestats.prn"
	IF _FILEEXISTS("teambattingstats.prn") THEN KILL "teambattingstats.prn"
	IF _FILEEXISTS("teampitchingstats.prn") THEN KILL "teampitchingstats.prn"
	IF teamName <> NULL THEN 
		ReportFile$ = teamName + "battingstats.prn"	
		IF _FILEEXISTS(ReportFile$) THEN KILL ReportFile$
		ReportFile$ = teamName + "pitchingstats.prn"	
		IF _FILEEXISTS(ReportFile$) THEN KILL ReportFile$
		battingfile$ = mysql_outputdir$ + teamName + "-battingstats.file"
		IF _FILEEXISTS(battingfile$) THEN KILL battingfile$
		pitchingfile$ = mysql_outputdir$ + teamName + "-pitchingstats.file"
		IF _FILEEXISTS(pitchingfile$) THEN KILL pitchingfile$
	END IF
	leaguefile$ = mysql_outputdir$ + "leaguestats.file"
	IF _FILEEXISTS(leaguefile$) THEN KILL leaguefile$
	battingfile$ = mysql_outputdir$ + "teambattingstats.file"
	IF _FILEEXISTS(battingfile$) THEN KILL battingfile$
	pitchingfile$ = mysql_outputdir$ + "teampitchingstats.file"
	IF _FILEEXISTS(pitchingfile$) THEN KILL pitchingfile$
	IF _FILEEXISTS("pipestderr") THEN KILL "pipestderr"    
