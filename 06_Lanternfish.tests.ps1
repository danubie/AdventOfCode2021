BeforeDiscovery {
    . .\06_Lanternfish.ps1
}
BeforeAll {
    . .\06_Lanternfish.ps1
}
Describe "Laternfish" {
    Context "Sampledata" {
        BeforeEach {
            $filename = "$PSScriptRoot\06_Lanternfish-sample.txt"
            [System.Collections.ArrayList]$FishTimer = @()
            ReadInputData $filename $FishTimer
        }
        It "Inits data correctly" {
            $FishTimer.Count | Should -Be 5
            $FishTimer -join ',' | Should -Be "3,4,3,1,2"
        }
        It "Should do 1 day"{
            RunDays 1 $FishTimer
            $FishTimer.Count | Should -Be 5
            $FishTimer -join ',' | Should -Be "2,3,2,0,1"
        }
        It "Should do 2 days"{
            RunDays 2 $FishTimer
            $FishTimer.Count | Should -Be 6
            $FishTimer -join ',' | Should -Be "1,2,1,6,0,8"
        }
        It "Should do 18 days"{
            RunDays 18 $FishTimer
            $FishTimer.Count | Should -Be 26
            $FishTimer -join ',' | Should -Be "6,0,6,4,5,6,0,1,1,2,6,0,1,1,1,2,2,3,3,4,6,7,8,8,8,8"
        }
        It "Part 1" {
            $ret = Day06a($filename)
            $ret | Should -Be 5934
        }
    }
}