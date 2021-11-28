#!/bin/sh
 
zenity --list \
       --title="Redsox Pitching Stats" \
       --width=1350 --height=500 --checklist \
      --ok-label=Update --extra-button=Report --extra-button=HELP --extra-button=QUIT \
 --column="S" --column="PLAYER" --column="W" --column="L" --column="SV" --column="SVO" --column="GP" --column="GS" --column="GC" --column="IP" --column="TBF" --column="H" --column="BB" --column="K" --column="RA" --column="ER" --column="HR" --column="HBP" --column="SF" --column="ERA" --column="OPP-AVG" --column="WHIP" --column="BABIP" --column="FIP" \
""	"Sale, C"	1	0	0	0	1	1	1	9.0	44	13	4	14	9	9	3	0	0	9.00	0.325	1.889	0.370	5.77 \
""	"Price, D"	0	0	0	0	1	1	0	8.0	30	5	0	11	2	2	2	0	0	2.25	0.167	0.625	0.176	3.71 \
""	"Workman, B"	1	0	0	0	1	0	0	1.0	7	1	2	2	1	1	0	0	0	9.00	0.200	3.000	0.200	5.21 \
""	"Rodriguez, E"	1	0	0	0	1	1	1	9.0	42	8	3	10	2	2	2	0	0	2.00	0.205	1.222	0.200	4.88 \
