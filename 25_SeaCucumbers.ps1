$field = @()
$SizeHorizontal = 0
$SizeVertical = 0

function ReadInputData() {
    $fileName = "$PSScriptRoot\25_Seacucumber.txt"
    $data = Get-Content $fileName
    $data = $data | ForEach-Object { $_.Trim() }
    $Script:SizeHorizontal = $data[0].length
    $Script:SizeVertical = $data.length
    $Script:field = New-Object 'char[,]' $Script:SizeHorizontal, $Script:SizeVertical
    for ($h=0; $h -lt $Script:SizeHorizontal; $h++) {
        for ($v=0; $v -lt $Script:SizeVertical; $v++) {
            $Script:field[$h, $v] = $data[$v].substring($h,1)
        }
    }
}

function PrintField($CntMove) {
    Write-Host (("-" * $Script:SizeHorizontal) + $cntMove)
    for ($v=0; $v -lt $Script:SizeVertical; $v++) {
        $s = ''
        for ($h=0; $h -lt $Script:SizeHorizontal; $h++) {
            $s += $Script:field[$h, $v]
        }
        Write-Host $s
    }
}

function MoveOne () {
    # start at the right-most column
    # if there is a > and in pos 0 is a '.' then move > to pos 0 and '.' to the current column
    # then move each > to the right if the position to the right is a '.'
    # do this for each row
    $DidMove = $false
    for ($v=0; $v -lt $Script:SizeVertical; $v++) {
        for ($h=0; $h -lt $Script:SizeHorizontal; $h++) {
            # is there something to move?
            if ($Script:field[$h, $v] -eq '>') {
                    if ($Script:field[(($h+1)%$Script:SizeHorizontal), $v] -eq '.') {
                    $Script:field[$h, $v] = '+'     # mark it as 'free after move
                    $Script:field[(($h+1)%$Script:SizeHorizontal), $v] = '*'
                    $DidMove = $true
                }
            }
        }
    }
    # now reset marker for the > if it is '+'
    for ($v=$Script:SizeVertical-1; $v -ge 0 ; $v--) {
        for ($h=0; $h -lt $Script:SizeHorizontal; $h++) {
            if ($Script:field[$h, $v] -eq '+') {
                $Script:field[$h, $v] = '.'
            }
            if ($Script:field[$h, $v] -eq '*') {
                $Script:field[$h, $v] = '>'
            }        }
    }    # now move the 'v' down
    for ($v=0; $v -lt $Script:SizeVertical; $v++) {
        for ($h=0; $h -lt $Script:SizeHorizontal; $h++) {
            # is there something to move?
            if ($Script:field[$h, $v] -eq 'v') {
                if ($Script:field[$h, (($v+1)%$Script:SizeVertical)] -eq '.') {
                    $Script:field[$h, $v] = '+'    # mark it as 'free after move
                    $Script:field[$h, (($v+1)%$Script:SizeVertical)] = '*'
                    $DidMove = $true
                }
            }
        }
    }
    # now reset marker for the > if it is '+'
    for ($v=$Script:SizeVertical-1; $v -ge 0 ; $v--) {
        for ($h=0; $h -lt $Script:SizeHorizontal; $h++) {
            if ($Script:field[$h, $v] -eq '+') {
                $Script:field[$h, $v] = '.'
            }
            if ($Script:field[$h, $v] -eq '*') {
                $Script:field[$h, $v] = 'v'
            }
        }
    }
    $DidMove
}
"+++++++++++++++++++++++++++++++++++++++"
ReadInputData
# PrintField 0
# $field
$sum = 1
while (MoveOne) {
    # PrintField $sum
    $sum += 1
}
$sum