$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.IO.Compression.FileSystem

$source = 'C:\Users\BlackHat\Documents\IC-Business-Project-Proposal-Template.docx'
$output = Join-Path (Get-Location) 'Student_Life_Hub_Project_Proposal.docx'
$zip = Join-Path (Get-Location) 'proposal-working.zip'
$work = Join-Path (Get-Location) 'proposal-working'

if (Test-Path $work) { Remove-Item -LiteralPath $work -Recurse -Force }
if (Test-Path $zip) { Remove-Item -LiteralPath $zip -Force }
if (Test-Path $output) { Remove-Item -LiteralPath $output -Force }

Copy-Item -LiteralPath $source -Destination $zip
Expand-Archive -LiteralPath $zip -DestinationPath $work

$documentPath = Join-Path $work 'word\document.xml'
$document = New-Object System.Xml.XmlDocument
$document.PreserveWhitespace = $true
$document.Load($documentPath)
$ns = New-Object System.Xml.XmlNamespaceManager($document.NameTable)
$ns.AddNamespace('w', 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
$w = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
$xml = 'http://www.w3.org/XML/1998/namespace'
$tables = $document.SelectNodes('//w:body/w:tbl', $ns)

function Get-Cell([int]$tableNumber, [int]$rowNumber, [int]$columnNumber) {
    $table = $tables[$tableNumber - 1]
    $row = $table.SelectNodes('./w:tr', $ns)[$rowNumber - 1]
    return $row.SelectNodes('./w:tc', $ns)[$columnNumber - 1]
}

function Set-CellText($cell, [string]$text) {
    $oldParagraph = $cell.SelectSingleNode('./w:p', $ns)
    $oldRun = if ($oldParagraph) { $oldParagraph.SelectSingleNode('./w:r', $ns) } else { $null }
    $pPr = if ($oldParagraph) { $oldParagraph.SelectSingleNode('./w:pPr', $ns) } else { $null }
    $rPr = if ($oldRun) { $oldRun.SelectSingleNode('./w:rPr', $ns) } else { $null }

    foreach ($child in @($cell.ChildNodes)) {
        if ($child.LocalName -ne 'tcPr') { [void]$cell.RemoveChild($child) }
    }

    $p = $document.CreateElement('w', 'p', $w)
    if ($pPr) { [void]$p.AppendChild($pPr.CloneNode($true)) }
    $r = $document.CreateElement('w', 'r', $w)
    if ($rPr) { [void]$r.AppendChild($rPr.CloneNode($true)) }
    $t = $document.CreateElement('w', 't', $w)
    $t.SetAttribute('space', $xml, 'preserve')
    $t.InnerText = $text
    [void]$r.AppendChild($t)
    [void]$p.AppendChild($r)
    [void]$cell.AppendChild($p)
}

function Set-TableCell([int]$table, [int]$row, [int]$column, [string]$text) {
    Set-CellText (Get-Cell $table $row $column) $text
}

# Project identification
Set-TableCell 1 1 2 'Student Life Hub - Offline Student Productivity System'
Set-TableCell 1 2 2 'Sum Sambo, Founder, with Sao Sreynet, Srun Darasthya, and Kun Korn'
Set-TableCell 1 2 4 'Software project - offline-first Flutter application'
Set-TableCell 1 3 2 'sumsambo8899@gmail.com; phone not provided'
Set-TableCell 1 3 4 'Student project prototype; current implementation uses no paid backend'
Set-TableCell 1 4 2 '28 September 2026'
Set-TableCell 1 4 4 '1.0 proposal'
Set-TableCell 1 5 2 'September 2026'
Set-TableCell 1 5 4 'December 2026 MVP release'

# Stakeholders
Set-TableCell 2 3 1 'Sum Sambo - Founder and project sponsor - sumsambo8899@gmail.com'
Set-TableCell 2 5 1 'Sum Sambo - Project manager and lead developer - sumsambo8899@gmail.com'
Set-TableCell 2 8 1 'Sao Sreynet'
Set-TableCell 2 8 2 'Team member - planning, research, and testing'
Set-TableCell 2 8 3 'Project team contact'
Set-TableCell 2 9 1 'Srun Darasthya'
Set-TableCell 2 9 2 'Team member - design review and documentation'
Set-TableCell 2 9 3 'Project team contact'
Set-TableCell 2 10 1 'Kun Korn'
Set-TableCell 2 10 2 'Team member - testing and feedback'
Set-TableCell 2 10 3 'Project team contact'
Set-TableCell 2 11 1 'Student users and instructors'
Set-TableCell 2 11 2 'Pilot users and reviewers'
Set-TableCell 2 11 3 'To be confirmed during pilot'

# Project overview
Set-TableCell 3 3 1 'Student Life Hub is a privacy-focused, offline-first Flutter application that helps students organize schedules, assignments, events, expenses, attendance, grades, study sessions, and personal progress in one calm workspace.'
Set-TableCell 3 5 1 'Provide one reliable student workspace; reduce missed deadlines; make weekly planning easier; track academic and financial routines; support English and Khmer users; work without an account or internet connection.'
Set-TableCell 3 7 1 'Students often use disconnected notes, calendars, spreadsheets, and messaging apps. A local-first hub reduces fragmentation, keeps sensitive student information on the device, and provides useful analytics without requiring a server.'
Set-TableCell 3 9 1 'The MVP can be fast-tracked because the core data model, responsive UI, offline persistence, backup, localization, analytics, and reminder foundation are already implemented. A pilot can validate usability before advanced integrations.'
Set-TableCell 3 11 1 'Flutter SDK; Android Studio for Android releases; macOS and Xcode for iOS releases; local device storage; optional system notification permissions; no required cloud account or backend.'
Set-TableCell 3 13 1 'Flutter and Dart; Material 3; GetX state management; GoRouter navigation; SharedPreferences local storage; AES-256-GCM encrypted backups with Argon2id password derivation; local notifications; PDF and calendar export.'
Set-TableCell 3 15 1 'Risks include device loss, forgotten backup passwords, notification permission differences, small-screen overflow, data migration defects, and untested store-signing configurations. Mitigations include encrypted exports, validation, migrations, responsive layouts, CI checks, and real-device acceptance testing.'

# Scope
Set-TableCell 4 3 2 'Student organization, academic planning, personal productivity, local privacy, accessibility, and bilingual support'
Set-TableCell 4 4 2 'Schedules, tasks, recurring tasks, events, expenses, attendance, GPA, streaks, reports, focus timer, and analytics'
Set-TableCell 4 5 2 'Offline storage, encrypted backups, local reminders, responsive UI, English and Khmer localization'
Set-TableCell 4 6 2 'Testing, documentation, deployment preparation, and release branding'
Set-TableCell 4 8 2 'Cloud synchronization, online accounts, payment processing, real-time social networking, and institution-wide administration'
Set-TableCell 4 9 2 'Guaranteed notification delivery when users deny system permissions or restrict background activity'
Set-TableCell 4 10 2 'Official academic-record integration without an approved institutional API'
Set-TableCell 4 12 1 'Working offline-first Flutter MVP; Android release preparation; web release; documentation; test suite; privacy and security guidance'

# Timeline
Set-TableCell 5 2 2 'The project is delivered in incremental phases so that a usable offline MVP is available before optional polish and store publication.'
$milestones = @(
    @('Requirements and user-flow review', 'September 2026'),
    @('Core data model and offline storage', 'September 2026'),
    @('Schedules, tasks, events, and expenses', 'October 2026'),
    @('Attendance, GPA, streaks, and analytics', 'October 2026'),
    @('Localization, accessibility, and responsive QA', 'November 2026'),
    @('Encrypted backup and local reminders', 'November 2026'),
    @('Android and web release validation', 'December 2026'),
    @('Pilot feedback and final MVP handoff', 'December 2026')
)
for ($i = 0; $i -lt $milestones.Count; $i++) {
    Set-TableCell 5 ($i + 4) 1 $milestones[$i][0]
    Set-TableCell 5 ($i + 4) 2 $milestones[$i][1]
}
Set-TableCell 5 14 2 'Small cross-functional student team with development, design, documentation, testing, and review responsibilities.'
$staff = @(
    @('Product and project management', 'Requirements, prioritization, acceptance decisions', '0.25'),
    @('Flutter development', 'Dart, Flutter, GetX, routing, local storage', '0.75'),
    @('UX and visual design', 'Responsive Material 3 layouts and accessibility review', '0.25'),
    @('QA and device testing', 'Analyzer, tests, Android device, narrow-layout checks', '0.25'),
    @('Documentation and presentation', 'Proposal, README, privacy, deployment notes', '0.15'),
    @('Pilot users', 'Student feedback and usability validation', 'As available'),
    @('Total planned effort', 'Student project effort; not a full-time commercial staffing plan', '1.65')
)
for ($i = 0; $i -lt $staff.Count; $i++) {
    Set-TableCell 5 ($i + 16) 1 $staff[$i][0]
    Set-TableCell 5 ($i + 16) 2 $staff[$i][1]
    Set-TableCell 5 ($i + 16) 3 $staff[$i][2]
}

# Budget
Set-TableCell 6 2 1 'Current development cost: student-owned tools and open-source Flutter packages. Expected pilot cost: USD 0 excluding personal hardware, internet, optional app-store accounts, and future hosting.'
Set-TableCell 6 3 2 'USD 0 current MVP budget; future store, domain, hosting, and support costs require separate approval.'

# Related documents
Set-TableCell 7 3 1 'Technical documentation'; Set-TableCell 7 3 2 'Architecture, features, run instructions, and deployment notes'; Set-TableCell 7 3 3 'README.md in project repository'
Set-TableCell 7 4 1 'Security'; Set-TableCell 7 4 2 'Security boundary, backup handling, deployment requirements'; Set-TableCell 7 4 3 'SECURITY.md in project repository'
Set-TableCell 7 5 1 'Privacy'; Set-TableCell 7 5 2 'Local storage, notifications, encrypted backup, and diagnostics'; Set-TableCell 7 5 3 'PRIVACY.md in project repository'
Set-TableCell 7 6 1 'Release checklist'; Set-TableCell 7 6 2 'CI, Android signing, web build, and device acceptance tests'; Set-TableCell 7 6 3 'GitHub Actions workflow and README.md'

# Executive decision record
Set-TableCell 8 3 1 '28 September 2026'; Set-TableCell 8 3 2 'Sum Sambo'; Set-TableCell 8 3 3 'Approve offline MVP completion and begin verification/pilot phase.'
Set-TableCell 8 4 1 '28 September 2026'; Set-TableCell 8 4 2 'Project team'; Set-TableCell 8 4 3 'Complete analyzer, tests, release build, and physical-device checks before publication.'

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Encoding = New-Object System.Text.UTF8Encoding($false)
$settings.Indent = $false
$writer = [System.Xml.XmlWriter]::Create($documentPath, $settings)
$document.Save($writer)
$writer.Close()

Compress-Archive -Path (Join-Path $work '*') -DestinationPath $zip -Force
Move-Item -LiteralPath $zip -Destination $output -Force
Remove-Item -LiteralPath $work -Recurse -Force
Write-Output "Created $output"
