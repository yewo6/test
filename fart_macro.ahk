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

; ================= WALLPAPER URLS =================
wallpaperURLs := Object()
wallpaperURLs[1] := "https://raw.githubusercontent.com/yewo6/wallpapers/main/dog_fart.jpg"
wallpaperURLs[2] := "https://raw.githubusercontent.com/yewo6/wallpapers/main/dog_fart2.jpg"
wallpaperURLs[3] := "https://raw.githubusercontent.com/yewo6/wallpapers/main/hamster_fart.jpg"
wallpaperURLs[4] := "https://raw.githubusercontent.com/yewo6/wallpapers/main/fart_rainbow.jpg"
wallpaperURLs[5] := "https://raw.githubusercontent.com/yewo6/wallpapers/main/man_fart.jpg"
wallpaperURLs[6] := "https://raw.githubusercontent.com/yewo6/wallpapers/main/poop_fart.jpg"
wallpaperURLs[7] := "https://raw.githubusercontent.com/yewo6/wallpapers/main/must_fart.jpg"

; ================= SETUP FOLDERS =================
IfNotExist, %musicFolder%
    FileCreateDir, %musicFolder%
IfNotExist, %wallpaperFolder%
    FileCreateDir, %wallpaperFolder%

; ================= DOWNLOAD WALLPAPERS =================
for index, url in wallpaperURLs {
    SplitPath, url, , , , name
    localFile := wallpaperFolder "\" name
    ; force .jpg extension
    SplitPath, localFile, fileNameNoExt, dir
    localFile := dir "\" fileNameNoExt ".jpg"

    if !FileExist(localFile)
        DownloadFile(url, localFile)
}

; ================= DOWNLOAD MUSIC =================
musicFile := musicFolder "\music.mp3"
if !FileExist(musicFile)
    DownloadFile(musicURL, musicFile)

; ================= SET TIMERS =================
SetTimer, SpeakTimer, %speakInterval%
SetTimer, CalcTimer, %calcInterval%
SetTimer, MusicTimer, %musicInterval%
SetTimer, WallpaperTimer, %wallpaperInterval%
return

; ---------------- FUNCTIONS ----------------
SpeakTimer:
    Speak(msg, volume)
return

Speak(str, vol) {
    v := ComObjCreate("SAPI.SpVoice")
    v.Volume := vol
    v.Speak(str)
}

CalcTimer:
    Run, calc.exe
    WinWaitActive, Calculator
    WinMaximize, Calculator
    Sleep, 500
    Send, %numbersToType%
return

MusicTimer:
    wmp := ComObjCreate("WMPlayer.OCX")
    wmp.settings.volume := 50
    wmp.URL := musicFile
    wmp.controls.play
return

WallpaperTimer:
    images := []
    Loop, Files, %wallpaperFolder%\*.jpg
        images.Push(A_LoopFileFullPath)
    if (images.MaxIndex() = 0)
        return

    Random, r, 1, % images.MaxIndex()
    chosen := images[r]

    DllCall("SystemParametersInfo", UInt, 20, UInt, 0, Str, chosen, UInt, 3)
return

; ---------------- DOWNLOAD FUNCTION ----------------
DownloadFile(URL, SavePath) {
    xml := ComObjCreate("MSXML2.XMLHTTP")
    xml.Open("GET", URL, false)
    xml.Send()
    if (xml.Status = 200) {
        stream := ComObjCreate("ADODB.Stream")
        stream.Type := 1 ; Binary
        stream.Open()
        stream.Write(xml.ResponseBody)
        stream.SaveToFile(SavePath, 2) ; 2 = overwrite
        stream.Close()
    }
}
