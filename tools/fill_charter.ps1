$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

$source = 'C:\Users\BlackHat\Documents\IC-Project-Charter-8556.xlsx'
$output = Join-Path (Get-Location) 'Student_Life_Hub_Project_Charter.xlsx'
$zip = Join-Path (Get-Location) 'charter-working.zip'
$work = Join-Path (Get-Location) 'charter-working'

if (Test-Path $work) { Remove-Item -LiteralPath $work -Recurse -Force }
if (Test-Path $zip) { Remove-Item -LiteralPath $zip -Force }
if (Test-Path $output) { Remove-Item -LiteralPath $output -Force }
Copy-Item -LiteralPath $source -Destination $zip
Expand-Archive -LiteralPath $zip -DestinationPath $work

$sheetPath = Join-Path $work 'xl\worksheets\sheet1.xml'
$sheet = New-Object System.Xml.XmlDocument
$sheet.PreserveWhitespace = $true
$sheet.Load($sheetPath)
$ns = New-Object System.Xml.XmlNamespaceManager($sheet.NameTable)
$ns.AddNamespace('x', 'http://schemas.openxmlformats.org/spreadsheetml/2006/main')
$main = 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'

function Set-Cell([string]$reference, [string]$value) {
    $rowNumber = [regex]::Match($reference, '\d+').Value
    $row = $sheet.SelectSingleNode("//x:sheetData/x:row[@r='$rowNumber']", $ns)
    if (-not $row) {
        $row = $sheet.CreateElement('x', 'row', $main)
        $row.SetAttribute('r', $rowNumber)
        [void]$sheet.SelectSingleNode('//x:sheetData', $ns).AppendChild($row)
    }
    $cell = $row.SelectSingleNode("./x:c[@r='$reference']", $ns)
    if (-not $cell) {
        $cell = $sheet.CreateElement('x', 'c', $main)
        $cell.SetAttribute('r', $reference)
        [void]$row.AppendChild($cell)
    }
    $cell.SetAttribute('t', 'inlineStr')
    foreach ($child in @($cell.ChildNodes)) { [void]$cell.RemoveChild($child) }
    $is = $sheet.CreateElement('x', 'is', $main)
    $text = $sheet.CreateElement('x', 't', $main)
    $text.InnerText = $value
    [void]$is.AppendChild($text)
    [void]$cell.AppendChild($is)
}

# General project information
Set-Cell 'B5' 'Student Life Hub - Offline Student Productivity System'
Set-Cell 'E5' 'Sum Sambo'
Set-Cell 'G5' 'Sum Sambo - Founder / Project Sponsor'
Set-Cell 'B7' 'sumsambo8899@gmail.com'
Set-Cell 'D7' 'Not provided'
Set-Cell 'E7' 'Student project / Computer Science'
Set-Cell 'B9' 'Sum Sambo; Sao Sreynet; Srun Darasthya; Kun Korn'
Set-Cell 'E9' 'September 2026'
Set-Cell 'G9' 'December 2026'
Set-Cell 'B11' 'Student project team'
Set-Cell 'E11' 'USD 0 current MVP budget'
Set-Cell 'G11' 'USD 0 excluding optional store, hardware, and future hosting costs'

# Project overview
Set-Cell 'C14' 'Students often manage classes, tasks, events, expenses, attendance, and grades in disconnected tools. This makes deadlines and routines difficult to track and can expose personal data to unnecessary online services.'
Set-Cell 'C15' 'Build a calm, professional, offline-first Flutter application that gives students one place to plan academic work, manage personal routines, understand progress, and keep data on their own device.'
Set-Cell 'C16' 'Student Life Hub addresses a practical student need with a low-cost local product. It reduces fragmented planning, supports English and Khmer users, works without internet access, and provides privacy-friendly exports and analytics.'
Set-Cell 'C17' 'MVP success is measured by: users can create and edit every core record; data remains after restart; backup and restore work; English and Khmer screens are usable; narrow layouts do not overflow; analyzer and tests pass; and pilot users can complete common tasks without guidance.'
Set-Cell 'C18' 'Responsive Flutter application; schedules; recurring tasks; events; expenses; attendance; GPA tracker; study streaks; reports; Pomodoro timer; analytics dashboard; English/Khmer localization; local reminders; encrypted backups; web and Android release builds; documentation and privacy guidance.'

# Scope
Set-Cell 'C21' 'Offline schedules, tasks, recurring tasks, events, expenses, attendance, grades, GPA, study streaks, analytics, reports, focus timer, local reminders, encrypted backups, English/Khmer localization, accessibility, responsive layouts, and Android/web release preparation.'
Set-Cell 'C22' 'Cloud synchronization, online accounts, real-time social groups, payment processing, institution-wide administration, guaranteed notifications when permissions are denied, and official academic-system integration without an approved API.'

