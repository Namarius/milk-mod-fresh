scriptName mmf_MCM extends SKI_ConfigBase

mmf_Core property gCore auto

import mmf_Domain
import mmf_Debug

float cMaxFlt = 340282346638528859811704183484516925440.0

string gSliderGroup ; currently displayed slider groups (Fill,Level,Stomach,Pad)
string[] gPresetList ; list of all slider presets from B
int[] gSliderMapOptionIndex ; list of all slider option indexes for a single slider view

string gChangeSliderName ; global name holder for subpage to change sliders
float gChangeSliderLow ; global low holder for subpage to change sliders
float gChangeSliderHigh ; global high holder for subpage to change sliders
int gSliderChangeIndex ; global index holder for subpage to change sliders

string cPageHello = "Hello"
string cPageLevelSlider = "Level Sliders"
string cPageFillSliders = "Fill Sliders"
string cPageStomachSliders = "Stomach Sliders"
string cPagePadSliders = "Pad Sliders"
string cPageOptions = "Options"
string cPageDebug = "Debug"

string cUpdateEvent = "mmf::UpdateDebugPage"

event OnConfigOpen()
  RegisterForModEvent(cUpdateEvent, "OnUpdateDebugPage")

  gSliderGroup = ""
  gSliderChangeIndex = -1
  gSliderMapOptionIndex = Utility.CreateIntArray(0)
endEvent

event OnUpdateDebugPage()
  LogSrc("mmf_MCM", "OnUpdateDebugPage")
  if CurrentPage == cPageDebug
    updatePageDebug()
  endIf
endEvent

event OnConfigInit()
  ModName = "Milk Mod Fresh"

  Pages = new string [7]
  Pages[0] = cPageHello
  Pages[1] = cPageLevelSlider
  Pages[2] = cPageFillSliders
  Pages[3] = cPageStomachSliders
  Pages[4] = cPagePadSliders
  Pages[5] = cPageOptions
  Pages[6] = cPageDebug
endEvent

event OnPageReset(string pPage)
  if pPage == Pages[0]
    DisplayPageHello()
    return
  elseIf pPage == Pages[1]
    DisplayPageSliders(gCore.cMILK_CAPACITY_SLIDER)
    return
  elseIf pPage == Pages[2]
    DisplayPageSliders(gCore.cMILK_FILLING_SLIDER)
    return
  elseIf pPage == Pages[3]
    DisplayPageSliders(gCore.cSTOMACH_SLIDER)
    return
  elseIf pPage == Pages[4]
    DisplayPageSliders(gCore.cLACTACID_SLIDER)
    return
  elseIf pPage == Pages[5]
    DisplayPageOptions()
    return
  elseIf pPage == Pages[6]
    DisplayPageDebug()
    return
  elseIf pPage == ""
    LogSrcFunc("mcm", "OnPageReset", "empty page")
    return
  endIf

  Unreachable()
  LogSrcFunc("mcm", "OnPageReset", pPage)
endEvent

;
; Display Functions
;

function DisplayPageHello()
  SetCursorFillMode(LEFT_TO_RIGHT)
  SetCursorPosition(0)

  AddHeaderOption("Hello")
  AddEmptyOption()

  AddTextOption("GameTime", gCore.gGameTime.GetValue())
endFunction

function DisplayPageSliders(string pType)
  string[] names = gCore.GetSliderNames(pType)
  float[] low = gCore.GetSliderLow(pType)
  float[] high = gCore.GetSliderHigh(pType)

  if gSliderGroup != pType
    gSliderGroup = pType
    gSliderChangeIndex = -1
  endif

  if gSliderChangeIndex < 0
    DisplayPageSliderOverview(names, low, high)
  else
    DisplaySubpageChangeSlider(names[gSliderChangeIndex], low[gSliderChangeIndex], high[gSliderChangeIndex])
  endIf
endFunction

