<#
.AUTHOR
	Michael Wharton
.Date
	04/24/2019
.Updated
    04/24/2019 
.FILENAME
   DemoRemoting.PS1
.SYNOPSIS
	CarolinaCon 2019 What can PS> do?
.DESCRIPTION
	Remoting and execution of PowerShell over many computers and server
    is the real power
#>
CD \
# setup variables
$computers = "computer1", "computer2" , "computer3"
$computers = "computer1"
# find all command that have a parameter "ComputerName"
Get-Command -CommandType Cmdlet -ParameterName ComputerName
#
#######################################################################
# Test-Connection
#######################################################################
#
PING 192.168.0.62 -n 2
PING computerName -n 2 -a
#
help Test-Connection
Test-Connection -ComputerName computerName
Test-Connection computerName
#
# Test-Connection WCC2MSI2, WCC001VS -Count 2 -Protocol DCOM
Test-Connection $computers -Count 2
#
#  Quiet is a true or false
"computer1", "computer2", "192.168.0.62", "computer3", "computer4" | 
   where { Test-Connection -Quiet -ComputerName $_ -Count 1 }
#
Test-NetConnection -ComputerName $computers | Select *
#
$MyResults = Test-NetConnection -ComputerName $computers -Count 1
$MyResults
$myResults.IsAdmin
$MyResults.SourceAddress
#
"computer1", "computer2" | 
   foreach {Test-NetConnection -ComputerName $_ -CommonTCPPort SMB }
#
#  handy for testing ports
$computers | 
    foreach {Test-NetConnection -ComputerName $_ -port 53 }
#
$computers | foreach {Test-NetConnection -ComputerName $_ -port 53 -InformationLevel Quiet -WarningAction SilentlyContinue}
#
$computers | foreach {Test-NetConnection -ComputerName $_ -port 53 -InformationLevel Detailed -WarningAction SilentlyContinue}
#
#######################################################################
# Test-NetConnection
#######################################################################
Get-help Test-NetConnection
#
Test-NetConnection -computername www.wcc2demo.com -CommonTCPPort HTTP -InformationLevel Detailed
#
#######################################################################
# Get-Process  (Executables and foreground services)
#######################################################################
Help get-process
#
Get-Process
#
get-process -computerName $computers
#
get-process lsass -ComputerName computer1 
#
get-process lsass -ComputerName $computers |
select MachineName, ID, Name, handles, VM, WS |
sort handles, machinename -Descending |
Format-Table

#######################################################################
# Get-Service  (backgrounds services)
#######################################################################
get-help Get-Service -Examples
#
Get-service | Get-Member
#
Get-Service 
#
Get-Service -ComputerName $computers -Name bits | 
Select name, Status, MachineName
#
Get-Service -ComputerName $computers -Name bits | 
Stop-Service -Force -PassThru |
Select name, Status, MachineName
#
Get-Service -ComputerName $computers -Name bits | 
Restart-Service -Force -PassThru |
Select name, Status, MachineName
#
#######################################
#  Get-EventLog
#######################################
Get-Help get-eventlog
#
Get-EventLog -List -ComputerName $computers
#
Get-EventLog -List -ComputerName $computers |
Where log -EQ 'system' |
Format-Table -GroupBy log -Property @{Name="ComputerName"; Expression={$_.MachineName}}, `
OverflowAction, `
@{Name="MaxDB";Expression={$_.MaximumKiloBytes}}, `
@{Name="Retain";Expression={$_.MinimumRetentionDays}}, `
@{Name="RecordCount";Expression={$_.entries.Count}} 
#
Get-EventLog -List -ComputerName $computers |
Where {$_.Entries.Count -gt 0} |
Sort MachineName, log | 
Format-Table -GroupBy @{Name="ComputerName"; Expression = {$_.MachineName.ToUpper()}}
#
Get-eventlog -LogName 'Windows PowerShell' | Select *
#
Get-EventLog -LogName "Windows PowerShell" -ComputerName  $computers 
#
Get-EventLog -LogName "Windows PowerShell" -ComputerName  $computers |
   Select EntryType, Message |
   Format-table 
