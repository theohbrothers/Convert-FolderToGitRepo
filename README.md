# Convert-FolderToGitRepo

A script to convert ancient folder(s) into a git repo.

It is especially useful for converting old folders (possibly decade(s) old) into git repos, committing the files in chronological order they were created / modified (i.e. (using modified dates of files). That way, file metadata, especially date modified, is preserved in the `git log`. Optionally, allows specifying an override `git author`.

## How it works

Gathers all modified dates of descending files of a given folder. Starting from the earliest modified date:

- Does `git init`
- Does `git add` each file matching the modified date
- Does `git commit -m '[<date_iso>] Add files' --date <date_iso_in_git_format> --author <optional author>`

The date in the commit message is in [`ISO 8601`](https://www.iso.org/iso-8601-date-and-time-format.html) format in timezone `UTC+0`. You may want to modify the commit message to your liking.