function DisplayPageOptions()
  SetCursorFillMode(LEFT_TO_RIGHT)
  SetCursorPosition(0)

  AddKeyMapOptionST("SelectKeySetup", "Option Key", gCore.GetSelectKey())
  AddEmptyOption()


  AddHeaderOption("Milk Capacity")
  AddEmptyOption()

  AddInputOptionST("SetMilkCapacitySoftMin", "Soft Minimum", gCore.gMilkCapacitySoftMin)
  AddInputOptionST("SetMilkCapacityHardMin", "Hard Minimum", gCore.gMilkCapacityHardMin)

  AddInputOptionST("SetMilkCapacitySoftMax", "Soft Maximum", gCore.gMilkCapacitySoftMax)
  AddInputOptionST("SetMilkCapacityHardMax", "Hard Maximum", gCore.gMilkCapacityHardMax)

  AddInputOptionST("SetMilkCapacityGrowMilking", "Grow by Milking", gCore.gMilkCapacityGrowMilking)
  AddInputOptionST("SetMilkCapacityGrowLactacid", "Grow by Lactacid", gCore.gMilkCapacityGrowLactacid)

  AddInputOptionST("SetMilkCapacityGrowPregnant", "Grow by Pregnancy", gCore.gMilkCapacityGrowPregnant)
  AddInputOptionST("SetMilkCapacityGrowFill", "Grow by Filling", gCore.gMilkCapacityGrowFill)

  AddInputOptionST("SetMilkCapacityBuffAddLactacid", "Add by Lactacid", gCore.gMilkCapacityBuffAddLactacid)
  AddInputOptionST("SetMilkCapacityBuffAddPregnant", "Add by Pregnancy", gCore.gMilkCapacityBuffAddPregnant)

  AddInputOptionST("SetMilkCapacityBuffMultLactacid", "Mult by Lactacid", gCore.gMilkCapacityBuffMultLactacid)
  AddInputOptionST("SetMilkCapacityBuffMultPregnant", "Mult by Pregnancy", gCore.gMilkCapacityBuffMultPregnant)
  
  AddInputOptionST("SetMilkCapacityDecayTime", "Decay by Time", gCore.gMilkCapacityDecayTime)
  AddEmptyOption()

  AddHeaderOption("Milk Production")
  AddEmptyOption()

  AddInputOptionST("SetMilkProductionSoftMin", "Soft Minimum", gCore.gMilkProductionSoftMin)
  AddInputOptionST("SetMilkProductionHardMin", "Hard Minimum", gCore.gMilkProductionHardMin)

  AddInputOptionST("SetMilkProductionSoftMax", "Soft Maximum", gCore.gMilkProductionSoftMax)
  AddInputOptionST("SetMilkProductionHardMax", "Hard Maximum", gCore.gMilkProductionHardMax)

  AddInputOptionST("SetMilkProductionGrowMilking", "Grow by Milking", gCore.gMilkProductionGrowMilking)
  AddInputOptionST("SetMilkProductionGrowLactacid", "Grow by Lactacid", gCore.gMilkProductionGrowLactacid)

  AddInputOptionST("SetMilkProductionGrowPregnant", "Grow by Pregnancy", gCore.gMilkProductionGrowPregnant)
  AddEmptyOption()

  AddInputOptionST("SetMilkProductionBuffAddLactacid", "Add by Lactacid", gCore.gMilkProductionBuffAddLactacid)
  AddInputOptionST("SetMilkProductionBuffAddPregnant", "Add by Pregnancy", gCore.gMilkProductionBuffAddPregnant)

  AddInputOptionST("SetMilkProductionBuffMultLactacid", "Multiply by Lactacid", gCore.gMilkProductionBuffMultLactacid)
  AddInputOptionST("SetMilkProductionBuffMultPregnant", "Multiply by Pregnancy", gCore.gMilkProductionBuffMultPregnant)

  AddInputOptionST("SetMilkProductionDecayTime", "Decay by Time", gCore.gMilkProductionDecayTime)
  AddEmptyOption()

  AddHeaderOption("Lactacid")
  AddEmptyOption()

  AddInputOptionST("SetLactacidSoftMax", "Soft Maximum", gCore.gLactacidSoftMax)
  AddInputOptionST("SetLactacidHardMax", "Hard Maximum", gCore.gLactacidHardMax)

  AddInputOptionST("SetLactacidDecayTime", "Decay by Time", gCore.gLactacidDecayTime)
  AddInputOptionST("SetLactacidDecayMilkProduction", "Decay by Milk Production", gCore.gLactacidDecayMilkProduction)

  AddHeaderOption("Stomach")
  AddEmptyOption()

  AddInputOptionST("SetStomachSoftMax", "Soft Maximum", gCore.gStomachSoftMax)
  AddInputOptionST("SetStomachHardMax", "Hard Maximum", gCore.gStomachHardMax)

  AddInputOptionST("SetStomachAbsorbTime", "Absorb by Time", gCore.gStomachAbsorbTime)
  AddEmptyOption()

  AddHeaderOption("Save/Load")
  AddEmptyOption()

  AddTextOptionST("SaveConfiguration","Save Configuration", "")
