# Baseball/Softball Statistical System
[![Licence CC NC-SA](https://img.shields.io/badge/License-CC%20NC--SA-green)](http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode) ![](https://img.shields.io/badge/Linux_Only-Any-critical) [![QB64](https://img.shields.io/badge/QB64-v2.0%2B-informational)](https://www.qb64.org/portal/)  [![MySQL](https://img.shields.io/badge/MySQL-v8.0%2B-critical)](https://dev.mysql.com/downloads/mysql/) ![Zenity](https://img.shields.io/badge/Zenity-v3.32%2B-critical) ![](https://img.shields.io/badge/enscript-1.6%2B-informational)
<br>
This application tracks multiple team's pitching, hitting and defensive statistics. It is licensed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International](https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode). If you want to incorporate this into a commercial package or in some way sell it, check out the [Licensing](#Licensing) section below.
&nbsp;
# Pre-release Version for QB64 Users
This is a Linux-only application, and currently this GitHub does not have the automatic installation script for the general public and this Readme is still a work in progress. When the official release is ready, there will be a release done here in GitHub.

This is a working system as it is right now. It will record and produce baseball or softball offensive, defensive and pitching statistics and reports for players and for multiple teams. Since I am still working on more advanced features (like left vs right for batters and pitchers) and to differentiate seasons and divisions within a league. This can be used if you manage/coach one or more youth baseball teams, run a single baseball/softball league, or play a game like Strat-o-Matic Baseball. 

If you wish to track multiple seasons, the only way to do this with this pre-release is to either create a new database with new tables, or create new tables within your database. When the official v1 release comes out, this will all be built in.

Also built into the HELP and ABOUT boxes is CSS to automatically detect and switch between Light, Dark and Standard desktop themes. The dark themes are based on what Ubuntu produces. 

However, if you use a desktop template, a different Linux distro, or changed the colors of your Dark Theme, then in the `/help` directory is a file `baseballStyle.css`, where you can change the colors of both the background and foreground for your Dark Theme. The rest will change according to your system.

For now, users of QB64 need to have any version of Linux, install Zenity, and install and run the MySQL server. If you want formatted reports on your printer, make sure you have `enscript` installed. If not, then all reports will be displayed in a generated screen.

The binaries in the `bin` directory were compiled in Ubuntu 20.04 LTS. You can first copy these into your project directory and see if they will run. To start, you need to run baseballStats binary to let it setup your system and create/allocate your database, tables, and configuration file.

If the binaries do not work, you will need to compile the five program located in the `src` directory. To compile for you version of Linux, copy the source code to the main project directory of this extract, and compile all five programs (the `include` directory is needed as a sub-directory to do compiles. You can do these compiles from either the QB64 IDE or externally from the terminal, so long as your teminal session is in the project's main directory.

If you run your applications from a `bin` or `application` like directory, the only directories/sub-directories with their files you will need are:
- Main directory (files only minus source code) and the following sub-directory with files
- Help directory and all its sub-directories
- Logs directory
- SQL directory

The rest of the directories are either needed to complete the compiles (like `include`), or have a future use in documentation for the general public.

I also have two SQL files (in the `sql` directory) called `pitchingTable.sql` and `battingTable.sql` that will load test data to your SQL tables so you can test the functionality of the system. You can execute these in either MySQL Workbench (or dbeaver-ce) or from the `mysql` terminal session. I will eventually include this as an option in the main menu, but for now they have to be manually run. Make sure you change the name of the database and tables to the ones you created.

***NOTE:** I know some of you use MariaDB or SQLite3 (and possibly other relational database packages). If you can, please share with me any changes you made to get it to work with these and any others you may be using, as I can incorporate that in the setup install and in the configuration file of this application. Send me a message at the email above (setup just for this project) or post it on the QB64 forum. The reason I ask is because I cannot install MariaDB or SQLite3 without it breaking my package manager (It took me more than 2 days to fix the issue when I tried to install MariaDB). If you do run a different relational DB other than mySQL, you will need to change the `include/baseballFunctions.inc` file, as the `SystemsCheck ()` function does a check to make sure all the required software is installed and if needs to be running, is running, otherwise the application will not run. Here it checks specifically for MySQL Server (both installed and running). There is also an independent check to make sure you are running on Linux as well in each of the modules.*

The following will replace the above text so the public can download, install and use this system.
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

5. If you get a setup screen and no messages about missing components in the  baseballstats.log file (located in the *logs* directory), and you created your SQL Region, you will get the main menu above. From here, you can now add baseball and softball data to your tables. 
6. The system has an extensive HELP file system, which you should familiarize yourself with.
&nbsp;
&nbsp;

<a name="Running BaseballStats"></a>
# Running BaseballStats
Once you have loaded the binaries to the main directory (or followed the recompile process), you need to click on the `baseballStats` module to get started. After you are presented with an introduction/splash screen, if this is the first time executing the program, a check box where you must acknowledge the license and conditions for using the program. Nothing will happen until you check that box. Once you do, the [OK] button will become available and you can proceed to setup your MySQL database and tables.

While all the programs are also designed to run stand-a-lone, if you do not go through the set up process, all the programs will error out. If you try to run a module and nothing happens, check the `logs` directory for the file `baseballStats.log` and open it up in a text editor. Below are some of the errors you may encounter:

```
*** Batting Stats Log File ***

>>>>> Executing SUB LoadConfigFile

*** pitchingStats ERROR: config.ini File Missing, Program Terminated.

```
This shows that the pitchingStats module failed due to lack of set up.


```
*** BaseballStats Log File ***

>>>>> Executing PGM=baseballStats

*** (baseballStats) ERROR: Program runs in Linux only. Program Terminated. ***

>>>>> Executing endPROG

*** baseballStats - Terminated Normally ***
```
This shows that you tried to run the binaries on a system that isn't Linux.

The log file records everything that the system does, including all the SQL it executes, return codes, and what buttons were pressed. Since this is a multi-program system, it tells you which program was running, was called.

Unless you encounter an error, you will not have a need to look at this file. Most errors, such as dependencies not installed will be found here, and you can correct those. However, if there is a program logic error, a message will appear towards the bottom of the log. 

For support, please send me the entire log, what release you are running, and as detailed as possible the issue you are having. I may need to have you export your MySQL tables, and if so, I can guide you through that process.

I have included what a typical log file looks like in this release.

Once you run through the set up process, you can run the application from its main program, `baseballStats`, or any of the other programs, such as the `battingStats` if you just want to work on batting statistics, `pitchingStats` for pitching records, `leagueStats` to just look at your league statistics, or the `baseballConfig` to update your configuration file.

This application will work with Linux's Dark, Light and Regular themes with one exception that I know of from the pre-release. I've set the Dark Theme to that of Ubuntu's 20.04. 

However, if you use a desktop template or changed the colors of your Dark Theme, then in the `/help` directory is a file `baseballStyle.css`, where you can change the colors of both the background and foreground for your Dark Theme. The rest will change according to your system.



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
<a href="https://github.com/GeorgeMcGinn/baseballStats"><b>Baseball/Softball  Statistical System</b></a> by 
<a href="https://www.linkedin.com/in/georgemcginn/">George McGinn</a> is licensed under <br>Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International <a href="https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode">CC BY-NC-SA 4.0</a>
<br>
<br>
<b>Icons & Images</b> used in this application were downloaded from <a href="https://wallpapercave.com/w/wp3206832">Wallpaper Cave</a>, an online community that shares images and <a href="https://www.vecteezy.com/">Vecteezy</a>.
<br>
<br>
<b>Ubuntu Fonts</b> distributed with this application are licensed by the <a href="https://ubuntu.com/legal/font-licence">Ubuntu font licence</a> or as available in the <code>Ubuntu Fonts License.md</code> file included with this distribution.
<br>
<br>
Licenses for <b>QB64</b> can be found at their GitHub page: <a href="https://github.com/QB64Team/qb64/blob/development/licenses/COPYING.TXT">QB64 Licensing Information</a>
<br>
<br>
<b>MySQL Community Edition 8.0</b> is licensed under the GNU General Public License Version 2.0, June 1991, and can be found at <a href="https://downloads.mysql.com/docs/licenses/mysqld-8.0-gpl-en.pdf">MySQL 8.0 Licensing Information User Manual</a>
<br>
<br>
<b>Zenity</b> is licensed under the GNU Lesser General Public License v2.1, February 1999, and can be found at <a href="https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html">GNU Lesser General Public License, version 2.1</a>
<br>
<br>
Questions or permissions beyond the scope of this license may be available at <a href="mailto:gbytes58@gmail.com?subject=Baseball/Softball Statistical System Licensing">Contact: George McGinn (Email)</a>
<br>
<br>

* * *
<br>

<b><i><small>Last Update: 12/15/2021 13:10</small></i></b>
