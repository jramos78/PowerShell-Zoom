function GetZoomUserProfile {
	param(
		[Parameter(Mandatory,ValueFromPipelinebyPropertyName,HelpMessage="Enter the user's Zoom username (email address).")]
		[String]$Email
	)
	$userId = ((Invoke-RestMethod -Uri 'https://api.zoom.us/v2/users?page_size=500&status=active' -Method GET -Headers $headers).users | Where email -eq $Email).id
	$uri = "https://api.zoom.us/v2/phone/users/" + $userId
	Invoke-RestMethod -Uri $uri -Method GET -Headers $headers
}
GetZoomUserProfile
