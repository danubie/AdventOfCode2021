Set-StrictMode -Version Latest
function ReadInputData ($fileName ) {
    Get-Content $filename
}
function FillMatrix ($matrix, $rawdata, $rows, $cols) {
    for ($row = 0; $row -lt $rows; $row++) {
        for ($col = 0; $col -lt $cols; $col++) {
            $matrix[$row, $col] = $rawdata[$row].Substring($col, 1)
        }
    }
}
function FillSurroundedMatrix ($matrix, $rawdata, $rows, $cols) {
    for ($row = 0; $row -lt $rows; $row++) {
        for ($col = 0; $col -lt $cols; $col++) {
            $matrix[($row+1), ($col+1)] = $rawdata[$row].Substring($col, 1)
        }
    }
    for ($i=0; $i -lt $rows+2; $i++) {
        $matrix[$i, 0] = 99
        $matrix[$i, ($cols+1)] = 99
    }
    for ($i=0; $i -lt $cols+2; $i++) {
        $matrix[0, $i] = 99
        $matrix[($rows+1), $i] = 99
    }

}

function FindAllLowPoints ($matrix, $rows, $cols) {
    for ($i = 1; $i -lt $rows+1; $i++) {
        for ($j = 1; $j -lt $cols+1; $j++) {
            $isLowPoint = $true
            $isLowPoint = $isLowPoint -and ($matrix[$i, $j] -lt $matrix[($i-1), ($j-1)])
            $isLowPoint = $isLowPoint -and ($matrix[$i, $j] -lt $matrix[($i-1), ($j)])
            $isLowPoint = $isLowPoint -and ($matrix[$i, $j] -lt $matrix[($i-1), ($j+1)])
            $isLowPoint = $isLowPoint -and ($matrix[$i, $j] -lt $matrix[($i), ($j-1)])
            $isLowPoint = $isLowPoint -and ($matrix[$i, $j] -lt $matrix[($i), ($j+1)])
            $isLowPoint = $isLowPoint -and ($matrix[$i, $j] -lt $matrix[($i+1), ($j-1)])
            $isLowPoint = $isLowPoint -and ($matrix[$i, $j] -lt $matrix[($i+1), ($j)])
            $isLowPoint = $isLowPoint -and ($matrix[$i, $j] -lt $matrix[($i+1), ($j+1)])
            if ($isLowPoint) {
                $lowpoint = $matrix[$i, $j]
                [pscustomobject]@{
                    lowpoint = $lowpoint
                    row = $i
                    col = $j
                }
            }
        }
    }

}

$level=0
function FindBasinFromPoint ($matrix, [int]$rows, [int]$cols, [int]$thisRow, [int]$thisCol) {
    $s = "$level Finding basin from point $thisRow, $thisCol = $($matrix[$thisRow, $thisCol])"
    Write-Verbose "$s -------"
    if ($surroundedmatrix[$thisRow, $thisCol] -ge 9) {
        Write-Verbose "$s returning 0"
        return 0
    }
    $level++
    $isBasin = 1
    $surroundedmatrix[$thisrow, $thiscol] = 88
    # ask my neigbours
    $isBasin += FindBasinFromPoint $surroundedmatrix $rows $cols ($thisRow-1) ($thisCol)
    $isBasin += FindBasinFromPoint $surroundedmatrix $rows $cols ($thisRow+1) ($thisCol)
    $isBasin += FindBasinFromPoint $surroundedmatrix $rows $cols ($thisRow) ($thisCol-1)
    $isBasin += FindBasinFromPoint $surroundedmatrix $rows $cols ($thisRow) ($thisCol+1)
    $level--
    Write-Verbose "$s returning $isbasin"
    return $isBasin
}

function DebugMatrix ($matrix, $rows, $cols) {
    for ($row = 0; $row -lt $rows; $row++) {
        for ($col = 0; $col -lt $cols; $col++) {
            Write-Host ("{0,2} " -f $matrix[$row, $col]) -NoNewline
        }
        Write-Host ""
    }
}

function Day9 {
    $filename = '.\09_SmokeBasin.txt'
    $rawdata = Get-Content -Path $fileName

    $matrix = New-Object 'System.Int32[,]' $rawdata.Length, $rawdata[0].Length
    FillMatrix $matrix $rawdata $rawdata.Length $rawdata[0].Length

    $surroundedMatrix = New-Object 'System.Int32[,]' ($rawdata.Length+2), ($rawdata[0].Length+2)
    FillSurroundedMatrix $surroundedMatrix $rawdata $rawdata.Length $rawdata[0].Length

    # Debugmatrix  $surroundedMatrix ($rawdata.Length+2) ($rawdata[0].Length+2)

    $lowpoints = FindAllLowPoints $surroundedMatrix $rawdata.Length $rawdata[0].Length
    $sumLowpoints = $lowpoints | % {
        $_.lowpoint + 1
    } | Measure-Object -sum
    Write-Host ("Sum of low points: {0}" -f $sumLowpoints.sum)

    $basins = foreach ($lowpoint in $lowpoints) {
        # DebugMatrix $surroundedMatrix ($rawdata.Length+2) ($rawdata[0].Length+2)
        Write-Verbose ("Lowpoint: {0} at {1}, {2}" -f $lowpoint.lowpoint, $lowpoint.row, $lowpoint.col)
        $isBasin = FindBasinFromPoint $surroundedMatrix $rawdata.Length $rawdata[0].Length $lowpoint.row $lowpoint.col
        if ($isBasin -gt 0) {
            Write-Verbose ("Basin found at {0}, {1} having {2}" -f $lowpoint.row, $lowpoint.col, $isBasin)
        }
        $isBasin
    }
    $product = 1
    # Set-StrictMode -Off
    $ret = $basins | Sort-Object -Descending | Select -First 3 | % { $product = $_ * $product }
    Write-Host ("Product of the three largest basins: {0}" -f $product)
}
