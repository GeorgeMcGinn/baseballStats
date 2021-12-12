# Baseball/Softball Statistical System
[![Licence CC NC-SA](https://img.shields.io/badge/License-CC%20NC--SA-green)](http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode) ![Linux Only](https://img.shields.io/badge/Linux_Only-Any-critical) [![QB64](https://img.shields.io/badge/QB64-v2.0%2B-informational)](https://www.qb64.org/portal/)  [![MySQL](https://img.shields.io/badge/MySQL-v8.0%2B-critical)](https://dev.mysql.com/downloads/mysql/) ![Zenity](https://img.shields.io/badge/Zenity-v3.32%2B-critical) ![enscript](https://img.shields.io/badge/enscript-1.6%2B-informational)
<br>
This application tracks multiple team's pitching, hitting and defensive statistics. It is licensed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International](https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode). If you want to incorporate this into a commercial package or in some way sell it, check out the [Licensing](#Licensing) section below.
&nbsp;
# Pre-release Version for QB64 Users
This is a Linux-only application, and currently this GitHub does not have the automatic installation script for the general public. Plus the Readme below is still a work in progress. When the official release is ready, there will be a release done here in GitHub.

This is a working system as it is right now. It will record and produce baseball or softball offensive, defensive and pitching statistics and reports for players and for multiple teams. Since I am still working on more advanced features (like left vs right hitters/pitchers) and differentiate seasons and divisions within a league. This can be used if you manage/coach one or more youth baseball teams, run a single baseball/softball league, or play a game like Strat-o-Matic Baseball. 

If you wish to track multiple seasons, the only way with this pre-release is to either create a new database with new tables, or create new tables within your database. When the official v1 release comes out, this will all be built in.

For now, users of QB64 need to have any version of Linux, install Zenity, and install and run the mySQL server. If you want formatted reports on your printer, make sure you have `enscript` installed. If not, then all reports will be displayed in the terminal.

I have provided binaries compiled in Ubuntu 20.04 LTS, and all the source code is in the `src` directory. To compile for you version of Linux if the binaries do not work, move the source to the main directory of this extract, and compile all five programs. 

If you run your applications from a `bin` like directory, the only directories/sub-directories with their files you will need are:
- Main directory (files only) and the following sub-directory with files
- Help directory and all its sub-directories
- Logs directory
- SQL directory

The rest of the directories are either needed to complete the compiles (like `include`), or have a future use in documentation for the general public.

I also have two SQL files (in the `sql` directory) called `pitchingTable.sql` and `battingTable.sql` that will load test data to your SQL tables so you can test the functionality of the system. You can execute these in either MySQL Workbench (or dbeaver-ce) or from the mysql terminal session. I will eventually include this as an option in the main menu, but for now they have to be manually run. Make sure you change the name of the database and tables to the ones you created.

***NOTE:** I know some of you use MariaDB or SQLite3. If you can, please share with me the changes you made to get it to work with these and any others you may be using, as I can incorporate that in the setup install and in the configuration file of this application. Send me a message at the email above (setup just for this project) or post it on the QB64 forum. The reason I ask is because I cannot install MariaDB or SQLite3 without it breaking my package manager (It took me more than 2 days to fix the issue when I tried to install MariaDB). If you do run a different DB other than mySQL, you will need to change the `include/baseballFunctions.inc` file, as the `SystemsCheck ()` function does a check to make sure all the required software is installed and if needs to be running, is running, otherwise the application will not run. Here it checks specifically for MySQL Server (both installed and running). There is also an independent check to make sure you are running on Linux as well in each of the modules.*
&nbsp;
# Requirements and Installation Instructions
<br>

## <u>Requirements</u>
This is a Linux-only application, and requires the following to be installed and/or running (Everything but QB64 should be available from your repository. Use your package manager to install them if not done already):
- **QB64 v2.0 or later *(May be required)*:** QB64 is what the application is written in. This distribution provides binaries compiled in Ubuntu 20.04 LTS. If it runs, then QB64 isn't needed. It will be needed if you need to recompile the modules to run on you version of Linux. To download this, click on the QB64 badge/image above and you will be taken to its download page, or go to the section on  [Installing QB64 and Compiling the Source Code](#InstallQB64) of this `Readme.md` below.
- **MySQL Server v8.0 or later *(Required)*:** You should be able to find this in your distribution repository. If not, click on the badge above and it will take you to the MySQL Community Server download page. MySQL Server needs to be running for this application to work.
- **Zenity (gdialog) v3.32 or later *(Required)*:** This also should be available from your Linux repository. Zenity (formally gdialog) is the GUI package this application uses. Zenity allows you to display GTK+ dialogs from shell scripts or programs; it is a rewrite of the 'gdialog' command from GNOME 1.
- **enscript v1.6 or later *(Optional)*:** Used to send formatted reports to your local printer. GNU Enscript takes ASCII files (often source code) and converts them to PostScript, HTML or RTF.  It can store generated output to a fil or send it directly to the printer. If the application does not detect enscript installed, it will display in a terminal instead of printing reports to the local printer.
&nbsp;
&nbsp;

## <u>Installing BaseballStats</u>

The following directions should get you going quickly:
1. Unzip the archive from GitHub to the baseballStats directory, or one of your choosing. All the sub-directories should not be changed, moved or deleted, except noted below.
2. Move the 5 binary files from the `bin` directory to the main directory (baseballStats).
3. Click on the program baseballStats. This is the main program that runs the application. If the binaries work in your version of Linux, and you have installed Zenity and have the MySQL server running, you should get a setup screen that looks like:<br>
![githubstrip](https://github.com/GeorgeMcGinn/baseballStats/blob/Master/.github/images/baseballStats%20-%20Main%20Menu.png?raw=true)

4. This is the initial setup of the baseballStats system. This process will create the databases and tables that you put into the input boxes, along with your mySQL USERID and PASSWORD. Update everything that asks you to **``(*****PLEASE UPDATE*****)``**. When you click **[CREATE]** button, the application will execute all the SQL statements required to setup your system. Notice that the SQL OUTPUT DIRECTORY is already populated with `/var/lib/mysql-files`. This is the default set up by mySQL, and does not have to be changed. Make sure that you have the correct privileges set up. If you get the error when running the application ***`(ERROR 1290 (HY000): The MySQL server is running with the --secure-file-priv option so it cannot execute this statement)`***, do the following:
```bash 
sudo nano /etc/mysql/my.cnf
```
At the bottom of this file, add the following two lines:
```bash
[mysqld] 
secure_file_priv="/var/lib/mysql-files/"
```
Then restart the mySQL server with:
```bash 
service mysql restart
``` 

(You may need to put sudo in front). <br><br>
&nbsp;
&nbsp;
![githubstrip](https://github.com/GeorgeMcGinn/baseballStats/blob/Master/.github/images/baseballStats%20-%20Install.png?raw=true)

5. If you get a setup screen and no messages about missing components in the  baseballstats.log file (located in the *logs* directory), and you created your SQL Region, you will get the main menu above. From here, you can now add baseball and sofrball data to your tables. 
6. The system has an extensive HELP file system, which you should familiarize yourself with.
&nbsp;
&nbsp;

<a name="InstallQB64"></a>
# Installing QB64 and Compiling the Source Code

QB64 is a modern extended BASIC+OpenGL language that retains QB4.5/QBasic compatibility and compiles native binaries for Windows (XP and up), Linux and macOS.

Download the appropriate package for your operating system over at https://github.com/QB64Team/qb64/releases. Extract the files into the location you plan to run it, such as in your `home` directory, or a `bin` inside your home directory where you already have your PATH variable pointed to.

If not, setting your PATH to include the qb64 directory will make compiling the baseballStats application, and any changes you want to make to it easier. There is a section that includes how to set up the Geany Editor to compile QB64 programs directly from this IDE. There is also a compiler script I wrote that makes compiling programs in the terminal easier.


<a name="QB64Linux"></a>
## <u>Linux</u>
Once you have installed the qb64 directories and files, open your terminal and do a `cd` to the directory. You can also in your `Files` program, right-click on the qb64 directory and select `Open in Terminal`.

In your terminal, once you are in the qb64 directory, you need to compile the QB64 compiler and IDE for your version of Linux. Execute the following in your terminal:
```bash
./setup_lnx.sh
```

Dependencies should be automatically installed. Required packages include OpenGL, ALSA and the GNU C++ Compiler.

<a name="QB64Usage"></a>
## <u>Usage</u>
Once you create the QB64 binary (it will reside in the qb64 folder), run the QB64 executable to launch the IDE, which you can use to edit your .BAS files. From there, hit F5 to compile and run your code.

To generate a binary without running it, hit F11.

Additionally, if you do not wish to use the integrated IDE and to only compile your program, you can use the following command-line calls:

```qb64 -c yourfile.bas```

```qb64 -c yourfile.bas -o outputname.exe```

Replacing `-c` with `-x` will compile without opening a separate compiler window.
<br>


<a name="Additional_Info"></a>
# Additional Information on QB64
More about QB64 at our wiki: www.qb64.org/wiki

There is a community forum at: www.qb64.org/forum

The QB64 team tweets from: [@QB64Team](https://twitter.com/QB64team)

Find QB64 on Discord: http://discord.qb64.org

<br>

* * *
<br>

<a name="Licensing"></a>
# Licensing Information
<p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"></p>
<a href="https://github.com/GeorgeMcGinn/baseballStats">Baseball/Softball Statisical System</a> by 
<a href="https://www.linkedin.com/in/georgemcginn/">George McGinn</a> is licensed under <br>Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International <a href="https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode">CC BY-NC-SA 4.0</a>
<br>
<br>
Ubuntu Fonts distributed with this application are licensed by the <a href="hhttps://ubuntu.com/legal/font-licence">Ubuntu font licence</a> or as available in the `UBUNTU FONT LICENSE Version 1.0.md` file included with this distribution.
<br>
<br>
Questions or permissions beyond the scope of this license may be available at <a href="mailto:gbytes58@gmail.com?subject=Baseball/Softball Statisical System Licensing">Contact: George McGinn (Email)</a>
<br>
<br>

* * *
<br>

***Last Update: 12/11/2021 21:08***
