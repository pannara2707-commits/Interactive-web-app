Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Web

$parser = New-Object Microsoft.VisualBasic.FileIO.TextFieldParser("NetFlix.csv")
$parser.TextFieldType = [Microsoft.VisualBasic.FileIO.FieldType]::Delimited
$parser.SetDelimiters(",")
$parser.HasFieldsEnclosedInQuotes = $true

$headers = $parser.ReadFields()

$sb = [System.Text.StringBuilder]::new()
$sb.Append("[") | Out-Null
$first = $true

while (-not $parser.EndOfData) {
    $fields = $parser.ReadFields()
    if ($fields.Length -ge 12) {
        if (-not $first) { $sb.Append(",") | Out-Null }
        $first = $false
        
        $typeVal = if ($fields[1] -eq 'Movie') { 1 } else { 2 }
        $y = 0
        [int]::TryParse($fields[7], [ref]$y) | Out-Null
        $dur = 0
        [int]::TryParse($fields[9], [ref]$dur) | Out-Null
        
        $ti = [System.Web.HttpUtility]::JavaScriptStringEncode($fields[2])
        $dir = [System.Web.HttpUtility]::JavaScriptStringEncode($fields[3])
        $cast = [System.Web.HttpUtility]::JavaScriptStringEncode($fields[4])
        $co = [System.Web.HttpUtility]::JavaScriptStringEncode($fields[5])
        $da = [System.Web.HttpUtility]::JavaScriptStringEncode($fields[6])
        $r = [System.Web.HttpUtility]::JavaScriptStringEncode($fields[8])
        $g = [System.Web.HttpUtility]::JavaScriptStringEncode($fields[10])
        $de = [System.Web.HttpUtility]::JavaScriptStringEncode($fields[11])
        $id = [System.Web.HttpUtility]::JavaScriptStringEncode($fields[0])
        
        $sb.Append("[$typeVal,`"$ti`",`"$dir`",`"$cast`",`"$co`",`"$da`",$y,`"$r`",$dur,`"$g`",`"$de`",`"$id`"]") | Out-Null
    }
}
$sb.Append("]") | Out-Null
$parser.Close()

[System.IO.File]::WriteAllText("data.json", $sb.ToString(), [System.Text.Encoding]::UTF8)
Write-Output "Successfully wrote data.json ($($sb.Length) chars)"