#
#######################################
#  Invoke-WebReuest (Screen Scraping)
#######################################
Get-Help Invoke-WebRequest 
#
$uri = "https://www.MyProjectExpert.com"
Invoke-WebRequest -Uri $uri -DisableKeepAlive -UseBasicParsing
#
Invoke-WebRequest -Uri $uri -OutFile $out -DisableKeepAlive -UseBasicParsing
$ScrapPage = Invoke-WebRequest -Uri $uri -DisableKeepAlive -UseBasicParsing
$ScrapPage
$ScrapPage.StatusCode
$ScrapPage.content
#
#######################################################################
# Resolve-DnsName 
#######################################################################
Get-help Resolve-DnsName 
#
Resolve-DnsName www.computerName.com
#
Resolve-DnsName www.computerName.com | Select * 
#
#######################################################################
#   Firewall commands
#    Group Policy may be better to use
#######################################################################
Get-Help Get-NetFirewallRule
#
Get-Command -Noun NetFirewallRule
#
# Find all my FireWall rules
Get-NetFirewallRule | Out-GridView -Title "FireWall Rules"
#
Get-NetFirewallRule -Enabled True |
Select Name, DisplayName, Description, Profile, DisplayGroup, Direction, Action |More
#
Get-NetFirewallRule -Name FPS* |
Where Profile -Contains 'domain' |
select Name, enabled, Direction, Action
#
# shows results if command was executed
Disable-NetFirewallRule FPS-ICMP6* -WhatIf
#
Get-NetFirewallRule -Enabled False |
Where profile -contains 'domain' |
Select Name, Description
#Select Name, DisplayName, Description, Profile, DisplayGroup, Direction, Action 
#
Get-NetFirewallRule remote* |
Where {$_.profile -contains 'domain' -AND $_.enabled -eq 'false'} |
Select Name, Description 
#
Get-NetFirewallRule remote* |
Where {$_.profile -contains 'domain' -AND $_.enabled -eq 'false'} |
Enable-NetFirewallRule -WhatIf
#
HELP Get-NetFirewallRule -Parameter Cimsession 
#
Get-NetFirewallRule remote* -CimSession $computers  |
Select Name, DisplayName, Profile, Enabled, PSComputerName
#
# summary of RDP
#   Read Full Help for examples
#   Plenty of life for traditional (legacy) remoting
#   Be aware of potential firewall issues
#   Be aware of potential credential issues
#   How to scale - may not be good for hundreds
#######################################################################
#
#  4. PowerShell Remoting
#
#######################################################################
# ENABLE-PSRemoting
#    Connect via single port 
#    5985 (HTTP)
#    5986 (HTTPS)
#    Requires admin credential by default on remote server
#    Utilizez Kerberos for mutual authenication
#    Encyrpted data transfer
#    Managed by WinRM service
#    Windows 2012R2 enabled by default
#
#    EndPoint
#      Access control
#      What commands are available
#      Available resources
#      Sessino configuration Settings
#
#  Starts and configures WinRm services (turns on remoting)
#  run elevated
#  Only applies to non-public networks
#  Creates default listner
#  Creates firewall rules
#  Configues endpoints
Enable-PSRemoting
#
#  Test-WSMAN
#  Verify a remote computer is ready for WSMan
#  Can specify SSl
#  Can specify credentials
Test-WSMan -ComputerName WCC001VS
#
# Enter-PSSession
#   Remoting 1 to 1
#   Establish interactive action
#   Telnet-like session adn secure
Enter-PSSession -ComputerName Wcc001vs -Credential company\admin
#
# Invoke-Commmand
#   Create a tempory PSSession
#   Run a script block
Invoke-Command -ScriptBlock {Get-Process -IncludeUserName} -ComputerName computer1 -Credential domainName\userName
Invoke-Command -ScriptBlock {Get-Process -IncludeUserName} -ComputerName computer1
#
# Demo
# START https://www.microsoft.com/en-us/download/details.aspx?id=45520
get-aduser $env:username -properties memberof, displayname 
#
#  Turns of PS remoting 
Disable-PSRemoting -Force
Stop-Service WINRM
Set-service winrm -StartupType Disabled
Get-NetFirewallRule *winrm* |
  Select name,enabled, profile, direction,action | Format-Table
