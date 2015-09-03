
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

BotEnabled := false
ReadINI(OSDEnabled, "Prefs", "OSDEnabled", true)
ReadINI(ClickEnabled, "Prefs", "ClickEnabled", true)
ReadINI(ForceMouseMiddleEnabled, "Prefs", "ForceMouseMiddleEnabled", true)

ReadINI(TimewarpX        , "Button positions", "TimewarpX"          , 950)
ReadINI(TimewarpY        , "Button positions", "TimewarpY"          , 265)
ReadINI(ConfirmTimewarpX , "Button positions", "ConfirmTimewarpX"   , 402)
ReadINI(ConfirmTimewarpY , "Button positions", "ConfirmTimewarpY"   , 342)
ReadINI(UpgradePistolX   , "Button positions", "UpgradePistolX"     , 950)
ReadINI(UpgradePistolY   , "Button positions", "UpgradePistolY"     , 194)
ReadINI(IdleModeX        , "Button positions", "IdleModeX"          , 723)
ReadINI(IdleModeY        , "Button positions", "IdleModeY"          , 575)
ReadINI(MiddleX          , "Button positions", "MiddleX"            , 500)
ReadINI(MiddleY          , "Button positions", "MiddleY"            , 300)

ReadINI(WarpPeriodHour, "Warp", "WarpPeriodHour", 1)
WarpPeriod := 1000 * 60 * 60 * WarpPeriodHour
LastWarpTime :=

InitOSD()

; ----------
; INIT END
; ----------


; Press Windows + Escape to exit the script
#Esc::ExitApp

; Press Windows + Space to stop the bot
#Space::

  LastWarpTime :=
  SetTimer Timewarp, off
  SetTimer Upgrade, off
  SetTimer Fire, off

  BotEnabled := false
  return

; Press Windows + Enter to start the bot
; ATTENTION LANCER EN BUY MODE U ET AU TOUT DEBUT APRES UN WARP
#Enter::
  BotEnabled := true
  Gosub Timewarp
  return

; Press Windows + T to force a Timewarp immediately
#T::
  if(!BotEnabled)
  {
    MsgBox The bot must be enabled to force a Timewarp
    return
  }

  Gosub Timewarp

; Press Windows + Y to plan a Timewarp in X minutes
#Y::
  inputValue := Ceil(WarpPeriodHour * 60)
  InputBox, inputValue, Plan a Timewarp, Please enter the number of minutes that you want remaining in the run, , , , , , , , %inputValue%
  if(ErrorLevel != 0)
    return

  if inputValue is number
  {
    BotEnabled := true
    StartTimers(inputValue * 60 * 1000)

    LastWarpTime := A_Now
    seconds := Ceil(inputValue - WarpPeriodHour * 60)
    EnvAdd, LastWarpTime, %seconds%, minutes
  }
  else
  {
    MsgBox %inputValue% is not a number
  }

  return

#F2::
  OSDEnabled := !OSDEnabled
  WriteINI(OSDEnabled, "Prefs", "OSDEnabled")
  return

#F3::
  InputBox, inputValue, Modify Timewarp period, Please enter the number of hours you want to wait between two warps (This will not change the current run), , , , , , , , %WarpPeriodHour%
  if(ErrorLevel != 0)
    return

  if inputValue is number
  {
    WarpPeriodHour := inputValue
    WarpPeriod := 1000 * 60 * 60 * WarpPeriodHour
    WriteINI(WarpPeriodHour, "Warp", "WarpPeriodHour")
  }
  else
  {
    MsgBox %inputValue% is not a number
  }
  return

#F4::
  CalibrateButtons()
  return

#F5::
  ClickEnabled := !ClickEnabled
  WriteINI(ClickEnabled, "Prefs", "ClickEnabled")
  return

#F6::
  ForceMouseMiddleEnabled := !ForceMouseMiddleEnabled
  WriteINI(ForceMouseMiddleEnabled, "Prefs", "ForceMouseMiddleEnabled")
  return

Fire:
  if(ForceMouseMiddleEnabled)
    MouseMove %MiddleX%, %MiddleY%
  if(ClickEnabled)
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

  ; Upgrade Pistol & team
  Loop 30
  {
    Send asdfg
    ClickUnity(UpgradePistolX, UpgradePistolY)
    Sleep 10
  }

  Sleep 500

  ; Upgrade Powers & team
  Loop 10
  {
    Send asdfg
    ClickUnity(TimewarpX, TimewarpY)
    Sleep 100
  }

  Sleep 500

  ; Enable Idle Mode
  ClickUnity(IdleModeX, IdleModeY)
  MouseMove %MiddleX%, %MiddleY%
  Sleep 500

  StartTimers(WarpPeriod)

  return

StartTimers(nextWarpPeriod)
{
  global LastWarpTime

  LastWarpTime := A_Now

  SetTimer Upgrade, 1000
  SetTimer Fire, 10
  SetTimer Timewarp, %nextWarpPeriod%
}

InitOSD()
{
  global BotEnabledText
  global WarpPeriodText
  global ClickEnabledText
  global ForceMouseMiddleEnabledText
  global RemainingTimeText
  
  initText = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

  CustomColor = EEAA99
  Gui +LastFound +AlwaysOnTop -Caption +ToolWindow
  Gui, Color, %CustomColor%
  Gui, Font, s16  ; Set a large font size (32-point).
  Gui, Add, Text, vBotEnabledText cFF0000, %initText%
  Gui, Add, Text, cFF0000, [Space] Disable bot
  Gui, Add, Text, cFF0000, [T] Force timewarp
  Gui, Add, Text, cFF0000, [F2] Hide OSD
  Gui, Add, Text, vWarpPeriodText cFF0000, %initText%
  Gui, Add, Text, cFF0000, [F4] Calibrate buttons
  Gui, Add, Text, vClickEnabledText cFF0000, %initText%
  Gui, Add, Text, vForceMouseMiddleEnabledText cFF0000, %initText%
  Gui, Add, Text, cFF0000, [Escape] Exit script
  Gui, Add, Text, vRemainingTimeText cFF0000, %initText%
  ; Make all pixels of this color transparent and make the text itself translucent (150):
  WinSet, TransColor, %CustomColor% 200
  SetTimer, UpdateOSD, 200
  Gosub, UpdateOSD
}

