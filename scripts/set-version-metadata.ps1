# Script for reading generated version values and updating metadata properties

#read major / minor version values from version.h (generated by cmake via version.h.in)
$majorVer=99
$minorVer=99
$patchVer=0
$buildNum=0

#define regular expressions to be used when checking for #define statements
$versionSniffingRegex = "(\s*#define\s+(\S+)\s+)(\d+)"

#read generated file, load values from this with regular expression
Get-Content "./version.h" |  Where-Object { $_ -match $versionSniffingRegex } | ForEach-Object {
	switch ($Matches[2])
	{
		"SRT_VERSION_MAJOR" { $majorVer = $Matches[3] }
		"SRT_VERSION_MINOR" { $minorVer = $Matches[3] }
		"SRT_VERSION_PATCH" { $patchVer = $Matches[3] }
		"SRT_VERSION_BUILD" { $buildNum = $Matches[3] }
	}	
}

$FileDescriptionBranchCommitValue = "SRT Local Build"

if($Env:APPVEYOR){
	#make AppVeyor update with this new version number
	Update-AppveyorBuild -Version "$majorVer.$minorVer.$patchVer.$buildNum"
	$FileDescriptionBranchCommitValue = "$Env:APPVEYOR_REPO_NAME - $($Env:APPVEYOR_REPO_BRANCH) ($($Env:APPVEYOR_REPO_COMMIT.substring(0,8)))"
}

#find C++ resource files and update file description with branch / commit details
$FileDescriptionStringRegex = '(\bVALUE\s+\"FileDescription\"\s*\,\s*\")([^\"]*\\\")*[^\"]*(\")'

Get-ChildItem -Path "$PSScriptRoot/../srtcore/srt_shared.rc" | ForEach-Object {
    $fileName = $_
    Write-Host "Processing metadata changes for file: $fileName"

    $FileLines = Get-Content -path $fileName 
    
    for($i=0;$i -lt $FileLines.Count;$i++)
    {
        $FileLines[$i] = $FileLines[$i] -Replace $FileDescriptionStringRegex, "`${1}$FileDescriptionBranchCommitValue`${3}"
    }
    
    [System.IO.File]::WriteAllLines($fileName.FullName, $FileLines)
}

