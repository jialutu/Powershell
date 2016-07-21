function Invoke-WeeklyCleanup
(
	[Parameter(Mandatory=$true)]
	[string]$path,
	[Parameter(Mandatory=$false)]
	[string]$weekOfBackup = "Friday"
)
{
	$week = (get-date).DayOfWeek
	$date = get-date -format "yyyy_MM_dd"

	$limit = (Get-Date).AddDays(-7)
	$limit_wk = (Get-Date).AddDays(-30)
	$path_wk = $path + '\weekly'

	try {
		if (Test-Path $path)
		{
			if ($week -eq $weekOfBackup)
			{
				$allDailyBackupFiles = Get-ChildItem -Path $path |?{!$_.PSIsContainer}
				$latestBackupFile = $allDailyBackupFiles | Sort-Object -Property CreationTime -Descending | Select-Object -First 1
				$file = $latestBackupFile.FullName
				if (Test-Path $file)
				{
					if (Test-Path $path_wk)
					{
						Move-Item -path $file -destination $path_wk
					}
					else
					{
						throw "Weekly destination path does not exist"
					}
				}
				else
				{
					throw "Weekly backup does not exist"
				}
			}
			# Delete files older than the $limit.
			Get-ChildItem -Path $path -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
			
			Get-ChildItem -Path $path_wk -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit_wk } | Remove-Item -Force
		}
		else
		{
			throw "Path doesn't exist"
		}
	}
	catch [Exception]
	{
		throw "File clean up failed"
	}
}

function Invoke-Cleanup (
	[Parameter(Mandatory=$true)]
	[string]$path 
)
{
	$limit = (Get-Date).AddDays(-7)
	
	try {
		if (Test-Path $path)
		{
			# Delete files older than the $limit.
			Get-ChildItem -Path $path -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
		}
		else
		{
			throw "Path doesn't exist"
		}
	}
	catch [Exception]
	{
		throw "File clean up failed"
	}
}