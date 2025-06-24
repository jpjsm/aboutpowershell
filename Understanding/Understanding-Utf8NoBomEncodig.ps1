## Define UTF8 No-BOM encoder/decoder$Utf8NoBom = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false
## Four point encoded UTF8 char: 𐍈[byte[]]$utf8encodedchar = @(0xF0,0x90, 0x8D, 0x88)

$utf8Decoder = $Utf8NoBom.GetDecoder()

[int]$encodedCharCount = $utf8Decoder.GetCharCount($utf8encodedchar, 0, ($utf8encodedchar.Length), $true)

[char[]]$encodedUtf8Chars = New-Object -Type char[] -ArgumentList  $encodedCharCount

$encodedCount = $utf8Decoder.GetChars($utf8encodedchar, 0, ($utf8encodedchar.Length), $encodedUtf8Chars, 0,$true)

$standardString = [string]::new($encodedUtf8Chars)
## End of four point UTF8 [string[]]$lines = @()[string[]]$recoveredLines = @()$lines = @("a","á","à", "â","ñ", "ç","Ç", $standardString)[int][char]'A'..[int][char]'C'| % { $lines += [char]$_}$lines[System.IO.File]::WriteAllLines("C:\tmp\Utf8NoBom.txt" , $lines, $Utf8NoBom)$recoveredLines = [System.IO.File]::ReadAllLines("C:\tmp\Utf8NoBom.txt", $Utf8NoBom)$recoveredLines