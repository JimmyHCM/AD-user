Import-Module ActiveDirectory
Import-Module ExchangeOnlineManagement

try {
    Connect-ExchangeOnline -ErrorAction Stop
} catch {
    Write-Error "Failed to connect to Exchange Online. Error: $_"
    exit
}

$AD_Users = Import-Csv -Path "C:\scripts\newusers.csv"
$filePath = "C:\scripts\uid.txt"
$logPath = "C:\scripts\user_creation_log.txt"

try {
    $currentUidNumber = [int](Get-Content -Path $filePath -ErrorAction Stop)
} catch {
    Write-Error "Failed to read the UID file. Error: $_"
    exit
}

function Log-Message {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $logPath -Append
    Write-Output $Message
}

Log-Message "Starting user creation process. Current UID: $currentUidNumber"

foreach ($User in $AD_Users) {
    $User_name = $User.username
    $User_Password = $User.password
    $First_name = $User.firstname
    $Last_name = $User.lastname
    $Groups = $User.groups -split '#'

    if (Get-ADUser -Filter "SamAccountName -eq '$User_name'" -ErrorAction SilentlyContinue) {
        Log-Message "A user $User_name already exists in Active Directory."
        continue
    }

    try {
        $newUser = New-ADUser `
            -SamAccountName $User_name `
            -UserPrincipalName "$User_name@YourDomainName" `
            -Name "$First_name $Last_name" `
            -GivenName $First_name `
            -Surname $Last_name `
            -Enabled $True `
            -ChangePasswordAtLogon $False `
            -DisplayName "$First_name $Last_name" `
            -AccountPassword (ConvertTo-SecureString $User_Password -AsPlainText -Force) `
            -PassThru

        Set-ADUser -Identity $newUser -PasswordNeverExpires $true

        foreach ($Group in $Groups) {
            if (Get-ADGroup -Filter "Name -eq '$Group'" -ErrorAction SilentlyContinue) {
                Add-ADGroupMember -Identity $Group -Members $newUser
                Log-Message "Added $User_name to group $Group"
            } else {
                Log-Message "Group '$Group' does not exist. Skipping."
            }
        }

        Set-ADUser -Identity $newUser.DistinguishedName -Replace @{
            loginShell = '/bin/bash'
            uid = "$User_name"
            uidNumber = $currentUidNumber
            unixHomeDirectory = "/home/$User_name"
            gidNumber = 123
            objectClass = @("top","posixAccount","person","organizationalPerson","user")
        }

        Set-Mailbox -Identity $newUser -PrimarySmtpAddress "$User_name@YourDomainName"
        Set-Mailbox -Identity $newUser -MailNickname $User_name

        Log-Message "Successfully created user $User_name with UID $currentUidNumber"

        $currentUidNumber++
        Set-Content -Path $filePath -Value $currentUidNumber -ErrorAction Stop

    } catch {
        Log-Message "Failed to create user $User_name. Error: $_"
    }
}

Log-Message "User creation process completed. Final UID: $currentUidNumber"
Disconnect-ExchangeOnline -Confirm:$false