endFunction

int gDebugIndex = 0
int gDebugObj = 0

function updatePageDebug()
  Actor act = gCore.GetTrackedActor(gDebugIndex)

  int maxIndex = gCore.GetTrackedActorCount()

  if act != None
    gDebugObj = JValue_releaseAndRetain(gDebugObj, JFormDB_findEntry(gCore.cBASE, act))
    
    SetTextOptionValueST(act.GetActorBase().GetName() + "(" + act.GetFormID() + ")", true, "DebugActorName")
    SetTextOptionValueST((gDebugIndex+1) +"/"+ maxIndex, true, "DebugIndex")

    SetOptionFlagsST(0, true, "SetDebugMilk")
    SetInputOptionValueST(JValue_solveFlt(gDebugObj, gCore.cMilk), true, "SetDebugMilk")
    SetOptionFlagsST(0, true, "SetDebugProduction")
    SetInputOptionValueST(JValue_solveFlt(gDebugObj, gCore.cProduction), true, "SetDebugProduction")
  
    SetOptionFlagsST(0, true, "SetDebugCapacity")
    SetInputOptionValueST(JValue_solveFlt(gDebugObj, gCore.cCapacity), true, "SetDebugCapacity")
    SetOptionFlagsST(0, true, "SetDebugLactacid")
    SetInputOptionValueST(JValue_solveFlt(gDebugObj, gCore.cLactacid), true, "SetDebugLactacid")
    
    SetOptionFlagsST(0, true, "SetDebugStomach")
    SetInputOptionValueST(JValue_solveFlt(gDebugObj, gCore.cStomach), true, "SetDebugStomach")
    SetOptionFlagsST(0, true, "SetDebugGameTime")
    SetInputOptionValueST(JValue_solveFlt(gDebugObj, gCore.cGameTime), true, "SetDebugGameTime")
  
    SetOptionFlagsST(0, true, "SetDebugPregnant")
    SetInputOptionValueST(JValue_solveFlt(gDebugObj, gCore.cPregnant), true, "SetDebugPregnant")
  else 
    SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "DebugActorName")
    SetTextOptionValueST("N/A", true, "DebugActorName")
    SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "DebugIndex")
    SetTextOptionValueST("-", true, "DebugIndex")
  
    SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "SetDebugMilk")
    SetInputOptionValueST("N/A", true, "SetDebugMilk")
    SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "SetDebugProduction")
    SetInputOptionValueST("N/A", true, "SetDebugProduction")
    
    SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "SetDebugCapacity")
    SetInputOptionValueST("N/A", true, "SetDebugCapacity")
    SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "SetDebugLactacid")
    SetInputOptionValueST("N/A", true, "SetDebugLactacid")

    SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "SetDebugStomach")
    SetInputOptionValueST("N/A", true, "SetDebugStomach")
    SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "SetDebugGameTime")
    SetInputOptionValueST("N/A", true, "SetDebugGameTime")
    
    SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "SetDebugPregnant")
    SetToggleOptionValueST(false, true, "SetDebugPregnant")
  endIf

  if gDebugIndex <= 0
    SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "PrevDebugActor")
  else
    SetOptionFlagsST(0, true, "PrevDebugActor")
  endIf

  if gDebugIndex >= maxIndex - 1
    SetOptionFlagsST(OPTION_FLAG_DISABLED, false, "NextDebugActor")
  else
    SetOptionFlagsST(0, false, "NextDebugActor")
  endIf
endFunction

