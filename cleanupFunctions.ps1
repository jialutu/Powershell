# This function does a cleanup to delete files older than 7 days. It also keeps a weekly backup indicated by $weekOfBackup, which defaults to Friday.
# It then clears the weekly backups that are older than 30 days.
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

# This function does a cleanup of files indicated in the $path parameter are older than $days, which is currently defaulted at 7.
function Invoke-Cleanup (
	[Parameter(Mandatory=$true)]
	[string]$path,
	[Parameter(Mandatory=$false)]
	[int]$days = 7
)
{
	$days = -1*$days
	$limit = (Get-Date).AddDays($days)
	
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

function Invoke-Archive
(
	[Parameter(Mandatory=$true)]
	[string]$path,
	[Parameter(Mandatory=$false)]
	[int]$days = 30,
	[Parameter(Mandatory=$false)]
	[int]$days_arc = 600
)
{
	$days = -1*$days
	$days_arc = -1*$days_arc
	$week = (get-date).DayOfWeek
	$date = get-date -format "yyyy_MM_dd"

	$limit = (Get-Date).AddDays($days)
	$limit_arc = (Get-Date).AddDays($days_arc)
	$path_arc = $path + '\archive'

	try {
		if (Test-Path $path)
		{
			if (Test-Path $path_arc)
			{	
				Get-ChildItem -Path $path -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Move-Item -destination $path_arc
			}
			else
			{
				mkdir $path_arc
				Get-ChildItem -Path $path -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Move-Item -destination $path_arc
			}
		# Delete files older than the $limit_arc
		Get-ChildItem -Path $path_arc -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit_arc } | Remove-Item -Force
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

function Invoke-Removal
(
	[Parameter(Mandatory=$true)]
	[string]$path,
	[Parameter(Mandatory=$false)]
	[string]$exclude,
	[Parameter(Mandatory=$false)]
	[int]$days = 30
)
{
	$days = -1*$days
	$week = (get-date).DayOfWeek
	$date = get-date -format "yyyy_MM_dd"

	$limit = (Get-Date).AddDays($days)

	try {
		if (Test-Path $path)
		{
			Get-ChildItem -Path $path -Exclude $exclude -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
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
