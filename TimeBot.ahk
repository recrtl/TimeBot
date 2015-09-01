
; ----------
; INIT START
; ----------

#SingleInstance force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

CoordMode Pixel, Screen
CoordMode Mouse, Screen

Stop := true

FrameWidth      := 1000
FrameHeight     := 600

Achievments           = %A_ScriptDir%\images\achievments.png

OffsetX := 0
OffsetY := 0
ScaleX  := 1.0
ScaleY  := 1.0

AchievmentsCornerX    := 10
AchievmentsCornerY    := 9
TimewarpX             := 950
TimewarpY             := 265
ConfirmTimewarpX      := 402
ConfirmTimewarpY      := 342
UpgradePistolX        := 950
UpgradePistolY        := 194
IdleModeX             := 723
IdleModeY             := 575

WarpPeriod := 1000 * 60 * 60 * 2
;WarpPeriod := 1000 * 5

; ----------
; INIT END
; ----------


; Press Windows + R to reload the script
#r::
  Msgbox, Do you really want to reload this script?
  ifMsgBox Yes
    Reload
  return
 
; Press Windows + Escape to exit the script
#Esc::ExitApp

; Press Windows + Space to stop the bot
#Space::
  Stop := true
  return
 
; Press Windows + Enter to start the bot
; ATTENTION LANCER EN BUY MODE U ET AU TOUT DEBUT APRES UN WARP
#Enter::
  Stop := false
  InitWindowSize()

  SetTimer Timewarp, -1
  
  Loop
  {
    Sleep 10
    if Stop
      break
  }
  
  SetTimer Timewarp, off
  SetTimer Upgrade, off
  SetTimer Fire, off
  
  return

; Press Windows + T to force a Timewarp
#T::
  if(Stop)
    return
  SetTimer Timewarp, -1
  
Fire:
  MouseMove %MiddleX%, %MiddleY%
  MouseClick
  return
  
Upgrade:
  Send asdfg
  Send 1234567890
  return

Timewarp:
  SetTimer Upgrade, off
  SetTimer Fire, off
  
  ClickUnity(TimewarpX, TimewarpY)
  Sleep 100
  ClickUnity(ConfirmTimewarpX, ConfirmTimewarpY)
  Sleep 2000
  
  ; Upgrade Pistol
  Loop 100
  {
    ClickUnity(UpgradePistolX, UpgradePistolY)
    Sleep 10
  }
    
  Sleep 500
  
  ; Upgrade Powers
  Loop 10
  {
    ClickUnity(TimewarpX, TimewarpY)
    Sleep 100
  }
    
  Sleep 500
  
  ; Enable Idle Mode
  Send asdfg
  Sleep 500
  ClickUnity(IdleModeX, IdleModeY)
  Sleep 500
  
  SetTimer Upgrade, 1000
  SetTimer Fire, 10
  SetTimer Timewarp, %WarpPeriod%
  
  return

InitWindowSize()
{
  global Achievments
  global FrameWidth
  global FrameHeight
  global AchievmentsCornerX    
  global AchievmentsCornerY
  global OffsetX
  global OffsetY
  global ScaleX
  global ScaleY
  global MiddleX
  global MiddleY
  
  if(ImageSearchScreen(Achievments, x, y))
  {
    ; WINDOWED
    OffsetX := x - AchievmentsCornerX
    OffsetY := y - AchievmentsCornerY
    ScaleX := 1
    ScaleY := 1
    MiddleX := OffsetX + FrameWidth // 2
    MiddleY := OffsetY + FrameHeight // 2
  }
  else
  {
    ; FULLSCREEN
    OffsetX := 0
    OffsetY := 0
    ScaleX := A_ScreenWidth / FrameWidth
    ScaleY := A_ScreenHeight / FrameHeight
    MiddleX := A_ScreenWidth // 2
    MiddleY := A_ScreenHeight // 2
  }
}

ImageSearchScreen(ImageFile, ByRef xRef, ByRef yRef)
{
  ImageSearch xRef, yRef, 0, 0, A_ScreenWidth, A_ScreenHeight, %ImageFile%
  if(ErrorLevel = 2)
  {
    MsgBox Error while searching for %ImageFile%
    ExitApp
    return false
  }
  if(ErrorLevel = 0)
  {
    return true
  }
  return false
}
 
ClickUnity(x, y)
{
  global OffsetX
  global OffsetY
  global ScaleX
  global ScaleY
  
  CoordMode, Mouse, Screen
  x := OffsetX + ScaleX * x
  y := OffsetY + ScaleY * y
  MouseMove %x%, %y%
  Click %x%, %y%
}
