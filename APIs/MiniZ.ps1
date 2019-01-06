﻿using module ..\Include.psm1

class MiniZ : Miner {
    [String[]]UpdateMinerData () {
        if ($this.GetStatus() -ne [MinerStatus]::Running) {return @()}

        $Server = "localhost"
        $Timeout = 10 #seconds

        $Request = '{"id":"0", "method":"getstat"}'
        $Response = ""

        $HashRate = [PSCustomObject]@{}

        try {
            $Response = Invoke-TcpRequest $Server $this.Port $Request $Timeout -ErrorAction Stop
            $Data = $Response | ConvertFrom-Json -ErrorAction Stop
        }
        catch {
            if ((Get-Date) -gt ($this.Process.PSBeginTime.AddSeconds(30))) {$this.SetStatus("Failed")}
            return @($Request, $Response)
        }

        $HashRate_Name = [String]$this.Algorithm[0]
        $HashRate_Value = [Double]($Data.result.speed_sps | Measure-Object -Sum).Sum
        $Accepted_Shares = [Double]($Data.result.accepted_shares | Measure-Object -Sum).Sum
        $Rejected_Shares = [Double]($Data.result.rejected_shares | Measure-Object -Sum).Sum

        if ($HashRate_Name -and $HashRate_Value -GT 0 -and ($Accepted_Shares -ge $Rejected_Shares * 10)) {$HashRate | Add-Member @{$HashRate_Name = [Int64]$HashRate_Value}} #Allow max. 10% rejected shares

        if ($HashRate | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Select-Object -ExpandProperty Name) {
            $this.Data += [PSCustomObject]@{
                Date       = (Get-Date).ToUniversalTime()
                Raw        = $Response
                HashRate   = $HashRate
                PowerUsage = (Get-PowerUsage $this)
                Device     = @()
            }
        }

        return @($Request, $Data | ConvertTo-Json -Compress)
    }
}
