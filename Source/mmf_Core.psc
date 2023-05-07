scriptName mmf_Core extends ReferenceAlias
{
  Autor: Namarius
  Purpose: core functionality for MMF
}

; properties set by game engine
FormList property gTrackingList auto
Spell property gMilktrackerSpell auto

; public read only constants
string property cBASE = "mmf" autoReadOnly
string property cLEVEL = ".slider.level" autoReadOnly
string property cFILL = ".slider.fill" autoReadOnly
string property cSTOMACH = ".slider.stomach" autoReadOnly
string property cPAD = ".slider.pad" autoReadOnly

; public restricted read only constants
string property cMilk = ".milk" autoReadOnly
string property cProduction = ".production" autoReadOnly
string property cCapacity = ".capacity" autoReadOnly
string property cLactacid = ".lactacid" autoReadOnly
string property cPregnant = ".pregnant" autoReadOnly

; public restricted variables (must be initialized at init)
float property gMilkProductionSoftMin auto
float property gMilkProductionHardMin auto
float property gMilkProductionSoftMax auto
float property gMilkProductionHardMax auto

float property gMilkCapacitySoftMin auto
float property gMilkCapacityHardMin auto
float property gMilkCapacitySoftMax auto
float property gMilkCapacityHardMax auto

float property gLactacidDecayTime auto
float property gLactacidDecayMilkProduction auto

float property gLactacidMultMilkCapacity auto
float property gLactacidMultMilkProduction auto

float property gLactacidAddMilkProduction auto
float property gLactacidAddMilkCapacity auto

float property gLactacidSoftMax auto
float property gLactacidHardMax auto

; local global variables
int gSelectKey = 9

string cOptionsFile = "SKSE\\mmf_config.json"
string cOptionMilkProductionSoftMin = ".option.milk.production.min.soft"
string cOptionMilkProductionHardMin = ".option.milk.production.min.hard"
string cOptionMilkProductionSoftMax = ".option.milk.production.max.soft"
string cOptionMilkProductionHardMax = ".option.milk.production.max.hard"

string cOptionMilkCapacitySoftMin = ".option.milk.capacity.min.soft"
string cOptionMilkCapacityHardMin = ".option.milk.capacity.min.hard"
string cOptionMilkCapacitySoftMax = ".option.milk.capacity.max.soft"
string cOptionMilkCapacityHardMax = ".option.milk.capacity.max.hard"

string cOptionLactacidDecayTime = ".option.lactacid.decay.time"
string cOptionLactacidDecayMilkProdution = ".option.lactacid.decay.milk-production"

string cOptionLactacidMultMilkCapacity = ".option.lactacid.mult.capacity"
string cOptionLactacidMultMilkProduction = ".option.lactacid.mult.milk.production"

string cOptionLactacidAddMilkProduction = ".option.lactacid.add.milk.production"
string cOptionLactacidAddMilkCapacity = ".option.lactacid.add.milk.capacity"

string cOptionLactacidSoftMax = ".option.lactacid.max.soft"
string cOptionLactacidHardMax = ".option.lactacid.max.hard"

string[] gSliderLevelName
float[] gSliderLevelLow
float[] gSliderLevelHigh

string[] gSliderFillName
float[] gSliderFillLow
float[] gSliderFillHigh

string[] gSliderStomachName
float[] gSliderStomachLow
float[] gSliderStomachHigh

string[] gSliderPadName
float[] gSliderPadLow
float[] gSliderPadHigh

import mmf_Debug
import mmf_Domain

event OnInit()
  LogSrc("mmf_Core", "OnInit")
  ; JValue_enableAPILog(true)

  ReadOptionsFromFile()

  if gSelectKey != 0
    RegisterForKey(gSelectKey)
  endIf
endEvent

string[] function GetSliderNames(string pGroup)
  if pGroup == cLEVEL
    return gSliderLevelName
  elseif pGroup == cFILL
    return gSliderFillName
  elseif pGroup == cSTOMACH
    return gSliderStomachName
  elseif pGroup == cPAD
    return gSliderPadName
  endif
  
  Unreachable()
endFunction

