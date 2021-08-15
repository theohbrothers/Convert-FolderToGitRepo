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

function Execute-Command ($Command, $DryRun)  {
    if ($Command) {
        "Will execute: $Command" | Write-Host -ForegroundColor Yellow
        if (!$DryRun) {
            Invoke-Expression $Command
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
        Execute-Command -Command "git init" -DryRun $CONFIG['dryrun']
        foreach ($group in $groups) {
            foreach ($file in $group.Group) {
                Execute-Command -Command "git add '$( $file.FullName )'" -DryRun $CONFIG['dryrun']
            }
            if ($date = $file.lastwritetime.ToUniversalTime()) {
                $isoDate = $date.tostring('yyyy-MM-dd HH:mm:ss zz00')
                $gitDate = $date.tostring('ddd MMM d HH:mm:ss yyyy zz00')

                $cmd = "git commit -m '[$isoDate] Add files' --date '$gitdate'"
                if ($CONFIG['author']) {
                    $cmd += " --author '$( $CONFIG['author'] )'"
                }
                Execute-Command -Command $cmd -DryRun $CONFIG['dryrun']
            }
        }

        "Completed repo: $repo" | Write-Host
        Pop-Location
    }
}

Convert-FolderToGitRepo
