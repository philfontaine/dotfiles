function CreateDirectory($path) {
    New-Item -ItemType Directory -Path $path -ErrorAction SilentlyContinue
}

function GetVideos($match) {
    Get-ChildItem | Where-Object { $_.Length -gt 200KB -and $_.Name -match $match -and !$_.PSIsContainer }
}

function CopyVideos($videos, $destination) {
    foreach ($file in $videos) {
        Copy-Item $file.FullName -Destination $destination
    }
}

CreateDirectory "Root"
CreateDirectory "Fill"

$rootVideos = GetVideos "Root"
$fillVideos = GetVideos "Fill"

CopyVideos $rootVideos "Root"
CopyVideos $fillVideos "Fill"

