BeforeDiscovery {
    . .\09_SmokeBasin.ps1
}
BeforeAll {
    . .\09_SmokeBasin.ps1
}
Describe "Day 9: Smoke Basin" {
    BeforeAll {
        $filename = '.\09_SmokeBasin-Sample.txt'
        $rawdata = Get-Content -Path $fileName

        $matrix = New-Object 'System.Int32[,]' $rawdata.Length, $rawdata[0].Length
        FillMatrix $matrix $rawdata $rawdata.Length $rawdata[0].Length
    }
    BeforeEach {
        $surroundedMatrix = New-Object 'System.Int32[,]' ($rawdata.Length+2), ($rawdata[0].Length+2)
        FillSurroundedMatrix $surroundedMatrix $rawdata $rawdata.Length $rawdata[0].Length
    }
    It "FindAllLowpoints" {
        $lowpoints = FindAllLowpoints $surroundedMatrix $rawdata.Length $rawdata[0].Length
        $lowpoints.Count    | Should -Be 4
        $sumLowpoints = $lowpoints | % {
            $_.lowpoint + 1
        } | Measure-Object -sum
        $sumLowpoints.sum | Should -Be 15
    }
    It "FindBasinFromPoint" {
        $lowpoints = FindAllLowpoints $surroundedMatrix $rawdata.Length $rawdata[0].Length
        $lowpoints.Count    | Should -Be 4
        $basins = foreach ($lowpoint in $lowpoints) {
            $isBasin = FindBasinFromPoint $surroundedMatrix $rawdata.Length $rawdata[0].Length $lowpoint.row $lowpoint.col
            $isBasin | Should -BeGreaterOrEqual 1
            $isBasin
        }
        $product = 1
        # Set-StrictMode -Off
        $ret = $basins | Sort-Object -Descending | Select -First 3 | % { $product = $_ * $product }
        $product | Should -Be 1134
    }

}