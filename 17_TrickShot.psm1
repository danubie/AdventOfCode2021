Class Probe {
    # current position
    [int] $PosX
    [int] $PosY
    # current velocity
    [int] $VelX
    [int] $VelY
    [int] $StartVelX
    [int] $StartVelY
    # Target arae
    [int] $TargetX1
    [int] $TargetY1
    [int] $TargetX2
    [int] $TargetY2

    [int] $MaxHeight
    [int] $HitCount
    # Control display
    [boolean] $DoTrackProbeStart
    [boolean] $DoTrackProbe
    [boolean] $DoTrackInTarget
    [boolean] $DoTrackOvershoot

    [void] SetTargetArea ([int] $x1, [int] $y1, [int] $x2, [int] $y2) {
        $This.TargetX1 = $x1
        $This.TargetY1 = $y1
        $This.TargetX2 = $x2
        $This.TargetY2 = $y2
    }

    [void] SetStartingVelocity ([int] $x, [int] $y) {
        $This.VelX = $x
        $This.VelY = $y
        $This.StartVelX = $x
        $This.StartVelY = $y
        if ($This.DoTrackProbeStart) {Write-Warning "***** Starting velocity: $x, $y"}
        $This.PosX = 0
        $This.PosY = 0
    }

    [void] DoOnStep() {
        $This.PosX += $This.VelX
        $This.PosY += $This.VelY
        # Due to drag, the probe's x velocity changes by 1 toward the value 0;
        # that is, it decreases by 1 if it is greater than 0,
        # increases by 1 if it is less than 0, or
        # does not change if it is already 0
        if ($This.VelX -gt 0) { $This.VelX-- } elseif ($This.VelX -lt 0) { $This.VelX++ }
        # Due to gravity, the probe's y velocity decreases by 1.
        $This.VelY--
        if ($This.DoTrackProbe) {
            $s = "Probe at ($($This.PosX), $($This.PosY)) with velocity ($($This.VelX), $($This.VelY))"
            if ($This.IsInTargetArea()) { $s += " in target" }
            if ($This.DidOvershoot()) { $s += " overshot" }
            Write-Warning $s
            $huhu = 1
        }
    }

    [boolean] IsInTargetArea() {
        $result = $This.PosX -ge $This.TargetX1 -and $This.PosX -le $This.TargetX2 -and
               $This.PosY -ge $This.TargetY1 -and $This.PosY -le $This.TargetY2
        # Write-Verbose "Is in target area: $result"
        if ($This.DoTrackInTarget) {
            if ($result) {
                $s = "Probe at ($($This.PosX), $($This.PosY)) with velocity ($($This.VelX), $($This.VelY)) overshoot"
                Write-Warning $s
                $huhu = 1
            }
        }
        return $result
    }

    [boolean] DidOvershoot() {
        # overshoot:
        # ich bin rechts vom Ziel; später dann auch: oder ich bin links vom Ziel und die Geschwindigkeit ist 0
        # ich bin unter dem Ziel
        $result = ($This.PosX -gt $This.TargetX2) -or
               ($This.PosY -lt $This.TargetY1)
        if ($This.DoTrackOvershoot) {
            if ($result) {
                $s = "Probe at ($($This.PosX), $($This.PosY)) with velocity ($($This.VelX), $($This.VelY)) overshoot"
                Write-Warning $s
            }
        }
        return $result
    }

    [int32] DoOneShot() {
        $max = [int32]::MinValue
        $This.DoOnStep()
        while (-not $This.IsInTargetArea() -and -not $This.DidOvershoot()) {
            if ($This.PosY -gt $max) { $max = $This.PosY }
            $This.DoOnStep()
        }
        return $max
    }

    [void] FindSolutions ([int] $StartInitialX, [int] $StartInitialY) {
        # start with x velocity of half the distance (because it will be reduced by 1 each step)
        # start with y of the lower bound of the target + StartVelx
        $locStartVelX = $StartInitialX      # for faster solutin of Part1: 18 is the highest integer to satisfy n*(n+1)/2 < 185
                                # for sample: 1
        $locStartVelY = $StartInitialY
        $This.MaxHeight = [int]::MinValue
        $Vx2 = $This.TargetX2
        # while ($This.StartVelX -le $This.TargetX2 -and $This.startVelY -le ($TargetHeight*2)) {
        for ($vx = $locStartVelX; $vx -le $Vx2 ; $vx++) {
            for ($vy = $locStartVelY; $vy -lt 200; $vy++) {
                $This.SetStartingVelocity($vx, $vy)
                $max = $This.DoOneShot()
                if ($This.IsInTargetArea() ) {
                    Write-Warning "Found solution: $($This.StartVelX), $($This.StartVelY), $($This.PosX), $($This.PosY), $max"
                    $This.HitCount++
                    if ($max -gt $This.MaxHeight) {
                        $This.MaxHeight = $max
                        Write-Warning "New max height: $($This.MaxHeight)"
                    }
                }
            }
        }
    }

    # [int32] Part2 ( [string] $filename ) {
    #     $rawdata = Get-Content $filename -ErrorAction Stop
    #     $cnt = 0
    #     foreach ($d in $rawdata) {
    #         $array = $d.Split(' ')
    #         foreach ($a in $array) {
    #             if ($a -eq "") { continue }
    #             $init = $a.Split(',')
    #             $Probe = [Probe]::new()
    #             $Probe.SetTargetArea(185, -122, 221, -74)
    #             $Probe.SetStartingVelocity($init[0], $init[1])
    #             $ret = $Probe.DoOneShot()
    #             if ($ret -gt [int]::MinValue) {
    #                 Write-Warning "Part2 Solution: $($init[0]), $($init[1])"
    #                 $cnt++
    #             }
    #         }
    #     }
    #     return $cnt
    # }
}
Export-ModuleMember  TrickShot