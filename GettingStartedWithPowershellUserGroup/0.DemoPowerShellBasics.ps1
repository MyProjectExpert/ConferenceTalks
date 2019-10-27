#################################################################
#
#  There are two ways to comment code in a PowerShell Script
#  Notice the DOTTED KEYWORD
#################################################################
<#
.AUTHOR
	Michael Wharton
.Date
	11/30/2014
.Updated
    10/123/2019 
.FILENAME
        0.DemoPowerShellBasics.PS1
.SYNOPSIS
	Demo of basics of using Powershell
.DESCRIPTION
	Go over the 10 key concepts of PowerShell
.PARAMETER serverInstance
	NONE
.EXAMPLE
	.\DemoPowerShellBasisc 
.INPUTS
	Server Object
.NOTES
 	Demo of PowerShellBasics
    http://PowerShell.org
    Document:    "Windows Powershell -EN.PDF"

    Keys to learning PowerShell (Jeff Snover and Don Jones)
    MASTER the following:
    1) Learn how to Learn
    2) Get-Help & Update-Help
    3) Get-Command & Show-Command
    4) Get-Member & Sort-Object
    5) Get-PSDrive

.AGENDA 
	 1. Essential Commands - (Get-Help, Get-Service, Get-Command, Get-Member)
     2. Seeting Security Policy
     3. To Execute a Sript
     4. Variables
     5. Arrays
     6. Constants
     7. Functions
     8. Creating Objects
     9. Writing Output
    10. Captuer User Input
    11. Passing Command Line Arguments
    12. Miscellanous  (Line Breaks, Comments, Merging Lines, PIPING)

    13. Do WHile Loop
    14. Do Until Loop
    15. For Loop
    16. ForEach Loop
    17. If Statuement
    18. Switch Statement

    19. Reading from a File
    20. Writing to a Simple File
    21. Writing to an HTML File
    22. Writing to a CSV File
#>
#############################################################################################
# Some Simple thigs to do with PowerShell -- programs,  start process, web sites
#############################################################################################
start Excel.exe   C:\Temp\Demo.xlsx
start winWord.exe C:\Temp\Demo.docx
# 
Start http://bing.com
Start-Sleep -seconds 1
start http://google.com
Start-Sleep -seconds 1
start http://MyProjectExpert.com
Start-Sleep -seconds 1
start http://WhartonComputer.com
Start-Sleep -seconds 1

cls
#$URL = "http://laba-2013sp/PWA/Projects.aspx"
#$URL = "http://MyProjectExpert.domainName.local"
#Start-Process "C:\Program Files\Internet Explorer\iexplore.exe" -ArgumentList $URL
#Start-Process "C:\Program Files\Internet Explorer\iexplore.exe" -ArgumentList $URL -Credential "domainName\userName"
##
#$URL = "http://serverName.domainName.local"
#$username = "domainName\userName"
#$admin    = "domainName\userName"
#$password = "MyPassword#1"
#$UserCred  = New-Object System.Management.Automation.PSCredential -ArgumentList @($username,(ConvertTo-SecureString -String $password -AsPlainText -Force))
#$AdminCred = New-Object System.Management.Automation.PSCredential -ArgumentList @($admin,(ConvertTo-SecureString -String $password -AsPlainText -Force))
#Start-Process "C:\Program Files\Internet Explorer\iexplore.exe" -ArgumentList $URL -Credential ($UserCred)
#Start-Process "C:\Program Files\Internet Explorer\iexplore.exe" -ArgumentList $URL -Credential ($AdminCred)
#############################################################################################
# Some Simple thigs to do with PowerShell -- check processes
#############################################################################################
CLS

#### SQL
Get-Service
Get-Service -Name *SQL* 
Get-Service -Name *SQL* -ComputerName "computerName"
Get-Service -Name *SQL* | Sort-Object Status
Get-Service -Name *sql* | Where-Object {$_.Status -eq 'Stopped'}
Get-Service -Name *sql* | Where-Object {$_.Status -eq 'Running'}

Get-Service
Get-Service | Sort-Object name
Get-Service s* | Sort-Object name

Get-Service -Name *SQL*      # SQL Server Service for SQL support

Get-Service s* | Where-Object status -eq "Stopped"
Get-Service s* | Where-Object status -like "stop*"
Get-Service s* | Where-Object status -ne "Stopped"
Get-Service s* | where-object {$_.Status -ne "Stopped"}

