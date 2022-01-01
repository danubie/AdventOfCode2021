Set-StrictMode -Version 1
Write-Verbose "Class Cave included"
Class Cave {
    [string] $Name
    [Cave[]] $CavesConnected = @()
    [int] $VisitsLeft = [int]::MaxValue
    [bool] $IsSmall = $false            # is it a small letter cave

    static [hashtable] $Caves
    static [System.Collections.Stack]$StackPaths = @()
    static [System.Collections.ArrayList] $Results = @()
    static [bool] $AllowSmallTwice = $false

    Cave () {}

    Cave ([string] $Name) {
        $This.Name = $Name
        $This.IsSmall = ($This.Name -cmatch '[a-z]+') -and $Name -ne 'start' -and $Name -ne 'end'
        $This.Reset()
        if ([Cave]::Caves.ContainsKey($Name)) {
            Write-Warning "Cave $Name already exists"
        }
        [Cave]::Caves.Add($Name, $This)
        [Cave]::StackPaths = New-Object System.Collections.Stack
        [Cave]::Results = New-Object System.Collections.ArrayList @()
    }

    [void] Reset () {
        if (-not $This.IsSmall) {
            $This.VisitsLeft = [int]::MaxValue
        } else {
            $This.VisitsLeft = 1
            if ([cave]::AllowSmallTwice) { $This.VisitsLeft = 2 }
        }
    }

    [string] ToString () {
        return "Cave: $($This.Name); CC: $($this.CavesConnected.Name -join ',')"
    }

    static [void] ClearList() {
        Write-Verbose "Clearing caves"
        [Cave]::Caves = @{}
        [Cave]::StackPaths = New-Object System.Collections.Stack
        [Cave]::Results = [System.Collections.ArrayList]::new()
        [Cave]::AllowSmallTwice = $false
    }

    static [boolean] Exists ([string] $Name) {
        return [Cave]::Caves.ContainsKey($Name)
    }

    [void] PushStack () {
        # $AllCaves = New-Object -TypeName PSObject -Property @()
        $AllCaves = foreach ($cName in [cave]::Caves.Keys){
            $cCopy = [PSCustomObject] @{
                Name = [cave]::Caves[$cName].Name;
                VisitsLeft = [cave]::Caves[$cName].VisitsLeft;
            }
            $cCopy
        }
        [Cave]::StackPaths.Push($AllCaves)
    }

    [void] PopStack () {
        $AllCaves = [Cave]::StackPaths.Pop()
        foreach ($c in $AllCaves) {
            [Cave]::Caves[$c.Name].VisitsLeft = $c.VisitsLeft
        }
        $AllCaves = $null
    }

    [void] ConnectTo ([string] $CaveName) {
        if ($null -eq [Cave]::Caves[$CaveName]) {
            throw "Cave $CaveName does not exist"
        }
        $This.ConnectTo([Cave]::Caves[$CaveName])
    }

    [void] ConnectTo ([Cave] $Cave) {
        if ($Cave.Name -eq $This.Name) {
            Throw "Error: Cave $($This.Name) can't connect to itself"
        }
        if ($This.CavesConnected.Count -gt 0 -and $This.CavesConnected.Name -contains $Cave.Name) {
            Write-Verbose "Ignored: Cave $($This.Name) already connected to $($Cave.Name)"
            return
        }
        if ($This.Name -eq 'end') {
            Write-Verbose "Ignored: $($This.Name) does not connect to anything else $($Cave.Name)"
            return
        }
        if ($Cave.Name -eq 'start') {
            Write-Verbose "Ignored: $($This.Name) does not connect back to $($Cave.Name)"
            $Cave.ConnectTo($This)      # but start has to connect to $this
            return
        }
        Write-Verbose "Connecting $($This.Name) to $($Cave.Name)"
        $This.CavesConnected += $Cave
        $Cave.ConnectTo($This)
    }

    [boolean] CanBePassed () {
        $ret = $This.Name -eq 'start' -or $This.VisitsLeft -gt 0
        Write-Verbose "Cave $($This.Name), left: $($This.VisitsLeft) can be passed: $($ret)"
        return $ret
    }

    [void] Visit () {
        Write-Verbose "Visit $($This.Name) left: $($This.VisitsLeft)"
        if ($This.Name -eq 'start') {
            Write-Verbose "Visited $($This.Name)"
            return
        }
        if ($This.VisitsLeft -le 0) {
            Write-Warning "Ignored: $($This.Name) has no visits left"
            return
        }
        $This.VisitsLeft -= 1
        if ($This.IsSmall -and [cave]::AllowSmallTwice -and $This.VisitsLeft -le 0) {
            # all caves that could have been still visited twice, now are reduced to one visit
            foreach ($n in [cave]::Caves.Keys) {
                [cave]::Caves[$n].VisitsLeft--
            }
            $This.VisitsLeft++      # got decremented twice, now it's one mote visit left
        }

        Write-Verbose "Visited $($This.Name) Left: $($This.VisitsLeft)"
    }

    [void] FindPath ([string] $PathTillNow) {
        Write-Verbose "Finding path for $PathTillNow $($This.Name)"
        if ($This.Name -eq 'end') {
            [Cave]::Results.Add($PathTillNow+"end")
            Write-Verbose "Found path: $($PathTillNow+"end")"
            return
        }
        # ein klein geschriebener darf nie als mein Nachfolger vorkommen
        # if ($This.IsSmall) {
        #     if ($PathTillNow -like "*,$($This.Name),*") {
        #         Write-Verbose "VisitsLeft = $($This.VisitsLeft); small letter cave already in path $($This.Name)"
        #         return
        #     }
        # }
        $This.PushStack()
        $This.Visit()
        $ret = foreach ($Cave in $This.CavesConnected) {
            if ($Cave.CanBePassed()) {
                $Cave.FindPath($PathTillNow+$This.Name+',')         # this is ok, because no upper case cave is connected to another upper case cave
            }            # ein klein geschriebener darf nie als mein Nachfolger vorkommen
        }
        $This.PopStack()
    }

    static [string[]] FindAllPaths () {
        $start = [Cave]::Caves['start']
        foreach ($c in $start.CavesConnected) {
            $c.FindPath('start,')
        }
        return @([Cave]::Results.ForEach({$_}))
    }

    static [void] LoadFromFile ([string] $FileName) {
        $FileName = $FileName.Trim()
        $rawdata = Get-Content $FileName -ErrorAction Stop
        foreach ($line in $rawdata) {
            $line = $line.Trim()
            if ($line -eq '') {
                continue
            }
            Write-Verbose "Processing line: $line"
            $connect = $line.Split('-')
            if ($connect[0] -eq 'end') {
                $connect[0] = $connect[1]
                $connect[1] = 'end'
            }
            $cave1 = $null
            $cave2 = $null
            if ( [Cave]::Exists($connect[0]) ) {
                $cave1 = [Cave]::Caves[$connect[0]]
                Write-Verbose "cave found: $($cave1.Name)"
            } else {
                $cave1 = [Cave]::new($connect[0])
            }
            if ( [Cave]::Exists($connect[1]) ) {
                $cave2 = [Cave]::Caves[$connect[1]]
                Write-Verbose "cave found: $($cave2.Name)"
            } else {
                $cave2 = [Cave]::new($connect[1])
            }
            $cave1.ConnectTo($cave2)
        }
        Write-Verbose "$([Cave]::Caves.Count) caves created"
    }
}