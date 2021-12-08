function ReadInputData ($fileName, $inputData) {
    (Get-Content $filename) -Split ',' | ForEach-Object { [void] $inputData.Add([int]$_) }
}
function CalcCostForPosition ($TargetPosition, $inputData, $Part) {
    $cost = 0
    $inputData.ForEach({
        $currPosition = $_
        if ($currPosition -ne $TargetPosition) {
            if ($Part -eq 1) {
                $cost += [math]::Abs($currPosition - $TargetPosition)
            } else {
                $sum = 0
                for ($move = 0; $move -le [math]::Abs($currPosition - $TargetPosition); $move++) {
                    $sum += $move
                }
                # Write-Warning "currPosition: $currPosition; TargetPosition: $TargetPosition; sum: $sum"
                $cost += $sum
            }
        }
    })
    return $cost
}

function GetLeastCostPosition ($filename, $Part) {
    [System.Collections.ArrayList]$InputData = @()
    ReadInputData $filename $InputData

    $listCosts = [System.Collections.ArrayList]::new($InputData.Count)
    $minCost = [int32]::MaxValue
    $minCostPosition = -1
    for ($i = 0; $i -lt $InputData.Count; $i++) {
        $ret = CalcCostForPosition $i $InputData $Part
        [void] $listCosts.Add($ret)
        # Write-Warning "Cost for position $i is $ret"
        if ($ret -lt $minCost) {
            $minCost = $ret
            $minCostPosition = $i
        }
    }
    Write-Warning "Least cost position is $minCostPosition with cost $minCost"
    return $minCost
}

