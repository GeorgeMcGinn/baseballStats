#!/bin/sh

zenity --text-info \
       --title="HELP: Team Input Form" \
       --html --ok-label="Return to Menu" \
       --width=850 --height=800 \
       --filename="help/baseballStats.html"  2> /dev/null

