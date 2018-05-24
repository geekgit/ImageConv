function Test-Reg
{
	$RPath=$args[0]
	$flag=Test-Path "Registry::$RPath"
	if($flag)
	{
	Write-Host "$RPath exists"
	}
	else
	{
	Write-Host "Create $RPath..."
	New-Item "Registry::$RPath"
	}
}
function Get-UserChoice-ProgId
{
	$Ext=$args[0]
	$RPath="Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Ext\UserChoice"
	$ID=(Get-ItemProperty $RPath).'ProgId'
	return $ID
}
function value-work
{
	$RPath=$args[0]
	$RName=$args[1]
	$RValue=$args[2]
	$RType=$args[3]
	$IP=(Get-ItemProperty -Path "Registry::$RPath" -Name $RName -errorAction SilentlyContinue)
	if($IP)
	{
		Write-Host "Registry ""$RPath"", Property ""$RName"" exists, overwriting..."
		Set-ItemProperty -Path "Registry::$RPath" -Name "$RName" -Value "$RValue"
	}
	else
	{
		Write-Host "Registry path ""$RPath"", Property ""$RName"" create..."
		New-ItemProperty -Path "Registry::$RPath" -Name "$RName" -Value "$RValue"
	}
}
function registry-work
{
	
	$Ext=$args[0]
	Write-Host "$Ext..."
	$WebpCommand="""C:\ImageConv\ImageConv.exe"" --png-to-webp ""%1"""
	Write-Host $WebpCommand
	$ID=$(Get-UserChoice-ProgId $Ext)
	Write-Host "$Ext UserChoice ProgId=$ID"
	$reg1="HKEY_CURRENT_USER\Software\Classes\$ID"
	$reg2="HKEY_CURRENT_USER\Software\Classes\$ID\shell"
	$reg3="HKEY_CURRENT_USER\Software\Classes\$ID\shell\webp"
	$reg4="HKEY_CURRENT_USER\Software\Classes\$ID\shell\webp\command"
	Test-Reg $reg1
	Test-Reg $reg2
	Test-Reg $reg3
	Test-Reg $reg4
	value-work $reg3 '(default)' 'webp'
	value-work $reg4 '(default)' $WebpCommand
}

$IsAdmin=([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator");
Write-Host 'Admin: ' $IsAdmin
if (!$IsAdmin)
{
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs;
	exit; 
}
Write-Host 'PNG to WEBP menu entry'
Try
{
	registry-work .png
}
Catch
{
	$Message=$_.Exception.Message
	Write-Host "Error: $Message"
	$Fail=$_.Exception.ItemName
	Write-Host "Failed: $Fail"
}
Read-Host -Prompt "Press Enter to exit..."
