$PesterPreference = New-PesterConfiguration
$PesterPreference.Output.Verbosity = 'Detailed'
BeforeDiscovery {
    . .\16_PacketDecoder.ps1
}
BeforeAll {
    . .\16_PacketDecoder.ps1
}
Describe "Base functions" {
    BeforeEach {
        $Script:Packets = @()
    }
    It "<hex> should give binary string <binary>" -ForEach @(
        @{ hex = "A1"                   ;version = 5; type = 0  ; binary = "10100001" }
        @{ hex = "D2FE28"               ;version = 6; type = 4  ; binary = "110100101111111000101000" }
        @{ hex = "38006F45291200"       ;version = 1; type = 6  ; binary = "00111000000000000110111101000101001010010001001000000000" }
        @{ hex = "78"                   ;version = 3; type = 6  ; binary = "01111000" }
        @{ hex = "EE00D40C823060"       ;version = 7; type = 3  ; binary = "11101110000000001101010000001100100000100011000001100000" }
    ) {
        $ret = ConvertTo-BinaryStringFromHexString $hex
        $ret | Should -Be $binary
        Get-PacketVersion $ret | Should -Be $version
        Get-PacketType $ret | Should -Be $type
    }
    It "literal should return 2021" {
        $binStream = ConvertTo-BinaryStringFromHexString "D2FE28"
        $binStream | Should -Be "110100101111111000101000"
        $version = Get-PacketVersion $binStream
        $type = Get-PacketType $binStream
        $version | Should -Be 6
        $type | Should -Be 4
        # now check for literal
        $rest = Get-Literal $version $type $binStream
        $Script:Packets | Should -HaveCount 1
        $literalValue = $Script:Packets[0]
        $literalValue.version  | Should -Be 6
        $literalValue.type  | Should -Be 4
        $literalValue.LiteralResult | Should -Be 2021
        $literalValue.local | Should -Be "101111111000101"
        $literalValue.rest | Should -Be '000'
    }
}
Describe "Analyze stream" {
    It "is a literal" {
        $Script:Packets = @()
        $binStream = ConvertTo-BinaryStringFromHexString "D2FE28"
        $binStream | Should -Be "110100101111111000101000"
        $reststream = Analyze-Stream $binStream
        $reststream.Length | Should -Be 3
        $Script:Packets | Should -HaveCount 1
        $packet = $Script:Packets[0]
        $packet.version | Should -Be 6
        $packet.type | Should -Be 4
        $packet.LiteralResult | Should -Be 2021
        $packet.local | Should -Be "101111111000101"
        $packet.rest | Should -Be '000'
    }
    It "is a bitlength packet" {
        $Script:Packets = @()
        $binStream = ConvertTo-BinaryStringFromHexString "38006F45291200"
        $binStream | Should -Be "00111000000000000110111101000101001010010001001000000000"
        $reststream = Analyze-Stream $binStream
        # $reststream.Length | Should -Be 3
        $Script:Packets | Should -HaveCount 3

        $packet = $Script:Packets[0]
        $packet.version | Should -Be 6
        $packet.type | Should -Be 4
        $packet.LiteralResult | Should -Be 10

        $packet = $Script:Packets[1]
        $packet.version | Should -Be 2
        $packet.type | Should -Be 4
        $packet.LiteralResult | Should -Be 20

        $packet = $Script:Packets[2]
        $packet.version | Should -Be 1
        $packet.type | Should -Be 6
    }
    It "is a packetcount packet" {
        $Script:Packets = @()
        $binStream = ConvertTo-BinaryStringFromHexString "EE00D40C823060"
        $binStream | Should -Be "11101110000000001101010000001100100000100011000001100000"
        $reststream = Analyze-Stream $binStream
        # $reststream.Length | Should -Be 3
        $Script:Packets | Should -HaveCount 4

        $packet = $Script:Packets[0]
        $packet.version | Should -Be 2
        $packet.type | Should -Be 4
        $packet.LiteralResult | Should -Be 1

        $packet = $Script:Packets[1]
        $packet.version | Should -Be 4
        $packet.type | Should -Be 4
        $packet.LiteralResult | Should -Be 2

        $packet = $Script:Packets[2]
        $packet.version | Should -Be 1
        $packet.type | Should -Be 4
        $packet.LiteralResult | Should -Be 3

        $packet = $Script:Packets[3]
        $packet.version | Should -Be 7
        $packet.type | Should -Be 3
    }
}
Describe "Testing Part 1" {
    It "<Run> should give correct sum <expected>" -ForEach @(
        @{Run = 1;    expected = 16; HexTransmission = '8A004A801A8002F478'}
        @{Run = 2;    expected = 12; HexTransmission = '620080001611562C8802118E34'}
        @{Run = 3;    expected = 23; HexTransmission = 'C0015000016115A2E0802F182340'}
        @{Run = 4;    expected = 31; HexTransmission = 'A0016C880162017C3686B18A3D4780'}
    ) {
        # $VerbosePreference='Continue'
        $ret = Part1 $HexTransmission
        $ret | Should -Be $expected
    }
}
Describe "Part 1 using my puzzle input" {
    It "should return 889" {
        $ret = Part1 (Get-Content "$PSScriptRoot\16_PacketDecoder-sample.txt")
        $ret | Should -Be 889
    }
}
