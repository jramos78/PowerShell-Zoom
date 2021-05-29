#Get a user’s call log for the last 30 days
function GetUserCallLog {
  param( 
    [Parameter(Mandatory,ValueFromPipelinebyPropertyName,HelpMessage = "Enter the user's Zoom username.")] 
    [String]$Email 
  ) 
  #Get the user's Zoom user Id
  $userId = ((Invoke-RestMethod -Uri 'https://api.zoom.us/v2/users?page_size=500&status=active' -Method GET -Headers $headers).users | Where email -eq $Email).id 
  #Set the call log's time frame 
  $endDate = Get-Date -Format "yyyy-MM-dd" 
  $startDate = ((Get-Date).AddDays(-30)).ToString("yyyy-MM-dd") 
  #Build the URI for the API call 
  $uri = "https://api.zoom.us/v2/phone/users/" + $userId + "/call_logs?to=" + $endDate + "&from=" + $startDate + "&page_size=1000" 
  #Save the user's call log to an array 
  $callLog = (Invoke-RestMethod -Uri $uri -Method GET -Headers $headers).call_logs 
  #Convert the UTC datetime in each call log with its ETC counterpart 
  forEach($i in $callLog){$i.date_time = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date -Date $i.date_time), "Eastern Standard Time")} 
  $callLog | Format-Table 	
}
GetUserCallLog