# Schedule
$milestones = @(
    @('Form project team / preliminary review / scope', 'September 2026', 'September 2026'),
    @('Finalize project plan / charter / kick-off', 'September 2026', 'September 2026'),
    @('Define phase - requirements, user flows, data model', 'September 2026', 'October 2026'),
    @('Measurement phase - baseline tests and responsive checks', 'October 2026', 'October 2026'),
    @('Analysis phase - usability, storage, and risk review', 'October 2026', 'November 2026'),
    @('Improvement phase - localization, accessibility, security', 'November 2026', 'November 2026'),
    @('Control phase - CI, release builds, and backup validation', 'November 2026', 'December 2026'),
    @('Project summary report and pilot close-out', 'December 2026', 'December 2026')
)
for ($i = 0; $i -lt $milestones.Count; $i++) {
    $row = 26 + $i
    Set-Cell "B$row" $milestones[$i][0]
    Set-Cell "E$row" $milestones[$i][1]
    Set-Cell "G$row" $milestones[$i][2]
}

# Resources
Set-Cell 'C38' 'Sum Sambo - project manager, lead Flutter developer, architecture, storage, and release coordination.'
Set-Cell 'C39' 'Sao Sreynet, Srun Darasthya, and Kun Korn - planning, design review, testing, documentation, and pilot feedback.'
Set-Cell 'C40' 'Flutter SDK, Android Studio, Android test device, macOS/Xcode for iOS release, GitHub CI, and secure release credentials.'

# Costs: this is a student MVP and intentionally replaces sample template figures.
Set-Cell 'C44' 'Flutter and Dart development'; Set-Cell 'E44' '0'; Set-Cell 'F44' '1'; Set-Cell 'G44' '0'
Set-Cell 'C45' 'Open-source packages'; Set-Cell 'E45' '0'; Set-Cell 'F45' '1'; Set-Cell 'G45' '0'
Set-Cell 'C46' 'Testing and documentation'; Set-Cell 'E46' '0'; Set-Cell 'F46' '1'; Set-Cell 'G46' '0'
Set-Cell 'C47' 'Student development time'; Set-Cell 'E47' '0'; Set-Cell 'F47' '1'; Set-Cell 'G47' '0'
Set-Cell 'C48' 'Optional app-store account fees'; Set-Cell 'E48' '0'; Set-Cell 'F48' '0'; Set-Cell 'G48' '0'
Set-Cell 'C49' 'Optional hosting or domain'; Set-Cell 'E49' '0'; Set-Cell 'F49' '0'; Set-Cell 'G49' '0'
Set-Cell 'C50' 'Contingency'; Set-Cell 'E50' '0'; Set-Cell 'F50' '0'; Set-Cell 'G50' '0'
Set-Cell 'G51' '0'

# Benefits and customers
Set-Cell 'C54' 'Student Life Hub project team / future product owner'
Set-Cell 'C55' 'Students, instructors, project reviewers, and potential campus partners'
Set-Cell 'C56' 'Students who need a private, simple productivity workspace'
Set-Cell 'C57' 'Better planning, fewer missed deadlines, improved routine awareness, safer local data handling, and a foundation for future optional integrations.'
Set-Cell 'C60' 'Reduced missed deadlines and duplicated planning work'; Set-Cell 'G60' 'Not monetized for MVP'
Set-Cell 'C61' 'Potential future campus or education partnerships'; Set-Cell 'G61' 'Not monetized for MVP'
Set-Cell 'C62' 'Less time switching between separate tools'; Set-Cell 'G62' 'Qualitative pilot metric'
Set-Cell 'C63' 'Clear privacy and backup boundaries'; Set-Cell 'G63' 'Qualitative pilot metric'
Set-Cell 'C64' 'Dashboard supports weekly decisions'; Set-Cell 'G64' 'Qualitative pilot metric'
Set-Cell 'C65' 'Local-first design reduces service dependency'; Set-Cell 'G65' 'Qualitative pilot metric'
Set-Cell 'C66' 'Offline access when internet is unavailable'; Set-Cell 'G66' 'Qualitative pilot metric'
Set-Cell 'G67' 'Not monetized for MVP'

# Risks, constraints, and assumptions
Set-Cell 'C70' 'Device loss, forgotten encrypted-backup passwords, permission differences, notification restrictions, data migration defects, small-screen overflow, and untested store signing.'
Set-Cell 'C71' 'Offline-only scope; limited student-team time; iOS signing requires macOS/Xcode; real-device coverage depends on available hardware; no institutional API or cloud backend.'
Set-Cell 'C72' 'Students have access to a supported Flutter platform; users understand that backups are their responsibility; pilot feedback is available; release credentials remain private; future cloud features remain optional.'

# Approval
Set-Cell 'B75' 'Sum Sambo'
Set-Cell 'C75' 'Founder / Project Manager'
Set-Cell 'G75' '28 September 2026'

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Encoding = New-Object System.Text.UTF8Encoding($false)
$settings.Indent = $false
$writer = [System.Xml.XmlWriter]::Create($sheetPath, $settings)
$sheet.Save($writer)
$writer.Close()

Compress-Archive -Path (Join-Path $work '*') -DestinationPath $zip -Force
Move-Item -LiteralPath $zip -Destination $output -Force
Remove-Item -LiteralPath $work -Recurse -Force
Write-Output "Created $output"