Get-help get-service -examples

#### SQL
########################################
$unit = "GB"
$measure = "1$unit"
$wmiQuery = @"
    SELECT systemName, Name, DriveType, FileSystem, FreeSpace, Capacity, Label
    FROM Win32_Volume
"@

Get-WmiObject -ComputerName $env:COMPUTERNAME -Query $wmiQuery |
    SELECT SystemName, Name, Label, DriveType, FileSystem,
           @{Label="Sizein$unit";Expression={"{0:n2}" -f ($_.Capacity/$measure)}},
           @{Label="Freein$unit";Expression={"{0:n2}" -f ($_.Freespace/$measure)}},
           @{Label="PercentFree";Expression={"{0:n2}" -f (($_.freespace/$_.capacity)*100)}} |
    Where-Object {$_.name -notlike '\\?\*'} |
    Sort-Object Name |
    Format-Table -AutoSize -Property SystemName, Name, Label, DriveType, FileSystem,
           @{Label="Size in $unit"; Align="Right"; Exp={($_."SizeIn$Unit")}},
           @{Label="Free in $unit"; Align="Right"; Exp={($_."FreeIn$Unit")}},
           @{Label="Percent Free" ; Align="Right"; Exp={($_.PercentFree)}}


#############################################################################################
# Some Simple thigs to do with PowerShell -- Search log files
# -Pattern for regular expression match
# -SimpleMatch for text match (more effiecent)
#############################################################################################
#select-string -Pattern "error" -path "c:\windows\logs\*\*.log"
select-string -Pattern "hello" -path "c:\temp\*.txt"
select-string -Pattern "Error" -path "c:\temp\*.txt"
select-string -Pattern "Error" -path "c:\temp\*.txt" -Context 2,1
select-string -Pattern "error","Warning" -path "c:\windows\logs\*\*.log" -Pattern "error","Warning"
select-string -SimpleMatch "error","Warning" -path "c:\windows\logs\*\*.*"

#### SQL
$sqllog = "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Log\*.*"
select-string -SimpleMatch "error","Warning" -path $sqllog
#############################################################################################
# Some Simple thigs to do with PowerShell -- Search log files
#############################################################################################
#############################################################################################
Get-EventLog -List

#### SQL
# Filter for SQL errors in past 3 days
#                                  SQL can be used
Get-EventLog Application |
    Where-Object {$_.source -like '*SQL*'  `
        -and $_.EntryType -EQ "Error" `
        -and $_.TimeGenerated -ge ((Get-date).AddDays(-30)) `
        } |
    Format-List

# Count Number of errors
#  Using Group-Object
Get-EventLog Application |
    Where-Object {$_.source -like '*vss*'  `
        -and $_.EntryType -EQ "Error" `
        -and $_.TimeGenerated -ge ((Get-date).AddMonths(-1)) `
        } |
    Group-Object Message |
    Sort-Object -Descending count |
    Format-Table -AutoSize Count, name

Get-Eventlog -Newest 5 -LogName System
$events = Get-EventLog -LogName System -Newest 100
$events | Group-Object -Property source -NoElement | Sort-Object 
get-eventlog -logname System -EntryType Error
get-eventlog -LogName System -EntryType Warning
#
Get-eventlog -LogName Application -Source MSSQLSERVER -Newest 10 
Get-eventlog -LogName Application -Source MSSQLSERVER -Newest 10 -EntryType Error
Get-eventlog -LogName Application -Source MSSQLSERVER -Newest 10 -EntryType warning
#############################################################################################
# Ping or test servers up
cls
#### SQL
Test-Connection localhost
Test-Connection Bing.com
Test-Connection computerName, BING.COM

