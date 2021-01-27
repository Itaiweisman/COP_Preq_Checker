<#

       .SYNOPSIS

              Check ControlUp installation Prerequisites

    .DESCRIPTION

              Check if all prerequisites are met before installing ControlUp on-premises components

      

    .PARAMETER Server

              Select the server NetBios name to check

      

    .EXAMPLE

              CU_Prerequisite_Check.ps1 -Server 'servername'

     

    .MODIFICATION_HISTORY

        Dennis van de Peppel - 26/01/2021 - Initial Version


    .LINK

        -→ externals sources/help & link to any code used from other sources/authors

 

    .COMPONENT

        -→ all external components/pre-reqs such as required modules

 

    .NOTES

        -→ Anything extra worthy of note (optional section)

 

#>

 

[CmdletBinding()]

    Param(

      # Declaring the input parameters, provided for the script

      [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]

      [string]

      $Server

     )

 

# Error Preferences

$ErrorActionPreference = 'Stop'

$VerbosePreference = 'SilentlyContinue'

$DebugPreference = 'SilentlyContinue'

 

# Disable in Final Script

Set-StrictMode -Version Latest

 

###

#

# Get-Data

#

###

 

$ErrorCount = 0

 

$osver = (Get-CimInstance Win32_OperatingSystem -ComputerName $Server).version

 

$Result = @()

 

$processor = (Get-WmiObject -Class Win32_Processor -ComputerName $Server)

 

$ProcessorCount =  $processor.NumberOfLogicalProcessors

 

$Memory = (Get-WMIObject -Class Win32_PhysicalMemory -ComputerName $Server | Measure-Object -Property capacity -Sum).sum /1gb

 

$DotNetVersion = Invoke-Command -Computer $Server {(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -gt 378389}

 

$port40705 = Invoke-Command -Computer $Server {(Test-NetConnection localhost -Port 40705).TcpTestSucceeded}

 

$port40706 = Invoke-Command -Computer $Server {(Test-NetConnection localhost -Port 40705).TcpTestSucceeded}

 

###

#

# Measure Data

#

###

 

CLS

 

IF ($ProcessorCount -ge 2){

((Write-Host "There are" $ProcessorCount "CPU's in the system $Server" -ForegroundColor Green))

}

ELSE{

((Write-Host "There are" $ProcessorCount "CPU's in the system, we advise a minumum of 2 Processors" -ForegroundColor Red))

$errorcount++

}

 

IF ($Memory -ge 8){

((Write-Host "There is" $Memory "GB Memory installed in the system" -ForegroundColor Green))

}

ELSE{

((Write-Host "There is" $Memory "GB Memory installed in the system, we advise a minumum of 8 GB" -ForegroundColor Red))

$errorcount++

}

 

if ($osver -gt 6.0) {

((Write-Host (get-ComputerInfo).OsName " is installed, please use a different Operating System" -ForegroundColor Red))

$errorcount++

}

 

if ($osver -gt 6.1) {

((Write-Host (get-ComputerInfo).OsName " is installed" -ForegroundColor Green))

}

 

if ($osver -gt 10.0) {

((Write-Host (get-ComputerInfo).OsName " is installed" -ForegroundColor Green))

}

 

if ($DotNetVersion = $true) {Write-Host "Microsoft .NetFramework 4.5 or higher detected " -ForegroundColor Green

}

if ($DotNetVersion = $false) {echo "Microsoft .NetFramework 4.5 NOT detected"

Write-Host "Please install .Net Framework 4.5 or higher before continuing" -ForegroundColor Red

$errorcount++

}

 

if ($port40705 = $true){

Write-Host "Port 40705 is open on the localsystem" -ForegroundColor Green

}

 

if ($port40705 = $false){

Write-Host "Port 40705 is NOT open on the localsystem, please open the Firewall" -ForegroundColor Red

$errorcount++

}

 

if ($port40706 = $true){

Write-Host "Port 40706 is open on the localsystem" -ForegroundColor Green

}

 

if ($port40706 = $false){

Write-Host "Port 40706 is NOT open on the localsystem, please open the Firewall" -ForegroundColor Red

$errorcount++

}

 

$internet = (Test-NetConnection "www.controlup.com").PingSucceeded

if ($internet = $true){

Write-Host "You have connection to the internet" -ForegroundColor Green

}

 

if ($internet = $false){

Write-Host "You do not have access to the internet. Please repair your internet connection"

$errorcount++

}

 

###

#

# Output-Data

#

###

 

IF ($ErrorCount -eq 0){

Write-Host " "

Write-Host "***" -ForegroundColor Green

Write-Host " "

Write-Host "All prerequisites are met. You can now install the ControlUp Console" -ForegroundColor Green

Write-Host "On " $Server -ForegroundColor Green

Write-Host " "

Write-Host "***" -ForegroundColor Green

Write-Host " "

}

IF($ErrorCount -ge 1){

Write-Host " "

Write-Host "***" -ForegroundColor RED

Write-Host " "

Write-Host $ErrorCount "Prerequisite(s) is/are missing" -ForegroundColor Red

Write-Host "On " $Server -ForegroundColor Red

Write-Host "Please check the errorlog above and fix any issues." -ForegroundColor Red

Write-Host " "

Write-Host "***" -ForegroundColor Red

Write-Host " "

}

 
