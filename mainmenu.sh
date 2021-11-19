#!/bin/sh
 
zenity --list \
	   --title=" Main Menu - Baseball/Softball Statistics System - v1.0" \
	   --text="Select/Double Click on Option to Process:" \
	   --width=420 --height=225 --column="Select One" --hide-header \
	   --extra-button=HELP --extra-button=QUIT  \
"Boxscores - Add/Update" \
"Batting - Add/Update"  \
"Pitching - Add/Update" \
"League/Team Stats" \
"Create New SQL Region" \
"Config File"
