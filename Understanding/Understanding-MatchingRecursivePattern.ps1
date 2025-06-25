<#
    .Synopsis
        Get a pattern that might have a repetition of itself

        .Description
        We need to find all occorrences of an anchor sequence followed by 
        a sequence that might contain one copy of itself.

        .Examples
        Let's  define:
        -  Left anchor:              ‘
        -  Right anchor:             ’
        -  Left sequence delimiter:  «
        -  Right sequence delimiter: »

        We're looking for a pattern similar to:

        ‘ ’« (« »)? »
#>


$testValues = @(
    "This a traditional ‘hello’«world» sample", ## This should be a match
    "No matches here", ## this is a clear no match
    "another ‘failed‘’«example»", ## no match here => empty anchor
    "here ‘starts’«a well «represented» example»", ## single full pattern
    "this ‘is’«a «doble» match» of a ‘pattern’«that «repeats» itself»" , ## double full pattern
    "this ‘is’«a «triple «depth pool» of» text» that is waiting to be revealed"
    )

$pattern = "‘([^‘]+?)’«([^«]+(«(.+?)»)?.+?)»"

$testValues |
    Select-String -Pattern $pattern -AllMatches |
    ForEach-Object { 
        $_.Matches | 
            ForEach-Object { 
                $_.Captures | 
                    ForEach-Object { 
                        Write-Output $("{0}|{1}|{2}|{3}|{4}" -f $_.Value,$_.Groups[1].Value,$_.Groups[2].Value,$_.Groups[3].Value,$_.Groups[4].Val) 
                    } 
            } 
    }