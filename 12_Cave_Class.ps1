Set-StrictMode -Version 1
Write-Verbose "Class Cave included"
Class Cave {
    static [hashtable] $Caves
    [string] $Name
    [Cave[]] $CavesConnected = @()
    # static [System.Collections.Stack]$StackPaths = @()
    static [System.Collections.ArrayList] $Results = @()

    Cave () {
        if ($null -eq [Cave]::Caves) {
            [Cave]::Caves = @{}
        }
    }

    [void] Reset () {}

    Cave (
        [string] $Name
    ) {
        $This.Name = $Name
        $This.Reset()
        if ([Cave]::Caves.ContainsKey($Name)) {
            Write-Warning "Cave $Name already exists"
        }
        [Cave]::Caves.Add($Name, $This)
        # [Cave]::StackPaths = New-Object System.Collections.Stack
        [Cave]::Results = New-Object System.Collections.ArrayList @()
        Write-Verbose "Cave $Name created"
    }

    [string] ToString () {
        return "Cave: $($This.Name); CC: $($this.CavesConnected.Name -join ',')"
    }

    static [void] ClearList() {
        Write-Verbose "Clearing caves"
        [Cave]::Caves = @{}
        # [Cave]::StackPaths = New-Object System.Collections.Stack
        [Cave]::Results = [System.Collections.ArrayList]::new()
    }

    static [boolean] Exists ([string] $Name) {
        return [Cave]::Caves.ContainsKey($Name)
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

    [boolean] CanBePassed ([string] $PathTillNow) {
        if ($This.Name -eq 'start') {
            return $false
        }
        if ($This.Name.ToLower() -ceq $this.Name) {
            $PathTillNow -notlike "*,$($This.Name)*"
        } else {

        }
        return ($PathTillNow -notlike "*,$($This.Name)*")
    }

    [void] FindPath ([string] $PathTillNow) {
        if ($This.Name -eq 'end') {
            [Cave]::Results.Add($PathTillNow+"end")
            Write-Verbose "Found path: $($PathTillNow+"end")"
            return
        }
        # ein klein geschriebener darf nie als mein Nachfolger vorkommen
        if ($This.Name -cmatch '[a-z]+') {
            if ($PathTillNow -like "*,$($This.Name),*") {
                Write-Verbose "small letter cave already in path $($This.Name)"
                return
            }
        }
        $ret = foreach ($Cave in $This.CavesConnected) {
            # ein klein geschriebener darf nie als mein Nachfolger vorkommen
            if ($Cave.Name -cmatch '[a-z]+') {
                if ($PathTillNow -clike ",$($Cave.Name),*") {
                    Write-Verbose "small letter cave ignored $($Cave.Name) in [$PathTillNow]"
                    continue
                }
            }
            # für jeden anderen: suche den nächsten Nachfolger
            $Cave.FindPath($PathTillNow+$This.Name+',')         # this is ok, because no upper case cave is connected to another upper case cave
        }
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