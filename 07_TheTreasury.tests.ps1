BeforeDiscovery {
    . .\07_TheTreasury.ps1
}
BeforeAll {
    . .\07_TheTreasury.ps1
}
Describe "Sample data" {
    Context "ContextName" {
        BeforeEach {
            $filename = "$PSScriptRoot\07_TheTreasury-Sample.txt"
            [System.Collections.ArrayList]$InputData = @()
            ReadInputData $filename $InputData
        }
        It "Cost for position <position> should be <EstimatedCost>" -Foreach @(
            @{ "Position" = 2; "EstimatedCost" = 37 }
            @{ "Position" = 1; "EstimatedCost" = 41 }
            @{ "Position" = 3; "EstimatedCost" = 39 }
            @{ "Position" = 10; "EstimatedCost" = 71 }
        ) {
            $ret = CalcCostForPosition $Position $InputData
            $ret | Should -Be $EstimatedCost
        }
        It "Should return 2 as minimum cost" {
            $listCosts = [System.Collections.ArrayList]::new($InputData.Count)
            $minCost = [int32]::MaxValue
            $minCostPostion = -1
            for ($i = 0; $i -lt $InputData.Count; $i++) {
                $ret = CalcCostForPosition $i $InputData
                [void] $listCosts.Add($ret)
                Write-Warning "Cost for position $i is $ret"
                if ($ret -lt $minCost) {
                    $minCost = $ret
                    $minCostPostion = $i
                }
            }
            $minCostPostion | Should -Be 2
        }
    }
}