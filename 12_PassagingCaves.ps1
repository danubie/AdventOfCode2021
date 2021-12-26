Set-Strictmode -Version Latest

. .\12_CaveClass.ps1
function ReadInputData ($filename) {
    $rawdata = Get.Content -Path $filename
}

Part1 ($filename) {
    $rawdata = ReadInputData $filename

    $rawdata | ForEach-Object {
        $connectors = $rawdata -split ","
        foreach ($connector in $connectors) {
            $c0 = [Cave]::New($connector[0])
            $c1 = [Cave]::New($connector[1])
            $c0.ConnectTo($c1)
        }
    }
}