function DisplayPageDebug()
  SetCursorFillMode(LEFT_TO_RIGHT)
  SetCursorPosition(0)

  AddTextOptionST("DebugActorName", "Name", "")
  AddTextOptionST("DebugIndex", "Index", gDebugIndex)

  AddTextOptionST("PrevDebugActor", "$Previous", "", OPTION_FLAG_DISABLED)
  AddTextOptionST("NextDebugActor", "$Next", "", OPTION_FLAG_DISABLED)

  AddHeaderOption("Values")
  AddEmptyOption()

  AddInputOptionST("SetDebugMilk", "Milk", "Loading")
  AddInputOptionST("SetDebugProduction", "Production", "Loading")

  AddInputOptionST("SetDebugCapacity", "Capacity", "Loading")
  AddInputOptionST("SetDebugLactacid", "Lactacid", "Loading")

  AddInputOptionST("SetDebugStomach", "Stomach", "Loading")
  AddInputOptionST("SetDebugGameTime", "GameTime", "Loading")

  AddInputOptionST("SetDebugPregnant", "Pregnant", "Loading")
  AddEmptyOption()

  AddTextOptionST("DebugUpdateValues", "Update Values", "")
  AddTextOptionST("DebugUpdateActor", "Update Actor", "")

  int evt = ModEvent.Create(cUpdateEvent)
  ModEvent.Send(evt)
endFunction

;
; Other Pages
;

function DisplaySubpageChangeSlider(string name, float low, float high)
  gChangeSliderName = name
  gChangeSliderLow = low
  gChangeSliderHigh = high

  SetCursorFillMode(LEFT_TO_RIGHT)
  SetCursorPosition(0)

  AddInputOptionST("SliderRename", "Rename", name)
  AddTextOptionST("SliderRemove", "Remove", "")
  AddInputOptionST("SliderSetLow", "Low Slider", low)
  AddInputOptionST("SliderSetHigh", "High Slider", high)
  AddTextOptionST("LeaveChangeSlider", "Back", "")
endFunction

function DisplayPageSliderOverview(string[] pNames, float[] pLows, float[] pHighs)
  SetCursorFillMode(LEFT_TO_RIGHT)
  SetCursorPosition(0)

  AddMenuOptionST("SelectSliderPreset", "Select Slider Preset", "Female")
  AddEmptyOption()

  int obj = JMap_object()
  int index = 0
  int maxIndex = pNames.Length
  int position = 0
  string sOut

  gSliderMapOptionIndex = Utility.CreateIntArray(0)

  while index < maxIndex
    JMap_setFlt(obj, "l", pLows[index])
    JMap_setFlt(obj, "h", pHighs[index])
    sOut = JValue_evalLuaStr(obj, "return string.format('L[%0.2f] H[%0.2f]', jobject.l, jobject.h)")

    position = AddTextOption(pNames[index], sOut)
    gSliderMapOptionIndex = Utility.ResizeIntArray(gSliderMapOptionIndex, index + 1, position)

    index += 1
  endWhile
endFunction

;
; Direct Handler
;

event OnOptionSelect(int pOption)
  int index = GetSliderIndexByOptionIndex(pOption)
  if index < 0
    return
  endif

  gSliderChangeIndex = index

  ForcePageReset()
endEvent

event OnOptionHighlight(int pOption)
  if CurrentPage == Pages[1] || \
    CurrentPage == Pages[2]

    SetInfoText("Click on slider to change name/low/high or remove")
  endIf
endEvent

;
; States Handler
;

;-----------------------

;
; Sliders
;
state SelectSliderPreset

event OnMenuOpenST()
  gPresetList = BodyslideReader.GetPresetList(true)
  SetMenuDialogOptions(gPresetList)
endEvent

event OnMenuAcceptST(int pIndex)
  string sPreset = gPresetList[pIndex]

  string[] names = BodyslideReader.GetPresetSliderStrings(sPreset)
  float[] lows = BodyslideReader.GetPresetSliderLows(sPreset)
  float[] highs = BodyslideReader.GetPresetSliderHighs(sPreset)

  gCore.ReplaceSliders(gSliderGroup, names, lows, highs)

  ForcePageReset()
endEvent

event OnHighlightST()
  SetInfoText("Opens menu for different Bodyslide XML Presets\nWill override all values in this list")
endEvent

endState
;-----------------
state SliderRename

event OnInputOpenST()
  SetInputDialogStartText(gChangeSliderName)
endEvent

event OnInputAcceptST(string pInput)
  if pInput == ""
    return
  endIf
  
  int index = gCore.RenameSlider(gSliderGroup, gChangeSliderName, pInput)
  if index < 0
    return
  endIf

  gSliderChangeIndex = index
  gChangeSliderName = pInput
  SetTextOptionValueST(gChangeSliderName)
