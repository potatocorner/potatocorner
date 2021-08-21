function sysinfo {
    $output = ""
    $machine = "."
    $compInfo = Get-wmiobject win32_computersystem -comp $machine
    $output += "COMPUTER INFO `r`n"
    $output += "===============`r`n"

    $output += "Ownername :" + $compinfo.PrimaryOwnerName + "`r`n"
    $output += "Name :" + $compinfo.name + "`r`n"
    $output += "Domain :" + $compinfo.domain + "`r`n"
    $output += "RAM :" + "{0:n2} GB" -f ($compinfo.TotalPhysicalMemory/1gb )
    $output += "`r`n"
     
    return $output
}

function driveInfo{
    $output = ""
    $machine = "."
    $output += "DISK INFO `r`n"
    $output += "===============`r`n"

    $logicalDisk = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" -ComputerName $machine
     
    foreach($disk in $logicalDisk)
    {
        $diskObj = "" | Select-Object Disk,Size,FreeSpace
        $diskObj.Disk = $disk.DeviceID
        $diskObj.Size = "{0:n0} GB" -f (($disk | Measure-Object -Property Size -Sum).sum/1gb)
        $diskObj.FreeSpace = "{0:n0} GB" -f (($disk | Measure-Object -Property FreeSpace -Sum).sum/1gb)

        $text = "{0}  {1}  Free: {2}" -f $diskObj.Disk,$diskObj.size,$diskObj.Freespace
        $output += $text + "`r`n"
    }
    return $output
}

function biosinfo {
    $output = ""
    $machine = "."
    $output += "BIOS INFO `r`n"
    $output += "===============`r`n"
    $biosInfo = Get-wmiobject win32_bios -comp $machine
    $output += "Name :" + $biosinfo.Name + "`r`n"
    $output += "Manufacturer :" + $biosinfo.Manufacturer + "`r`n"
    $output += "Serial No. :" + $biosinfo.SerialNumber+ "`r`n"
     
    return $output
}

function osinfo {
    $output = ""
    $machine = "."
    $output += "OS INFO `r`n"
    $output += "===============`r`n"
     
    $osInfo = get-wmiobject win32_operatingsystem -comp $machine

    $output += "OS Name:" + $osInfo.Caption + "`r`n"
    $output += "Service Pack:" + $osInfo.ServicePackMajorVersion + "`r`n"
    $output += "Windows Serial No.:" + $osInfo.SerialNumber + "`r`n"
    $output += "RegisteredUser:" + $osInfo.RegisteredUser + "`r`n"
 
    return $output
}

function cpuInfo {
    $machine = "."
    $output = ""
    $output += "CPU INFO LIST `r`n"
    $output += "===============`r`n"

    $cpuInfo = get-wmiobject win32_processor -comp $machine
    $output += "Name:" + $cpuInfo.Name + "`r`n"
    $output += "Caption:" + $cpuInfo.Caption + "`r`n"
    $output += "Manufacturer:" + $cpuInfo.Manufacturer + "`r`n"
    $output += "MaxClockSpeed:" + $cpuInfo.MaxClockSpeed + "`r`n"
  
    return $output
}

function productinfo {
    $output = ""
    $machine = "."
    $output += "PRODUCT INFO `r`n"
    $output += "===============`r`n"
     
    $productinfo = Get-wmiobject Win32_ComputerSystemProduct -comp $machine

    $output += "Vendor:" + $productinfo.Vendor + "`r`n"
    $output += "Version:" + $productinfo.Version + "`r`n"
    $output += "Model Name:" + $productinfo.Name + "`r`n"
    $output += "Serial No.:" + $productinfo.IdentifyingNumber + "`r`n"
 
    return $output
}

function localuser {
    $machine = "."
    $output = ""
    $output += "Local User `r`n"
    $output += "===============`r`n"

    $localuser = Get-WmiObject Win32_UserAccount -filter “LocalAccount=True” | Select-Object Name
    $output += "Name:" + $localuser.Name + "`r`n"
       
    return $output
}


$data1 = sysinfo
$data2 = driveInfo
$data3 = biosInfo
$data4 = osinfo
$data5 = cpuInfo
$data6 = Productinfo
$data7 = localUser

$finaloutput = $data1 + "`r`n" + $data2  + "`r`n" + $data3 + "`r`n" + $data4 +  "`r`n"  + $data5 +  "`r`n"  + $data6 +  "`r`n"  + $data7
 
write-host $finaloutput

$EmailTo = "inventory@potatocorner.com"
$EmailFrom = "it@potatocorner.com"
$Subject = "System Info"
$Body = $finaloutput
$SMTPServer = "smtp.gmail.com"
$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 25)
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 465)
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("inventory@potatocorner.com","1nv3ntory@dmin");
$SMTPClient.Send($SMTPMessage)