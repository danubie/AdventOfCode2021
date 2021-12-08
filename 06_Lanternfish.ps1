function ReadInputData ($fileName, $listTimer) {
    (Get-Content $filename) -Split ',' | ForEach-Object { [void] $listTimer.Add([int]$_) }
}
function RunDays {
    [CmdletBinding()]
    param (
        $days, $listTimer
    )
    for ($d = 0; $d -lt $days; $d++) {
        if ($d % 8 -eq 0) {
            Write-Verbose "$(Get-Date -DisplayHint Time) Day $d; $($listTimer.Count)"
        }
        for ($i = 0; $i -lt $listTimer.Count; $i++) {
            if ($listTimer[$i] -eq 0) {
                $listTimer[$i] = 7      # the current, will get -1 later
                [void] $listTimer.Add(9)       # the new one, will get -1 later
            }
            $listTimer[$i] -= 1
        }
    }
}

function Day06a ($filename, $nBDays) {
    # read starting reprocude rates
    $FishTimer = [System.Collections.ArrayList]::new()
    if ($FishTimer) {Throw "FishTimer is null"}
    ReadInputData $filename $FishTimer

    RunDays $nBDays $FishTimer

    $nbFishes = $FishTimer.Count
    return $nbFishes
}
function RunDaysPerFishCount {
    # first creates a list of all issues for one fish (starting with 5) for all days
    # then loops through the starting list, claculates the diffence and sums all of this list
    [CmdletBinding()]
    param (
        $days, $startingFish, $sumIssuesPerFish
    )
    $days = $days + 1       # correct off by one error
    # this is the list of all issues for one fish
    [System.Collections.ArrayList] $listAllDebug = @()
    [System.Collections.ArrayList] $listIssues = @()
    for ($sf = 0; $sf -lt $startingFish.Count; $sf++) {
        # leere Felder werden übersprungen
        if ($startingFish[$sf] -eq 0) {
            continue
        }
        $listIssues.Clear()
        $firstFish = [PSCustomObject]@{
            startDay = 1
            counter = $sf
        }
        $SlowVerbosityCounter = 0
        $SlowVerbosityModulo = 1000000
        Write-Verbose "$(Get-Date -Format 'HH:mm:ss') Fish# $sf Days: $($firstFish.days) Counter: $($firstFish.counter)"
        [void] $listIssues.Add($firstFish)
        [void] $listAllDebug.Add($firstFish)
        for ($f = 0; $f -lt $listIssues.Count; $f++) {
            # start ist der erste Tag, wo der Fish ein Child kreiert
            for ($d = $listIssues[$f].startDay; $d -lt $days; $d++) {
                if ($SlowVerbosityCounter -ge $SlowVerbosityModulo) {
                    Write-Verbose "$(Get-Date -DisplayHint Time) StartType $sf Fish# $f Day $d; In Summe $($listIssues.Count)"
                    $SlowVerbosityCounter = 0
                }
                $SlowVerbosityCounter += 1
                if ($listIssues[$f].counter -eq 0) {
                    $listIssues[$f].counter = 7
                    $indexNewFish = $listIssues.Add([PSCustomObject]@{
                        startDay = $d
                        counter = 9
                    })
                    [void] $listAllDebug.Add($listIssues[$f])
#s                    Write-Verbose "$(Get-Date -Format 'HH:mm:ss') StartType $sf Fish# $f; Day $d; New child with start at $($listIssues[$indexNewFish].startDay) "
                }
                $listIssues[$f].counter -= 1
            }
            $sumIssuesPerFish[$sf] = $listIssues.Count
        }
        Write-Verbose "$(Get-Date -Format 'HH:mm:ss')  After $days :  Finistype $sf has $($sumIssuesPerFish[$sf]) issues" -Verbose
    }
    Write-Verbose "$(Get-Date -Format 'HH:mm:ss')  Finished calculating fishes per starttype" -Verbose
}
function Day06aFast ($filename, $nBDays) {
    # read starting reprocude rates
    $FishTimer = [System.Collections.ArrayList]::new(10000)
    if ($FishTimer) {Throw "FishTimer is null"}
    ReadInputData $filename $FishTimer

    $StartingFish = [int[]]::new(10)
    $NbIssuesPerStartingFish = [int[]]::new(10)
    #count the number of fish per index
    for ($i = 0; $i -lt $FishTimer.Count; $i++) {
        $StartingFish[$FishTimer[$i]] += 1
    }
    # returns a list of issues per StartingFish
    RunDaysPerFishCount $nBDays $StartingFish $NbIssuesPerStartingFish 

    $nbFishes = [int64] 0
    for ($i = 0; $i -lt $StartingFish.Length; $i++) {
        $nbFishes += [int64] $NbIssuesPerStartingFish[$i] * [int64] $StartingFish[$i]
    }
    return $nbFishes
}
# $ret = Day06aFast .\06_Lanternfish-sample.txt 18
# Write-Output "Day06a: $ret"
# Pause