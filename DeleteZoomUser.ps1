#Delete a user’s account
function DeleteZoomUser {    
	param(    
		[Parameter(Mandatory,ValueFromPipelinebyPropertyName,HelpMessage = "Enter the user's Zoom username.")]    
		[String]$Email
	)
	#Get the user's Zoom Id
	$userId = ((Invoke-RestMethod -Uri 'https://api.zoom.us/v2/users?page_size=500&status=active' -Method GET -Headers $headers).users | Where email -eq $Email).id
	#Set the URI for the API call
  $uri = "https://api.zoom.us/v2/users/" + $userId + "?action=delete" 
	#Delete the user's account 
	Invoke-RestMethod -Uri $uri -Method DELETE -Headers $headers
} 
DeleteZoomUser
