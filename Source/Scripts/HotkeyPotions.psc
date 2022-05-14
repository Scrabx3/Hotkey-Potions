Scriptname HotkeyPotions extends ReferenceAlias

HotkeyPotionsMCM Property HPMCM
  HotkeyPotionsMCM Function Get()
    return GetOwningQuest() as HotkeyPotionsMCM
  EndFunction
EndProperty

Actor Player
Keyword[] PotionTypes
String[] AV

Event OnInit()
  Player = Game.GetPlayer()

  PotionTypes = new Keyword[3]
  PotionTypes[0] = Keyword.GetKeyword("MagicAlchRestoreHealth")
  PotionTypes[1] = Keyword.GetKeyword("MagicAlchRestoreStamina")
  PotionTypes[2] = Keyword.GetKeyword("MagicAlchRestoreMagicka")

  AV = new String[3]
  AV[0] = "Health"
  AV[1] = "Stamina"
  AV[2] = "Magicka"
EndEvent

Event OnPlayerLoadGame()
  RegisterKeys()
EndEvent

Function RegisterKeys()
  UnregisterForAllKeys()
  int i = 0
  While(i < 3)
    RegisterForKey(HPMCM.iHotkeys[i])
    i += 1
  EndWhile
EndFunction

Event OnKeyDown(int keyCode)
  ; Ignore Inputs while in some Menu or controls are disabled
  If(UI.IsMenuOpen("Dialogue Menu") || Utility.IsInMenuMode() || !Game.IsLookingControlsEnabled())
    ; Debug.Trace(self + "OnKeyDown() -> Player in Menu")
    return
  EndIf
  HotkeyPotionsMCM MCM = HPMCM
  ; Get the Key Index we registered for
  int i = MCM.iHotkeys.Find(keyCode)
  ; Debug.Trace(self + "OnKeyDown() -> request = " + i)
  ; And look if the Player is actually damage :)
  float per = Player.GetActorValuePercentage(AV[i])
  float damage = Player.GetActorValueMax(AV[i]) * (1.0 - per)
  ; Debug.Trace(self + "OnKeyDown() -> damage = " + damage + " = " + Player.GetActorValueMax(AV[i]) + " * 1 - " + Player.GetActorValuePercentage(AV[i]))
  If(damage == 0)
    return
  EndIf
  bool reqdur = per > (MCM.fInstant[i] / 100)
  ; Then look for the Potion to apply
  Form[] potions = 	PO3_SKSEFunctions.AddItemsOfTypeToArray(Player, 46, abNoQuestItem = true)
  ; Debug.Trace(self + "OnKeyDown() -> Player has Potions in inventory: " + potions.Length)
  float e = 10000.0 ; e for efficiency!
  int ei ; e index!
  int n = 0
  While(n < potions.Length)
    ; Debug.Trace(self + "OnKeyDown() -> Cycling..  " + n)
    Potion p = potions[n] as Potion
    If(!p.IsFood() && p.GetNumEffects() == 1 && p.HasKeyword(PotionTypes[i]))
      ; Check for Duration so HoT Potions are recognized properly
      float s = p.GetNthEffectMagnitude(0)
      If(reqdur)
        float d = p.GetNthEffectDuration(0)
        If(d > 1)
          s *= d
        EndIf
      EndIf
      float h = damage - s
      ; Debug.Trace(self + "OnKeyDown() -> Potion Nr " + n + " d = " + d + " s = " + s + " h = " + h)
      If(h == 0.0 || h > 9000 && per < 0.1)
        ; Debug.Trace(self + "OnKeyDown() -> h = 0, Cancel Out")
        ; No point continuing if you we already found a potion that is healing you to 100%
        Player.EquipItemEx(p, equipSound = false)
        return
      ElseIf(h > 0 || MCM.bAllowWaste)
        float ha = Math.abs(h)
        ; Debug.Trace(self + "OnKeyDown() -> Checking efficiency; ha = " + ha)
        If(ha < e)
          ; Debug.Trace(self + "OnKeyDown() -> Replacing old index with new one. Old e = " + e + " old ei = " + ei)
          e = ha
          ei = n
        EndIf
      EndIf      
    EndIf
    n += 1
  EndWhile
  ; Debug.Trace(self + "OnKeyDown() -> End of analytic. e = " + e)
  If(e < 10000.0)
    ; Debug.Trace(self + "OnKeyDown() -> Equipping " + potions[ei])
    Player.EquipItemEx(potions[ei], equipSound = false)
  EndIf
EndEvent