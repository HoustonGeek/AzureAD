<#
    .SYNOPSIS
    Export-AzADUsers.ps1

    .DESCRIPTION
    Export Azure Active Directory users to CSV file.

    .LINK
    alitajran.com/export-azure-ad-users-to-csv-powershell

    .NOTES
    Written by: ALI TAJRAN
    Website:    alitajran.com
    LinkedIn:   linkedin.com/in/alitajran

    .CHANGELOG
    V1.00, 03/26/2022 - Initial version
    V1.10, 04/01/2023 - Added manager display name, manager user principal name, and employee ID
#>

# Split path
$Path = Split-Path -Parent "~/Scripts/*.*"

# Create variable for the date stamp in log file
$LogDate = Get-Date -f yyyyMMddhhmm

# Define CSV and log file location variables
# They have to be on the same location as the script
$Csvfile = $Path + "\AllAzADUsers_$logDate.csv"

# Get all Azure AD users
$AzADUsers = Get-AzureADUser -All $true | Select-Object -Property *

# Display progress bar
$progressCount = 0
for ($i = 0; $i -le $AzADUsers.Count; $i++) {

    Write-Progress `
        -Id 0 `
        -Activity "Retrieving User " `
        -Status "$progressCount of $($AzADUsers.Count)" `
        -PercentComplete (($progressCount / $AzADUsers.Count) * 100)

    $progressCount++
}

# Create list
$AzADUsers | Sort-Object GivenName | Select-Object `
@{Label = "First name"; Expression = { $_.GivenName } },
@{Label = "Last name"; Expression = { $_.Surname } },
@{Label = "Display name"; Expression = { $_.DisplayName } },
@{Label = "User principal name"; Expression = { $_.UserPrincipalName } },
@{Label = "Street"; Expression = { $_.StreetAddress } },
@{Label = "City"; Expression = { $_.City } },
@{Label = "State/province"; Expression = { $_.State } },
@{Label = "Zip/Postal Code"; Expression = { $_.PostalCode } },
@{Label = "Country/region"; Expression = { $_.Country } },
@{Label = "Employee ID"; Expression = { $_.ExtensionProperty.employeeId } },
@{Label = "Job Title"; Expression = { $_.JobTitle } },
@{Label = "Department"; Expression = { $_.Department } },
@{Label = "Company"; Expression = { $_.CompanyName } },
@{Label = "Manager display name"; Expression = { (Get-AzureADUserManager -ObjectId $_.ObjectId).DisplayName } },
@{Label = "Manager user principal name"; Expression = { (Get-AzureADUserManager -ObjectId $_.ObjectId).UserPrincipalName } },
@{Label = "Description"; Expression = { $_.Description } },
@{Label = "Office"; Expression = { $_.PhysicalDeliveryOfficeName } },
@{Label = "Telephone number"; Expression = { $_.TelephoneNumber } },
@{Label = "E-mail"; Expression = { $_.Mail } },
@{Label = "Mobile"; Expression = { $_.Mobile } },
@{Label = "User type"; Expression = { $_.UserType } },
@{Label = "Dirsync"; Expression = { if (($_.DirSyncEnabled -eq 'True') ) { 'True' } Else { 'False' } } },
@{Label = "Account status"; Expression = { if (($_.AccountEnabled -eq 'True') ) { 'Enabled' } Else { 'Disabled' } } } |

# Export report to CSV file
Export-Csv -Encoding UTF8 -Path $Csvfile -NoTypeInformation #-Delimiter ";"