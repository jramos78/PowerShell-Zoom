#Create a pre-provisioned user, assign them a phone license and the first available number
function AddZoomUserWithPhone {
	param(
		[parameter(Mandatory)]
		[String]$FirstName,
		[parameter(Mandatory)]
		[String]$Lastname,
		[parameter(Mandatory)]
		[String]$Email
		) 
	#Create the user's account
	$uri = "https://api.zoom.us/v2/users" 
	$body = "{`"action`":`"ssoCreate`",`"user_info`":{`"email`":`"$Email`",`"type`":1,`"first_name`":`"$FirstName`",`"last_name`":`"$Lastname`"}}"
	Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -ContentType 'application/json' -Body $body
	#Assign the user a phone license
	$uri = "https://api.zoom.us/v2/users/" + $userId + "/settings"
	Invoke-RestMethod -Uri $uri -Method PATCH -Headers $headers -ContentType 'application/json' -Body '{"feature":{"zoom_phone":true}}'
	#Assign the user a calling plan
	$uri = "https://api.zoom.us/v2/phone/users/" + $userId + "/calling_plans"
	Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -ContentType 'application/json' -Body '{"calling_plans":[{"type":"200"}]}'
	#Assign a user the first available number
	$uri = "https://api.zoom.us/v2/phone/users/" + $userId + "/phone_numbers"
	$body = "{`"phone_numbers`":[{`"id`":`"$phoneId`"}]}"
	Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -ContentType 'application/json' -Body $body
}
AddZoomUserWithPhone
