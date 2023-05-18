scriptName mmf_Core extends ReferenceAlias
{
  Autor: Namarius
  Purpose: core functionality for MMF
}

; properties set by game engine
FormList property gTrackingList auto
Spell property gMilktrackerSpell auto
GlobalVariable property gGameTime auto

; public read only constants
string property cBASE = "mmf" autoReadOnly

string property cMILK_CAPACITY_SLIDER = ".slider.milk-capacity" autoReadOnly
string property cMILK_FILLING_SLIDER = ".slider.milk-filling" autoReadOnly
string property cSTOMACH_SLIDER = ".slider.stomach" autoReadOnly
string property cLACTACID_SLIDER = ".slider.lactacid" autoReadOnly

; public restricted read only constants
string property cMilk = ".milk" autoReadOnly
string property cProduction = ".production" autoReadOnly
string property cCapacity = ".capacity" autoReadOnly
string property cStomach = ".stomach" autoReadOnly
string property cLactacid = ".lactacid" autoReadOnly
string property cPregnant = ".pregnant" autoReadOnly
string property cGameTime = ".gametime" autoReadOnly

; public restricted variables (must be initialized at init)
float property gMilkProductionSoftMin auto
float property gMilkProductionHardMin auto
float property gMilkProductionSoftMax auto
float property gMilkProductionHardMax auto
float property gMilkProductionDecayTime auto
float property gMilkProductionGrowMilking auto
float property gMilkProductionGrowLactacid auto
float property gMilkProductionGrowPregnant auto
float property gMilkProductionBuffAddLactacid auto
float property gMilkProductionBuffAddPregnant auto
float property gMilkProductionBuffMultLactacid auto
float property gMilkProductionBuffMultPregnant auto

float property gMilkCapacitySoftMin auto
float property gMilkCapacityHardMin auto
float property gMilkCapacitySoftMax auto
float property gMilkCapacityHardMax auto
float property gMilkCapacityGrowFill auto
float property gMilkCapacityGrowMilking auto
float property gMilkCapacityGrowPregnant auto
float property gMilkCapacityGrowLactacid auto
float property gMilkCapacityBuffAddPregnant auto
float property gMilkCapacityBuffMultPregnant auto
float property gMilkCapacityBuffAddLactacid auto
float property gMilkCapacityBuffMultLactacid auto
float property gMilkCapacityDecayTime auto

float property gLactacidSoftMax auto
float property gLactacidHardMax auto
float property gLactacidDecayTime auto
float property gLactacidDecayMilkProduction auto

float property gStomachSoftMax auto
float property gStomachHardMax auto
float property gStomachAbsorbTime auto

; local global variables
int gSelectKey = 9

string cOptionsFile = "SKSE\\mmf_config.json"
string cOptionMilkProductionSoftMin = ".option.milk.production.min.soft"
string cOptionMilkProductionHardMin = ".option.milk.production.min.hard"
string cOptionMilkProductionSoftMax = ".option.milk.production.max.soft"
string cOptionMilkProductionHardMax = ".option.milk.production.max.hard"
string cOptionMilkProductionDecayTime = ".option.milk.production.decay.time"
string cOptionMilkProductionGrowMilking = ".option.milk.production.grow.milking"
string cOptionMilkProductionGrowLactacid = ".option.milk.production.grow.lactactid"
string cOptionMilkProductionGrowPregnant = ".option.milk.production.grow.pregnant"
string cOptionMilkProductionBuffAddLactacid = ".option.milk.production.buff.add.lactacid"
string cOptionMilkProductionBuffAddPregnant = ".option.milk.production.buff.add.pregnant"
string cOptionMilkProductionBuffMultLactacid = ".option.milk.production.buff.mult.lactacid"
string cOptionMilkProductionBuffMultPregnant = ".option.milk.production.buff.mult.pregnant"

