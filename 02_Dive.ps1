#  $data = @('forward 5', 'down 5', 'forward 8', 'up 3', 'down 8','forward 2')
$data = Get-Content -Path $PSScriptRoot\02_Dive.txt
$commands = $data | ConvertFrom-CSV -Delimiter ' ' -Header 'command', 'amount'
$position = 0
$depth = 0
$commands.foreach({
    $c= $_
    switch ($c.command) {
        'forward' { $position += $c.amount }
        'down' { $depth += $c.amount }
        'up' { $depth -= $c.amount }
        Default {}
    }
    Write-Verbose "$($c.command) $($c.amount)   $position  $depth"
})
"Puzzle 1 $($position * $depth)"

class submarine { 
    [int] $position
    [int] $depth
    [int] $aim
}
$submarine = [submarine]::new()
$commands.foreach({
    $c= $_
    $c.amount = [int] $c.amount
    switch ($c.command) {
        'forward' { $submarine.position += $c.amount; $submarine.depth += ($c.amount * $submarine.aim) }
        'down' { $submarine.aim += $c.amount }
        'up' { $submarine.aim -= $c.amount }
        Default {}
    }
    Write-Verbose ("{0}, {1}    {2}, {3}, {4}," -f $c.command, $c.amount, $submarine.position, $submarine.depth, $submarine.aim)
})
"Puzzle 2: $($submarine.position * $submarine.depth)"