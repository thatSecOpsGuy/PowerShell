﻿<#
	.SYNOPSIS
		Install Oracle Java
	
	.DESCRIPTION
		Uninstall the old version of Java and then install the new version.
	
	.NOTES
		===========================================================================
		Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.145
		Created on:   	2/20/2018 10:53 AM
		Created by:   	Mick Pletcher
		Filename:		InstallJava.ps1
		===========================================================================
#>
[CmdletBinding()]
param ()

function Uninstall-MSIByName {
<#
	.SYNOPSIS
		Uninstall-MSIByName
	
	.DESCRIPTION
		Uninstalls an MSI application using the MSI file
	
	.PARAMETER ApplicationName
		Display Name of the application. This can be part of the name or all of it. By using the full name as displayed in Add/Remove programs, there is far less chance the function will find more than one instance.
	
	.PARAMETER Switches
		MSI switches to control the behavior of msiexec.exe when uninstalling the application.
#>
	
	[CmdletBinding()]
	param
	(
		[ValidateNotNullOrEmpty()][String]$ApplicationName,
		[ValidateNotNullOrEmpty()][String]$Switches
	)
	
	#MSIEXEC.EXE
	$Executable = $Env:windir + "\system32\msiexec.exe"
	Do {
		#Get list of all Add/Remove Programs for 32-Bit and 64-Bit
		$Uninstall =  Get-ChildItem REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall -Recurse -ErrorAction SilentlyContinue -Force
		$Uninstall += Get-ChildItem REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall -Recurse -ErrorAction SilentlyContinue
		#Find the registry containing the application name specified in $ApplicationName
		$Key = $uninstall | foreach-object { Get-ItemProperty REGISTRY::$_ -ErrorAction SilentlyContinue} | where-object { $_.DisplayName -like "*$ApplicationName*" }
		If ($Key -ne $null) {
			Write-Host "Uninstall"$Key[0].DisplayName"....." -NoNewline
			#Define msiexec.exe parameters to use with the uninstall
			$Parameters = "/x " + $Key[0].PSChildName + [char]32 + $Switches
			#Execute the uninstall of the MSI
			$ErrCode = (Start-Process -FilePath $Executable -ArgumentList $Parameters -Wait -Passthru).ExitCode
			#Return the success/failure to the display
			If (($ErrCode -eq 0) -or ($ErrCode -eq 3010) -or ($ErrCode -eq 1605)) {
				Write-Host "Success" -ForegroundColor Yellow
			} else {
				Write-Host "Failed with error code "$ErrCode -ForegroundColor Red
			}
		}
	} While ($Key -ne $null)
}

#Uninstall previous version(s) of Java
Uninstall-MSIByName -ApplicationName "Java 6" -Switches "/qb- /norestart"
Uninstall-MSIByName -ApplicationName "Java 7" -Switches "/qb- /norestart"
Uninstall-MSIByName -ApplicationName "Java 8" -Switches "/qb- /norestart"