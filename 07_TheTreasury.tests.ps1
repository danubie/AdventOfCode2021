BeforeDiscovery {
    . .\07_TheTreasury.ps1
}
BeforeAll {
    . .\07_TheTreasury.ps1
}
Describe "Day 7: The Treachery of Whales with sample data" {
    BeforeEach {
        $filename = "$PSScriptRoot\07_TheTreasury-Sample.txt"
        [System.Collections.ArrayList]$InputData = @()
        ReadInputData $filename $InputData
    }
    Context "Part 1" {
        It "Cost for position <position> should be <EstimatedCost>" -Foreach @(
            @{ "Position" = 2; "EstimatedCost" = 37 }
            @{ "Position" = 1; "EstimatedCost" = 41 }
            @{ "Position" = 3; "EstimatedCost" = 39 }
            @{ "Position" = 10; "EstimatedCost" = 71 }
        ) {
            $ret = CalcCostForPosition $Position $InputData 1
            $ret | Should -Be $EstimatedCost
        }
        It "Should return 2 as minimum cost" {
            $listCosts = [System.Collections.ArrayList]::new($InputData.Count)
            $minCost = [int32]::MaxValue
            $minCostPostion = -1
            for ($i = 0; $i -lt $InputData.Count; $i++) {
                $ret = CalcCostForPosition $i $InputData 1
                [void] $listCosts.Add($ret)
                if ($ret -lt $minCost) {
                    $minCost = $ret
                    $minCostPostion = $i
                }
            }
            $minCostPostion | Should -Be 2
        }
    }
    Context "Part 2" {
        It "Cost for position <position> should be <EstimatedCost>" -Foreach @(
            @{ "Position" = 2; "EstimatedCost" = 206 }
            @{ "Position" = 5; "EstimatedCost" = 168 }
        ) {
            $ret = CalcCostForPosition $Position $InputData 2
            $ret | Should -Be $EstimatedCost
        }
        It "Should return 2 as minimum cost" {
            $listCosts = [System.Collections.ArrayList]::new($InputData.Count)
            $minCost = [int32]::MaxValue
            $minCostPostion = -1
            for ($i = 0; $i -lt $InputData.Count; $i++) {
                $ret = CalcCostForPosition $i $InputData 2
                [void] $listCosts.Add($ret)
                if ($ret -lt $minCost) {
                    $minCost = $ret
                    $minCostPostion = $i
                }
            }
            $minCostPostion | Should -Be 5
        }
    }
}

Describe "Day 7: The Treachery of Whales with my personal data" {
    BeforeEach {
        $filename = "$PSScriptRoot\07_TheTreasury.txt"
    }
    Context "Part 1" {
        It "Should return 344535" {
            $minCost = GetLeastCostPosition $filename 1
            $minCost | Should -Be 344535
        }
    }
    Context "Part 2" {
        It "Should return 344535" {
            $minCost = GetLeastCostPosition $filename 2
            $minCost | Should -Be 95581659
        }
    }
}