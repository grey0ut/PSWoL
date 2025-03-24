BeforeAll {
    Import-Module $ModuleName
}

Describe 'Convert-HostnameToIP' {
    InModuleScope $ModuleName {
        It 'Should resolve localhost' {
            $Result = Convert-HostnameToIP -ComputerName localhost
            $Result | Should -Be "127.0.0.1"
        }
    }
}