endEvent

endState
;-----------------
state SliderRemove

event OnSelectST()
  if ShowMessage("Do you really want to delete the Slider '" + gChangeSliderName + "'?")
    gCore.RemoveSlider(gSliderGroup, gChangeSliderName)
    gSliderChangeIndex = -1
    ForcePageReset()
  endIf
endEvent

endState
;-----------------
state SliderSetLow

event OnInputOpenST()
  SetInputDialogStartText(gChangeSliderLow)
endEvent

event OnInputAcceptST(string pValue)
  gChangeSliderLow = pValue as float
  gCore.AddSlider(gSliderGroup, gChangeSliderName, gChangeSliderLow, gChangeSliderHigh)
  SetInputOptionValueST(gChangeSliderLow)
endEvent

endState
;------------------
state SliderSetHigh

event OnInputOpenST()
  SetInputDialogStartText(gChangeSliderHigh)
endEvent

event OnInputAcceptST(string pValue)
  gChangeSliderHigh = pValue as float
  gCore.AddSlider(gSliderGroup, gChangeSliderName, gChangeSliderLow, gChangeSliderHigh)
  SetInputOptionValueST(gChangeSliderHigh)
endEvent

endState
;-----------------------
state LeaveChangeSlider

event OnSelectST()
  gSliderChangeIndex = -1
  ForcePageReset()
endEvent

endState

;-------------------

state SelectKeySetup

event OnKeyMapChangeST(int pKeyCode, string pConflictControl, string pConfiglictName)
  if pConflictControl != "" && pKeyCode != 0
    if !ShowMessage("$SKI_MSG2{"+pConflictControl+"}", true)
      return
    endIf
  endIf

  gCore.SetSelectKey(pKeyCode)
  SetKeyMapOptionValueST(pKeyCode)
endEvent

event OnHighlightST()
  SetInfoText("TODO")
endEvent

endState
;-----------------------

;
; Options States
;

bool function fltNotBetween(float pValue, float pMin, float pMax)
  if pValue < pMin || pValue > pMax
    if pMax >= cMaxFlt
      ShowMessage("Value must be between "+pMin+" and 'maximum single-precision float'\n(Keep the vaule sane)", false)
    else
      ShowMessage("Value must be between "+pMin+" and "+pMax, false)
    endIf
    return true
  endIf
  return false
endFunction

bool function fltNotLessZero(float pValue)
  if pValue < 0.0
    ShowMessage("Value mut be greater than or equal to 0", false)
    return true
  endIf
  return false
endFunction

state SetMilkCapacitySoftMin

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkCapacitySoftMin)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  if fltNotLessZero(fValue) 
    return
  endIf
  if fltNotBetween(fValue, gCore.gMilkCapacityHardMin, gCore.gMilkCapacitySoftMax)
    return
  endIf
  gCore.gMilkCapacitySoftMin = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;-----------------------
state SetMilkCapacityHardMin

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkCapacityHardMin)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  if fltNotLessZero(fValue) 
    return
  endIf
  if fltNotBetween(fValue, 0.0, gCore.gMilkCapacitySoftMin)
    return
  endIf
  gCore.gMilkCapacityHardMin = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkCapacitySoftMax

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkCapacitySoftMax)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  if fltNotLessZero(fValue)
    return
  endIf
  if fltNotBetween(fValue, gCore.gMilkCapacitySoftMin, gCore.gMilkCapacityHardMax)
    return
  endIf
  gCore.gMilkCapacitySoftMax = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkCapacityHardMax

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkCapacityHardMax)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  if fltNotLessZero(fValue) || fltNotBetween(fValue, gCore.gMilkCapacitySoftMax, cMaxFlt)
    return
  endIf
  gCore.gMilkCapacityHardMax = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkCapacityGrowMilking

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkCapacityGrowMilking)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gMilkCapacityGrowMilking = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkCapacityGrowLactacid

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkCapacityGrowLactacid)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gMilkCapacityGrowLactacid = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkCapacityGrowPregnant

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkCapacityGrowPregnant)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gMilkCapacityGrowPregnant = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkCapacityGrowFill

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkCapacityGrowFill)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gMilkCapacityGrowFill = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkCapacityBuffAddLactacid

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkCapacityBuffAddLactacid)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gMilkCapacityBuffAddLactacid = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkCapacityBuffAddPregnant

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkCapacityBuffAddPregnant)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gMilkCapacityBuffAddPregnant = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkCapacityBuffMultLactacid

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkCapacityBuffMultLactacid)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gMilkCapacityBuffMultLactacid = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkCapacityBuffMultPregnant

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkCapacityBuffMultPregnant)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gMilkCapacityBuffMultPregnant = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkCapacityDecayTime

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkCapacityDecayTime)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gMilkCapacityDecayTime = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;-----------------------
state SetMilkProductionSoftMin

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkProductionSoftMin)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  if fltNotLessZero(fValue) || fltNotBetween(fValue, gCore.gMilkProductionHardMin, gCore.gMilkProductionSoftMax)
    return
  endIf
  gCore.gMilkProductionSoftMin = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;-----------------------
