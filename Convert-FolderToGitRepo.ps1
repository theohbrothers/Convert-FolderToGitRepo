# Edit script settings
$CONFIG = @{
    # 1 to do a dry run (i.e. simulate a run)
    # 0 to actually run
    dryrun = 1

    # Specify folder(s) to convert to repos, one per line. Be sure to double-quote each path
    # It is suggested to convert one repo at a time.
    repos = @(
        # Windows
        # 'C:\path\to\folder1'
        # 'C:\path\to\folder2'
        # 'C:\path\to\folder3'

        # Unix
        # '/path/to/folder1'
        # '/path/to/folder2'
        # '/path/to/folder3'
    )

    # Optional: Override git author
    # author = 'John Doe <johndoe@example.com>'
}

function Execute-Command ([string]$Command, [array]$ArgumentList, [string]$WorkingDirectory, [bool]$DryRun)  {
    if ($Command) {
        "Will execute: $Command $ArgumentList" | Write-Host -ForegroundColor Green
        if (!$DryRun) {
            # Start-Process requires that each item in the -ArgumentList must be double-quoted if there are spaces, or else they be treated as individual arguments. See: https://github.com/PowerShell/PowerShell/issues/5576
            $process = Start-Process -NoNewWindow -Wait -WorkingDirectory $WorkingDirectory -FilePath $Command -ArgumentList $ArgumentList -PassThru # Use -FilePath echoargs to test
            if ($process.ExitCode -gt 0) {
                Write-Error "There was an error."
            }
        }
    }
}

function Convert-FolderToGitRepo {
    foreach ($repo in $CONFIG['repos']) {
        "[Repo]" | Write-Host -ForegroundColor Cyan
        "Repo: $repo" | Write-Host
        Push-Location "$repo" -ErrorAction Stop
        $groups = Get-childitem . -Recurse -File | sort-object -property lastwritetime | Group-Object LastWriteTime #-descending | select -first 1 | select -expandproperty lastwritetime
        $groups | Out-String | Write-Host

        "[Commands]" | Write-Host -ForegroundColor Cyan
        $args = @( 'init' )
        Execute-Command -Command 'git' -ArgumentList $args -WorkingDirectory $repo -DryRun $CONFIG['dryrun']
        foreach ($group in $groups) {
            foreach ($file in $group.Group) {
                $args = @( "add", "`"$( $file.FullName )`"" )
                Execute-Command -Command 'git' -ArgumentList $args -WorkingDirectory $repo -DryRun $CONFIG['dryrun']
            }
            if ($date = $file.lastwritetime.ToUniversalTime()) {
                $isoDate = $date.tostring('yyyy-MM-dd HH:mm:ss zz00')
                $gitDate = $date.tostring('ddd MMM d HH:mm:ss yyyy zz00')

                $args = @( "commit", "-m", "`"[$isoDate] Add files`"", "--date", "`"$gitDate`"" )
                if ($CONFIG['author']) {
                    $args += @( "--author", $CONFIG['author'] )
                }
                Execute-Command -Command 'git' -ArgumentList $args -WorkingDirectory $repo -DryRun $CONFIG['dryrun']
            }
        }

        "Completed repo: $repo" | Write-Host
        Pop-Location
    }
}

Convert-FolderToGitRepo