string cOptionMilkCapacitySoftMin = ".option.milk.capacity.min.soft"
string cOptionMilkCapacityHardMin = ".option.milk.capacity.min.hard"
string cOptionMilkCapacitySoftMax = ".option.milk.capacity.max.soft"
string cOptionMilkCapacityHardMax = ".option.milk.capacity.max.hard"
string cOptionMilkCapacityDecayTime = ".optiion.milk.capacity.decay.time"
string cOptionMilkCapacityGrowFill = ".option.milk.capacity.grow.fill"
string cOptionMilkCapacityGrowMilking = ".option.milk.capacity.grow.milking"
string cOptionMilkCapacityGrowLactacid = ".option.milk.capacity.grow.lactacid"
string cOptionMilkCapacityGrowPregnant = ".option.milk.capacity.grow.pregnant"
string cOptionMilkCapacityBuffAddLactacid = ".option.milk.capacity.buff.add.lactacid"
string cOptionMilkCapacityBuffAddPregnant = ".option.milk.capacity.buff.add.pregnant"
string cOptionMilkCapacityBuffMultLactacid = ".option.milk.capacity.buff.mult.lactacid"
string cOptionMilkCapacityBuffMultPregnant = ".option.milk.capacity.buff.mult.pregnant"

string cOptionLactacidSoftMax = ".option.lactacid.max.soft"
string cOptionLactacidHardMax = ".option.lactacid.max.hard"
string cOptionLactacidDecayTime = ".option.lactacid.decay.time"
string cOptionLactacidDecayMilkProdution = ".option.lactacid.decay.milk-production"

string cOptionStomachSoftMax = ".option.stomach.max.soft"
string cOptionStomachHardMax = ".option.stomach.max.hard"
string cOptionStomachAbsorbTime = ".option.stomach.absorb.time"

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

float gNextUpdateTime = 5.0
float gLastGameTime

import mmf_Debug
import mmf_Domain

function registerNextUpdate()
  gNextUpdateTime += Utility.RandomFloat(2.0, 7.0)
  if gNextUpdateTime > 10.0
    gNextUpdateTime -= 5
  endIf

  LogSrcFunc("core", "registerNextUpdate", gNextUpdateTime)
  RegisterForSingleUpdate(gNextUpdateTime)
endFunction

event OnInit()
  LogSrcFunc("core", "OnInit", "start")
  ; JValue_enableAPILog(true)

  registerNextUpdate()

  ReadOptionsFromFile()

  if gSelectKey != 0
    RegisterForKey(gSelectKey)
  endIf
endEvent

event OnPlayerLoadGame()
  registerNextUpdate()
endEvent

event OnUpdate()
  float now = gGameTime.GetValue()
  if gLastGameTime == 0.0 
    gLastGameTime = now
  else
    float delta = now - gLastGameTime
    LogSrcFunc("core", "OnUpdate", "delta=" + delta)
    gLastGameTime = now

    tickAllActors(now)
  endIf

  registerNextUpdate()
endEvent

string[] function GetSliderNames(string pGroup)
  if pGroup == cMILK_CAPACITY_SLIDER
    return gSliderLevelName
  elseif pGroup == cMILK_FILLING_SLIDER
    return gSliderFillName
  elseif pGroup == cSTOMACH_SLIDER
    return gSliderStomachName
  elseif pGroup == cLACTACID_SLIDER
    return gSliderPadName
  endif
  
  Unreachable()
endFunction

float[] function GetSliderLow(string pGroup)
  if pGroup == cMILK_CAPACITY_SLIDER
    return gSliderLevelLow
  elseif pGroup == cMILK_FILLING_SLIDER
    return gSliderFillLow
  elseif pGroup == cSTOMACH_SLIDER
    return gSliderStomachLow
  elseif pGroup == cLACTACID_SLIDER
    return gSliderPadLow
  endif

  Unreachable()
endFunction

float[] function GetSliderHigh(string pGroup)
  if pGroup == cMILK_CAPACITY_SLIDER
    return gSliderLevelHigh
  elseif pGroup == cMILK_FILLING_SLIDER
    return gSliderFillHigh
  elseif pGroup == cSTOMACH_SLIDER
    return gSliderStomachHigh
  elseif pGroup == cLACTACID_SLIDER
    return gSliderPadHigh
  endif

  Unreachable()
endFunction

