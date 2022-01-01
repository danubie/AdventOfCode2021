# $VerbosePreference = 'Continue'
$PesterPreference = New-PesterConfiguration
$PesterPreference.Output.Verbosity = 'Detailed'

# BeforeAll {
#     . $PSScriptRoot\12_Cave_Class.ps1
# }
BeforeDiscovery {
    . $PSScriptRoot\12_Cave_Class.ps1
}
Describe "Cave class" {
    Context "Constructors" {
        BeforeAll {
            $dummy = [cave]::new()
        }
        BeforeEach {
            [cave]::ClearList()
        }
        It "should create 2 caves" {
            $cave1 = [Cave]::new('cave1')
            $cave2 = [Cave]::new('cave2')
            [cave]::Caves.Count | Should -Be 2
        }
        It "should not allow create a cave with the same name" {
            $cave1 = [Cave]::new('cave1')
            { $cave2 = [Cave]::new('cave1') } | Should -Throw
            [cave]::Caves.Count | Should -Be 1
        }
    }

    Context "usage" {
        BeforeEach {
            [Cave]::ClearList()
            $start = [Cave]::new('start')
            $end = [Cave]::new('end')
            $cave1 = [Cave]::new('cave1')
            $cave2 = [Cave]::new('CAVE2')
            $cave3 = [Cave]::new('cave3')
        }
        It "can be initialized with a name" {
            $cave1.Name  | Should -Be 'cave1'
            # $cave1.PassesLeft | Should -Be 1

            $cave2.Name  | Should -Be 'CAVE2'
            # $cave2.PassesLeft | Should -Be ([Int]::MaxValue)
        }
        It "can be connected to other caves" {
            $cave1.ConnectTo('cave2')
            $cave1.CavesConnected.Count | Should -Be 1
            $cave1.CavesConnected[0].Name | Should -Be 'cave2'
            $cave2.CavesConnected.Count | Should -Be 1
            $cave2.CavesConnected[0].Name | Should -Be 'cave1'
            # now add a third one
            $cave1.ConnectTo('cave3')
            $cave1.CavesConnected.Count | Should -Be 2
            $cave1.CavesConnected[1].Name | Should -Be 'cave3'
            $cave3.CavesConnected.Count | Should -Be 1
            $cave3.CavesConnected[0].Name | Should -Be 'cave1'
        }
    }

    Context "check error conditions" {
        BeforeEach {
            [Cave]::ClearList()
            $start = [Cave]::new('start')
            $end = [Cave]::new('end')
            $cave1 = [Cave]::new('cave1')
            $cave2 = [Cave]::new('cave2')
            $cave3 = [Cave]::new('cave3')
        }
        It "should not connect to itself" {
            { $cave1.ConnectTo('cave1') } | Should -Throw
        }
        It "should not allow connecting twice the same cave" {
            $cave1.ConnectTo('cave2')
            $cave1.ConnectTo('cave2')
            $cave1.CavesConnected.Count | Should -Be 1
        }
        It "start as destination is not added to the list of caves connected" {
            $cave1.ConnectTo('start')
            $cave1.CavesConnected.Count | Should -Be 0
            $start.CavesConnected.Count | Should -Be 1      # implies, that start can only be the first cave
        }
        It "if end is connected, end still has no successor" {
            $cave1.ConnectTo('end')
            $cave1.CavesConnected.Count | Should -Be 1
            $end.CavesConnected.Count | Should -Be 0
        }
        It "should Exists -eq $True" {
            [Cave]::Exists('cave1') | Should -Be $True
        }
        It "should Exists -eq $False" {
            [Cave]::Exists('cave99') | Should -Be $False
        }
    }
}