state SetMilkProductionHardMin

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkProductionHardMin)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  if fltNotLessZero(fValue) || fltNotBetween(fValue, 0.0, gCore.gMilkProductionSoftMin)
    return
  endIf
  gCore.gMilkProductionHardMin = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkProductionSoftMax

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkProductionSoftMax)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  if fltNotLessZero(fValue) || fltNotBetween(fValue, gCore.gMilkProductionSoftMin, gCore.gMilkProductionHardMax)
    return
  endIf
  gCore.gMilkProductionSoftMax = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkProductionHardMax

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkProductionHardMax)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  if fltNotLessZero(fValue) || fltNotBetween(fValue, gCore.gMilkProductionSoftMax, cMaxFlt)
    return
  endIf
  gCore.gMilkProductionHardMax = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkProductionGrowMilking

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkProductionGrowMilking)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gMilkProductionGrowMilking = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkProductionGrowLactacid

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkProductionGrowLactacid)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gMilkProductionGrowLactacid = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkProductionGrowPregnant

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkProductionGrowPregnant)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gMilkProductionGrowPregnant = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkProductionBuffAddLactacid

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkProductionBuffAddLactacid)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gMilkProductionBuffAddLactacid = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkProductionBuffAddPregnant

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkProductionBuffAddPregnant)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gMilkProductionBuffAddPregnant = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkProductionBuffMultLactacid

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkProductionBuffMultLactacid)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gMilkProductionBuffMultLactacid = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkProductionBuffMultPregnant

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkProductionBuffMultPregnant)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gMilkProductionBuffMultPregnant = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------
state SetMilkProductionDecayTime

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkProductionDecayTime)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gMilkProductionDecayTime = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;-------
state SetLactacidSoftMax
  event OnInputOpenST()
    SetInputDialogStartText(gCore.gLactacidSoftMax)
  endEvent
  
  event OnInputAcceptST(string pValue)
    float fValue = pValue as float
    if fltNotBetween(fValue, 0.0, gCore.gLactacidHardMax)
      return
    endIf
    gCore.gLactacidSoftMax = fValue
    SetInputOptionValueST(fValue)
  endEvent
endState
;-------
state SetLactacidHardMax
  event OnInputOpenST()
    SetInputDialogStartText(gCore.gLactacidHardMax)
  endEvent
  
  event OnInputAcceptST(string pValue)
    float fValue = pValue as float
    if fltNotBetween(fValue, gCore.gLactacidSoftMax, cMaxFlt)
      return
    endIf
    gCore.gLactacidHardMax = fValue
    SetInputOptionValueST(fValue)
  endEvent
endState
;-------------------------
state SetLactacidDecayTime

event OnInputOpenST()
  SetInputDialogStartText(gCore.gLactacidDecayTime)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gLactacidDecayTime = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;-----------------------------------
state SetLactacidDecayMilkProduction

event OnInputOpenST()
  SetInputDialogStartText(gCore.gLactacidDecayMilkProduction)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gLactacidDecayMilkProduction = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;-------
state SetStomachSoftMax

event OnInputOpenST()
  SetInputDialogStartText(gCore.gStomachSoftMax)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gStomachSoftMax = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;-------
state SetStomachHardMax

event OnInputOpenST()
  SetInputDialogStartText(gCore.gStomachHardMax)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gStomachHardMax = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;-------