float[] function GetSliderLow(string pGroup)
  if pGroup == cLEVEL
    return gSliderLevelLow
  elseif pGroup == cFILL
    return gSliderFillLow
  elseif pGroup == cSTOMACH
    return gSliderStomachLow
  elseif pGroup == cPAD
    return gSliderPadLow
  endif

  Unreachable()
endFunction

float[] function GetSliderHigh(string pGroup)
  if pGroup == cLEVEL
    return gSliderLevelHigh
  elseif pGroup == cFILL
    return gSliderFillHigh
  elseif pGroup == cSTOMACH
    return gSliderStomachHigh
  elseif pGroup == cPAD
    return gSliderPadHigh
  endif

  Unreachable()
endFunction

bool function isValidSliderGroup(string pGroup) 
  return pGroup == cLEVEL || \
  pGroup == cFILL || \
  pGroup == cSTOMACH || \
  pGroup == cPAD
endFunction

bool function AddSlider(string pGroup, string pName, float pLow, float pHigh)
  if isValidSliderGroup(pGroup)
    return addSliderByGroup(pGroup, pName, pLow, pHigh)
  endIf

  Unreachable()
  return false
endFunction

bool function RemoveSlider(string pGroup, string pName)
  if isValidSliderGroup(pGroup) 
    return RemoveSliderByGroup(pGroup, pName)
  endIf

  Unreachable()
  return false
endFunction

int function RenameSlider(string pGroup, string pOldName, string pNewName)
  if isValidSliderGroup(pGroup)
    return RenameSliderByGroup(pGroup, pOldName, pNewName)
  endIf

  Unreachable()
  return -1
endFunction

bool function ReplaceSliders(string pGroup, string[] pNames, float[] pLows, float[] pHighs)
  if isValidSliderGroup(pGroup) 
    return ReplaceSlidersByGroup(pGroup, pNames, pLows, pHighs)
  endIf

  Unreachable()
  return false
endFunction

bool function addSliderByGroup(string pGroup, string pName, float pLow, float pHigh)
  string[] names = getSliderNameByGroup(pGroup)
  float[] lows = getSliderLowByGroup(pGroup)
  float[] highs = getSliderHighByGroup(pGroup)

  
  int index = 0
  int maxIndex = names.Length

  while index < maxIndex
    if names[index] == pName
      lows[index] = pLow
      highs[index] = pHigh
      return true
    endif

    index += 1
  endWhile

  names = Utility.ResizeStringArray(names, maxIndex + 1, pName)
  lows = Utility.ResizeFloatArray(lows, maxIndex + 1, pLow)
  highs = Utility.ResizeFloatArray(highs, maxIndex + 1, pHigh)

  setSliderNameByGroup(pGroup, names)
  setSliderLowByGroup(pGroup, lows)
  setSliderHighByGroup(pGroup, highs)
  return true
endFunction

string[] function getSliderNameByGroup(string pGroup)
  if pGroup == cFILL
    return gSliderFillName
  elseIf pGroup == cLEVEL
    return gSliderLevelName
  elseIf pGroup == cSTOMACH
    return gSliderStomachName
  elseIf pGroup == cPAD
    return gSliderPadName
  endIf

  Unreachable()
endFunction

function setSliderNameByGroup(string pGroup, string[] pNames)
  if pGroup == cFILL
    gSliderFillName = pNames
    return
  elseIf pGroup == cLEVEL
    gSliderLevelName = pNames
    return
  elseIf pGroup == cSTOMACH
    gSliderStomachName = pNames
    return
  elseIf pGroup == cPAD
    gSliderPadName = pNames
    return
  endIf

  Unreachable()
endFunction

float[] function getSliderLowByGroup(string pType)
  if pType == cFILL
    return gSliderFillLow
  elseIf pType == cLEVEL
    return gSliderLevelLow
  elseIf pType == cSTOMACH
    return gSliderStomachLow
  elseIf pType == cPAD
    return gSliderPadLow
  endIf

  Unreachable()
endFunction

function setSliderLowByGroup(string pGroup, float[] pLow)
  if pGroup == cFILL
    gSliderFillLow = pLow
    return
  elseIf pGroup == cLEVEL
    gSliderLevelLow = pLow
    return
  elseIf pGroup == cSTOMACH
    gSliderStomachLow = pLow
    return
  elseIf pGroup == cPAD
    gSliderPadLow = pLow
    return
  endIf

  Unreachable()
