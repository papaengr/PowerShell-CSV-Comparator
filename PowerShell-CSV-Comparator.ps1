$oldCsv = Import-Csv -Path '.\old.csv'
$newCsv = Import-Csv -Path '.\new.csv'

$argsEmail = @{
	To = 'me@domain.com'
	From = 'you@domain.com'
	Subject = 'New Customers'
	BodyAsHtml = $true
	SmtpServer = 'smtp.domain.com'
	# UseSsl = $true # Uncomment to use SSL
	# Port = 587     # Uncomment to use SSL
}
$htmlHead = @'
<style>
	table	{border-width:1px; border-style:solid; border-color:black;}
	th		{border-width:1px; border-style:solid; border-color:black; padding:1px;}
	td		{border-width:1px; border-style:solid; border-color:black; padding:1px;}
</style>
'@
$htmlPreContent = "<H3>$($argsEmail['Subject'])</H3>"

$newCustomers = Compare-Object -ReferenceObject $oldCsv -DifferenceObject $newCsv -Property Customer -PassThru |
	Where-Object {$_.SideIndicator -eq '=>'} |
	Select-Object -Property * -ExcludeProperty SideIndicator

If ($newCustomers) {
	Write-Output 'Found new customers:'
	$newCustomers | Format-Table -AutoSize
	$body = ($newCustomers | ConvertTo-Html -Head $htmlHead -PreContent $htmlPreContent) -join "`r`n"
	Send-MailMessage @argsEmail -Body $body
} Else {
	Write-Output 'Found no new customers.'
}
