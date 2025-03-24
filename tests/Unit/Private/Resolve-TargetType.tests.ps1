BeforeAll {
    Import-Module $ModuleName
}

Describe 'Resolve-TargetType' {
    InModuleScope $ModuleName {
        It 'Should resolve a MAC address' {
            $Result = Resolve-TargetType -Target '00-00-0A-BB-28-FC'
            $Result -eq 'MacAddress' | Should -BeTrue
        }
        It 'Should resolve an IP address' {
            $Result = Resolve-TargetType -Target '192.168.1.1'
            $Result -eq 'IPAddress' | Should -BeTrue
        }
        It 'Should resolve anything else as a ComputerName' {
            $Result = Resolve-TargetType -Target 'AnythingElse'
            $Result -eq 'ComputerName' | Should -BeTrue
        }
    }
}