endFunction

float[] function getSliderHighByGroup(string pGroup)
  if pGroup == cFILL
    return gSliderFillHigh
  elseIf pGroup == cLEVEL
    return gSliderLevelHigh
  elseIf pGroup == cSTOMACH
    return gSliderStomachHigh
  elseIf pGroup == cPAD
    return gSliderPadHigh
  endIf

  Unreachable()
endFunction

function setSliderHighByGroup(string pGroup, float[] pHigh)
  if pGroup == cFILL
    gSliderFillHigh = pHigh
    return
  elseIf pGroup == cLEVEL
    gSliderLevelHigh = pHigh
    return
  elseIf pGroup == cSTOMACH
    gSliderStomachHigh = pHigh
    return
  elseIf pGroup == cPAD
    gSliderPadHigh = pHigh
    return
  endIf

  Unreachable()
endFunction

bool function RemoveSliderByGroup(string pGroup, string pName)
  string[] names = getSliderNameByGroup(pGroup)
  float[] lows = getSliderLowByGroup(pGroup)
  float[] highs = getSliderHighByGroup(pGroup)
  int index = 0
  int maxIndex = names.Length

  bool copy = false
  bool found = false

  while index < maxIndex
    if copy 
      names[index - 1] = names[index]
      lows[index - 1] = lows[index]
      highs[index - 1] = highs[index]
    elseIf names[index] == pName
      copy = true
      found = true
    endif

    index += 1
  endWhile

  if found 
    names = Utility.ResizeStringArray(names, maxIndex - 1)
    lows = Utility.ResizeFloatArray(lows, maxIndex - 1)
    highs = Utility.ResizeFloatArray(highs, maxIndex - 1)
  endIf

  setSliderNameByGroup(pGroup, names)
  setSliderLowByGroup(pGroup, lows)
  setSliderHighByGroup(pGroup, highs)

  return found
endfunction

bool function ReplaceSlidersByGroup(string pGroup, string[] pNames, float[] pLows, float[] pHighs)
  int min = pNames.Length
  int b = pLows.Length
  int c = pHighs.Length

  bool unequal = false

  if min > b
    unequal = true
    min = b
  elseIf min > c
    unequal = true
    min = c
  endIf

  if unequal
    pNames = Utility.ResizeStringArray(pNames, min)
    pLows = Utility.ResizeFloatArray(pLows, min)
    pHighs = Utility.ResizeFloatArray(pHighs, min)
  endIf

  setSliderNameByGroup(pGroup, pNames)
  setSliderHighByGroup(pGroup, pHighs)
  setSliderLowByGroup(pGroup, pLows)

  return true
endFunction

int function RenameSliderByGroup(string pGroup, string pOldName, string pNewName)
  string[] names = getSliderNameByGroup(pGroup)
  int index = 0
  int oldIndex = -1
  int newIndex = -1
  int indexMax = names.Length

  while index < indexMax
    if names[index] == pOldName
      oldIndex = index
    endif

    if names[index] == pNewName
      newIndex = index
    endif

    index += 1
  endWhile

  if oldIndex < 0
    return -1
  endIf

  if oldIndex >= 0 && newIndex < 0
    names[oldIndex] = pNewName
    return oldIndex
  endIf

  setSliderNameByGroup(pGroup, names)
  RemoveSliderByGroup(pGroup, pNewName)
  names = getSliderNameByGroup(pGroup)
  names[oldIndex] = pNewName
  setSliderNameByGroup(pGroup, names)

  return oldIndex
endFunction

;---------------------------
; select and interaction key
;---------------------------

int function GetSelectKey()
  return gSelectKey
endFunction

function SetSelectKey(int pKeyCode) 
  UnregisterForAllKeys()
  
  gSelectKey = pKeyCode

  if gSelectKey != 0
    RegisterForKey(gSelectKey)
  endIf
endFunction

