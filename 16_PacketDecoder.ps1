$Script:Packets = @()
$Script:Stack = New-Object System.Collections.Stack
$Script:DebugStartStream = ''
$Script:Marker = [int64]::MinValue          # mark that an operator has to be executed

function ConvertTo-BinaryStringFromHexString ([string]$hexString) {
    $stream = ''
    foreach ($c in $hexString.ToCharArray()) {
        $u = [int]"0x$c"
        $s = [convert]::ToString($u,2)
        $mod4 = $s.Length % 4
        if ($mod4 -ne 0) {
            $s = ("0" * (4-$mod4) ) + $s
        }
        $stream += $s
    }
    $Script:DebugStartStream = $stream
    return $stream
}

function DebugPacketHeader ($data, $stream) {
    $s = ''
    $s += "[{0}] " -f (' '*($Script:DebugStartStream.Length - $binStream.length) +  $stream)
    $s += "V:{0,4} T:{1,5} Name:{2,-12} " -f $data.Version, $data.Type, $data.TypeName
    switch ($data.TypeName) {
        'Literal' {
            # $s += "Multi?: [{0}]" -f $stream.Substring(6,1)
        }
        'operator Bit' {
            $s += "l:{0} bits:{1}" -f 15, $data.TypeLen
        }
        'operator Cnt' {
            $s += "l:{0} cnt :{1}" -f 11, $data.TypeCnt
        }
    }
    Write-Verbose $s

    $s =  "{0} " -f (' '*($Script:DebugStartStream.Length +2))
    $s += "v:[{0}] t:[{1}] " -f $stream.Substring(0,3), $stream.Substring(3,3)
    switch ($data.TypeName) {
        'Literal' {
            $s += "Multi?: [{0}]" -f $stream.Substring(6,1)
        }
        'operator Bit' {
            $s += "l:[{0}] bits:[{1}]" -f $stream.Substring(6,1), $stream.Substring(7,15)
        }
        'operator Cnt' {
            $s += "c:[{0}] cnt:[{1}]" -f $stream.Substring(6,1), $stream.Substring(7,11)
        }
    }
    $s += "substream: [{0}]" -f $data.Substream
    Write-Verbose $s
}

function Get-PacketHeader ($binstream) {
    $version = [int] ("0b" + $binstream.Substring(0,3))
    $type = [int] ("0b" + $binstream.Substring(3,3))
    $typestring = 'N.A.'
    $typelen = 'N.A.'
    $typecnt = 'N.A.'
    $substream = 'N.A.'
    switch ($type) {
        '4' {
            $typename = 'Literal'
            $substream = $binstream.Substring(6)
            $rest ='-var. length-'
        }
        Default {
            if ($binstream[6] -eq '0') {
                $typename = 'operator Bit'
                $typestring = $binstream.Substring(7,15)
                $typeLen = [int]"0b$typestring"           # nb of bits
                $substream = $binstream.Substring(22, $typevalue)
                $rest = $binstream.Substring(22 + $typevalue)

            } else {
                $typename = 'operator Cnt'
                $typestring = $binstream.Substring(7,11)
                $typeCnt = [int]"0b$typestring"           # nb of packets
                $substream = $binstream.Substring(18)
                $rest ='-var. length-'
            }
        }
    }
    $header = [PSCustomObject]@{
        Version = $version
        Type = $type
        TypeName = $typename
        TypeString = $typestring
        TypeLen = $typelen
        TypeCnt = $typecnt
        SubStream = $substream
        Rest = $rest
    }
    # DebugPacketHeader $header $binstream
    return $header
}

function DebugPacket ($thePacketResult) {
    $s = ''
    $s += "[{0}] " -f (' '*($Script:DebugStartStream.Length - $thePacketResult.local.length) + $thePacketResult.local)
    $s += "Debug Packet V:{0}, T:{1}" -f $thePacketResult.version, $thePacketResult.type
    $s +=  "    V:{0}; T:{1}, Operator:{2}, local=[{3}], Rest=[{4}]" -f $thePacketResult.version, $thePacketResult.type, $thePacketResult.TypeName, $thePacketResult.local, $thePacketResult.rest
    # Write-Verbose $s
}

function ApplyOperator($Packet) {
    # zuerst alle Elemenate vom Stack in ein Array packen bis ein Operator kommt
    $rev = @()
    while ($Script:Stack.Peek() -ne $Script:Marker) {
        $rev += $Script:Stack.Pop()
    }
    # dann den Operator aus dem Stack holen
    $op = $Script:Stack.Pop()
    if ($op -ne $Script:Marker) {
        Write-Warning "Marker expected but found $op"
    }
    # $rev = $Script:Stack.ToArray()
    # $Script:Stack.Clear()
    $array = @()
    for ($i = $rev.Length - 1; $i -ge 0; $i--) {
        $array += $rev[$i]
    }
    switch ([int]$Packet.Type) {
        0 {     # sum all elements and push it to the stack
            $sum = 0
            foreach ($e in $array) {
                $sum += $e
            }
            $Script:Stack.Push($sum)
          }
        1 {    # build the product of all elements and push it to the stack
            $product = 1
            foreach ($e in $array) {
                $product *= $e
            }
            $Script:Stack.Push($product)

        }
        2 {    # select the minimum element and push it to the stack
            $min = $array[0]
            foreach ($e in $array) {
                if ($e -lt $min) {
                    $min = $e
                }
            }
            $Script:Stack.Push($min)
        }
        3 {    # select the maximum element and push it to the stack
            $max = $array[0]
            foreach ($e in $array) {
                if ($e -gt $max) {
                    $max = $e
                }
            }
            $Script:Stack.Push($max)
        }
        5 {    # push 1 to the stack if the first element is greater then the second
            if ($array[0] -gt $array[1]) {
                $Script:Stack.Push(1)
            } else {
                $Script:Stack.Push(0)
            }
        }
        6 {    # push 1 to the stack if the first element is smaller then the second
            if ($array[0] -lt $array[1]) {
                $Script:Stack.Push(1)
            } else {
                $Script:Stack.Push(0)
            }
        }
        7 {    # push 1 to the stack if the first element is equal to the second
            if ($array[0] -eq $array[1]) {
                $Script:Stack.Push(1)
            } else {
                $Script:Stack.Push(0)
            }
        }
        Default {}
    }
}

