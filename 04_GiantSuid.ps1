class BingoBoard {
    [int] $nbBoards
    $undrawnNumbers
    $drawnNumbers
    $WinningBoardNumber = -1
    $ListWinningBoardNumbers = @()
    [boolean] $LetLastWin = $false
    
    [int] $FillBoardNr = 0
    [int] $FillRow = 0

    [void] DrawNumber($number) {
        for ($boardNr = 0; $boardNr -lt $this.nbBoards; $boardNr++) {
            for ($row = 0; $row -lt 5; $row++) {
                for ($column = 0; $column -lt 5; $column++) {
                    if ($this.undrawnNumbers[$boardNr, $row, $column] -eq $number) {
                        $this.drawnNumbers[$boardNr, $row, $column] = $number
                        $this.undrawnNumbers[$boardNr, $row, $column] = -1
                    }
                }
            }
        }
    }
    [void] Show ([int] $BoardNumber) {
        $boardNr = $BoardNumber
        Write-Host "Board $boardNr"
        for ($row = 0; $row -lt 5; $row++) {
            for ($column = 0; $column -lt 5; $column++) {
                $number = $this.undrawnNumbers[$boardNr, $row, $column]
                if ($number -eq -1) {
                    $number = " "
                }
                Write-Host ("{0,5} " -f $number) -NoNewline
            }
            Write-Host " | " -NoNewline
            for ($column = 0; $column -lt 5; $column++) {
                $number = $this.drawnNumbers[$boardNr, $row, $column]
                if ($number -eq -1) {
                    $number = " "
                }
                Write-Host ("{0,5} " -f $number) -NoNewline
            }
            Write-Host ""
        }
    }
    [void] Show () {
        for ($i = 0; $i -lt $this.nbBoards; $i++) {
            $this.Show($i)
        }
    }
    [int] GetBingoBoardNumber() {
        $localWinningBoardNumber = -1
        for ($boardNr = 0; $boardNr -lt $this.nbBoards -and ($localWinningBoardNumber -eq -1 -or $this.LetLastWin) ; $boardNr++) {
            # skip Boardnr if already won
            if ($this.ListWinningBoardNumbers -contains $boardNr) {
                continue
            }   
            for ($row = 0; $row -lt 5; $row++) {
                $rawIsBingo = $true
                for ($column = 0; $column -lt 5; $column++) {
                    if ($this.drawnNumbers[$boardNr, $row, $column] -eq -1) {
                        $rawIsBingo = $false
                        break
                    }
                }
                if ($rawIsBingo) {
                    $localWinningBoardNumber = $boardNr
                    break
                }
            }
            if ($localWinningBoardNumber -eq 1) {
                for ($column = 0; $column -lt 5; $column++) {
                    $colIsBingo = $true
                    for ($row = 0; $row -lt 5; $row++) {
                        if ($this.drawnNumbers[$boardNr, $row, $column] -eq -1) {
                            $colIsBingo = $false
                            break
                        }
                    }
                    if ($colIsBingo) {
                        $localWinningBoardNumber = $boardNr
                        break
                    }
                }
            }
        }
        if ($localWinningBoardNumber -ne -1) {
            $this.WinningBoardNumber = $localWinningBoardNumber     # set last winning board number
        }
        return $localWinningBoardNumber
    }
    [boolean] IsBingo() {
        $gotIt = $false
        $BingoBoardNr = $this.GetBingoBoardNumber()
        if ($BingoBoardNr -ne -1) { $this.ListWinningBoardNumbers += $BingoBoardNr}
        $gotIt = $BingoBoardNr -ne -1
        return $gotIt
    }
    [void] FillBoardRow ([string] $InputData) {
        Write-Verbose "FillBoardRow: $InputData; $this.FillBoardNr; $this.FillRow"
        if ('' -eq $InputData -or $this.FillBoardNr -ge $this.nbBoards) {
            return
        }
        [int[]] $InputNumbers = ($inputData -replace '( *)(\S+)', '$2 ') -split " "
        for ($column = 0; $column -lt 5; $column++) {
            $this.undrawnNumbers[$this.FillBoardNr, $this.FillRow, $column] = $InputNumbers[$column]
        }
        $this.FillRow = ($this.FillRow + 1) % 5
        if ($this.FillRow -eq 0) {
            $this.FillBoardNr = ($this.FillBoardNr + 1)
        }
    }
    [int] GetSumUndrawnNumbers() {
        $sum = 0
        for ($row = 0; $row -lt 5; $row++) {
            for ($column = 0; $column -lt 5; $column++) {
                if ($this.undrawnNumbers[$this.WinningBoardNumber, $row, $column] -ne -1) {
                    $sum = $sum + $this.undrawnNumbers[$this.WinningBoardNumber, $row, $column]
                }
            }
        }
        return $sum
    }
    [void] SetStrategyWinLast () {
        $this.LetLastWin = $true
    }
    BingoBoard ([int] $Count = 5) {
        $this.nbBoards = $Count
        # $this.undrawnNumbers =  (New-Object 'int[,,]' $Count, 5, 5)
        # $this.drawnNumbers = (New-Object 'int[,,]' $Count, 5, 5)
        $this.undrawnNumbers =  (New-Object 'int[,,]' $Count, 5, 5)
        $this.drawnNumbers = (New-Object 'int[,,]' $Count, 5, 5)
        for ($i=0; $i -lt $Count; $i++) {
            for ($j=0; $j -lt 5; $j++) {
                for ($k=0; $k -lt 5; $k++) {
                    $this.undrawnNumbers[$i, $j, $k] = -1
                    $this.drawnNumbers[$i, $j, $k] = -1
                }
            }
        }
    }
}