event OnKeyUp(int pKeyCode, float pHoldTime) 
  if Utility.IsInMenuMode() 
    return
  endIf

  ObjectReference ref = Game.GetCurrentCrosshairRef()

  if ref != None
    Debug.MessageBox("Reference is: " + ref)
    Actor act = ref as Actor
    if act != None && !act.HasSpell(gMilktrackerSpell)
      LogSrc("mmf_Core", "act="+act)
      act.AddSpell(gMilktrackerSpell, false)
    endIf
  endIf

endEvent

;--
; Actor Tracking
;--

function AddTrackingActor(Actor pActor)
  int id = pActor.GetFormID()
  LogSrc("mmf_Core", "AddTrackingActor:id=" + id)
  if id <= 0xFF000000
    return
  endIf

  if gTrackingList.HasForm(pActor) 
    return
  endIf

  int obj = JFormDB_makeEntry(cBase, pActor)
  JValue_solveFltSetter(obj, cMilk, 0.0, true)
  JValue_solveFltSetter(obj, cProduction, gMilkProductionSoftMin, true)
  JValue_solveFltSetter(obj, cCapacity, gMilkCapacitySoftMin, true)
  JValue_solveFltSetter(obj, cLactacid, 0.0, true)
  JValue_solveIntSetter(obj, cPregnant, 0, true)
  gTrackingList.AddForm(pActor)
  updateActor(pActor)
endFunction

function RemoveDirtyTrackingActor(Actor pActor)
  gTrackingList.RemoveAddedForm(pActor)
endFunction

function RemoveCleanTrackingActor(Actor pActor)
  if !gTrackingList.HasForm(pActor)
    return
  endIf
  
  gTrackingList.RemoveAddedForm(pActor)
  cleanActor(pActor)

  JFormDB_setEntry(cBASE, pActor, 0)
endFunction

float function fltMinMax(float pValue, float pMin, float pMax)
  if pValue < pMin
    pValue = pMin
  endIf
  if pValue > pMax
    pValue = pMax
  endIf

  return pValue
endFunction

function updateActorSlider(Actor pActor, float pValue, string pGroup)
  string[] names = getSliderNameByGroup(pGroup)
  float[] lows = getSliderLowByGroup(pGroup)
  float[] highs = getSliderHighByGroup(pGroup)

  LogSrc("mmf_Core", "updateActorSlider:group="+pGroup+",pValue="+pValue)

  int index = names.Length - 1
  float value
  while index >= 0
    value = ((highs[index] - lows[index]) * pValue) + lows[index]
    LogSrc("mmf_Core", "updateActorSlider:actor=" + pActor + ",name=" + names[index] + ",key=" + "mmf"+pGroup + ",value=" + value)
    NiOverride.SetBodyMorph(pActor, names[index], "mmf"+pGroup, value)
    index -= 1
  endWhile
endFunction

function updateActor(Actor pActor)
  int obj = JFormDB_findEntry(cBASE, pActor)
  if obj == 0
    return
  endIf

  float milk = JValue_solveFlt(obj, cMilk)
  float capacity = JValue_solveFlt(obj, cCapacity)
  float lactacid = JValue_solveFlt(obj, cLactacid)

  float capacityScale = gMilkCapacitySoftMax - gMilkCapacitySoftMin

  float normMilk = 0.0
  float normCapacity = 0.0
  float normLactacid = 0.0

  if capacity > 0.0
    normMilk = fltMinMax(milk / capacity, 0.0, 1.0)
  endIf

  if capacityScale > 0.0
    normCapacity = fltMinMax((capacity - gMilkCapacitySoftMin) / capacityScale, 0.0, 1.0)
  endIf

  if gLactacidSoftMax > 0.0
    normLactacid = fltMinMax(lactacid / gLactacidSoftMax, 0.0, 1.0)
  endIf

  updateActorSlider(pActor, normMilk, cFILL)
  updateActorSlider(pActor, normCapacity, cLEVEL)
  updateActorSlider(pActor, normLactacid, cPAD)
  NiOverride.UpdateModelWeight(pActor)
endFunction

function cleanActor(Actor pActor)
  NiOverride.ClearBodyMorphKeys(pActor, cBASE + cFILL)
  NiOverride.ClearBodyMorphKeys(pActor, cBASE + cLEVEL)
  NiOverride.ClearBodyMorphKeys(pActor, cBASE + cPAD)
  NiOverride.UpdateModelWeight(pActor)
endFunction

