Scriptname HotkeyPotionsMCM extends SKI_ConfigBase

HotkeyPotions Property HP
  HotkeyPotions Function Get()
    return Quest.GetQuest("HotkeyPotions").GetNthAlias(0) as HotkeyPotions
  EndFunction
EndProperty

; Hotkey
int[] Property iHotkeys Auto Hidden

; Primary Attributes
bool Property bAllowWaste = true Auto Hidden
bool Property bAllowImpure = false Auto Hidden
float[] Property fInstant Auto Hidden

; =============================================================
; =============================== INIT
; =============================================================
int Function GetVersion()
  return 2
EndFunction

Event OnVersionUpdate(int a_version)
  If(a_version == 2)
    fInstant = new float[3]
    int n = 0
    While(n < fInstant.Length)
      fInstant[n] = 25
      n += 1
    EndWhile
  EndIf
EndEvent

Event OnConfigInit()
  ModName = "Hotkey Potions"
  Pages = new String[1]
  Pages[0] = "$HP_Config"

  iHotkeys = new int[5]
  int i = 0
  While(i < iHotkeys.Length)
    iHotkeys[i] = -1
    i += 1
  EndWhile

  fInstant = new float[3]
  int n = 0
  While(n < fInstant.Length)
    fInstant[n] = 25
    n += 1
  EndWhile
EndEvent

; =============================================================
; =============================== MENU
; =============================================================
Event OnPageReset(string page)
  SetCursorFillMode(TOP_TO_BOTTOM)
  AddHeaderOption("$HP_Hotkeys")
  int i = 0
  While(i < 3) ; iHotkeys.Length)
    AddKeyMapOptionST("HotkeyNr_" + i, "$HP_HotkeyKey_" + i, iHotkeys[i])
    i += 1
  EndWhile
  SetCursorPosition(1)
  AddHeaderOption("$HP_PrimAtt")
  AddToggleOptionST("AllowWaste", "$HP_AllowWaste", bAllowWaste)
  AddToggleOptionST("AllowImpure", "$HP_AllowImpure", bAllowImpure)
  int n = 0
  While(n < fInstant.Length)
    AddSliderOptionST("DisableTimed_" + n, "$HP_DisableTimed_" + n, fInstant[n], "{1}%")
    n += 1
  EndWhile
EndEvent

; =============================================================
; =============================== STATES
; =============================================================
Event OnSliderOpenST()
  String[] st = StringUtil.Split(GetState(), "_")
  If(st[0] == "DisableTimed")
    int i = st[1] as int
    SetSliderDialogStartValue(fInstant[i])
    SetSliderDialogDefaultValue(25)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(0.5)
  EndIf
EndEvent

Event OnSliderAcceptST(Float afValue)
  String[] st = StringUtil.Split(GetState(), "_")
  If(st[0] == "DisableTimed")
    int i = st[1] as int
    fInstant[i] = afValue
    SetSliderOptionValueST(fInstant[i])
  EndIf
EndEvent


Event OnKeyMapChangeST(Int aiNewKeyCode, String asConflictControl, String asConflictName)
  Bool bContinue = True
  If(aiNewKeyCode > 0)
    If(asConflictControl != "")
      String sMessage
      If(asConflictName != "")
        sMessage = "This key is already mapped to:\n" + asConflictControl + " (" + asConflictName + ")\nAre you sure you want to continue?"
      Else
        sMessage = "This key is already mapped to:\n" + asConflictControl + "\nAre you sure you want to continue?"
      EndIf
      bContinue = ShowMessage(sMessage, True, "$Yes", "$No")
    EndIf
  Else
    aiNewKeyCode = -1
  EndIf
  String[] st = StringUtil.Split(GetState(), "_")
  If(st[0] == "HotkeyNr")
    int i = st[1] as int
    iHotkeys[i] = aiNewKeyCode
    SetKeyMapOptionValueST(iHotkeys[i])
    HP.RegisterKeys()
  EndIf
EndEvent

Event OnDefaultST()
  String[] st = StringUtil.Split(GetState(), "_")
  If(st[0] == "HotkeyNr")
    int i = st[1] as int
    iHotkeys[i] = -1
    SetKeyMapOptionValueST(iHotkeys[i])
  ElseIf(st[0] == "DisableTimed")
    int i = st[1] as int
    fInstant[i] = 25
    SetSliderOptionValueST(fInstant[i])
  EndIf
EndEvent

Event OnHighlightST()
  String[] st = StringUtil.Split(GetState(), "_")
  If(st[0] == "HotkeyNr")
    int i = st[1] as int
    SetInfoText("$HP_HotkeyKeyHighlight_" + i)
  ElseIf(st[0] == "DisableTimed")
    int i = st[1] as int
    SetInfoText("$HP_DisableTimedHighlight_" + i)
  EndIf
EndEvent


State AllowWaste
  Event OnSelectST()
    bAllowWaste = !bAllowWaste
    SetToggleOptionValueST(bAllowWaste)
  EndEvent
  Event OnDefaultST()
    bAllowWaste = true
    SetToggleOptionValueST(bAllowWaste)
  EndEvent
  Event OnHighlightST()
    SetInfoText("$HP_AllowWasteHighlight")
  EndEvent
EndState

State AllowImpure
  Event OnSelectST()
    bAllowImpure = !bAllowImpure
    SetToggleOptionValueST(bAllowImpure)
  EndEvent
  Event OnDefaultST()
    bAllowImpure = false
    SetToggleOptionValueST(bAllowImpure)
  EndEvent
  Event OnHighlightST()
    SetInfoText("$HP_AllowImpureHighlight")
  EndEvent
EndState