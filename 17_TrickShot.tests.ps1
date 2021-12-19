using Module ./17_TrickShot.psm1
$PesterPreference = New-PesterConfiguration
$PesterPreference.Output.Verbosity = 'Detailed'

$VerbosePreference = 'Continue'

AfterAll {
    . Remove-Module 17_TrickShot -Force
}

Describe "Test setup" -Skip {
    BeforeEach {
        $Probe = [Probe]::new()
    }
    It "should be able to create a new TrickShot object and move it" {
        $VerbosePreference = 'Continue'
        $Probe.SetTargetArea(20, 0, 30, 10)
        $Probe.SetStartingVelocity(1, 2)
        $Probe.DoOnStep()
        # check movement
        $Probe.PosX | Should -Be 1
        $Probe.PosY | Should -Be 2
        $Probe.VelX | Should -Be 0
        $Probe.VelY | Should -Be 1
        $Probe.IsInTargetArea() | Should -Be $False
        $Probe.DidOvershoot() | Should -Be $False
        # do 3 more steps
        $Probe.DoOnStep()
        $Probe.DoOnStep()
        $Probe.DoOnStep()
        $Probe.PosX | Should -Be 1
        $Probe.PosY | Should -Be 2
        $Probe.VelX | Should -Be 0
        $Probe.VelY | Should -Be -2
        $Probe.IsInTargetArea() | Should -Be $False
        $Probe.DidOvershoot() | Should -Be $False

        $Probe.DoOnStep()
        $Probe.DoOnStep()
        $Probe.DidOvershoot() | Should -Be $true

    }
}

Describe "Brut force" {
    BeforeEach {
        $Probe = [Probe]::new()
    }
    It "find all solutions" -Skip {
        $Probe.DoTrackProbe = $false
        $Probe.DoTrackProbeStart = $false
        $Probe.DoTrackInTarget = $true
        $Probe.SetTargetArea(5, 0, 10, 10)
        $Probe.FindSolutions()
    }
    It "will be algorithm for FindSolutions" {
        $Probe.DoTrackProbeStart = $false
        $Probe.DoTrackProbe = $false
        $Probe.DoTrackInTarget = $true
        $Probe.SetTargetArea(20, -10, 30, -5)
        $Probe.FindSolutions(1, -100)
        Write-Warning "                 Final max = $($Probe.MaxHeight)"
        $Probe.MaxHeight | Should -Be 45
        $Probe.HitCount | Should -Be 112
        # This one failes
    }
}
# target area: x=185..221, y=-122..-74
Describe "Brut force" {
    BeforeEach {
        $Probe = [Probe]::new()
    }
    It "will be algorithm for FindSolutions" {
        $Probe.DoTrackProbeStart = $false
        $Probe.DoTrackProbe = $false
        $Probe.DoTrackOverShoot = $false
        $Probe.DoTrackInTarget = $false
        $Probe.SetTargetArea(185, -122, 221, -74)
        $Probe.FindSolutions(18, -100)
        Write-Warning "                 Final max = $($Probe.MaxHeight)"
        $Probe.MaxHeight | Should -Be 7381
        $Probe.HitCount | Should -Be 2205 # 2205 is too low :-()
    }
}

Describe "One shot" {
    BeforeEach {
        $Probe = [Probe]::new()
    }
    It "will be algorithm for FindSolutions" -Skip {
        $Probe.DoTrackProbeStart = $true
        $Probe.DoTrackProbe = $true
        $Probe.DoTrackOverShoot = $true
        $Probe.DoTrackInTarget = $true
        $Probe.SetTargetArea(185, -122, 221, -74)
        $Probe.SetStartingVelocity(23, -10)
        # $Probe.SetStartingVelocity(19, 60)
        # $Probe.SetStartingVelocity(20, 50)
        $max = $Probe.DoOneShot()
        Write-Warning "                 max = $max"
    }
    It "should solve Part2" {
        $ret = $Probe.Part2("$PSSCriptRoot\17_TrickShot-Part2.ps1")
        $ret | Should -Be 1
    }
}