int function GetTrackedActorCount()
  return gTrackingList.GetSize()
endFunction

Actor function GetTrackedActor(int pIndex)
  if pIndex >= gTrackingList.GetSize() || pIndex < 0
    return None
  endIf

  return gTrackingList.GetAt(pIndex) as Actor
endFunction

function UpdateActorByIndex(int pIndex)
  Actor act = GetTrackedActor(pIndex)
  if act != None 
    updateActor(act)
  endIf
endFunction
;---
;
;---

string cName = "name"
string cLow = "low"
string cHigh = "high"

function ReadOptionsSlidersFromObj(int obj, string pName)
  int arr = JValue_solveObj(obj, pName);JMap_getObj(obj, pName)

  if arr != 0
    string[] sliderName = Utility.CreateStringArray(0)
    float[] sliderLow = Utility.CreateFloatArray(0)
    float[] sliderHigh = Utility.CreateFloatArray(0)
    int index = 0
    int maxIndex = JArray_count(arr)
    int entry = 0

    while index < maxIndex
      entry = JArray_getObj(arr, index)
      if entry != 0
        sliderName = Utility.ResizeStringArray(sliderName, sliderName.Length + 1, JMap_getStr(entry, cName))
        sliderLow = Utility.ResizeFloatArray(sliderLow, sliderLow.Length + 1, JMap_getFlt(entry, cLow))
        sliderHigh = Utility.ResizeFloatArray(sliderHigh, sliderHigh.Length + 1, JMap_getFlt(entry, cHigh))
      endIf

      index += 1
    endWhile

    if pName == cFILL
      gSliderFillName = sliderName
      gSliderFillLow = sliderLow
      gSliderFillHigh = sliderHigh
    elseif pName == cLEVEL
      gSliderLevelName = sliderName
      gSliderLevelLow = sliderLow
      gSliderLevelHigh = sliderHigh
    elseif pName == cSTOMACH
      gSliderStomachName = sliderName
      gSliderStomachLow = sliderLow
      gSliderStomachHigh = sliderHigh
    elseif pName == cPAD
      gSliderPadName = sliderName
      gSliderPadLow = sliderLow
      gSliderPadHigh = sliderHigh
    else
      Unreachable()
    endif
  endIf
endFunction

function ReadOptionsFromFile()
  int obj = JValue_readFromFile(cOptionsFile)

  gMilkCapacitySoftMin = JValue_solveFlt(obj, cOptionMilkCapacitySoftMin, 1.0)
  gMilkCapacityHardMin = JValue_solveFlt(obj, cOptionMilkCapacityHardMin, 0.5)

  gMilkCapacitySoftMax = JValue_solveFlt(obj, cOptionMilkCapacitySoftMax, 8.0)
  gMilkCapacityHardMax = JValue_solveFlt(obj , cOptionMilkCapacityHardMax, 10.0)
  

  gMilkProductionSoftMin = JValue_solveFlt(obj, cOptionMilkProductionSoftMin, 0.1)
  gMilkProductionHardMin = JValue_solveFlt(obj, cOptionMilkProductionHardMin, 0.0)

  gMilkProductionSoftMax = JValue_solveFlt(obj, cOptionMilkProductionSoftMax, 8.0)
  gMilkProductionHardMax = JValue_solveFlt(obj, cOptionMilkProductionHardMax, 10.0)


  gLactacidSoftMax = JValue_solveFlt(obj, cOptionLactacidSoftMax, 8.0)
  gLactacidHardMax = JValue_solveFlt(obj, cOptionLactacidHardMax, 8.0)

  gLactacidDecayTime = JValue_solveFlt(obj, cOptionLactacidDecayTime, 1.0)
  gLactacidDecayMilkProduction = JValue_solveFlt(obj, cOptionLactacidDecayMilkProdution, 0.25)

  gLactacidMultMilkCapacity = JValue_solveFlt(obj, cOptionLactacidMultMilkCapacity, 0.03)
  gLactacidMultMilkProduction = JValue_solveFlt(obj, cOptionLactacidMultMilkProduction, 0.5)

  gLactacidAddMilkCapacity = JValue_solveFlt(obj, cOptionLactacidAddMilkCapacity, 0.0)
  gLactacidAddMilkProduction = JValue_solveFlt(obj, cOptionLactacidAddMilkProduction, 0.0)

  string[] sliderName = Utility.CreateStringArray(0)
  float[] sliderLow = Utility.CreateFloatArray(0)
  float[] sliderHigh = Utility.CreateFloatArray(0)

  int arr = 0
  
  ReadOptionsSlidersFromObj(obj, cLEVEL)
  ReadOptionsSlidersFromObj(obj, cFILL)
  ReadOptionsSlidersFromObj(obj, cSTOMACH)
  ReadOptionsSlidersFromObj(obj, cPAD)

  JValue_zeroLifetime(obj)