bool function isValidSliderGroup(string pGroup) 
  return pGroup == cMILK_CAPACITY_SLIDER || \
  pGroup == cMILK_FILLING_SLIDER || \
  pGroup == cSTOMACH_SLIDER || \
  pGroup == cLACTACID_SLIDER
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
  if pGroup == cMILK_FILLING_SLIDER
    return gSliderFillName
  elseIf pGroup == cMILK_CAPACITY_SLIDER
    return gSliderLevelName
  elseIf pGroup == cSTOMACH_SLIDER
    return gSliderStomachName
  elseIf pGroup == cLACTACID_SLIDER
    return gSliderPadName
  endIf

  Unreachable()
endFunction

function setSliderNameByGroup(string pGroup, string[] pNames)
  if pGroup == cMILK_FILLING_SLIDER
    gSliderFillName = pNames
    return
  elseIf pGroup == cMILK_CAPACITY_SLIDER
    gSliderLevelName = pNames
    return
  elseIf pGroup == cSTOMACH_SLIDER
    gSliderStomachName = pNames
    return
  elseIf pGroup == cLACTACID_SLIDER
    gSliderPadName = pNames
    return
  endIf

  Unreachable()
endFunction

float[] function getSliderLowByGroup(string pType)
  if pType == cMILK_FILLING_SLIDER
    return gSliderFillLow
  elseIf pType == cMILK_CAPACITY_SLIDER
    return gSliderLevelLow
  elseIf pType == cSTOMACH_SLIDER
    return gSliderStomachLow
  elseIf pType == cLACTACID_SLIDER
    return gSliderPadLow
  endIf

  Unreachable()
endFunction

function setSliderLowByGroup(string pGroup, float[] pLow)
  if pGroup == cMILK_FILLING_SLIDER
    gSliderFillLow = pLow
    return
  elseIf pGroup == cMILK_CAPACITY_SLIDER
    gSliderLevelLow = pLow
    return
  elseIf pGroup == cSTOMACH_SLIDER
    gSliderStomachLow = pLow
    return
  elseIf pGroup == cLACTACID_SLIDER
    gSliderPadLow = pLow
    return
  endIf

  Unreachable()
endFunction

float[] function getSliderHighByGroup(string pGroup)
  if pGroup == cMILK_FILLING_SLIDER
    return gSliderFillHigh
  elseIf pGroup == cMILK_CAPACITY_SLIDER
    return gSliderLevelHigh
  elseIf pGroup == cSTOMACH_SLIDER
    return gSliderStomachHigh
  elseIf pGroup == cLACTACID_SLIDER
    return gSliderPadHigh
  endIf

  Unreachable()
endFunction

function setSliderHighByGroup(string pGroup, float[] pHigh)
  if pGroup == cMILK_FILLING_SLIDER
    gSliderFillHigh = pHigh
    return
  elseIf pGroup == cMILK_CAPACITY_SLIDER
    gSliderLevelHigh = pHigh
    return
  elseIf pGroup == cSTOMACH_SLIDER
    gSliderStomachHigh = pHigh
    return
  elseIf pGroup == cLACTACID_SLIDER
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
      LogSrcFunc("core", "OnKeyUp", "act="+act)
      act.AddSpell(gMilktrackerSpell, false)
    endIf
  endIf

endEvent

;---------------
; Actor Tracking
;---------------

