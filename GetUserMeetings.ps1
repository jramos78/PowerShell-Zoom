#List a user’s scheduled meetings
function GetUserMeetings {
  Param( 
    [parameter(Mandatory)] 
    [String]$Email  
  ) 
  $userId = ((Invoke-RestMethod -Uri 'https://api.zoom.us/v2/users?page_size=500&status=active' -Method GET -Headers $headers).users | Where email -eq $Email).id 
  $uri = "https://api.zoom.us/v2/users/" + $userId + "/meetings?page_size=30&type=scheduled'"
  (Invoke-RestMethod -Uri $uri -Method GET -Headers $headers).Meetings | Format-Table -AutoSize
}
GetUserMeetings
