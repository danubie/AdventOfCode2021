function ReadInputData ($fileName, $listTimer) {
    (Get-Content $filename) -Split ',' | ForEach-Object { [void] $listTimer.Add([int]$_) }
}
function RunDays {
    [CmdletBinding()]
    param (
        $days, $listTimer
    )
    for ($d = 0; $d -lt $days; $d++) {
        for ($i = 0; $i -lt $listTimer.Count; $i++) {
            if ($listTimer[$i] -eq 0) {
                $listTimer[$i] = 7      # the current, will get -1 later
                [void] $listTimer.Add(9)       # the new one, will get -1 later
            }
            $listTimer[$i] -= 1
        }
    }
}
function Day06a ($filename) {
    # read starting reprocude rates
    [System.Collections.ArrayList]$FishTimer = @()
    ReadInputData $filename $FishTimer

    RunDays 80 $FishTimer

    $nbFishes = $FishTimer.Count
    return $nbFishes
}