state SetStomachAbsorbTime

event OnInputOpenST()
  SetInputDialogStartText(gCore.gStomachAbsorbTime)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gStomachAbsorbTime = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;----------------------
state SaveConfiguration

event OnSelectST()
  gCore.WriteOptionsToFile()
  ShowMessage("Saved", false)
endEvent

endState
;-------
state PrevDebugActor

event OnSelectST()
  if gDebugIndex > 0
    gDebugIndex -= 1
    updatePageDebug()
  else
    SetOptionFlagsST(OPTION_FLAG_DISABLED)
  endIf
endEvent

endState
;-------
state NextDebugActor

event OnSelectST()
  if gDebugIndex < (gCore.GetTrackedActorCount() - 1)
    gDebugIndex += 1
    updatePageDebug()
  else
    SetOptionFlagsST(OPTION_FLAG_DISABLED)
  endIf
endEvent

endState
;-----------------
state SetDebugMilk

event OnInputOpenST()
  SetInputDialogStartText(JValue_solveFlt(gDebugObj, gCore.cMilk))
endEvent

event OnInputAcceptST(string pValue) 
  float fValue = pValue as float
  JValue_solveFltSetter(gDebugObj, gCore.cMilk, fValue)
  SetInputOptionValueST(fValue)
endEvent

endState
;-----------------
state SetDebugProduction

event OnInputOpenST()
  SetInputDialogStartText(JValue_solveFlt(gDebugObj, gCore.cProduction))
endEvent

event OnInputAcceptST(string pValue) 
  float fValue = pValue as float
  JValue_solveFltSetter(gDebugObj, gCore.cProduction, fValue)
  SetInputOptionValueST(fValue)
endEvent

endState
;-----------------
state SetDebugLactacid

event OnInputOpenST()
  SetInputDialogStartText(JValue_solveFlt(gDebugObj, gCore.cLactacid))
endEvent

event OnInputAcceptST(string pValue) 
  float fValue = pValue as float
  JValue_solveFltSetter(gDebugObj, gCore.cLactacid, fValue)
  SetInputOptionValueST(fValue)
endEvent

endState
;-----------------
state SetDebugCapacity

event OnInputOpenST()
  SetInputDialogStartText(JValue_solveFlt(gDebugObj, gCore.cCapacity))
endEvent

event OnInputAcceptST(string pValue) 
  float fValue = pValue as float
  JValue_solveFltSetter(gDebugObj, gCore.cCapacity, fValue)
  SetInputOptionValueST(fValue)
endEvent

endState
;-----------------
state SetDebugStomach

event OnInputOpenST()
  SetInputDialogStartText(JValue_solveFlt(gDebugObj, gCore.cStomach))
endEvent

event OnInputAcceptST(string pValue) 
  float fValue = pValue as float
  JValue_solveFltSetter(gDebugObj, gCore.cStomach, fValue)
  SetInputOptionValueST(fValue)
endEvent

endState
;-----------------
state SetDebugGameTime

event OnInputOpenST()
  SetInputDialogStartText(JValue_solveFlt(gDebugObj, gCore.cGameTime))
endEvent

event OnInputAcceptST(string pValue) 
  float fValue = pValue as float
  JValue_solveFltSetter(gDebugObj, gCore.cGameTime, fValue)
  SetInputOptionValueST(fValue)
endEvent

endState
;-----------------
state SetDebugPregnant

event OnInputOpenST()
  SetInputDialogStartText(JValue_solveFlt(gDebugObj, gCore.cPregnant))
endEvent

event OnInputAcceptST(string pValue) 
  float fValue = pValue as float
  JValue_solveFltSetter(gDebugObj, gCore.cPregnant, fValue)
  SetInputOptionValueST(fValue)
endEvent

endState
;-------
state DebugUpdateActor

event OnSelectST()
  gCore.UpdateActorByIndex(gDebugIndex)
endEvent

endState
;-------
;
; Utils
;

int function GetSliderIndexByOptionIndex(int pOption)
  int index = 0
  int maxIndex = gSliderMapOptionIndex.Length

  while index < maxIndex
    if gSliderMapOptionIndex[index] == pOption
      return index
    endif

    index += 1
  endWhile

  return -1
endFunction
