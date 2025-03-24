BeforeAll {
    Import-Module $ModuleName
}

Describe 'Convert-MacToByte' {
    InModuleScope $ModuleName {
        It 'Should convert a MAC address to as 6 byte array' {
            $Result = Convert-MacToByte -MacAddress 'E2-5D-0E-B5-E2-E8'
            $Result.Count -eq 6 | Should -BeTrue
        }
        It 'Should accept MAC addresses with no spaces' {
            $Result = Convert-MacToByte -MacAddress '00000ABB28FC'
            $Result.Count -eq 6 | Should -BeTrue
        }
        It 'Should accept MAC addresses with 5x :' {
            $Result = Convert-MacToByte -MacAddress '00:00:0A:BB:28:FC'
            $Result.Count -eq 6 | Should -BeTrue
        }
        It 'Should accept MAC addresses with dashes' {
            $Result = Convert-MacToByte -MacAddress '00-00-0A-BB-28-FC'
            $Result.Count -eq 6 | Should -BeTrue
        }
        It 'Should throw an error on an incorrect MAC' {
            try {
                $Result = Convert-MacToByte -MacAddress '00:00:0A:BB:28:FG' -ErrorAction Stop
                $Success = $false
            } catch {
                $Success = $true
            }
            $Success | Should -BeTru
        }
    }
}