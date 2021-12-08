function ReadInputData ($fileName, $inputData) {
    (Get-Content $filename) -Split ',' | ForEach-Object { [void] $inputData.Add([int]$_) }
}
function CalcCostForPosition ($TargetPosition, $inputData) {
    $cost = 0
    $inputData.ForEach({
        $currPosition = $_
        $currCost = [math]::Abs( $currPosition - $TargetPosition )
        $cost += $currCost
    })
    return $cost
}

function GetLeastCostPosition ($inputData) {
    $filename = "$PSScriptRoot\07_TheTreasury-Sample.txt"
    [System.Collections.ArrayList]$InputData = @()
    ReadInputData $filename $InputData

    $listCosts = [System.Collections.ArrayList]::new($InputData.Count)
    $minCost = [int32]::MaxValue
    $minCostPosition = -1
    for ($i = 0; $i -lt $InputData.Count; $i++) {
        $ret = CalcCostForPosition $i $InputData
        [void] $listCosts.Add($ret)
        Write-Warning "Cost for position $i is $ret"
        if ($ret -lt $minCost) {
            $minCost = $ret
            $minCostPosition = $i
        }
    }
    Write-Warning "Least cost position is $minCostPosition with cost $minCost"
}

