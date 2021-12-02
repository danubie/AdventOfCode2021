$depths = Get-Content -Path $PSScriptRoot\01_SonarSweep.txt
$cnt = -1
[int] $depthbefore = 0
$depths.ForEach({
    $d = $_
    if ($depthbefore -lt $d) {
        $cnt++
    }
    $depthbefore = $d
})
"Puzzle 1 :$cnt"