Test-Connection LABA-2013SP, LABA-2012SQL
Test-Connection LABA-2013SP, LABA-2012SQL -Source 192.168.1.22
Test-Connection LABA-2013SP, LABA-2012SQL -Source computerName -Credential domainName\userName
$PngRtn = Test-Connection Bing.com
$PngRtn |Get-member
$Pngrtn | format-list
#############################################################################################
# Login Attempts
#############################################################################################
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
#$url = "http://www.TestKing.com"
#$ie = New-Object -ComObject internetexplorer.application
#$ie.Visible = $true
#$ie.Navigate($url)
#$ie.Document.getElementByID("loginhref").click();
#$ie.Document.getElementByID("login").value = "bogus@bogus.com"
#$ie.Document.getElementByID("pass").value = "MyPassword"
#$ie.Document.getElementByID("loginboxForm").submit();
#
#$url = "http://www.FaceBook.com"
#$ie = New-Object -ComObject internetexplorer.application 
#$ie.Visible = $true
#$ie.Navigate($url)
#$ie.Document.getElementByID("email").value ="bogus@bogus.com"
#$ie.Document.getElementByID("pass").value = "MyPassword"
#$ie.Document.getElementByID("loginbutton").click();
##
#$url = "http://mail.computerName.com/IClient/Login.aspx"
#$ie = New-Object -ComObject internetexplorer.application
#$ie.Visible = $true
#$ie.Navigate($url)
#$ie.Document.getElementByID("txtUserName").value = "bogus@bogus.com"
#$ie.Document.getElementByID("txtPassword").value = "MyPassword"
#$ie.Document.getElementByID("lbLogin").click();
#############################################################################################
# Essential Commands 
#     2) Get-Help & Update-Help
#     3) Get-Command & Show-Command
#     4) Get-Member & Sort-Object
#     5) Get-PSDrive
#############################################################################################
# To Get Help  on any cmdlet use Get-Help
Get-Help
Get-Help -Examples
Get-Help -Full
Get-Help -Detailed
Get-Help -Name pool
Get-Help -Category All
cls
Get-Help Get-Service
Get-Service

# To get all available cmdlet use get-command
Get-Command

# To get all properities and methdos for an object use get-member
Get-Service | Get-Member

Get-Help Update-Help -Online
Update-Help   ## Gets the latest updates to PowerShell

############################################################
# Learn How to Learn Powershell
#   Get-Help - MORE ON GET-HELP
#   Get-Command 
#
#
#
############################################################
Update-Help   ## Gets the latest updates to PowerShell

Get-Help
Get-Help -Examples
Get-Help -Full
Get-Help -Detailed
Get-Help -Name pool
Get-Help -Category All
Get-Help -Component  ??
Get-Help Update-Help -Online
CLS
Get-Help Get-Service -Examples

############################################################
#   Commands (4 types) 
#   1. Cmdlets        Verb-Noun   New-SPWebApplication, Remove-SPWebApplication
#   2. Functions      One or more commands that can be resused in script
#                     Close host and lose funtions...so put in the profile
#   3. Scripts        Commands, functions, Loops, inputs, etc
#                     Saves as PS1 files
#   4. Native Commands NotePad.exe, STSADM.exe, etc
############################################################

############################################################
#   Get-Command
############################################################
Get-Command
Get-Command -Name SQL 

Get-Command -Name DIR 
Get-Command -Verb NEW
Get-Command -Verb GET
Get-Command -Noun SPWEb
Get-Command -Noun SPSite

Get-Command -Module AppLocker
Get-Command -Module DISM
Get-Command -Module NFS
Get-Command -Module NetSecurity
Get-Command -Module PKI
Get-Command -Module PSworkflow

Get-Command -Module Microsoft.Powershell.Core
Get-Command -Module Microsoft.Powershell.Utility
Get-Command -Module Microsoft.SharePoint.Powershell
Get-Command -Module Microsoft.SharePoint.Powershell -name SP*
Get-Command -Module Microsoft.SharePoint.Powershell -name *SPWeb*
Get-Command -Module Microsoft.SharePoint.Powershell -verb Back*
Get-Command -Module *

Get-Command -CommandType Alias
Get-Command -CommandType All
Get-Command -CommandType Application
Get-Command -CommandType Cmdlet
Get-Command -CommandType Filter
Get-Command -CommandType Function
Get-Command -CommandType Script
Get-Command -CommandType Workflow

Get-Command -All

#############################################################################################
# Create file for next 
#############################################################################################
$myString = @"
#MyScript.ps1
#
# Hello World
Write-Host "Hello World"
Write-Host "Hello World"
Write-Host "Hello World"
Write-Host "Hello World"
Write-Host "Hello World"
"@
Set-Content "C:\demo\MyScript.ps1" -Value  $myString
#
Type "C:\demo\MyScript.ps1"
cls
#############################################################################################
# To Execute Script from command prompt
powershell.exe "C:\demo\myscript.ps1"
#############################################################################################
# Executing powershell script from PowerShell
&"C:\demo\myscript.ps1"
#############################################################################################
cls
Type "C:\demo\myscript.ps1"
Alias Type
Get-Content "C:\demo\myscript.ps1"
#############################################################################################
# Setting Security Policy
Set-ExecutionPolicy "Unrestricted" 
Set-ExecutionPolicy "Unrestricted" -Force:$true
Get-help Set-ExecutionPolicy -Examples 
#############################################################################################
# Piping - More on this later
Get-Service
Get-Service | Sort-Object name
Get-Service s* | Sort-Object name
Get-help get-service -examples