Disable-NetFirewallRule winrm-http-in-TCP*
# verify
Test-WSMan
#
Get-Service winrm
#
Enable-PSRemoting 
# 
Get-Service winrm
Test-WSMan
#
Test-WSMan -ComputerName computer1
Test-WSMan -ComputerName computer2
Test-WSMan -ComputerName computer2 -Credential wcc2prod\mawharton  # fails 
Test-WSMan -ComputerName computer2 -Credential wcc2prod\mawharton -Authentication Default
#
Get-service winrm -ComputerName computer1, computer1, computer3 | 
  Select MachineName, name, status, starttype
#
# Demo 1 to 1
#
Enter-PSSession -ComputerName computer1
hostname
get-process -IncludeUserName
dir c:\
dir c:\iso 
# get registry info
cd HKLM:
dir .\system
#
Restart-Computer -WhatIf
#
exit
#
#  New Remote PowerShell tab
#
# Provides additional functionality
#   Find-module iseremotetab
#   Import-module isresmotetab
#   New-ISERemoteForm
#
#####################################
# 1 to Many
#####################################
#
HELP Invoke-Command
#
$r = Invoke-command -ScriptBlock {
 get-item HKLM:\System\CurrentControlSet\Control\BitlockerStatus
} -ComputerName wcc001vs
$r | get-member
#
#
Invoke-command -ScriptBlock {
 get-process | sort ws -Descending | Select -First 5
} -ComputerName wcc001vs, WCC2MSI2, bigred
#
#
$sessions = New-PSSession wcc001vs, WCC2MSI2, bigred

get-pssession
get-pssession | where computerName -eq wcc001vs

Invoke-command {get-service bits} -session $sessions

$sb = {
$fso = new-object -ComObject scripting.filesystemobject
$fso.Drives | where drivetype -eq 2 |
Select Path, 
@{Name="SizeGB";Expression={$_.Totalsize/1GB -as [int]}},
@{Name="FreeGB";Expression={$_.FreeSpace/1GB}},
@{Name="AvailGB";Expression={$_.AvailableSpace/1GB }},
@{Name="ComputerName";Expression={$env:computername}}
}

Invoke-Command -ScriptBlock $sb -Session $sessions

Invoke-Command -ScriptBlock $sb -Session $sessions -HideComputerName |
  Select *  -ExcludeProperty runspaceid

#  grab contents of script
ise c:\scripts\fsoreport.ps1
$params = @{
FilePath = "C:\scripts\fsoreport.ps1"
argumentlist = @("Cd","D:")
session = $sessions
HideComputername = $true
}

$report = Invoke-Command @pparms | Select * -ExcludeProperty run*
# removes all session or close PowerShell
$sessions | Remove-PSSession
#
# Demo remoting for Workgroup
#  Needs trusted 
#
##################################################
#  WMI Windows Management Instrumentation
#   Local repository for system information
#   Managed by wimmgmt service
#   Can be queries like SQL
#   Derived from an industry set of standards
#   WMI is Microsoft implementation
#
#   CMI repository 
#        Root\CimV2
#        Root\SecurityCenter2
#        Root\Microsoft\Windows\SMB
##################################################
Get-wmiObject -classname win32_service 
Get-wmiObject -classname win32_service -ComputerName Wcc001vs
#
# PowerShell and WMI
Help get-wmiObject
#
# how to discover which classrd to use
get-wmiobject -list -Class win32* | more

Get-wmiObject -classname win32_operatingsystem
Get-wmiObject -classname win32_operatingsystem | Select *

$computers = "wcc001vs", "WCC2MSI2", "BigRed"
Get-wmiObject -classname win32_operatingsystem -ComputerName $computers |
  Select PSComputerName, Caption, OSArchitecture, ServicePackMajorVersion, InstallDate
#
# format date
Get-wmiObject -classname win32_operatingsystem -ComputerName $computers |
  Select PSComputerName, Caption, OSArchitecture, `
  ServicePackMajorVersion, `
  @{Name="Installed";Expression={$_.ConvertToDateTime($_.INstallDate)}}

# filtering results
get-wmiobject win32_process -ComputerName computer1  | 
    Select Name, ProcessID, WorkingSetSize

# works but not effective
get-wmiobject win32_process -ComputerName computer1  | 
   Where { $_.name -eq 'lsass.exe'}

# preferred
get-wmiobject -Query "Select * from win32_process where name = 'lsass.exe'"-ComputerName BigRed  | 
    Select PSComputerName, Name, ProcessID, WorkingSetSize

