$length = 25

$CS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!"#¤%&/()'.ToCharArray()
 
$range = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
$bytes = New-Object byte[]($length)
$range.GetBytes($bytes)
$res = New-Object char[]($length)

    for ($i = 0 ; $i -lt $length ; $i++) {
    $res[$i] = $charSet[$bytes[$i]%$charSet.Length]
    }
    return -join $res