Get-Service s* | Where-Object status -eq "Stopped"
Get-Service s* | Where-Object status -like "stop*"
Get-Service s* | Where-Object status -ne "Stopped"

Get-Service s* | where-object {$_.Status -ne "Stopped"}
# SQL Server
Get-Service *sql* | Where-Object status -ne "Stopped" | Sort-Object displayName

# Get-SPServiceApplication
#############################################################################################
# Variables
$ Must start with $
CD \

$Farm = "Hello World"
$Farm
ClS

$a=32
[int]$a=32
$a
$b=5+5
$b

#  For SharePoint Demo
#Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
$Farm = Get-SPFarm
$Farm
$Farm | select *
#$farm.GetType().FullName   #  ????
$farm | Get-Member
$farm.Status
$farm.Servers
$farm.BuildVersion

#############################################################################################
# Arrays
# To Initialise
$a=1,2,4,8
$a
$b=$a[3]
$b

#############################################################################################
# Constants
Set-Variable -name MyConstant -value 3.2233 -option constant
# Reference with $
$MyConstant

#############################################################################################
# Functions
# parameters seperate by space. Return is optional
function MySum ([int]$a, [int]$b)
{
return $a + $b
}

MySum 3 2
MySum 10 20
MySum 1 2
#############################################################################################
# Creating Objects
# To create an instance of a com object   New-Object -comobject<ProgID>
$MyName = new-Object -comobject "wscript.network"
$MyName.username

# To create an instance of a .NET frame object. Parameters can be passed if required
# New-Object -type<.net object>
$MyTime = New-object -type system.datetime 2006,12,25
$MyTime
$MyTime.Get_DayOfWeek()

#############################################################################################
# Writing to Console
$Status = "OK - What a Great Day to Learn PowerShell"
write-host -ForegroundColor Yellow $Status
write-host $status -ForegroundColor Red 
write-host $status -ForegroundColor Green
write-host $status -ForegroundColor Yellow

#############################################################################################
# Capture User Input
# User to Read-Host to get user input
$MyName = Read-Host "Enter Your Name"
Write-Host "Hello" $MyName -ForegroundColor Yellow

#############################################################################################
# Passing Command Line Arguments
# Passed to script with spaces
MyScript.ps1 ServerName UserName

#Access with script by $args array
$ServerName= $args[0]
$UserName = $args[1]