UpdateOSD:
  if(OSDEnabled)
  {
    if(LastWarpTime)
    {
      elapsed := A_Now
      EnvSub, elapsed, %LastWarpTime%, seconds
      remaining := Ceil((WarpPeriod / 1000 - elapsed) / 60)
      GuiControl,, RemainingTimeText, Remaining time: %remaining%m
    }
    else
    {
      GuiControl,, RemainingTimeText, Remaining time: N/A
    }

    GuiControl,, BotEnabledText, [Enter] Bot enabled: %BotEnabled%
    GuiControl,, WarpPeriodText, [F3] Warp every: %WarpPeriodHour%h
    GuiControl,, ClickEnabledText, [F5] Click enabled: %ClickEnabled%
    GuiControl,, ForceMouseMiddleEnabledText, [F6] Force mouse middle enabled: %ForceMouseMiddleEnabled%

    Gui, Show, x0 y200 NoActivate

    DrawBox("Timewarp", TimewarpX, TimewarpY, 25, 25)
    DrawBox("IdleMode", IdleModeX, IdleModeY, 25, 25)
    DrawBox("ConfirmTimewarp", ConfirmTimewarpX, ConfirmTimewarpY, 25, 25)
    DrawBox("UpgradePistol", UpgradePistolX, UpgradePistolY, 25, 25)
    DrawBox("Middle", MiddleX, MiddleY, 25, 25)
  }
  else
  {
    Gui Hide
    RemoveBox("Timewarp")
    RemoveBox("IdleMode")
    RemoveBox("ConfirmTimewarp")
    RemoveBox("UpgradePistol")
    RemoveBox("Middle")
  }
  return

CalibrateButtons()
{
  global TimewarpX
  global TimewarpY
  global ConfirmTimewarpX
  global ConfirmTimewarpY
  global UpgradePistolX
  global UpgradePistolY
  global IdleModeX
  global IdleModeY
  global MiddleX
  global MiddleY

  MsgBox Target the Abilities / Timewarp button and press Enter
  MouseGetPos TimewarpX, TimewarpY
  MsgBox Target the Timewarp Confirmation button and press Enter
  MouseGetPos ConfirmTimewarpX, ConfirmTimewarpY
  MsgBox Target the Pistol Upgrade button and press Enter
  MouseGetPos UpgradePistolX, UpgradePistolY
  MsgBox Target the Idle Mode button and press Enter
  MouseGetPos IdleModeX, IdleModeY
  MsgBox Target the spot where you want to leave the mouse and press Enter
  MouseGetPos MiddleX, MiddleY

  WriteINI(TimewarpX        , "Button positions", "TimewarpX")
  WriteINI(TimewarpY        , "Button positions", "TimewarpY")
  WriteINI(ConfirmTimewarpX , "Button positions", "ConfirmTimewarpX")
  WriteINI(ConfirmTimewarpY , "Button positions", "ConfirmTimewarpY")
  WriteINI(UpgradePistolX   , "Button positions", "UpgradePistolX")
  WriteINI(UpgradePistolY   , "Button positions", "UpgradePistolY")
  WriteINI(IdleModeX        , "Button positions", "IdleModeX")
  WriteINI(IdleModeY        , "Button positions", "IdleModeY")
  WriteINI(MiddleX          , "Button positions", "MiddleX")
  WriteINI(MiddleY          , "Button positions", "MiddleY")
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
  global ClickEnabled

  CoordMode, Mouse, Screen
  MouseMove %x%, %y%
  if(ClickEnabled)
    Click %x%, %y%
}

ReadINI(ByRef outputVar, section, key, defaultValue)
{
  IniRead, outputVar, TimeBot.ini, %section%, %key%, %defaultValue%
  WriteINI(outputVar, section, key)
}

WriteINI(value, section, key)
{
  IniWrite, %value%, TimeBot.ini, %section%, %key%
}

DrawBox(id, X, Y, W, H, c="FF0000")
{
  thickness := 2

  Gui, %id%1: +ToolWindow -Caption +AlwaysOnTop +LastFound
  Gui, %id%2: +ToolWindow -Caption +AlwaysOnTop +LastFound
  Gui, %id%3: +ToolWindow -Caption +AlwaysOnTop +LastFound
  Gui, %id%4: +ToolWindow -Caption +AlwaysOnTop +LastFound

	Gui, %id%1: Color, % c
	Gui, %id%2: Color, % c
	Gui, %id%3: Color, % c
	Gui, %id%4: Color, % c

  x -= W // 2
  y -= H // 2

	Gui, %id%1: Show, % "x" X " y" Y " w" W " h" thickness " NA", Horizontal 1
	Gui, %id%2: Show, % "x" X " y" Y + H " w" W " h" thickness " NA", Horizontal 2
	Gui, %id%3: Show, % "x" X " y" Y " w" thickness " h" H " NA", Vertical 1
	Gui, %id%4: Show, % "x" X + W " y" Y " w" thickness " h" H " NA", Vertical 2
}

RemoveBox(id)
{
  Gui, %id%1: Destroy
  Gui, %id%2: Destroy
  Gui, %id%3: Destroy
  Gui, %id%4: Destroy
}

Min(x, y)
{
  if(x < y)
    return x
  else
    return y
}