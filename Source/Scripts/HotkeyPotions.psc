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
  float per = Player.GetActorValuePercentage(AV[i])
  float damage = Player.GetActorValueMax(AV[i]) * (1.0 - per)
  If(damage == 0)
    return
  EndIf
  bool reqdur = per > (MCM.fInstant[i] / 100)
  Form[] potions = 	PO3_SKSEFunctions.AddItemsOfTypeToArray(Player, 46, abNoQuestItem = true)
  ; Debug.Trace(self + "OnKeyDown() -> Player has Potions in inventory: " + potions.Length)
  float e = 10000.0 ; efficiency of the most efficient data. Closer to 0 = more efficient
  int idx ; Index of the most efficient in array
  int n = 0
  While(n < potions.Length)
    ; Debug.Trace(self + "OnKeyDown() -> Cycling..  " + n)
    Potion p = potions[n] as Potion
    If(!p.IsFood() && !p.IsHostile() && p.HasKeyword(PotionTypes[i]))
      int efxCount = p.GetNumEffects()
      If(MCM.bAllowImpure || efxCount == 1)
        int j = 0
        While (j < efxCount)
          float magn = p.GetNthEffectMagnitude(j)
          ; Check for Duration so HoT Potions are recognized properly
          If(reqdur)
            float dur = p.GetNthEffectDuration(j)
            If(dur > 1)
              magn *= dur
            EndIf
          EndIf
          float hp = damage - magn
          ; Debug.Trace(self + "OnKeyDown() -> Potion Nr " + n + " dur = " + dur + " magn = " + magn + " hp = " + hp)
          If(hp == 0.0 || hp > 9000 && per < 0.1)
            ; Cant get more efficient -> cancel out zzz
            ; Debug.Trace(self + "OnKeyDown() -> h = 0, Cancel Out")
            Player.EquipItemEx(p, equipSound = false)
            return
          ElseIf(hp > 0 || MCM.bAllowWaste)
            float ha = Math.abs(hp)
            If(ha < e)
              ; Debug.Trace(self + "OnKeyDown() -> Replacing old index with new one. Old e = " + e + " old ei = " + ei)
              e = ha
              idx = n
            EndIf
          EndIf
          j += 1
        EndWhile
      EndIf
    EndIf
    n += 1
  EndWhile
  ; Debug.Trace(self + "OnKeyDown() -> End of analytic. e = " + e)
  If(e < 10000.0)
    ; Debug.Trace(self + "OnKeyDown() -> Equipping " + potions[ei])
    Player.EquipItemEx(potions[idx], equipSound = false)
  EndIf
EndEvent