# Miscellaneous
#############################################################################################
# Line Break ` (tick and not appostre)
Get-Process | Select-Object `
name, id

# Comments #
# Code here not executed

# Merging Lines
$a=1; $b=2; $c=3; 
$a=1; $b=2; $c=3; write-host $a $b $c -foregroundcolor yellow
write-host $a $b $c -foregroundcolor yellow

# Pipe the output to another command
Get-Service | Get-Member
#############################################################################################
#####   SharePoint  ##########################################################################
#############################################################################################
#############################################################################################
#############################################################################################
Get-SPFarm
# Adding snap-in
Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

If ((Get-PSSnapin Microsoft.SharePoint.PowerShell -EA SilentlyContinue) -eq $null)
    {Add-PSSnapin Microsoft.SharePoint.Powershell}
 Else 
    {"SharePoint.Powershell is Already Loaded" | echo}

#############################################################################################
# Looping
# Do While Loop
# Can repeart of set of commands while a condition is met
$a=3
Do{$a;$a++;}
While ($a -lt 10)

#  The bracket sow what needs to be done
$a=1
Do{write-host $a -foregroundcolor red;$a++;}
While ($a -lt 11)

# Do Until Loop
# can Repeat a set of comands untila condition is met
$a=1
Do{$a;$a++;}
UNTIL ($a -gt 10)

# For Loop
# Repeat the same steps a specific number of times
For ($a=1; $a -le 10; $a++)
{$a}

# ForEach -Loop Through Collection of Objects
# Loop through a collection of objects
Foreach ($i in Get-Childitem C:\Windows\*.log)
{$i.name; $i.creationtime}

# If Statement
#Run a specific set of code given specific conditions
$a= "Blue"
if ($a -eq "red")
    {"The Color is red"}
elseif ($a -eq "white")
    {"The color is white"}
else
    {"Another Color"}


# Switch Statement
# Another method to run a specific set of code given specific conditions
$a = "blue"
switch ($a)
{
    "red"   {"The color is red"}
    "white" {"The color is white"}
    Default {"another color"}
}

#############################################################################################
# Reading from a File
# Use Get-Content to create an array of lines.  Then loop thru array
$a = Get-Content "C:\temp\servers.txt"
foreach ($L in $a)
{$L}

# Writing to a Simple File
# Use Out-file or > for a simple test file
$a = "Hello World"
$a | out-file c:\temp\Servers.txt

# or use > to output script result to file
.\test.ps1 > C:\Temp\Test.txt

# Writing to a HTML File
# User ConvertTo-HTML and > 
$a = Get-Process
$a | Convertto-HTML -property Name,Path,Company > c:\Temp\Test.htm


# Writing to a CSV File
# Use Export-CSV and Select-Object to filter output
$a = Get-Process
$a | Select-Object Name,Path,Company | Export-csv -path C:\temp\Test.csv

#>
############################################################
#  Powershell Objects
#     Properties
#     Methods
#   
#   Coming back to this when getting into SharePoint or SQL objects
############################################################

############################################################
# enviroment
############################################################
Get-ChildItem env:
Get-ChildItem env:computername
$tempSqlServer = (Get-ChildItem env:computername).name
$tempSqlServer = (Get-ChildItem env:computername).value

$domain = (Get-ChildItem env:userdomain).value
$tempfarmaccount = $domain.ToString() + '\sp_farm' 
############################################################
#
#  Alias
#
DIR
GCI
Get-Alias
#
#  Combining Statments
#
$SharePointHome="Home"
$Contentdatabse = "WSS_CONTENT"
$SharePointHome="Home" ; $Contentdatabse = "WSS_CONTENT"
#
#    Write-Output
#
$farm
Write-Output $farm
Get-Command -verb format

###$farm | format-Custom
$farm | format-List
$farm | format-Table
$farm | format-WIde

Write-Output $farm Format-Custom
Write-Output $farm Format-List

#
#  Filtering  and Iterating
#
#   Not Equal To (-ne)
#   Greater Than (-gt)
#   Greater Than or equal to (-ge)
2 -eq 8
9 -gt 3

If (9 -gt 13)
   { "Opps There it is" } 
   Else
   {"Not Opps"}
    
####################################################################
#    Profile
####################################################################

$profile
NotePad $profile
Start-Transcript  #  Keeps everything is a log file

<#
.AGENDA 
	5. PowerShell Remoting 
.NOTES
	Must eable remote session on each SQL server for remoting
#>
Get-Help Remoting | Sort-by Name
Get-Help Enable-PSRemoting
get-Help Disable-PSRemoting
Get-Help Configuration | Sort-Object Name
Get-help Get-PSSession
Get-help Get-PSSessionConfiguration

#
Get-PSSession
Get-PSSessionConfiguration

Enable-PSRemoting
Get-PSSessionConfiguration

Disable-PSRemoting
Get-PSSessionConfiguration

####################################################################
#    OneGet Notes
####################################################################
get-command -module oneget

Get-PackageSource
#  a is the variable and does not the $ (example 
Find-Package -OutVariable a
$a
$a | Out-GridView

INstall-package zoomit   # didnt work

# may need to load oneget to 
get-command -Module psget

find-module # goes out to the internet

find-module | Sort-Object name

Install-Module snmp -Verbose


Dir .\snmp

psedit swn*

#  dont use Write-host


####################################################################
#
####################################################################
#  Fill browser fields and login
#  F12 to find fields
$url = "http://mail.computerName.com/IClient/Login.aspx"
$ie = New-Object -ComObject internetexplorer.application
$ie.Visible = $true
$ie.Navigate($url)
$ie.Document.getElementByID("txtUserName").value = "userName@domainName.com"
$ie.Document.getElementByID("txtPassword").value = "MyPassword"
$ie.Document.getElementByID("lbLogin").click();



