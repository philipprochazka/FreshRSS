# This script performs the following:
# - Generate configuration file for po4a (can be configured in CONFIGFILE)
# - Generate POT file from pages/<DIRECTORY>/*.md
# - Update PO files in i18n directory with POT file
# - Generate localized pages.XX/<DIRECTORY>/*.md (where XX is the language code)
# - Remove unneeded new lines from generated pages

# Name of the po4a configuration file
$CONFIGFILE = 'po4a.conf'

# List of supported languages
$LANGS = @('fr')

# Check if po4a is installed
if (-Not (Get-Command po4a -ErrorAction SilentlyContinue)) {
    Write-Error 'It seems that po4a is not installed on your system.'
    Write-Error 'Please install po4a to use this script.'
    exit 1
}

# Generate po4a.conf file with list of TLDR pages
Write-Output 'Generating configuration file for po4a…'
@"
# WARNING: this file is generated with translation-update.ps1
# DO NOT modify this file manually!
[po4a_langs] $($LANGS -join ' ')
[po4a_paths] i18n/templates/freshrss.pot $lang:i18n/freshrss.$lang.po
"@ > $CONFIGFILE

Get-ChildItem -Path 'en' -Recurse -Filter '*.md' | Where-Object { $_.FullName -notmatch 'admins' } | ForEach-Object {
    Add-Content -Path $CONFIGFILE -Value "[type: text] en/$($_.FullName) \$lang:\$lang/$($_.FullName) opt:\"-o markdown\" opt:\"-M utf-8\""
}

# Generate POT file, PO files, and pages.XX pages
Write-Output 'Generating POT file and translated pages…'
Start-Process po4a -ArgumentList "-k 0 --msgid-bugs-address 'https://github.com/FreshRSS/FreshRSS/issues' $CONFIGFILE" -NoNewWindow -Wait
