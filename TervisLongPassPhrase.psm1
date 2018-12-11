. "\\tervis.prv\applications\GitRepository\TervisPassPhrase\Definition.ps1"

#The code below was originally written in cyborg style, not yet refactored to be a robot
function Add-TervisPassPhraseUserToLongPWPolicyGroup {
    $DeploymentGroups.UPNs | 
    % {
        Get-ADUser -Filter { UserPrincipalName -Eq $_ }
    } |
    % {
        Add-ADGroupMember -Identity LongPWPolicy -Members $_
    }    
}

function Get-TervisPassPhraseLongPWPolicyGroupMemebers {
    Get-ADGroupMember -Identity LongPWPolicy | 
    Select-Object -property samaccountname | 
    Sort-Object samaccountname 
}

function Get-TervisPassPhraseUserStatus {
    $DeploymentGroups.UPNs  | 
    % {
        Get-ADUser -Filter { UserPrincipalName -Eq $_ } -Property PasswordLastSet, PasswordNeverExpires 
    } | Select-Object -Property UserPrincipalName, PasswordLastSet, PasswordNeverExpires |
    Sort-Object -Property PasswordLastSet
    
}

function Set-TervisPhassPhraseUserPasswordNeverExpire {
    $DeploymentGroups | % {
        $_.UPNs |
        % {
            Get-ADUser -Filter { UserPrincipalName -Eq $_ } -Property PasswordLastSet, PasswordNeverExpires 
        } |
        Where-Object PasswordNeverExpires -eq $false |
        Where-Object PasswordLastSet -gt $_.TimeAfterPasswordMustHaveBeenChangedToGetNeverExpiresSet | 
        Set-ADUser -PasswordNeverExpires $true
    }
}
