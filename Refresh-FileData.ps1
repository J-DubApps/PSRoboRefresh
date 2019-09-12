param (
    #The file object, when present, will trigger a refresh from source to destination
    [string] $refreshIdentFilePath = "C:\Temp\IdentFile.txt",
    #Source path of the file data in question, e.g. a "backup" or point-in-time which is desired in the destination
    [string] $refreshSourcePath = "C:\Temp\SourcePath",
    #Destination path when the refreshed file data will ultimately rest and mirror the source
    [string] $refreshDestinationPath = "C:\Temp\DestinationPath",
    #The log path of the Robocopy refreshes that occur, this would contain the Robocopy logging output
    [string] $robocopyLogPath = "C:\Temp\Robocopy_Refresh_$(get-date -f yyyy-MM-dd-hh.mm.ss).log",
    #The log path for iterations of the refreshes which run, note, this log would not contain Robocopy output
    [string] $internalLogPath = "C:\Temp\Application_Migration_Refresh_Logs.log",
    #File path of log which signifies a successful refresh has occurred
    [string] $refreshSuccessFilePath = "C:\Temp\File_Refresh_Successful_$(get-date -f yyyy-MM-dd-hh.mm.ss).txt"
)


#Check to see if Internal Log File Exists, if not, create
if ((Test-Path -Path $internalLogPath) -eq $false)
{
    New-Item -Path:$internalLogPath -ItemType:File -Value:"File Created On $(get-date -f yyyy-MM-dd-hh.mm.ss)`n`r"
}

#TODO: Allow supplying custom set of options in a parameter or similar
#$robocopyOptions = "/Custom /Robocopy /Options"

#TODO: Create logging function to reduce the deplicate code

#The below would be run on a scheduled basis. For example, via Task Scheduler on Windows
#Test if the refresh signal is present via a file objects' presence on the file system
if (Test-Path $refreshIdentFilePath)
{
    #Options for the robocopy - Mirror + Restart + Backup Mode + Retry Once + Wait 0 Seconds + Copy File Data, Attributes, Timestamps, Security, Ownership + Copy Directory\
    #cont'd: Data, Attributes, Timestamps + Multithread 16 Threads + Exclude Junction Points + Report Extra Files + Verbosity + Show Timestamps + Show Full Path + Do Not Show Progress + Log destination
    #Build the Robocopy command using source and destination params. The options for Robocopy are static for now. Take note of the log file path param.
    #*****NOTE: THIS WILL OVERWRITE DATA IN THE DESTINATION*****
    Robocopy $refreshSourcePath $refreshDestinationPath /S /E /MIR /ZB /R:1 /W:0 /COPY:DATSO /DCOPY:DAT /MT:16 /XJ /X /V /TS /FP /NP "/LOG+:$robocopyLogPath"


    New-Item -Path:$refreshSuccessFilePath  -ItemType:File -Value:"Refresh Complete at approximately $(get-date -f yyyy-MM-dd-hh.mm.ss)"
 
    #Write to the Windows event log
    #Check if event log source exists, in this case, "PSRoboRefresh" is the source. A source must be registered to write to a windows event log
    if ([System.Diagnostics.EventLog]::SourceExists("PSRoboRefresh") -ne $true)
{
    #If the log source doesn't exist, create it in the "Application" event log
    New-EventLog -Source:PSRoboRefresh -LogName:Application

    #Write to the generic log file
    $currentLogMessage = "`n`n`rCreated Windows Event Log Source on $(get-date -f yyyy-MM-dd-hh.mm.ss)"
    $currentLogMessage | Out-File -FilePath:$internalLogPath -Append:$true -Encoding:ascii
    #Write to the Windows Event Log, the current log message, $currentLogMessage
    Write-EventLog -LogName:Application -Source:PSRoboRefresh -EntryType:Information -EventId:2020 -Message:$currentLogMessage
}

    #Write to generic log file regarding the overall status of the refresh operation.
    $currentLogMessage += "Completed refresh on $(get-date -f yyyy-MM-dd-hh.mm.ss) - See $robocopyLogPath"
    $currentLogMessage | Out-File -FilePath:$internalLogPath -Append:$true -Encoding:ascii
    #Write to the Windows Event Log, the current log message, $currentLogMessage
    Write-EventLog -LogName:Application -Source:PSRoboRefresh -EntryType:Information -EventId:2021 -Message:$currentLogMessage
    #Delete the "indentifier" file
    Remove-Item -Path:$refreshIdentFilePath -Force
    Exit

}
    else
    {
        #If the run does not occur on this iterations examination, just note such in the log to track that it is in fact still running the check
        $currentLogMessage = "`n`n`rSkipped on $(get-date -f yyyy-MM-dd-hh.mm.ss)"
        $currentLogMessage | Out-File -FilePath:$internalLogPath -Append:$true -Encoding:ascii
        #Write to the Windows Event Log, the current log message, $currentLogMessage
        Write-EventLog -LogName:Application -Source:PSRoboRefresh -EntryType:Information -EventId:2022 -Message:$currentLogMessage
        Exit
    }