#Export a user’s call log from last 30 days to Excel
function ExportUserCallLog {
	param( 
		[Parameter(Mandatory,ValueFromPipelinebyPropertyName,HelpMessage = "Enter the user's Zoom username.")] 
		[String]$Email 
	) 
	$userData = (Invoke-RestMethod -Uri 'https://api.zoom.us/v2/users?page_size=500&status=active' -Method GET -Headers $headers).users | Where email -eq $Email
	#Set the call log's time frame
	$endDate = Get-Date -Format "yyyy-MM-dd"
	$startDate = ((Get-Date).AddDays(-30)).ToString("yyyy-MM-dd")
	#Build the URI for the API call
	$uri = "https://api.zoom.us/v2/phone/users/" + $email + "/call_logs?to=" + $endDate + "&from=" + $startDate + "&page_size=1000"
	#Save the user's call log to an array
	$callLog = (Invoke-RestMethod -Uri $uri -Method GET -Headers $headers).call_logs
	#Define a new Excel object as a global variable and create a new workbook
	$global:excel = New-Object -ComObject Excel.Application
	#create a new Excel workbook
	$global:workbook = $global:excel.Workbooks.Add()
	#Create a new spreadsheet
	$spreadsheet = $global:workbook.Worksheets.Item(1)
	#Create a spreadsheet and name it
	if ($spreadsheet.Name -ne "Sheet1"){$spreadsheet = $global:excel.Worksheets.Add()}
	$spreadsheet.Name = "Call Log"
	#Freeze the top row
	$global:excel.Rows.Item("2:2").Select() | Out-Null
	$global:excel.ActiveWindow.FreezePanes = $True
	#Define the column headers
	$columnHeaders = ("Date/Time","Result","Direction","Caller","Caller's number/extension","Called number/extension","Call duration")
	$column = 1
	#Write the headers on the top row in bold text
	forEach($i in $columnHeaders) {
		$spreadsheet.Cells.Item(1,$column) = $i
		$spreadsheet.Cells.Item(1,$column).Font.Bold = $True
		$column++
	}
	#Add an auto-filter to each column header
	$spreadsheet.Cells.Autofilter(1,$columnHeaders.Count) | Out-Null
	#Set the starting column and row in the spreadsheet to write data 
	$row = 2
	$column = 1
	#Get the data to populate the spreadsheet
	forEach($i in $callLog){
		#Convert each call log's timestamp from UTC format to Eastern Standard time 
		$timestamp = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date -Date $i.date_time), "Eastern Standard Time")
		#Convert the call duration from seconds to hh:mm:ss format
		$duration = [timespan]::fromseconds($i.duration)
		$duration = $duration.ToString("hh\:mm\:ss")
		#Populate the spreadsheet cells with data
		$spreadsheet.Cells.Item($row,$column++) = $timestamp
		$spreadsheet.Cells.Item($row,$column++) = $i.result
		$spreadsheet.Cells.Item($row,$column++) = $i.direction
		$spreadsheet.Cells.Item($row,$column++) = $i.caller_name
		$spreadsheet.Cells.Item($row,$column++) = $i.caller_number
		$spreadsheet.Cells.Item($row,$column++) = $i.callee_number
		$spreadsheet.Cells.Item($row,$column++) = $duration
		#Start the next row at column 1
		$column = 1
		#Go to the next row
		$row++
	}
	#Auto fit the column width
	$global:excel.ActiveSheet.UsedRange.EntireColumn.AutoFit() | Out-Null
	#Format active cells into a table
	$ListObject = $excel.ActiveSheet.ListObjects.Add([Microsoft.Office.Interop.Excel.XlListObjectSourceType]::xlSrcRange, $excel.ActiveCell.CurrentRegion, $null ,[Microsoft.Office.Interop.Excel.XlYesNoGuess]::xlYes)
	$ListObject.Name = "TableData"
	$ListObject.TableStyle = "TableStyleMedium9"
	#Open the spreadsheet
	$global:excel.Visible = $True
}
ExportUserCallLog 
