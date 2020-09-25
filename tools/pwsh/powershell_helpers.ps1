function Write-And-Invoke([string]$command) {
<#
  .SYNOPSIS
    Write a command to the terminal before executing it.

  .DESCRIPTION
    Uses `Write-Ouptut` to print the given command then uses `Invoke-Expression`
    to execute it.

    The command is written to the terminal with a preceeding '+ ' to indicate
    that this function printed it, and it's not an output of the given command.

  .PARAMETER command
    Command to execute.

  .EXAMPLE
    Write-And-Invoke "Write-Output 'Hello, World!'"
      Outputs:
        + Write-Output 'Hello, World!'
        Hello, World!
#>
  Write-Output "+ $command"
  Invoke-Expression "$command"
}

function Invoke-In-Dir {
<#
  .SYNOPSIS
    Execute a command in the given directory then return to the original
    directory - printing the given command.

  .DESCRIPTION
    Changes directory before executing the command. It uses a try-finally block
    so that the original directory is returned to even if the given command
    exits the script. The command is executed using Write-And-Invoke, so it is
    written to the terminal with a preceeding '+ ' before being executed.

  .PARAMETER directory
    The directory to execute the command in.
  .PARAMETER command
    Command to execute.

  .EXAMPLE
    cd C:\Users\Public\
    Get-Location
    Invoke-In-Dir C:\Users\Public\Documents Get-Location
    Get-Location

      Outputs:
        C:\Users\Public\
        + Get-Location
        C:\Users\Public\Documents
        C:\Users\Public\
#>
  param([string]$directory, [string]$command)
  Push-Location -Path $directory
  try {
    Write-And-Invoke "$command"
  }
  finally {
    Pop-Location
  }
}