# using query
get-wmiobject win32_process -filter "name = 'lsass.exe'"-ComputerName computer1  | 
    Select PSComputerName, Name, ProcessID, WorkingSetSize

# using filter
get-wmiobject win32_process -filter "name = 'lsass.exe'"-ComputerName computer1  | 
    Select PSComputerName, Name, ProcessID, WorkingSetSize

# cannot be used for local 
$cred = get-credential wcc2prod\mawharton
get-wmiobject win32_process -filter "name = 'lsass.exe'"-ComputerName computer1 -Credential $cred | 
    Select PSComputerName, Name, ProcessID, WorkingSetSize

# disk drive info
get-wmiobject win32_logicaldisk -filter "deviceid='C:'"-ComputerName computer1 -Credential $cred | 
    Select PSComputerName, Caption, `
    @{Name="SizeGB"; Expression={($_.Size/1gb) -as [INT]}}, `
    @{Name="FreeGB"; Expression={($_.Freespace/1GB)}}, `
    @{Name="PCtFree"; Expression={($_.freespace/$_.size)*100}}

############################################################################
#  another way to test for using PowerShell and find values for system info
wbemtest
# \\bigred\root\cimv2

#  another way to query or short cut to get info
[wmi]"\\.\root\cimv2:win32_logicaldisk.deviceid='c:'"

$c = get-wmiobject -List win32_service
$c.Properties | Select name,type, qualifiers

$c.Properties |
where {$_.qualifiers.name -contains 'key'}   

$search = [wmisearcher]"Select * from win32_service where name = 'bits'"
$search 
$search.Query

$search.get()

$ns = "root\microsoft\windows\storage"
Get-wmiobject -Namespace $ns -List -Class msft*

Get-wmiobject -Namespace $ns -Class msft_disk
#
# c:\scripts\wmiexplorer.ps1 # written many years ago for PowerShell 1

###########################################################################
#  WMI Methods
###########################################################################
$c = [wmiclass]"win32_share"
$c.Methods
#
start http://bit.ly/CreateWin32_Share
#
$c.Create("C:\Work", "work", 0,$null, "My Demo Share")
$work = get-wmiobject win32_share -Filter "Name = 'work'"
$work | get-member -MemberType Method
#
# $c.Delete()  #  didnt delete completed
#
$c.GetMethodParameters("create")

###########################################################################
#  WMI Jobs
###########################################################################
help get-wmiOjbect -Parameter asJob
#
$J = Get-wmiobject win32_logicaldisk -filter "deviceid='c:'" -computerName $computers -AsJob
wait-job $J
$J | receive-job -keep

Receive-Job $J -Keep |
    Select PSComputerName, DeviceID, size, Freespace

#
Start-job {Get-wmiobject win32_operatingsystem -computername bigred} -name OS2
wait-job OS2
receive-job OS2 -keep 

###########################################################################
#  WMI and PowerShell
###########################################################################
# powerShell report

get-wmiobject win32_operatingsystem -computer bigred |
  Invoke-WmiMethod -Name reboot -WhatIf

Restart-Computer bigred -WhatIf
#
#  Shares
get-smbshare 
New-smbshare 
# Remove-smbshare -Name work
Get-smbshareaccess -Name xfr
Get-smbshareaccess -Name c$
Get-smbshareaccess -Name IPC$

###########################################################################
#  CMI cmdlets
#    Does not support alternate credentials
#    Requires 3.0
###########################################################################
Help  Get-CimIntance
#
Get-CimClass -ClassName win32*
#
Get-CimClass -ClassName win32_operatingsystem | get-member
Get-wmiObject -ClassName win32_operatingsystem | get-member
#
$computers = "BigRed","WCC001VS","WCC2MSI2"
get-ciminstance win32_logicaldisk -ComputerName $computers

get-ciminstance win32_operatingsystem -ComputerName $computers |
  select PSComputerName, Caption, OSArchitecture, InstallDate

get-ciminstance -Query "Select * from win32_process where name = 'lsass.exe'" -ComputerName $computers |
  select PSComputerName, name, processid,  workingsetsize

Get-ciminstance win32_process -Filter "name='lsass.exe'" -ComputerName $computers |
  select PSComputerName, name, processid,  workingsetsize

Get-ciminstance win32_volume -Filter "bootvolume='true'" -ComputerName $computers |
  select PSComputerName, Name, capacity, Freespace, Compressed, quotasEnable
#
#  Demo Cim Sessions  
help New-CimSession
New-CimSession -ComputerName $computers -Credential $cred
#
help New-CimSessionOption 
$opt = New-CimSessionOption -Protocol Dcom 
$s3 = New-CimSession -ComputerName wCC2016SQl -Credential $cred -SessionOption $opt
#
Get-cimsession
#
Get-CimInstance win32_computersystem -cimsession $s3 
#
Get-CimInstance win32_computersystem -cimsession $computers
#
Get-cimsession |
  Get-CimInstance win32_logicaldisk -Filter "deviceid='C:'" |
    Select PSComputerName, Caption, `
    @{Name="SizeGB"; Expression={($_.Size/1gb) -as [INT]}}, `
    @{Name="FreeGB"; Expression={($_.Freespace/1GB)}}, `
    @{Name="PCtFree"; Expression={($_.freespace/$_.size)*100}} |
    Sort PCtFree | Format-Table
