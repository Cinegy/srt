# Script for reading generated version values and updating metadata properties

#read major / minor version values from version.h (generated by cmake via version.h.in)
$majorVer=99
$minorVer=99
$patchVer=0
$buildNum=0

#define regular expressions to be used when checking for #define statements
$versionSniffingRegex = "(\s*#define\s+(\S+)\s+)(\d+)"

#read generated file, load values from this with regular expression
Get-Content ".\version.h" |  Where-Object { $_ -match $versionSniffingRegex } | ForEach-Object {
	switch ($Matches[2])
	{
		"SRT_VERSION_MAJOR" { $majorVer = $Matches[3] }
		"SRT_VERSION_MINOR" { $minorVer = $Matches[3] }
		"SRT_VERSION_PATCH" { $patchVer = $Matches[3] }
		"SRT_VERSION_BUILD" { $buildNum = $Matches[3] }
	}	
}

#make AppVeyor update with this new version number
Update-AppveyorBuild -Version "$SRT_VERSION_MAJOR.$SRT_VERSION_MINOR.$SRT_VERSION_PATCH.$SRT_VERSION_BUILD"

