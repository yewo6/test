#Persistent
#NoEnv
SetBatchLines, -1

; ================= SETTINGS =================
speakInterval     := 1000 * 60 * 15       ; 15 minutes
calcInterval      := 1000 * 60 * 50       ; 50 minutes
musicInterval     := 1000 * 60 * 32       ; 32 minutes
wallpaperInterval := 1000 * 60 * 10       ; 10 minutes
volume            := 20
msg               := "penis"
numbersToType     := "67"
musicURL          := "http://archive.org/download/BigBillBroonzyHowYouWantItDone/BigBillBroonzy-HowYouWantItDone.mp3"
musicFolder       := "C:\soundsfolderthing"
wallpaperFolder   := "C:\wallpaperthing"

; GitHub raw URLs for wallpapers
wallpaperURLs := Object()
wallpaperURLs[1] := "https://github.com/yewo6/wallpapers/blob/main/dog_fart.jpg?raw=true"
wallpaperURLs[2] := "https://github.com/yewo6/wallpapers/blob/main/dog_fart2.jpg?raw=true"
wallpaperURLs[3] := "https://github.com/yewo6/wallpapers/blob/main/hamster_fart.jpg?raw=true"
wallpaperURLs[4] := "https://github.com/yewo6/wallpapers/blob/main/fart_rainbow.jpg?raw=true"
wallpaperURLs[5] := "https://github.com/yewo6/wallpapers/blob/main/man_fart.jpg?raw=true"
wallpaperURLs[6] := "https://github.com/yewo6/wallpapers/blob/main/poop_fart.jpg?raw=true"
wallpaperURLs[7] := "https://github.com/yewo6/wallpapers/blob/main/must_fart.jpg?raw=true"
; ============================================

; ---------------- SETUP FOLDERS ----------------
IfNotExist, %musicFolder%
    FileCreateDir, %musicFolder%

IfNotExist, %wallpaperFolder%
    FileCreateDir, %wallpaperFolder%

; ---------------- DOWNLOAD WALLPAPERS FROM GITHUB IF NOT ALREADY ----------------
for index, url in wallpaperURLs {
    ; Extract a file name from the URL — take the part after last "/"
    SplitPath, url, , , , name
    ; Remove query `?raw=true` if present
    StringSplit, parts, name, `?
    localFile := wallpaperFolder "\" parts1

    ; If file doesn't already exist locally, download it
    if !FileExist(localFile) {
        URLDownloadToFile, %url%, %localFile%
    }
}

; ---------------- SET TIMERS ----------------
SetTimer, SpeakTimer, %speakInterval%
SetTimer, CalcTimer, %calcInterval%
SetTimer, MusicTimer, %musicInterval%
SetTimer, WallpaperTimer, %wallpaperInterval%
return

; ---------------- SPEAK ----------------
SpeakTimer:
    Speak(msg, volume)
return

Speak(str, vol) {
    v := ComObjCreate("SAPI.SpVoice")
    v.Volume := vol
    v.Speak(str)
}

; ---------------- CALCULATOR ----------------
CalcTimer:
    Run, calc.exe
    WinWaitActive, Calculator
    WinMaximize, Calculator
    Sleep, 500
    Send, %numbersToType%
return

; ---------------- MUSIC ----------------
MusicTimer:
    filePath := musicFolder "\music.mp3"
    ; Download music every time (overwrite)
    URLDownloadToFile, %musicURL%, %filePath%
    wmp := ComObjCreate("WMPlayer.OCX")
    wmp.settings.volume := 50
    wmp.URL := filePath
    wmp.controls.play
return

; ---------------- WALLPAPER ----------------
WallpaperTimer:
    images := []
    Loop, Files, %wallpaperFolder%\*.jpg,%wallpaperFolder%\*.png
        images.Push(A_LoopFileFullPath)
    if (images.MaxIndex() = 0)
        return  ; no wallpapers found

    Random, r, 1, % images.MaxIndex()
    chosen := images[r]

    ; Change wallpaper
    DllCall("SystemParametersInfo", UInt, 20, UInt, 0, Str, chosen, UInt, 3)
return