#
Get-cimsession | Remove-CimSession
#
Get-cimsession
#
#######################################################
#  Exploring Cim namespace
$ns = "root\microsoft\windows\storage"
Get-CimClass -Namespace $ns -ClassName msft* 
#
Get-CimInstance -Namespace $ns -ClassName msft_disk | select *
#
Get-disk | Select *
get-disk | get-member
#
get-command get-disk
#
Get-typedata -Typename *Cim* |
    where  {$_.typename -notmatch 'win32'} | sort typename
#
get-command -Noun *healthAction*
# show Get-StoragehealthAction
Get-StorageHealthAction
#
#  Demo Using CIM Methods
Get-CimClass win32_share ###  NOT FOUND on Windows 10
$c = Get-CimClass win32_share
#$c = Get-CimClass win32_sharetodirectory
$c
$c.CimClassMethods

Invoke-Command {get-item c:\temp } -computerName $computers
Invoke-Command {get-item c:\temp }
Invoke-Command -ComputerName $computers {get-item c:\temp } 

get-command -parameterName cimsession

#######################################################
#  CIM Background Jobs
Start-Job { Get-CimInstance win32_service -Filter "startmode='auto' and state<>'running'" -ComputerName $computers  } -Name SvcCheck2
#
Wait-Job SvcCheck2
#
#Receive-Job SvcCheck2
#
Receive-Job SvcCheck2 -Keep |
  Select systemName, Name, displayname, state, startmode |
  Format-Table

#
Invoke-Command { Get-CimInstance win32_service -Filter "startmode='auto' and state<>'running'" -ComputerName $computers | Select systemName, Name, displayname, state, startmode  } -JobName SvcCheck3 -computerName $computers
Wait-Job SvcCheck3
Receive-Job SvcCheck3 -Keep |
  Select systemName, Name, displayname, state, startmode |
  Format-Table

$pssess = New-PSSession -ComputerName $computers
invoke-command {
Start-Job { Get-CimInstance win32_service -Filter "startmode='auto' and state<>'running'" } -name check
} -session $pssess

Invoke-Command -Session $pssess { wait-job check } 

Invoke-Command  {
Receive-Job check -Keep |
 Select  systemName, Name, displayname, state, startmode |
 Format-Table
} -session $pssess

#######################################################
#  Powershell and CIM in action

$AllComputer = (Get-ADComputer -filter "OperatingSystem -like '*Server*'").Name


$name = (Get-ADComputer -filter "OperatingSystem -like '*Server*'").Name
$servers = $name | where { Test-wsman $_}
$servers

# reboot -- waits for computer to be up and running
Restart-Computer WCC2MSI2xx -Force -Wait -For WinRM

# Find last boot time and 
Get-CimInstance -ClassName win32_operatingsystem -ComputerName $computers -Property lastBootupTime |
  Select PSComputerName, LastBootupTime, @{Name="Runtime";Expression={(get-Date) - $_.lastbootuptime}}

#
Get-hotfix -ComputerName $computers
#
Get-CimInstance win32_quickFixEngineering -ComputerName $computers
#
(get-cimclass win32_quickfixengineering).CimClassProperties | Select Name
#
Get-CimInstance win32_quickFixEngineering -ComputerName $computers |
   Select CSName, HotfixID, Installed*, Description, Caption |
   Format-Table

