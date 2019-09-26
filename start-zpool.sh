#!/bin/bash

pwsh -command ".\multipoolminer.ps1 -Wallet 1Q24z7gHPDbedkaWDTFqhMF8g7iHMehsCb -UserName aaronsace -WorkerName multipoolminer -Region europe -Currency btc,usd,eur -DeviceName amd,nvidia,cpu -PoolName zpool -Donate 24 -Watchdog -MinerStatusURL https://multipoolminer.io/monitor/miner.php -SwitchingPrevention 2"