# Read input data
$data = Get-Content $PSScriptRoot\04_GiantSquid-Sample.txt
# $data = Get-Content $PSScriptRoot\04_GiantSquid.txt
$drawNumbers = $data[0] -split ","
" Numbers to be drawn: $($drawNumbers -join ', ')"

$Boards = [BingoBoard]::new(($data.Length - 1)/6)       # 1 empty line + 5 data lines
for ($i = 1; $i -lt $data.Length; $i++) {
    $Boards.FillBoardRow($data[$i])
}
for ($n = 0; $n -lt $drawNumbers.Length; $n++) {
    $Boards.DrawNumber($drawNumbers[$n])
    Write-Verbose "Drawing number $($drawNumbers[$n])"
    $Boards.Show()
    if ($Boards.IsBingo()) {
        $Boards.Show($Boards.GetBingoBoardNumber())
        $SumUndrawnNumbers = $Boards.GetSumUndrawnNumbers()
        Write-Host "Bingo! Board=$($Boards.WinningBoardNumber) Result= $([convert]::ToInt32($drawNumbers[$n]) * $SumUndrawnNumbers) "
        break
    }
}

# # exampe2
# $Boards = [BingoBoard]::new(($data.Length - 1)/6)       # 1 empty line + 5 data lines
# $Boards.SetStrategyWinLast()
# for ($i = 1; $i -lt $data.Length; $i++) {
#     $Boards.FillBoardRow($data[$i])
# }
# $lastDrawToWin = -1
# for ($n = 0; $n -lt $drawNumbers.Length; $n++) {
#     $Boards.DrawNumber($drawNumbers[$n])
#     Write-Verbose "Drawing number $($drawNumbers[$n])"
#     if ($Boards.IsBingo()) {
#         $Boards.Show($Boards.GetBingoBoardNumber())
#         $lastDrawToWin = [convert]::ToInt32($drawNumbers[$n])
#         $SumUndrawnNumbers = $Boards.GetSumUndrawnNumbers()
#         Write-Host "Bingo! Board=$($Boards.WinningBoardNumber) Result= $([convert]::ToInt32($drawNumbers[$n]) * $SumUndrawnNumbers) "
#     }
# }
# break