function AddTrackingActor(Actor pActor)
  int id = pActor.GetFormID()
  LogSrcFunc("core", "AddTrackingActor", "AddTrackingActor:id=" + id)
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
  JValue_solveFltSetter(obj, cStomach, 0.0, true)
  JValue_solveFltSetter(obj, cPregnant, 0.0, true)
  JValue_solveFltSetter(obj, cGameTime, gGameTime.GetValue(), true)

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

  LogSrcFunc("core", "updateActorSlider", "group=" + pGroup + ",pValue=" + pValue)

  int index = names.Length - 1
  float value
  while index >= 0
    value = ((highs[index] - lows[index]) * pValue) + lows[index]
    LogSrcFunc("core", "updateActorSlider", "actor=" + pActor + ",name=" + names[index] + ",key=" + "mmf"+pGroup + ",value=" + value)
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
  float stomach = JValue_solveFlt(obj, cStomach)

  float capacityScale = gMilkCapacitySoftMax - gMilkCapacitySoftMin

  float normMilk = 0.0
  float normCapacity = 0.0
  float normLactacid = 0.0
  float normStomach = 0.0

  if capacity > 0.0
    normMilk = fltMinMax(milk / capacity, 0.0, 1.0)
  endIf

  if capacityScale > 0.0
    normCapacity = fltMinMax((capacity - gMilkCapacitySoftMin) / capacityScale, 0.0, 1.0)
  endIf

  if gLactacidSoftMax > 0.0
    normLactacid = fltMinMax(lactacid / gLactacidSoftMax, 0.0, 1.0)
  endIf

  if gStomachSoftMax > 0.0
    normStomach = fltMinMax(stomach / gStomachSoftMax, 0.0, 1.0)
  endIf

  updateActorSlider(pActor, normMilk, cMILK_FILLING_SLIDER)
  updateActorSlider(pActor, normCapacity, cMILK_CAPACITY_SLIDER)
  updateActorSlider(pActor, normLactacid, cLACTACID_SLIDER)
  updateActorSlider(pActor, normStomach, cSTOMACH_SLIDER)
  NiOverride.UpdateModelWeight(pActor)
endFunction

function cleanActor(Actor pActor)
  NiOverride.ClearBodyMorphKeys(pActor, cBASE + cMILK_FILLING_SLIDER)
  NiOverride.ClearBodyMorphKeys(pActor, cBASE + cMILK_CAPACITY_SLIDER)
  NiOverride.ClearBodyMorphKeys(pActor, cBASE + cLACTACID_SLIDER)
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

