<#
.SYNOPSIS

  Convert source image to 4K images for Wallpaper

.LINK 
	.Author

    Mikael Palmqvist, Gohybrid AB, 2023-nn-nn

    Version 0.1

#>


$imageSizes = @("1200x1920","2160x3840","3840x2160","768x1366","1366x768","2560x1600","5120x2880","1024x768","1600x2560","2844x1600","768x1024")

$sourcePath = "C:\Mijk\SourceImages"
$destinationPath = "C:\Mijk\DestinationImages"


foreach ($size in $imageSizes) {
    $sizeArr = $size.Split("x")
    $width = [int]$sizeArr[0]
    $height = [int]$sizeArr[1]
    Get-ChildItem $sourcePath -Filter *.jpg | ForEach-Object {
        $fileName = $_.Name  
        $newFileName = "{0}_{1}x{2}.jpg" -f $fileName.Replace(".jpg", ""), $width, $height
        $newFilePath = Join-Path $destinationPath $newFileName
        $image = [System.Drawing.Image]::FromFile($_.FullName)
        $newImage = New-Object System.Drawing.Bitmap $width, $height
        $graphics = [System.Drawing.Graphics]::FromImage($newImage)
        $graphics.DrawImage($image, 0, 0, $width, $height)
        $newImage.Save($newFilePath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
        $graphics.Dispose()
        $newImage.Dispose()
        $image.Dispose()

    }
}


