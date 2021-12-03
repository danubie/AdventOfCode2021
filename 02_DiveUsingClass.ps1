. $PSScriptRoot\02_DiveClass.ps1

#  $data = @('forward 5', 'down 5', 'forward 8', 'up 3', 'down 8','forward 2')
$data = Get-Content -Path $PSScriptRoot\02_Dive.txt
$commands = $data | ConvertFrom-CSV -Delimiter ' ' -Header 'command', 'amount'

$sub = [submarine]::new()
$commands.ForEach({
    $sub.Command($_.command, $_.amount)
})
"Puzzle 2: $($sub.GetResult())"
