# implemented as  full class
class submarine { 
    [int] hidden $position
    [int] hidden $depth
    [int] hidden $aim

    [void] Forward ([int] $Value) {
        $this.position += $Value
        $this.depth += ($Value * $this.aim)
    }
    [void] Down  ([int] $Value) {
        $this.aim += $Value
    }
    [void] Up  ([int] $Value) {
        $this.aim -= $Value
    }
    [int] GetPosition() {
        return $this.position
    }
    [int] GetDepth() {
        return $this.depth
    }
    [int] GetAim() {
        return $this.aim
    }
    [int] GetResult() {
        return $this.position * $this.depth
    }
    [void] Command ([string] $Command, [int] $Value) {
        switch ($Command) {
            'forward' { $this.Forward($Value) }
            'down' { $this.Down($Value) }
            'up' { $this.Up($Value) }
            Default {}
        }
        Write-Verbose ("{0}, {1}    {2}, {3}, {4}," -f $Command, $Value, $this.GetPosition(), $this.GetDepth(), $this.GetAim())
    }
}

function Puzzle2 {
    #  $data = @('forward 5', 'down 5', 'forward 8', 'up 3', 'down 8','forward 2')
    $data = Get-Content -Path $PSScriptRoot\02_Dive.txt
    $commands = $data | ConvertFrom-CSV -Delimiter ' ' -Header 'command', 'amount'
    
    $sub = [submarine]::new()
    $commands.ForEach({
        $sub.Command($_.command, $_.amount)
    })
    "Puzzle 2: $($sub.GetResult())"
}