Get-CimInstance win32_quickFixEngineering -ComputerName $computers |
   Select CSName, HotfixID, Installed*, Description, Caption |
   Out-GridView

#######################################################
#  Scripting with CIM

Get-Ciminstance win32_OperatingSystem -ComputerName Bigred |
 Select-Object -Property `
    @{Name="ComputerName";Expression={$_.CSName}}, `
    @{Name="Fullname";Expression={ $_.Caption}}, ` 
    Version, Buildnumber, InstallDate, OSArchitecture

# C;\scripts\Get-MyOS.ps1

# C;\scripts\sysreport.ps1
# C:\Scripts\sysreport.ps1 -computer bigred -path c:\work\dom1.htm

###########################################################################
#  PowerShell and the Web
#    Designed with cloud and Internet in mind
#    PowerShell commadns can abstract teh process
###########################################################################
#
# Send http and other request to a web site
# Response is a structured object
# Handy for "Scapting" a site or downloading
Invoke-WebRequest http://www.MyProjectExpert.com |
    Select Content

$uri = "http://www.MyProjectExpert.com/"
Invoke-WebRequest -Uri $uri -OutFile $out -DisableKeepAlive -UseBasicParsing

$uri = 'https://api.github.com/users/myprojectexpert/repos?per_page=50'
#$uri = 'https://github.com/MyProjectExpert/ProjectServer-Tools'
Start $uri
#
# sebd reqyest ti REST services
# Usually automatically converts JSON to objectes
# Also hand for strucutre data like RSS XML
Invoke-RestMethod "$uri'?per_page=50" -Method Get

# consume by other 
#New-WebServiceProxy 
$px = New-WebServiceProxy -uri http://182.168.3.41/mywebservices/firstservice.asmx
$ps.add(123,321)

# Demo Invoke-WebRequest
help Invoke-WebRequest -Examples
$uri = "http://www.MyProjectExpert.com"
$a = Invoke-WebRequest -uri $uri -UseBasicParsing # give just content
$a 
(Invoke-WebRequest -uri $uri -UseBasicParsing).content
#
$uri = 'https://git-scm.com/download/win'
start $uri
$page = Invoke-WebRequest -Uri $uri -UseBasicParsing -DisableKeepAlive 
$page.Links
# filter links
$dl = $page.Links | Where-Object outerhtml -Match 'git-.*-64-bit.exe' |
    select-object -First 1 *
$dl | Format-List
$filename = Split-Path $dl.href -Leaf 
# save file to work directory
$out = Join-Path -Path c:\temp -ChildPath $filename
# Net.Service requierd
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $dl.href -OutFile $out -UseBasicParsing -DisableKeepAlive
# this downloads as well
start $dl.href
#
# Get-Babynames.ps1
#
# Demo  Invoke-RestMethod
Help Invoke-RestMethod 
#
$r = Invoke-RestMethod https://api.github.com/users/myprojectexpert/repos?per_page=50
$r.Count 
$r[0] 

$r | where {-not $_.fork} |
Select name, Description,Updated_at, html_urol, *count |
Out-GridView -Title "MyProjectExpert"
#
# ARIN
Start https://www.arin.net/resources/whoisrws/whois_api.html
$baseUrl = 'http://whois.arin.net/rest'
$uri = "$baseUrl/ip/52.27.12.198"
$who = Invoke-RestMethod $uri
$Who
$who.net

$s = Invoke-RestMethod $uri -Headers @{"Accept"="application/json"}
$s
$s.net

Invoke-RestMethod $uri -Headers @{"Accept"="text/plain"}

$uri = "http://feeds.feedburner.com/brainyquote/QUOTEBR"
$data = Invoke-RestMethod -Uri $uri
$data
$data[0]
$quote = "{0} - {1}" -f $data[0].description,$data[0].title
Write-Host $quote -ForegroundColor Yellow

# Get-RSSw4.ps1

#
help New-WebServiceProxy
#
#
# Demo  Advance APplication ODATA
$name = "odatademo"
$base = "C:\Program Files\WindowsPowerShell\Modules\"
$outpath = Join-path -Path $base -ChildPath $name 
mkdir $outpath

Export-ODataEndpointProxy -uri $uri  -AllowUnsecureConnection -OutputModule -Force

# PSSwagger --- auto generate cmdlets from ReSTfull service
#    Heavy developer focus
# https://github.com/PowerShell/PSSwagger