# read binary stream for literals
# first bit 1 this is not last group; then 4 bits are the value
# first bit 0 this is last group; then 4 bits are the value
function Get-Literal($version, $type, $binString) {
    # Write-Verbose "    Literal V:$version, T:$type"
    $binString = $binString.Substring(6)
    $local = ''
    $result = ''
    do {
        $firstBit = $binString.Substring(0,1)
        $value = $binString.Substring(1,4)
        $local += $binString.Substring(0,5)
        $result += $value
        # remove first bit + 4 bits from string
        $binString = $binString.Substring(5)
    } while ($firstBit -ne '0')
    $literalResult = [int64]"0b$result"
    $thisPacket = [PSCustomObject]@{
        version = $version
        type = $type
        literalResult = $literalResult
        local = $local
        rest = $binString
    }
    DebugPacket $thisPacket
    $Script:Packets += $thisPacket
    $Script:Stack.Push($thisPacket.literalResult)
    # Write-Verbose "    Literal end; rest=[$($thisPacket.rest)]"
    return $thisPacket.rest
}

function Get-OperatorBits ($version, $type, $binStream) {
    # Write-Verbose "    bitOperator: version=$version; Type=$type"

    $bits15 = $binStream.Substring(7,15)
    $bitsLen = [ulong]"0b$bits15"
    $subStream = $binStream.Substring((7+15),$bitsLen)

    $thisPacket = [PSCustomObject]@{
        version = $version
        type = $type
        operator = $operator
        local = $substream
        rest = $binStream.Substring((7+15+$bitsLen))
    }
    DebugPacket $thisPacket
    $Script:Stack.Push($Script:Marker)
    do {
        $subStream = Analyze-Stream $subStream
    } while ($subStream.length -gt 6)

    # Write-Verbose ("    bitOper(end): version={0}; Type={1}, Operator={2}, Rest={3}" -f $thisPacket.version, $thisPacket.type, $thisPacket.operator, $thisPacket.rest)
    ApplyOperator $thisPacket
    $Script:Packets += $thisPacket
    # Write-Verbose "    bitOperator end; rest=[$($thisPacket.rest)]; substream=[$substream]"
    return $thisPacket.rest
}

function Get-OperatorCnt ($version, $type, $binStream) {
    # Write-Verbose "    cntOper: version=$version Operator=$type; "

    $bits11 = $binStream.Substring(7,11)
    $bitsCountSubPackets = [ulong]"0b$bits11"
    # Write-Verbose "version=$version Operator=$type; Count =$bitsCountSubPackets [$binStream]"
    $binStream = $binStream.Substring((7+11))
    $thisPacket = [PSCustomObject]@{
        version = $version
        type = $type
        operator = $operator
        local = "-variable-$bitsCountSubPackets packets-"
        rest = 'unknown'
    }
    DebugPacket $thisPacket
    $Script:Stack.Push($Script:Marker)
    for ($i=0; $i -lt $bitsCountSubPackets; $i++) {
        # Write-Verbose "                                 Packet#:[$($i+1)]"
        $binStream = Analyze-Stream $binStream
    }
    $thisPacket.rest = $binStream
    $Script:Packets += $thisPacket
    ApplyOperator $thisPacket
    # Write-Verbose "    cntOperator end; rest=[$($thisPacket.rest)]"
    return $thisPacket.rest
}

function Analyze-Stream ($binStream) {
    # Write-Verbose "Analyze Stream"

    # Write-Verbose "            in loop"
    $d = Get-PacketHeader $binStream

    $version = Get-PacketVersion $binStream
    $type = Get-PacketType $binStream
    switch ($type) {
        4 { # literal
            # Write-Verbose "version=$version Literal =$type; [$binStream]"
            $binStream = Get-Literal $version $type $binStream
        }
        Default { # operator
            if ($binStream[6] -eq '0') {
                $binStream = Get-OperatorBits $version $type $binStream
            } else {
                $binStream = Get-OperatorCnt $version $type $binStream
            }
        }
    }
    #    $binStream = $thisPacket.rest
    # Write-Verbose "Analyze Stream: end; [$binStream]"
    return $binStream
}

function Part1 ($hexValue) {
    $Script:Packets = @()
    Write-Verbose "Part1 hexvalue=[$hexValue]"
    $binStream = ConvertTo-BinaryStringFromHexString $hexValue
    Write-Verbose "[$binStream]"
    $binStream = Analyze-Stream $binStream
    Write-Verbose "Part1 end; [$binStream]"
    # add up all version numbers
    $measureVersion = $Script:Packets.Version | Measure-Object -Sum
    return $measureVersion.sum

}