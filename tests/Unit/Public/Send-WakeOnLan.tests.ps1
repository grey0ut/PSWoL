BeforeAll {
    Import-Module $ModuleName
}

Describe 'Send-WakeOnLan' {
    It 'Should execute without error using -WhatIf' {
        try {
            Send-WakeOnLan -TargetAddress 255.255.255.255 -WhatIf -ErrorAction Stop
        } catch {
            $Fail = $_
        }
        $Fail | Should -BeNullOrEmpty
    }
    It 'Should warn if provided computername cannot be found' {
        try {
            Send-WakeOnLan -TargetAddress 'Contoso.local' -WarningAction Stop
        } catch {
            $Warned = $true
        }
        $Warned | Should -BeTrue
    }
}