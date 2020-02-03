function Write-And-Invoke([string]$command) {
  Write-Output "+ $command"
  Invoke-Expression "$command"
}

function Invoke-In-Dir {
  param([string]$directory, [string]$command)
  Push-Location -Path $directory
  try {
    Write-And-Invoke "$command"
  }
  finally {
    Pop-Location
  }
}