bool function tickActor(Actor pActor, float pNow)
  LogSrcFunc("core", "tickActor", "Begin with Actor=" + pActor)
  int obj = JFormDB_findEntry(cBASE, pActor)
  if obj == 0
    LogSrcFunc("core", "tickActor", "JContainer not found exit")
    return false
  endIf

  float gameTime = JValue_solveFlt(obj, cGameTime)
  if gameTime > pNow ; well something is not right
    LogSrcFunc("core", "tickActor", "gameTime="+gameTime+" > pNow="+pNow)
    JValue_solveFltSetter(obj, cGameTime, pNow)
    return true
  endIf

  float delta = pNow - gameTime
  LogSrcFunc("core", "tickActor", "delta=" + delta)

  ; if delta < (1.0/(24.0*4))
  ;   return true
  ; endIf

  float stomach = fltMinMax(JValue_solveFlt(obj, cStomach), 0.0, gStomachHardMax)
  float lactacid = fltMinMax(JValue_solveFlt(obj, cLactacid), 0.0, gLactacidHardMax)
  float milk = fltMinMax(JValue_solveFlt(obj, cMilk), 0.0, gMilkCapacityHardMax)
  float capacity = fltMinMax(JValue_solveFlt(obj, cCapacity), gMilkCapacityHardMin, gMilkCapacityHardMax)
  float production = fltMinMax(JValue_solveFlt(obj, cProduction), gMilkProductionHardMin, gMilkProductionHardMax)
  float pregnant = fltMinMax(JValue_solveFlt(obj, cPregnant), 0.0, 1.0)

  LogSrcFunc("core", "tickActor", \
    "start:" + pActor + "\n" + \
    "stomach="+stomach + "\n" + \
    "lactacid="+lactacid + "\n" + \
    "milk="+milk + "\n" + \
    "capacity="+capacity + "\n" + \
    "production="+production)

  float capacityMod = capacity
  float add = 0.0
  float sub = 0.0
  ; Mod Capacity by Pregnancy
  if pregnant > 0.0
    add = gMilkCapacityBuffAddPregnant * pregnant
    add += capacity * gMilkCapacityBuffMultPregnant * pregnant
    LogSrcFunc("core", "tickActor", "capacityMod(pregnant)+="+add)
    
    capacityMod += add
  endIf

  ; Mod Capacity by Lactacid
  if lactacid > 0.0
    float fillLactacid = lactacid / gLactacidSoftMax
    if fillLactacid > 1.0
      fillLactacid = 1.0
    endIf

    add = fillLactacid * gMilkCapacityBuffAddLactacid
    add += capacity * fillLactacid * gMilkCapacityBuffMultLactacid

    LogSrcFunc("core", "tickActor", "capacityMod(lactacid)+="+add)
    capacityMod += add
  endIf

  if capacityMod > gMilkCapacityHardMax
    capacityMod = gMilkCapacityHardMax
  endIf
  LogSrcFunc("core", "tickActor", "capacityMod="+capacityMod)

  ; Convert Stomach to Lactacid
  if stomach > 0.0
    float leftSpace = gLactacidHardMax - lactacid
    float potential = gStomachAbsorbTime * delta

    if leftSpace < potential 
      potential = leftSpace
    endIf

    LogSrcFunc("core", "tickActor", "lactacid(stomach)+="+potential)

    lactacid += potential
    stomach -= potential
  endIf

  float overshoot = 0.0

  ; Milk Prduction
  if production > 0.0
    float leftSpace = capacityMod - milk
    float potential = production * delta

    if lactacid > 0.0
      float lactacidWorkPotential = lactacid / (gLactacidDecayMilkProduction * delta)

      if lactacidWorkPotential > 1.0
        lactacidWorkPotential = 1.0
      endIf

      add = production * delta * gMilkProductionBuffMultLactacid
      add += (production+gMilkProductionBuffAddLactacid) * delta
      LogSrcFunc("core", "tickActor", "milk(lactacid)+=" + add)
      potential += add

      sub = lactacidWorkPotential * gLactacidDecayMilkProduction
      LogSrcFunc("core", "tickActor", "lactacid(production)-=" + sub)

      lactacid -= sub
    endIf

    if pregnant > 0.0
      add = production * delta * gMilkProductionBuffMultPregnant * pregnant
      add += (production+gMilkProductionBuffAddPregnant) * delta * pregnant
      LogSrcFunc("core", "tickActor", "milk(pregnant)+=" + add)
      potential += add
    endIf

    if leftSpace < potential
      overshoot += potential - leftSpace
      potential = leftSpace
    endIf

    milk += potential
  endIf

  ; Milk Production Grow by Lactacid
  if lactacid > 0.0
    float lactacidFill = lactacid / gLactacidSoftMax
    
    if lactacidFill > 1.0 
      lactacidFill = 1.0
    endIf

    add = lactacidFill * delta * gMilkProductionGrowLactacid
    LogSrcFunc("core", "tickActor", "production(lactacid)+="+ add)
    production += add

    if production > gMilkProductionHardMax
      production = gMilkCapacityHardMax
    endIf
  endIf

  ; Milk Production Grow by Pregnancy
  if pregnant > 0.0
    add = delta * gMilkProductionGrowPregnant * pregnant
    LogSrcFunc("core", "tickActor", "production(pregnant)+=" + add)
    production += add

    if production > gMilkProductionHardMax
      production = gMilkCapacityHardMax
    endIf
  endIf

  ; Milk Production Decay by Time
  if production > 0.0
    sub = delta * gMilkProductionDecayTime
    LogSrcFunc("core","tickActor", "prodution(time)-=" + sub)
    production -= sub
    
    if production < gMilkProductionHardMin
      production = gMilkProductionHardMin
    endIf
  endIf

  ; Milk Capacity Grow by Filling
  if milk > 0.0
    float milkFill = milk / gMilkCapacitySoftMax

    if milkFill > 1.0
      milkFill = 1.0
    endIf

    add = milkFill * delta * gMilkCapacityGrowFill
    LogSrcFunc("core", "tickActor", "capacity(fill)+=" + add)

    capacity += add
  endIf

  ; Milk Capacity Grow by Pregnancy
  if pregnant > 0.0
    add = gMilkCapacityGrowPregnant * delta * pregnant
    LogSrcFunc("core", "tickActor", "capacity(pregnant)+=" + add)
    capacity += add
  endIf

  ; Milk Capacity Decay by Time
  if capacity > gMilkCapacityHardMin
    sub = gMilkCapacityDecayTime * delta
    LogSrcFunc("core", "tickActor", "capacity(time)-=" + sub)
    capacity -= sub
    if capacity < gMilkCapacityHardMin
      capacity = gMilkCapacityHardMin
    endIf
  endIf

  if capacity > gMilkCapacityHardMax
    capacity = gMilkCapacityHardMax
  endIf

  ; Lactacid Time Decay
  if lactacid > 0.0
    sub = delta * gLactacidDecayTime
    if sub > lactacid 
      sub = lactacid
    endIf

    LogSrcFunc("core","tickActor", "lactacid(time)-=" + sub)
    lactacid -= sub
  endIf

  stomach = fltMinMax(stomach, 0.0, gStomachHardMax)
  lactacid = fltMinMax(lactacid, 0.0, gLactacidHardMax)
  capacity = fltMinMax(capacity, gMilkCapacityHardMin, gMilkCapacityHardMax)
  milk = fltMinMax(milk, 0.0, gMilkCapacityHardMax)
  production = fltMinMax(production, gMilkProductionHardMin, gMilkProductionHardMax)

  LogSrcFunc("core", "tickActor", \
    "end:" + pActor + "\n" + \
    "stomach="+stomach + "\n" + \
    "lactacid="+lactacid + "\n" + \
    "milk="+milk + "\n" + \
    "capacity="+capacity + "\n" + \
    "production="+production)

  JValue_solveFltSetter(obj, cStomach, stomach)
  JValue_solveFltSetter(obj, cLactacid, lactacid)
  JValue_solveFltSetter(obj, cMilk, milk)
  JValue_solveFltSetter(obj, cCapacity, capacity)
  JValue_solveFltSetter(obj, cProduction, production)
  JValue_solveFltSetter(obj, cGameTime, pNow)

  updateActor(pActor)

  return true
