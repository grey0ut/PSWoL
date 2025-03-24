BeforeAll {
    Import-Module $ModuleName
}

Describe 'Remove-WolTarget' {
    It 'Should warn if you attempt to remove a non-existent target' {
        try {
            Remove-WolTarget -Name "Test" -WarningAction Stop
            $Success = $fale
        } catch {
            $Success = $true
        }
        $Success -eq $true | Should -BeTrue
    }
}