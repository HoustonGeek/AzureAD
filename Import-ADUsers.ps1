<#
    .SYNOPSIS
    Import-ADUsers.ps1

    .DESCRIPTION
    Import Active Directory users from CSV file.

    .LINK
    alitajran.com/import-ad-users-from-csv-powershell

    .NOTES
    Written by: ALI TAJRAN
    Website:    alitajran.com
    LinkedIn:   linkedin.com/in/alitajran

    .CHANGELOG
    V1.00, 04/24/2023 - Initial version
#>

# Define the CSV file location and import the data
$Csvfile = "C:\scripts\AllADUsers_202304240919.csv"
$Users = Import-Csv $Csvfile

# Import the Active Directory module
Import-Module ActiveDirectory

# Loop through each user
foreach ($User in $Users) {
    $GivenName = $User.'First name'
    $Surname = $User.'Last name'
    $DisplayName = $User.'Display name'
    $SamAccountName = $User.'User logon name'
    $UserPrincipalName = $User.'User principal name'
    $StreetAddress = $User.'Street'
    $City = $User.'City'
    $State = $User.'State/province'
    $PostalCode = $User.'Zip/Postal Code'
    $Country = $User.'Country/region'
    $JobTitle = $User.'Job Title'
    $Department = $User.'Department'
    $Company = $User.'Company'
    $ManagerDisplayName = $User.'Manager'
    $Manager = if ($ManagerDisplayName) {
        Get-ADUser -Filter "DisplayName -eq '$ManagerDisplayName'" -Properties DisplayName |
        Select-Object -ExpandProperty DistinguishedName
    }
    $OU = $User.'OU'
    $Description = $User.'Description'
    $Office = $User.'Office'
    $TelephoneNumber = $User.'Telephone number'
    $Email = $User.'E-mail'
    $Mobile = $User.'Mobile'
    $Notes = $User.'Notes'
    $AccountStatus = $User.'Account status'

    # Check if the user already exists in AD
    $UserExists = Get-ADUser -Filter { SamAccountName -eq $SamAccountName } -ErrorAction SilentlyContinue

    if ($UserExists) {
        Write-Warning "User '$SamAccountName' already exists in Active Directory."
        continue
    }

    # Create new user parameters
    $NewUserParams = @{
        Name                  = "$GivenName $Surname"
        GivenName             = $GivenName
        Surname               = $Surname
        DisplayName           = $DisplayName
        SamAccountName        = $SamAccountName
        UserPrincipalName     = $UserPrincipalName
        StreetAddress         = $StreetAddress
        City                  = $City
        State                 = $State
        PostalCode            = $PostalCode
        Country               = $Country
        Title                 = $JobTitle
        Department            = $Department
        Company               = $Company
        Manager               = $Manager
        Path                  = $OU
        Description           = $Description
        Office                = $Office
        OfficePhone           = $TelephoneNumber
        EmailAddress          = $Email
        MobilePhone           = $Mobile
        AccountPassword       = (ConvertTo-SecureString "P@ssw0rd1234" -AsPlainText -Force)
        Enabled               = if ($AccountStatus -eq "Enabled") { $true } else { $false }
        ChangePasswordAtLogon = $true # Set the "User must change password at next logon" flag
    }

    # Add the info attribute to OtherAttributes only if Notes field contains a value
    if (![string]::IsNullOrEmpty($Notes)) {
        $NewUserParams.OtherAttributes = @{info = $Notes }
    }

    try {
        # Create the new AD user
        New-ADUser @NewUserParams
        Write-Host "User $SamAccountName created successfully." -ForegroundColor Cyan
    }
    catch {
        # Failed to create the new AD user
        Write-Warning "Failed to create user $SamAccountName. $_"
    }
}
