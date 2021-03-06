<#

Before making any API calls to your Zoom account, you must request API keys and use them with this script to generate a temporary Jave Web Token (JWT). The source of the script below can be found athttps://gist.github.com/hthoma/8715fc28523270141aa11cb8c87d4138

#>
function Generate-JWT (
    [Parameter(Mandatory = $True)]
    [ValidateSet("HS256", "HS384", "HS512")]
    $Algorithm = $null,
    $type = $null,
    [Parameter(Mandatory = $True,HelpMessage="Enter your API key")]
    [string]$Issuer,
    [int]$ValidforSeconds = $null,
    [Parameter(Mandatory = $True,HelpMessage="Enter your API secret key")]
    $secretKey
    ){
        #Grab Unix Epoch Timestamp and add desired expiration.
        $exp = [int][double]::parse((Get-Date -Date $((Get-Date).AddSeconds($ValidforSeconds).ToUniversalTime()) -UFormat %s)) 
        [hashtable]$header = @{alg = $Algorithm; typ = $type}
        [hashtable]$payload = @{iss = $Issuer; exp = $exp}
        $headerJson = $header | ConvertTo-Json -Compress
        $payloadJson = $payload | ConvertTo-Json -Compress
        $headerJsonBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($headerJson)).Split('=')[0].Replace('+', '-').Replace('/', '_')
        $payloadJsonBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($payloadJson)).Split('=')[0].Replace('+', '-').Replace('/', '_')
        $toBeSigned = $headerJsonBase64 + "." + $payloadJsonBase64
        $signingAlgorithm = switch ($Algorithm) {
            "HS256" {New-Object System.Security.Cryptography.HMACSHA256}
            "HS384" {New-Object System.Security.Cryptography.HMACSHA384}
            "HS512" {New-Object System.Security.Cryptography.HMACSHA512}
        }
        $signingAlgorithm.Key = [System.Text.Encoding]::UTF8.GetBytes($secretKey)
        $signature = [Convert]::ToBase64String($signingAlgorithm.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($toBeSigned))).Split('=')[0].Replace('+', '-').Replace('/', '_')
        $token = "$headerJsonBase64.$payloadJsonBase64.$signature"
        $token
}
#Set the token's lifetime
$ValidforSeconds = 600
#Generate JWT token for use in API calls
$token = Generate-JWT -Algorithm "HS256" -Type "JWT" -ValidforSeconds $ValidforSeconds
#Generate the API call header
[string]$contentType = "application/json"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", $contentType)
$headers.Add("Authorization", "Bearer $token")  

