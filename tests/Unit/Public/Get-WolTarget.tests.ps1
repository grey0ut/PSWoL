BeforeAll {
    Import-Module $ModuleName
}

Describe 'Get-WolTarget' {
    It 'Should return $null with no saved settings file' {
        $Result = Get-WolTarget
        $Result -eq $null | Should -BeTrue
    }
}