Describe "Pathfinder" {
    BeforeEach {
        [Cave]::ClearList()
        $start = [Cave]::new('start')
        $end = [Cave]::new('end')
        $cave1 = [Cave]::new('a')
        $cave2 = [Cave]::new('b')
        $cave3 = [Cave]::new('c')
        $cave4 = [Cave]::new('D')
    }
    It "It only has start to end" {
        $start.ConnectTo('end')
        $s = [cave]::FindAllPaths()
        $s | Should -Be "start,end"
    }
    It "Has a straight path" {
        $start.ConnectTo('a')
        $cave1.ConnectTo('end')
        $s = [cave]::FindAllPaths()
        $s | Should -Be "start,a,end"
    }
    It "start has 2 connectors" {
        $start.ConnectTo('a')
        $start.ConnectTo('b')
        $cave1.ConnectTo('end')
        $cave2.ConnectTo('end')
        $s = [cave]::FindAllPaths()
        $s[0] | Should -Be "start,a,end"
        $s[1] | Should -Be "start,b,end"
        $s | Should -HaveCount 2
    }
    It "start has 2 connectors + each is connected to each other + cave3 only connected to cave2" {
        $start.ConnectTo('a')
        $start.ConnectTo('b')

        $cave1.ConnectTo('b')
        $cave1.ConnectTo('end')

        $cave2.ConnectTo('a')
        $cave2.ConnectTo('c')       # only connect to small cave -> never visited
        $cave2.ConnectTo('end')
        $s = [cave]::FindAllPaths()
        $s | Should -Contain "start,a,end"
        $s | Should -Contain "start,a,b,end"
        $s | Should -Contain "start,b,end"
        $s | Should -Contain "start,b,a,end"
        $s | Should -HaveCount 4
    }
    It "start has 2 connectors + each is connected to each other + cave3 only connected to CAVE4" {
        $start.ConnectTo('a')
        $start.ConnectTo('D')

        $cave1.ConnectTo('D')
        $cave1.ConnectTo('end')

        $cave4.ConnectTo('a')
        $cave4.ConnectTo('c')       # only connect to small cave -> never visited
        $cave4.ConnectTo('end')
        $s = [cave]::FindAllPaths()
        # $s | Should -HaveCount 4
        $s | Should -Contain "start,a,end"
        $s | Should -Contain "start,a,D,end"
        $s | Should -Contain "start,a,D,c,D,end"

        $s | Should -Contain "start,D,end"

        $s | Should -Contain "start,D,a,end"
        $s | Should -Contain "start,D,a,D,end"
        $s | Should -Contain "start,D,a,D,c,D,end"

        $s | Should -Contain "start,D,c,D,end"
        $s | Should -Contain "start,D,c,D,a,end"
        $s | Should -Contain "start,D,c,D,a,D,end"

    }
}
Describe "Pathfinder AllowTwice" {
    BeforeEach {
        [Cave]::ClearList()
        [cave]::AllowSmallTwice = $true
        $start = [Cave]::new('start')
        $end = [Cave]::new('end')
        $cave1 = [Cave]::new('a')
        $cave2 = [Cave]::new('b')
        $cave3 = [Cave]::new('c')
        $cave4 = [Cave]::new('D')
    }
    Context "Pathfinder" {
        It "It only has start to end" {
            $start.ConnectTo('end')
            $s = [cave]::FindAllPaths()
            $s | Should -Be "start,end"
        }
        It "Has a straight path" {
            $start.ConnectTo('a')
            $cave1.ConnectTo('end')
            $s = [cave]::FindAllPaths()
            $s | Should -Be "start,a,end"
        }
        It "start has 2 connectors" {
            $start.ConnectTo('a')
            $start.ConnectTo('b')
            $cave1.ConnectTo('end')
            $cave2.ConnectTo('end')
            $s = [cave]::FindAllPaths()
            $s[0] | Should -Be "start,a,end"
            $s[1] | Should -Be "start,b,end"
            $s | Should -HaveCount 2
        }
        It "start has 2 connectors + each is connected to each other + cave3 only connected to cave2" {
            $start.ConnectTo('a')
            $start.ConnectTo('b')

            $cave1.ConnectTo('b')
            $cave1.ConnectTo('end')

            $cave2.ConnectTo('a')
            $cave2.ConnectTo('c')       # only connect to small cave -> now visited once
            $cave2.ConnectTo('end')
            $s = [cave]::FindAllPaths()
            $s | Should -Contain "start,a,end"
            $s | Should -Contain "start,a,b,end"
            $s | Should -Contain "start,a,b,a,end"
            $s | Should -Contain "start,b,end"
            $s | Should -Contain "start,b,a,end"
            $s | Should -Contain "start,b,a,b,end"
            $s | Should -Contain "start,b,c,b,end"
            $s | Should -Contain "start,b,c,b,a,end"
            $s | Should -Contain "start,a,b,c,b,end"
            $s | Should -HaveCount 9
        }
        It "start has 2 connectors + each is connected to each other + cave3 only connected to CAVE4" {
            $start.ConnectTo('a')
            $start.ConnectTo('D')

            $cave1.ConnectTo('D')
            $cave1.ConnectTo('end')

            $cave4.ConnectTo('a')
            $cave4.ConnectTo('c')       # only connect to small cave -> never visited
            $cave4.ConnectTo('end')
            $s = [cave]::FindAllPaths()
            # $s | Should -HaveCount 4
            $s | Should -Contain "start,a,end"
            $s | Should -Contain "start,a,D,end"
            $s | Should -Contain "start,a,D,c,D,end"

            $s | Should -Contain "start,D,end"

            $s | Should -Contain "start,D,a,end"
            $s | Should -Contain "start,D,a,D,end"
            $s | Should -Contain "start,D,a,D,c,D,end"

            $s | Should -Contain "start,D,c,D,end"
            $s | Should -Contain "start,D,c,D,a,end"
            $s | Should -Contain "start,D,c,D,a,D,end"

        }
    }
}
Describe "with sample file input" {
    It "Allowtwice <Allowtwice> Should work give <Expected>" -ForEach @(
        @{ AllowTwice = $false; Expected = 19 }
        @{ AllowTwice = $true; Expected = 103 }
        ) {
        # $Global:VerbosePreference = 'Continue'
        [cave]::ClearList()
        [cave]::AllowSmallTwice = $AllowTwice
        [cave]::LoadFromFile("$PSScriptRoot\12_PassagingCaves-samples.txt")
        $null = [Cave]::FindAllPaths()
        [cave]::Results | Should -HaveCount $Expected
    }
    It "Allowtwice <Allowtwice> Should work give <Expected>"  -ForEach @(
        @{ AllowTwice = $false; Expected = 226 }
        @{ AllowTwice = $true; Expected = 3509 }
        ) {
        # $VerbosePreference = 'Continue'
        [cave]::ClearList()
        [cave]::AllowSmallTwice = $AllowTwice
        [cave]::LoadFromFile("$PSScriptRoot\12_PassagingCaves-samples2.txt")
        $null = [Cave]::FindAllPaths()
        [cave]::Results | Should -HaveCount $Expected
    }
}
# Describe "with my input" {
#     [cave]::ClearList()
#     [cave]::LoadFromFile("$PSScriptRoot\12_PassagingCaves.txt")
#     $null = [Cave]::FindAllPaths()
#     [cave]::Results | Should -HaveCount 4754
# }