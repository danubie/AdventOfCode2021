# $data = @('00100', '11110', '10110', '10111', '10101', '01111', '00111', '11100', '10000', '11001', '00010', '01010')
$data = Get-Content -Path $PSScriptRoot\03_BinaryDiagnostics.txt
$nbBits = $data[0].Length


# Part 1

$nbBits = $data[0].Length
$mostCommon = 0
$leastCommon = 0
for ( $index = 0; $index -lt $nbBits; $index++) {
    $cnt0 = 0
    $cnt1 = 0
    foreach ($d in $data) {
        if ($d[$index] -eq '1') {
            $cnt1++
        } else {
            $cnt0++
        }
    }
    if ($cnt1 -gt $cnt0) {
        $mostCommon = $mostCommon * 2 + 1
        $leastCommon = $leastCommon * 2
    } else {
        $mostCommon = $mostCommon * 2 + 0
        $leastCommon = $leastCommon * 2 + 1
    }
}
"$mostCommon $leastCommon $($mostCommon*$leastCommon)"

# part 2
$oxygenData = $data
for ( $index = 0; $index -lt $nbBits -and ($oxygenData.Length -gt 1); $index++) {
    $cnt0 = 0
    $cnt1 = 0
    $listBitIs1 = [array] @()
    $listBitIs0 = [array] @()
    foreach ($d in $oxygenData) {
        if ($d[$index] -eq '1') {
            $cnt1++
            $listBitIs1 += $d
        } else {
            $cnt0++
            $listBitIs0 += $d
        }
    }
    Write-Verbose "Result = $([convert]::ToString($result,2)) | Data; $($oxygenData -join ', ')"
    if ($cnt1 -ge $cnt0) {
        $oxygenData = $listBitIs1
    } else {
        $oxygenData = $listBitIs0
    }
}
$oxygenRating = [convert]::ToInt32($oxygenData[0], 2)
Write-Verbose "OxygenRating : $oxygenRating"
# co2
$co2Data = $data
for ( $index = 0; ($index -lt $nbBits) -and ($co2Data.Length -gt 1); $index++) {
    $cnt0 = 0
    $cnt1 = 0
    $listBitIs1 = [array] @()
    $listBitIs0 = [array] @()
    foreach ($d in $co2Data) {
        if ($d[$index] -eq '1') {
            $cnt1++
            $listBitIs1 += $d
        } else {
            $cnt0++
            $listBitIs0 += $d
        }
    }
    Write-Verbose "Result = $([convert]::ToString($result,2)) | Data; $($co2Data -join ', ')"
    if ($cnt1 -lt $cnt0) {
        $co2Data = $listBitIs1
    } else {
        $co2Data = $listBitIs0
    }
    Write-Verbose "next iteration data = Data; $($co2Data -join ', ')"
}
Write-Verbose "CO2 rating : $result $([convert]::ToInt32($Co2data[0], 2))"
$co2Rating = [convert]::ToInt32($co2Data[0], 2)

"*** $oxygenRating $co2Rating  $($oxygenRating * $co2Rating)"

break