endFunction

function tickAllActors(float pNow)
  int index = gTrackingList.GetSize() - 1

  LogSrcFunc("core", "tickAllActors", "index="+index)
  while index >= 0
    Actor act = gTrackingList.GetAt(index) as Actor
    
    if act != None 
      if !tickActor(act, pNow)
        gTrackingList.RemoveAddedForm(act)
        index = gTrackingList.GetSize()
      endIf
    endIf

    index -=1
  endWhile
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

    if pName == cMILK_FILLING_SLIDER
      gSliderFillName = sliderName
      gSliderFillLow = sliderLow
      gSliderFillHigh = sliderHigh
    elseif pName == cMILK_CAPACITY_SLIDER
      gSliderLevelName = sliderName
      gSliderLevelLow = sliderLow
      gSliderLevelHigh = sliderHigh
    elseif pName == cSTOMACH_SLIDER
      gSliderStomachName = sliderName
      gSliderStomachLow = sliderLow
      gSliderStomachHigh = sliderHigh
    elseif pName == cLACTACID_SLIDER
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
  gMilkCapacityBuffAddLactacid = JValue_solveFlt(obj, cOptionMilkCapacityBuffAddLactacid, 0.1)
  gMilkCapacityBuffAddPregnant = JValue_solveFlt(obj, cOptionMilkCapacityBuffAddPregnant, 1.0)
  gMilkCapacityBuffMultLactacid = JValue_solveFlt(obj, cOptionMilkCapacityBuffMultLactacid, 0.1)
  gMilkCapacityBuffMultPregnant = JValue_solveFlt(obj, cOptionMilkCapacityBuffMultPregnant, 1.0)
  gMilkCapacityGrowFill = JValue_solveFlt(obj, cOptionMilkCapacityGrowFill, 0.1)
  gMilkCapacityGrowMilking = JValue_solveFlt(obj, cOptionMilkCapacityGrowMilking, 0.1)
  gMilkCapacityGrowLactacid = JValue_solveFlt(obj, cOptionMilkCapacityGrowLactacid, 0.01)
  gMilkCapacityGrowPregnant = JValue_solveFlt(obj, cOptionMilkCapacityGrowPregnant, 0.2)
  gMilkCapacityDecayTime = JValue_solveFlt(obj, cOptionMilkCapacityDecayTime, 0.1)

  gMilkProductionSoftMin = JValue_solveFlt(obj, cOptionMilkProductionSoftMin, 0.1)
  gMilkProductionHardMin = JValue_solveFlt(obj, cOptionMilkProductionHardMin, 0.0)
  gMilkProductionSoftMax = JValue_solveFlt(obj, cOptionMilkProductionSoftMax, 8.0)
  gMilkProductionHardMax = JValue_solveFlt(obj, cOptionMilkProductionHardMax, 10.0)
  gMilkProductionDecayTime = JValue_solveFlt(obj, cOptionMilkCapacityDecayTime, 0.1)
  gMilkProductionGrowMilking = JValue_solveFlt(obj, cOptionMilkProductionGrowMilking, 0.05)
  gMilkProductionGrowLactacid = JValue_solveFlt(obj, cOptionMilkProductionGrowLactacid, 0.005)
  gMilkProductionGrowPregnant = JValue_solveFlt(obj, cOptionMilkProductionGrowPregnant, 0.1)
  gMilkProductionBuffAddLactacid = JValue_solveFlt(obj, cOptionMilkProductionBuffAddLactacid, 0.0)
  gMilkProductionBuffAddPregnant = JValue_solveFlt(obj, cOptionMilkProductionBuffAddPregnant, 0.1)
  gMilkProductionBuffMultLactacid = JValue_solveFlt(obj, cOptionMilkProductionBuffMultLactacid, 0.2)
  gMilkProductionBuffMultPregnant = JValue_solveFlt(obj, cOptionMilkProductionBuffMultPregnant, 0.5)


  gLactacidSoftMax = JValue_solveFlt(obj, cOptionLactacidSoftMax, 8.0)
  gLactacidHardMax = JValue_solveFlt(obj, cOptionLactacidHardMax, 8.0)
  gLactacidDecayTime = JValue_solveFlt(obj, cOptionLactacidDecayTime, 1.0)
  gLactacidDecayMilkProduction = JValue_solveFlt(obj, cOptionLactacidDecayMilkProdution, 0.25)


  gStomachSoftMax = JValue_solveFlt(obj, cOptionStomachSoftMax, 80.0)
  gStomachHardMax = JValue_solveFlt(obj, cOptionStomachHardMax, 100.0)
  gStomachAbsorbTime = JValue_solveFlt(obj, cOptionStomachAbsorbTime, 150.0)

  string[] sliderName = Utility.CreateStringArray(0)
  float[] sliderLow = Utility.CreateFloatArray(0)
  float[] sliderHigh = Utility.CreateFloatArray(0)

  int arr = 0
  
  ReadOptionsSlidersFromObj(obj, cMILK_CAPACITY_SLIDER)
  ReadOptionsSlidersFromObj(obj, cMILK_FILLING_SLIDER)
  ReadOptionsSlidersFromObj(obj, cSTOMACH_SLIDER)
  ReadOptionsSlidersFromObj(obj, cLACTACID_SLIDER)

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

  LogSrcFunc("core", "WriteOptionsFile", "obj=" + obj)

  if obj == 0
    Fatal("couldn't create JMap_object")
    return
  endIf
  
  JValue_solveFltSetter(obj, cOptionMilkCapacitySoftMin, gMilkCapacitySoftMin, true)
  JValue_solveFltSetter(obj, cOptionMilkCapacityHardMin, gMilkCapacityHardMin, true)
  JValue_solveFltSetter(obj, cOptionMilkCapacitySoftMax, gMilkCapacitySoftMax, true)
  JValue_solveFltSetter(obj, cOptionMilkCapacityHardMax, gMilkCapacityHardMax, true)
  JValue_solveFltSetter(obj, cOptionMilkCapacityDecayTime, gMilkCapacityDecayTime, true)
  JValue_solveFltSetter(obj, cOptionMilkCapacityGrowFill, gMilkCapacityGrowFill, true)
  JValue_solveFltSetter(obj, cOptionMilkCapacityGrowMilking, gMilkCapacityGrowMilking, true)
  JValue_solveFltSetter(obj, cOptionMilkCapacityGrowLactacid, gMilkCapacityGrowLactacid, true)
  JValue_solveFltSetter(obj, cOptionMilkCapacityGrowPregnant, gMilkCapacityGrowPregnant, true)
  JValue_solveFltSetter(obj, cOptionMilkCapacityBuffAddLactacid, gMilkCapacityBuffAddLactacid, true)
  JValue_solveFltSetter(obj, cOptionMilkCapacityBuffAddPregnant, gMilkCapacityBuffAddPregnant, true)
  JValue_solveFltSetter(obj, cOptionMilkCapacityBuffMultLactacid, gMilkCapacityBuffMultLactacid, true)
  JValue_solveFltSetter(obj, cOptionMilkCapacityBuffMultPregnant, gMilkCapacityBuffMultPregnant, true)
  

  JValue_solveFltSetter(obj, cOptionMilkProductionSoftMin, gMilkProductionSoftMin, true)
  JValue_solveFltSetter(obj, cOptionMilkProductionHardMin, gMilkProductionHardMin, true)
  JValue_solveFltSetter(obj, cOptionMilkProductionSoftMax, gMilkProductionSoftMax, true)
  JValue_solveFltSetter(obj, cOptionMilkProductionHardMax, gMilkProductionHardMax, true)
  JValue_solveFltSetter(obj, cOptionMilkProductionDecayTime, gMilkProductionDecayTime, true)
  JValue_solveFltSetter(obj, cOptionMilkProductionGrowMilking, gMilkProductionGrowMilking, true)
  JValue_solveFltSetter(obj, cOptionMilkProductionGrowLactacid, gMilkProductionGrowLactacid, true)
  JValue_solveFltSetter(obj, cOptionMilkProductionGrowPregnant, gMilkProductionGrowPregnant, true)
  JValue_solveFltSetter(obj, cOptionMilkProductionBuffAddLactacid, gMilkProductionBuffAddLactacid, true)
  JValue_solveFltSetter(obj, cOptionMilkProductionBuffAddPregnant, gMilkProductionBuffAddPregnant, true)
  JValue_solveFltSetter(obj, cOptionMilkProductionBuffMultLactacid, gMilkProductionBuffMultLactacid, true)
  JValue_solveFltSetter(obj, cOptionMilkProductionBuffMultPregnant, gMilkProductionBuffMultPregnant, true)


  JValue_solveFltSetter(obj, cOptionLactacidSoftMax, gLactacidSoftMax, true)
  JValue_solveFltSetter(obj, cOptionLactacidHardMax, gLactacidHardMax, true)
  JValue_solveFltSetter(obj, cOptionLactacidDecayTime, gLactacidDecayTime, true)
  JValue_solveFltSetter(obj, cOptionLactacidDecayMilkProdution, gLactacidDecayMilkProduction, true)


  JValue_solveFltSetter(obj, cOptionStomachSoftMax, gStomachSoftMax, true)
  JValue_solveFltSetter(obj, cOptionStomachHardMax, gStomachHardMax, true)


  WriteOptionsSlidersToObj(obj, cMILK_FILLING_SLIDER, gSliderFillName, gSliderFillLow, gSliderFillHigh)
  WriteOptionsSlidersToObj(obj, cMILK_CAPACITY_SLIDER, gSliderLevelName, gSliderLevelLow, gSliderLevelHigh)
  WriteOptionsSlidersToObj(obj, cSTOMACH_SLIDER, gSliderStomachName, gSliderStomachLow, gSliderStomachHigh)
  WriteOptionsSlidersToObj(obj, cLACTACID_SLIDER, gSliderPadName, gSliderPadLow, gSliderPadHigh)

  LogSrcFunc("core", "WriteOptionsToFile", "to file:" + cOptionsFile)
  JValue_writeToFile(obj, cOptionsFile)
  
  JValue_zeroLifetime(obj)
endFunction
