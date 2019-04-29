#################################################################
#
#  There are two ways to comment code in a PowerShell Script
#  Notice the DOTTED KEYWORD
#################################################################
<#
.AUTHOR
	Michael Wharton
.Date
	04/27/2019 
.Updated
    04/27/2019 
.FILENAME
        0.DemoPowerShellBasics.PS1
.SYNOPSIS
	Demo of basics of using Powershell
.DESCRIPTION
	Go over key concepts of PowerShell
.PARAMETER serverInstance
	NONE
.EXAMPLE
	.\DemoPowerShellBasic 
.INPUTS
	Server Object
.NOTES
 	Demo of PowerShellBasics
    Start http://PowerShell.org
    Document:    "Windows Powershell -EN.PDF"

    Keys to learning PowerShell (Jeff Snover/Don Jones/Jeff Hicks)
    MASTER the following:
    1) Learn how to Learn
    2) Get-Help (Update-Help)
    3) Get-Command 
    4) Get-Member ping | WHere-Object | Sort-Object | Select-Object

.AGENDA 
	 1. Essential Commands - (Get-Help, Get-Service, Get-Command, Get-Member)
     2. Setting Security Policy
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
# automate desktop activities
start Excel.exe   C:\Temp\Demo.xlsx
start winWord.exe C:\Temp\Demo.docx

# Warm up systems
Start http://bing.com
Start-Sleep -seconds 1
start http://google.com
Start-Sleep -seconds 1
start http://MyProjectExpert.com
Start-Sleep -seconds 1
start http://CarolinaCon.org
Start-Sleep -seconds 1
cls
# 
# Documentation and reference links
# Start http://PowershellGallery.org
#
#############################################################################################
# Essential Commands 
#     1) Get-Help & Update-Help
#     2) Get-Command 
#     3) Get-Member 
#     4) Pipping | Sort-Object | WHere-object | Select-Object
#############################################################################################
# Get-Help
#############################################################################################
# Update-Help   ## Gets the latest updates to PowerShell

Get-Help
Get-Help Get-Help
Get-Help -Examples
Get-Help -Full
Get-Help -Detailed
Get-Help -Name pool
Get-Help -Category All
CLS

Get-Help Get-Service -Examples
CLS

Get-Service 

Get-Service | 
    Where-Object {$_.Status -eq "Running"} | 
    Sort-Object Name |
    Select-Object MachineName, DisplayName 

# To get all properties and methdos for an object use get-member
Get-Service | Get-Member

############################################################
#   Get-Command
#
#   Commands (4 types) 
#   1. Cmdlets        Verb-Noun   New-SPWebApplication, Remove-SPWebApplication
#   2. Functions      One or more commands that can be resused in script
#                     Close host and lose funtions...so put in the profile
#   3. Scripts        Commands, functions, Loops, inputs, etc
#                     Saves as PS1 files
#   4. Native Commands NotePad.exe, STSADM.exe, etc
############################################################
Get-Command
Get-Command -Verb GET
Get-Command -Verb NEW

Get-Command -Name Get-Process
Get-Command -Name DIR 

Get-Module

Get-Command -Module Microsoft.PowerShell.Security
Get-Command -Module NetSecurity
Get-Command -Module AppLocker
Get-Command -Module DISM
Get-Command -Module NFS
Get-Command -Module PKI
Get-Command -Module PSworkflow

Get-Command -Module Microsoft.Powershell.Core
Get-Command -Module Microsoft.Powershell.Utility
Get-Command -Module Microsoft.SharePoint.Powershell
Get-Command -Module Microsoft.SharePoint.Powershell -name SP*
Get-Command -Module Microsoft.SharePoint.Powershell -name *SPWeb*
Get-Command -Module Microsoft.SharePoint.Powershell -verb Back*

Get-Command -CommandType Alias
Get-Command -CommandType All
Get-Command -CommandType Application
Get-Command -CommandType Cmdlet
Get-Command -CommandType Filter
Get-Command -CommandType Function
Get-Command -CommandType Script
Get-Command -CommandType Workflow

#############################################################################################
# Get-Member
#############################################################################################
# To get all properties and methdos for an object use get-member
Get-Service | Get-Member

#############################################################################################
# Piping 
#############################################################################################
# To get all properties and methdos for an object use get-member
Get-Service | 
    Where-Object {$_.Status -eq "Running"} | 
    Sort-Object Name |
    Select-Object Name, CanStop, ServiceType |
    Format-table

Get-Service | 
    Where-Object {$_.Status -eq "Running"} | 
    Format-Wide

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
$url = "http://mail.whartoncomputer.com/IClient/Login.aspx"
$ie = New-Object -ComObject internetexplorer.application
$ie.Visible = $true
$ie.Navigate($url)
$ie.Document.getElementByID("txtUserName").value = "username@domain.com"
$ie.Document.getElementByID("txtPassword").value = "password"
$ie.Document.getElementByID("lbLogin").click();



