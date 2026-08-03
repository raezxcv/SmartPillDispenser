$files = Get-ChildItem -Path "c:\Users\User\SmartPillDispenser\flutter_app\lib" -Recurse -Filter "*.dart"
foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $updated = $content `
        -replace "Smart Pill Dispenser", "SmartDose" `
        -replace "SmartPill Dispenser", "SmartDose" `
        -replace "SmartPillDispenser", "SmartDose" `
        -replace "MedSync", "SmartDose"
    if ($updated -ne $content) {
        Set-Content -Path $file.FullName -Value $updated -Encoding UTF8 -NoNewline
        Write-Host "Updated: $($file.FullName)"
    }
}
Write-Host "Done."
