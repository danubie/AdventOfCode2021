BeforeDiscovery {
    . $PSScriptRoot\05_HydrothermalVenture.ps1
}

BeforeAll {
    function Assert-ArrayEquality($test, $expected) {
        $test | Should -HaveCount $expected.Count
        0..($test.Count - 1) | % {$test[$_] | Should -Be $expected[$_]}
    }
    
    function Assert-HashtableEquality($test, $expected) {
        $test.Keys | Should -HaveCount $expected.Keys.Count
        $test.Keys | % {$test[$_] | Should -Be $expected[$_]}
    }
    
    function Assert-ObjectEquality($test, $expected) {
        $testKeys = $test.psobject.Properties | % Name
        $expectedKeys = $expected.psobject.Properties | % Name
        $testKeys | Should -HaveCount $expectedKeys.Count
        $testKeys | % {$test.$_ | Should -Be $expected.$_}
    }
}
Describe "Check input data" {
    BeforeAll {
        Mock Get-Content {
            '0,9 -> 5,9'
            '8,0 -> 0,8'
            '7,2 -> 7,4'
        }
    }
    It "Should build data list" {
        $ret = ReadInputData 'dummy'
        $ret | Should -Not -BeNullOrEmpty
        $ret | Should -HaveCount (Get-Content 'huhu').Length
        $ret[0].From.x | Should -Be 0
        $ret[0].From.y | Should -Be 9
        $ret[0].To.x | Should -Be 5
        $ret[0].To.y | Should -Be 9
        $ret[1].From.x | Should -Be 8
        $ret[1].From.y | Should -Be 0
        $ret[1].To.x | Should -Be 0
        $ret[1].To.y | Should -Be 8
    }
    It "Should reduce to straight lines" {
        $ret = ReadInputData 'dummy'
        $ret = ReduceToStraightLines $ret
        $ret | Should -HaveCount 2
        $ret[0].From.x | Should -Be 0
        $ret[0].From.y | Should -Be 9
        $ret[0].To.x | Should -Be 5
        $ret[0].To.y | Should -Be 9
    }
}
Describe "Normalize Data" {
    It "Should be unchanged" -foreach @(
        @{ in = [pscustomobject]@{ From = [pscustomobject]@{x=0;y=0}; To = [pscustomobject]@{ x=0;y=0} }; out = [pscustomobject]@{ From = [pscustomobject]@{x=0;y=0}; To = [pscustomobject]@{ x=0;y=0} } }
        @{ in = [pscustomobject]@{ From = [pscustomobject]@{x=5;y=0}; To = [pscustomobject]@{ x=6;y=0} }; out = [pscustomobject]@{ From = [pscustomobject]@{x=5;y=0}; To = [pscustomobject]@{ x=6;y=0} } }
    ) {
        NormalizeCoordinates $in
        Assert-ObjectEquality $in.From $out.From
        Assert-ObjectEquality $in.To $out.To
    }
    It "Should be changed" -foreach @(
        # @{ in = [pscustomobject]@{ From = [pscustomobject]@{x=7;y=0}; To = [pscustomobject]@{ x=6;y=0} }; out = [pscustomobject]@{ From = [pscustomobject]@{x=6;y=0}; To = [pscustomobject]@{ x=7;y=0} } }
        @{ in = [pscustomobject]@{ From = [pscustomobject]@{x=7;y=4}; To = [pscustomobject]@{ x=6;y=3} }; out = [pscustomobject]@{ From = [pscustomobject]@{x=6;y=3}; To = [pscustomobject]@{ x=7;y=4} } }
        @{ in = [pscustomobject]@{ From = [pscustomobject]@{x=3;y=4}; To = [pscustomobject]@{ x=1;y=2} }; out = [pscustomobject]@{ From = [pscustomobject]@{x=1;y=2}; To = [pscustomobject]@{ x=3;y=4} } }
        @{ in = [pscustomobject]@{ From = [pscustomobject]@{x=9;y=4}; To = [pscustomobject]@{ x=9;y=1} }; out = [pscustomobject]@{ From = [pscustomobject]@{x=9;y=1}; To = [pscustomobject]@{ x=9;y=4} } }
    ) {
        NormalizeCoordinates $in
        Assert-ObjectEquality $in.From $out.From
        Assert-ObjectEquality $in.To $out.To
    }
}
Describe "Should mark lines" {
    # rows count from 0
    It "Should mark correctly :-)" {
        Mock Get-Content {
            '0,0 -> 0,2'
            '2,8 -> 4,8'
            '9,0 -> 9,6'
            '9,4 -> 9,1'
        }
        $field = New-Object 'System.Int32[,]' 10,10 # InitField 10
        $data = ReadInputData 'dummy'
        NormalizeCoordinates $data
        $data = ReduceToStraightLines $data
        $data | Should -HaveCount (Get-Content 'huhu').Length
        MarkLines $field $data
        # check horicontal line row 0
        (0..9| ForEach-Object { $field[0,$_] }) -join '' | Should -Be '1110000000'
        # check vertical line column 8
        (0..9| ForEach-Object { $field[$_,8] }) -join '' | Should -Be '0011100000'
        # row 9 has to line commands, so should be 122211
        (0..9| ForEach-Object { $field[9,$_] }) -join '' | Should -Be '1222211000'
    }
    It "Should do diagonal as well" {
        Mock Get-Content {
            '0,0 -> 2,2'
            '8,7 -> 6,5'
        }
        $field = New-Object 'System.Int32[,]' 10,10 # InitField 10
        $data = ReadInputData 'dummy'
        NormalizeCoordinates $data
        $data | Should -HaveCount (Get-Content 'huhu').Length
        MarkLines $field $data
        # check horicontal line row 0
        (0..9| ForEach-Object { $field[0,$_] }) -join '' | Should -Be '1000000000'
        (0..9| ForEach-Object { $field[1,$_] }) -join '' | Should -Be '0100000000'
        (0..9| ForEach-Object { $field[2,$_] }) -join '' | Should -Be '0010000000'
        # check vertical line column 8
        (0..9| ForEach-Object { $field[8,$_] }) -join '' | Should -Be '0000000100'
        (0..9| ForEach-Object { $field[7,$_] }) -join '' | Should -Be '0000001000'
        (0..9| ForEach-Object { $field[6,$_] }) -join '' | Should -Be '0000010000'
    }
}
Describe "Countfields" {
    It "Should count fields correctly" {
        Mock Get-Content {
            '0,0 -> 0,2'
            '2,8 -> 4,8'
            '9,0 -> 9,6'
            '9,4 -> 9,1'
        }
        $field = New-Object 'System.Int32[,]' 10,10 # InitField 10
        $data = ReadInputData 'dummy'
        NormalizeCoordinates $data
        $data = ReduceToStraightLines $data
        $data | Should -HaveCount (Get-Content 'huhu').Length
        MarkLines $field $data
        CountFieldsGreaterThenOne $field 10 | Should -Be 4
    }
}
Describe "Using sample data" {
    It "Should be 5" {
        $field = New-Object 'System.Int32[,]' 10,10 # InitField 10
        $data = ReadInputData $PSScriptRoot\05_HydrothermalVenture-Sample.txt
        NormalizeCoordinates $data
        $data = ReduceToStraightLines $data
        MarkLines $field $data
        CountFieldsGreaterThenOne $field 10 | Should -Be 5
    }    
    It "Should be 12" {
        $field = New-Object 'System.Int32[,]' 10,10 # InitField 10
        $data = ReadInputData $PSScriptRoot\05_HydrothermalVenture-Sample.txt
        MarkLines $field $data
        CountFieldsGreaterThenOne $field 10 | Should -Be 12
    }
}

