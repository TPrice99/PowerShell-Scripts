Connect-MicrosoftTeams
$SamAccount = Read-Host "Enter Sam Account name:"
$City = Read-Host "Enter the City:"

$Data = @()
$global:PhoneNumberArray = @()

function Get_Number_List ($Country, $AreaCode)
{
  $Data = Get-CsPhoneAssignment -PstAssignmentStatus Unassigned -IsoCountryCode $Country -TelephoneNumberContain $AreaCode -CapabilitiesContain 'UserAssignment'
  $numbers = $Data.TelePhoneNumber
  $global:PhoneNumberArray += $numbers.split(" ")
  
}

switch ($location)
{
  # This is where you specify what city and the areacode with the city
  Denver {
    $Country = 'US'
    $AreaCode = '303'
    Get_Number_List $Country $AreaCode
    $AreaCode = '720'
    Get_Number_List $Country $AreaCode

    # Emergency City Location
    $location = Get-CsOnlineLisLocation -City Denver
  }

}

# Writes out the available phone numbers and can select based on index
$i = 0
while ($i -lt $PhoneNumberArray.count)
{
  Write-Host "$i :" $PhoneNumberArray[$i]
  $i++
}

$index = Read-Host "Select index for phone number to add to" $SamAccount
$SelectNumber = $PhoneNumberArray[$index]
$email = $SamAccount+'@company.com'

if ($location.count -gt 1)
{
  $location = $location[0]
}

# Add number into Teams admin
Set-CsPhoneNumberAssignment -Identity $email -PhoneNumber $SelectNumber -PhoneNumberType CallingPlan -LocationId $location.LocationId
Write-Host "Added" $SelectNumber "to" $SamAccount

Disconnect-MicrosoftTeams

# Add number to the AD account
Set-ADUser -Identity $SamAccount -add @{telephoneNumber = $SelectNumber}