endFunction

function WriteOptionsSlidersToObj(int obj, string pName, string[] pNames, float[] pLows, float[] pHighs)
  int arr = JArray_object()
  int entry = 0
  int index = 0
  int maxIndex = pNames.Length

  while index < maxIndex
    entry = JMap_object()

    JMap_setStr(entry, cName, pNames[index])
    JMap_setFlt(entry, cLow, pLows[index])
    JMap_setFlt(entry, cHigh, pHighs[index])

    JArray_addObj(arr, entry)

    index += 1
  endWhile

  JValue_solveObjSetter(obj, pName, arr, true)
endFunction

function WriteOptionsToFile()
  int obj = JMap_object()

  LogSrc("mmf_Core", "WriteOptionsToFile:obj=" + obj)

  if obj == 0
    Fatal("couldn't create JMap_object")
    return
  endIf

  JValue_solveFltSetter(obj, cOptionMilkCapacitySoftMin, gMilkCapacitySoftMin, true)
  JValue_solveFltSetter(obj, cOptionMilkCapacityHardMin, gMilkCapacityHardMin, true)

  JValue_solveFltSetter(obj, cOptionMilkCapacitySoftMax, gMilkCapacitySoftMax, true)
  JValue_solveFltSetter(obj, cOptionMilkCapacityHardMax, gMilkCapacityHardMax, true)


  JValue_solveFltSetter(obj, cOptionMilkProductionSoftMin, gMilkProductionSoftMin, true)
  JValue_solveFltSetter(obj, cOptionMilkProductionSoftMax, gMilkProductionSoftMax, true)

  JValue_solveFltSetter(obj, cOptionMilkProductionSoftMax, gMilkProductionSoftMax, true)
  JValue_solveFltSetter(obj, cOptionMilkProductionHardMax, gMilkProductionHardMax, true)


  JValue_solveFltSetter(obj, cOptionLactacidSoftMax, gLactacidSoftMax, true)
  JValue_solveFltSetter(obj, cOptionLactacidHardMax, gLactacidHardMax, true)

  JValue_solveFltSetter(obj, cOptionLactacidDecayTime, gLactacidDecayTime, true)
  JValue_solveFltSetter(obj, cOptionLactacidDecayMilkProdution, gLactacidDecayMilkProduction, true)

  JValue_solveFltSetter(obj, cOptionLactacidMultMilkCapacity, gLactacidMultMilkCapacity, true)
  JValue_solveFltSetter(obj, cOptionLactacidMultMilkProduction, gLactacidMultMilkProduction, true)

  JValue_solveFltSetter(obj, cOptionLactacidAddMilkProduction, gLactacidAddMilkProduction, true)
  JValue_solveFltSetter(obj, cOptionLactacidAddMilkCapacity, gLactacidAddMilkCapacity, true)


  WriteOptionsSlidersToObj(obj, cFILL, gSliderFillName, gSliderFillLow, gSliderFillHigh)
  WriteOptionsSlidersToObj(obj, cLEVEL, gSliderLevelName, gSliderLevelLow, gSliderLevelHigh)
  WriteOptionsSlidersToObj(obj, cSTOMACH, gSliderStomachName, gSliderStomachLow, gSliderStomachHigh)
  WriteOptionsSlidersToObj(obj, cPAD, gSliderPadName, gSliderPadLow, gSliderPadHigh)

  LogSrc("mmf_Core", "to file:" + cOptionsFile)
  JValue_writeToFile(obj, cOptionsFile)
  
  JValue_zeroLifetime(obj)
endFunction
