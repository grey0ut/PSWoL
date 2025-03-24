BeforeAll {
    Import-Module $ModuleName
}

Describe 'Get-SettingsPath' {
    InModuleScope $ModuleName {
        It 'Should return string' {
            $Result = Get-SettingsPath
            $Result.GetType().Name -eq 'String' | Should -BeTrue
        }
    }
}