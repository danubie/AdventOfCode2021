# $PSScriptRoot\05_HydrothermalVenture-Sample.txt
# $data = Get-Content $PSScriptRoot\05_HydrothermalVenture.txt
function ReadInputData($filename) {
    $data = Get-Content $filename
    $data = $data | ForEach-Object {
        $null = $_ -match '(?<x0>\d*),(?<y0>\d*) -> (?<x1>\d*),(?<y1>\d*)'
        [pscustomobject] [ordered] @{
            From = [pscustomobject] [ordered] @{
                x = [int] $Matches['x0']
                y = [int] $Matches['y0']
            }
            To = [pscustomobject] [ordered] @{
                x = [int] $Matches['x1']
                y = [int] $Matches['y1']
            }
        }
    }
    $data
}

function DebugData ($data) {
    foreach ($d in $data) {
        Write-Host " $($d.From.x), $($d.From.y) -> $($d.To.x), $($d.To.y)"
    }
}

function ShowField ($field, $dimension) {
    if ($VerbosePreference -ne 'Continue') { return }
    for ($j = 0; $j -lt $dimension; $j++) {
        $s = ''
        for ($i = 0; $i -lt $dimension; $i++) {
            if ($field[$i, $j] -eq 0) {
                $s = $s + "."
            } else {
                $s = $s + $field[$i, $j]
            }
        }
        Write-Verbose $s
    }
    Write-Verbose "        ----------"
}

function CountFieldsGreaterThenOne ($field, $dimension) {
    $count = 0
    for ($i = 0; $i -lt $dimension; $i++) {
        for ($j = 0; $j -lt $dimension; $j++) {
            if ($field[$i, $j] -gt 1) {
                $count++
            }
        }
    }
    return $count
}
function NormalizeCoordinates ($data) {
    foreach ($coord in $data) {
        if ($coord.From.x -gt $coord.To.x) {
            # swap from x and to x
            $tmp = $coord.From.x
            $coord.From.x = $coord.To.x
            $coord.To.x = $tmp
        }
        if ($coord.From.y -gt $coord.To.y) {
            # swap from y and to y
            $tmp = $coord.From.y
            $coord.From.y = $coord.To.y
            $coord.To.y = $tmp
        }
    }
}

function xInitField ($dimension) {
    $field = New-Object 'System.Int32[,]' $dimension, $dimension
    for ($i = 0; $i -lt $dimension; $i++) {
        for ($j = 0; $j -lt $dimension; $j++) {
            $field[$i,$j] = 0
        }
    }
    $field
}

function MarkLines ($field, $data) {
    foreach ($coord in $data) {
        $i = $coord.From.x
        $j = $coord.From.y
        $iIncr = $coord.From.x -lt $coord.To.x ? 1 : ($coord.From.x -eq $coord.To.x ? 0 : -1)
        $jIncr = $coord.From.y -lt $coord.To.y ? 1 : ($coord.From.y -eq $coord.To.y ? 0 : -1)
        do {
           $field[$i, $j] = $field[$i, $j] + 1
           $i += $iIncr; $j += $jIncr;
        } until ($i -eq $coord.To.x -and $j -eq $coord.To.y)
        # set the last point
        $field[$i, $j] = $field[$i, $j] + 1
       Write-Verbose "$($coord.From.x),$($coord.From.y) -> $($coord.To.x),$($coord.To.y)"
       ShowField $field $dimension
    }
}

function ReduceToStraightLines ($data) {
    # for now only consider horicontal and vertical lines
    $data = $data | Where-Object {
        $d = $_
        $d.From.x -eq $d.To.x -or $d.From.y -eq $d.To.y
    }
    $data
}
function part1 ($filename, $dimension) {
    $field = New-Object 'System.Int32[,]' $dimension,$dimension
    $data = ReadInputData $filename
    NormalizeCoordinates $data
    $data = ReduceToStraightLines $Data

    # DebugData $data

    MarkLines $field $data

    # ShowField $field
    
    $count = CountFieldsGreaterThenOne $field $dimension
    Write-Host "Number of fields with more then one line: $count"
}
part1 $PSScriptRoot\05_HydrothermalVenture-Sample.txt 10
function part2 ($filename, $dimension) {
    $field = New-Object 'System.Int32[,]' $dimension,$dimension
    $data = ReadInputData $filename
    # NormalizeCoordinates $data
    MarkLines $field $data
    ShowField $field $dimension
    $count = CountFieldsGreaterThenOne $field $dimension
    Write-Host "Number of fields with more then one line: $count"
}
part2 $PSScriptRoot\05_HydrothermalVenture.txt 1000

