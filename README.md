# PSRoboRefresh
**An amalgam of Scheduled Task + PowerShell + Robocopy which allows someone else to invoke a folder refresh from one environment to another**

PSRoboRefresh is a tool written in PowerShell and is commonly used to perform on-demand, complex/privileged refreshes of a source folder to a specified destination folder. This is a handy thing to leverage when, for example, a developer wants to be able to refresh the unstructured data from the Development environment to the Testing environment.


## Getting started

This was developed and tested in Python 5.1.x on Windows Server 2016. There is no installation necessary aside from having a relevant version of PowerShell on the running system.

### To get started:

1. Clone the repo or simply download the Refresh-FileData.ps1 file
2. Put the .ps1 file in a static location for reference by the Scheduled Task
3. Create a new Scheduled Task, being mindful of the privileges and security context, trigger, and the action.
4. The action can be something like "Program/script:" = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" + "Add arguments:" = ".\Refresh-FileData.ps1" + "Start in:" = "C:\ScriptsFolder"
5. Test the function by creating the "refreshIdentFilePath" - For example, this could be "C:\Temp\IdentFile.txt"
6. If the above file object exists, the refresh will proceed. If the file object is not present, it will log such and wait for the next trigger/iteration
7. If it ran successfully, the destination path should be populated with the source path contents.
8. Additionally, multiple log files will be created and be accompanied by Windows Application Event Log Events.

**---Example Log Outputs---**
Overall Refreshes Log File: Application_Migration_Refresh_Logs.log
Individual Refresh Status Log File: File_Refresh_Successful_2019-09-09-04.03.48.txt
Individual Refresh Robocopy Log File: Robocopy_Refresh_2019-09-09-04.03.48.log

Windows Event Log - Event Source: PSRoboRefresh - Event IDs:2020,2021,2022

**---End Example Log Outputs---**

## Features

* On a scheduled interval and given the "Identifier File" exists, perform the Robocopy function to refresh source>destination

#### Argument 1 - The file object, when present, will trigger a refresh from source to destination
**Name:** $refreshIdentFilePath
**Type: **`String`
**Default:** C:\Temp\IdentFile.txt
 
#### Argument 2 -  Source path of the file data in question, e.g. a "backup" or point-in-time which is desired in the destination
**Name:** $refreshSourcePath
**Type:** `String`
**Default:** C:\Temp\SourcePath

#### Argument 3 -  Destination path when the refreshed file data will ultimately rest and mirror the source
**Name:** $refreshDestinationPath
**Type:** `String`
**Default:** C:\Temp\DestinationPath

#### Argument 4 -  The log path of the Robocopy refreshes that occur, this would contain the Robocopy logging output
**Name:** $robocopyLogPath
**Type:** `String`
**Default:** "C:\Temp\Robocopy_Refresh_$(get-date -f yyyy-MM-dd-hh.mm.ss).log"

#### Argument 5 -  The log path for iterations of the refreshes which run, note, this log would not contain Robocopy output
**Name:** $internalLogPath
**Type:** `String`
**Default:** "C:\Temp\Application_Migration_Refresh_Logs.log"

#### Argument 6 -  File path of log which signifies a successful refresh has occurred
**Name:** $refreshSuccessFilePath
**Type:** `String`
**Default:** "C:\Temp\File_Refresh_Successful_$(get-date -f yyyy-MM-dd-hh.mm.ss).txt"


## Contributing

This tool is simple but is not without its shortcomings; all contributions are welcomed.

Aside from working on the random **TODO:** and shrinking the code, I would like to add sources and copy functions which are not bound to Windows Like File Access Layers. Additionally, adding support for additional interfaces such as S3 object storage, NFS, etc.

I welcome all feedback and contributions.


## Links

- Project homepage: https://github.com/Kentix/PSRoboRefresh
- Repository: https://github.com/Kentix/PSRoboRefresh
- Issue tracker: https://github.com/Kentix/PSRoboRefresh/issues

## License

The code in this project is licensed under the MIT license.