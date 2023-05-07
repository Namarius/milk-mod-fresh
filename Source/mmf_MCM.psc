scriptName mmf_MCM extends SKI_ConfigBase

mmf_Core property gCore auto

import mmf_Domain
import mmf_Debug

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
    DisplayPageSliders(gCore.cLEVEL)
    return
  elseIf pPage == Pages[2]
    DisplayPageSliders(gCore.cFILL)
    return
  elseIf pPage == Pages[3]
    DisplayPageSliders(gCore.cSTOMACH)
    return
  elseIf pPage == Pages[4]
    DisplayPageSliders(gCore.cPAD)
    return
  elseIf pPage == Pages[5]
    DisplayPageOptions()
    return
  elseIf pPage == Pages[6]
    DisplayPageDebug()
    return
  elseIf pPage == ""
    LogSrc("mmf_MCM","empty page")
    return
  endIf

  Unreachable()
  LogSrc("mmf_MCM", pPage)
endEvent

;
; Display Functions
;

function DisplayPageHello()
  SetCursorFillMode(LEFT_TO_RIGHT)
  SetCursorPosition(0)

  AddHeaderOption("Hello")
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

  AddInputOptionST("SetMilkCapacitySoftMin", "Soft Min. Capacity", gCore.gMilkCapacitySoftMin)
  AddInputOptionST("SetMilkCapacityHardMin", "Hard Min. Capacity", gCore.gMilkCapacityHardMin)

  AddInputOptionST("SetMilkCapacitySoftMax", "Soft Max. Capacity", gCore.gMilkCapacitySoftMax)
  AddInputOptionST("SetMilkCapacityHardMax", "Hard Max. Capacity", gCore.gMilkCapacityHardMax)


  AddHeaderOption("Milk Production")
  AddEmptyOption()

  AddInputOptionST("SetMilkProductionSoftMin", "Soft Min. Milk Production", gCore.gMilkProductionSoftMin)
  AddInputOptionST("SetMilkProductionHardMin", "Hard Min. Milk Production", gCore.gMilkProductionHardMin)

  AddInputOptionST("SetMilkProductionSoftMax", "Soft Max. Milk Production", gCore.gMilkProductionSoftMax)
  AddInputOptionST("SetMilkProductionHardMax", "Hard Max. Milk Production", gCore.gMilkProductionHardMax)


  AddHeaderOption("Lactacid")
  AddEmptyOption()

  AddInputOptionST("SetLactacidSoftMax", "Soft Max. Lactacid", gCore.gLactacidSoftMax)
  AddInputOptionST("SetLactacidHardMax", "Hard Max. Lactacid", gCore.gLactacidHardMax)

  AddInputOptionST("SetLactacidDecayTime", "Decay By Time", gCore.gLactacidDecayTime)
  AddInputOptionST("SetLactacidDecayMilkProduction", "Decay By Milk Production", gCore.gLactacidDecayMilkProduction)

  AddInputOptionST("SetLactacidMultMilkCapacity", "Mult. Milk Capacity", gCore.gLactacidMultMilkCapacity)
  AddInputOptionST("SetLactacidMultMilkProduction", "Mult. Milk Production", gCore.gLactacidMultMilkProduction)

  AddInputOptionST("SetLactacidAddMilkCapacity", "Add Milk Capacity", gCore.gLactacidAddMilkCapacity)
  AddInputOptionST("SetLactacidAddMilkProduction", "Add Milk Production", gCore.gLactacidAddMilkProduction)

  AddEmptyOption()
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
  
    SetOptionFlagsST(0, true, "ToggleDebugPregnant")
    SetToggleOptionValueST(JValue_solveInt(gDebugObj, gCore.cPregnant) == 1, true, "ToggleDebugPregnant")
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
    
    SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "ToggleDebugPregnant")
    SetToggleOptionValueST(false, true, "ToggleDebugPregnant")
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

  AddToggleOptionST("ToggleDebugPregnant", "Pregnant", false)
  AddEmptyOption()

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
state SetMilkCapacitySoftMin

event OnInputOpenST()
  SetInputDialogStartText(gCore.gMilkCapacitySoftMin)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
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
  gCore.gMilkCapacityHardMax = fValue
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
  gCore.gMilkProductionHardMax = fValue
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
;-----------------------------------
state SetLactacidMultMilkCapacity

event OnInputOpenST()
  SetInputDialogStartText(gCore.gLactacidMultMilkCapacity)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gLactacidMultMilkCapacity = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;-----------------------------------
state SetLactacidMultMilkProduction

event OnInputOpenST()
  SetInputDialogStartText(gCore.gLactacidMultMilkProduction)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gLactacidMultMilkProduction = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;-------------------------------
state SetLactacidAddMilkCapacity

event OnInputOpenST()
  SetInputDialogStartText(gCore.gLactacidAddMilkCapacity)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gLactacidAddMilkCapacity = fValue
  SetInputOptionValueST(fValue)
endEvent

endState
;---------------------------------
state SetLactacidAddMilkProduction

event OnInputOpenST()
  SetInputDialogStartText(gCore.gLactacidAddMilkProduction)
endEvent

event OnInputAcceptST(string pValue)
  float fValue = pValue as float
  gCore.gLactacidAddMilkProduction = fValue
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
;-------
state ToggleDebugPregnant

event OnSelectST()
  int iValue = JValue_solveInt(gDebugObj, gCore.cPregnant)
  if iValue == 0
    iValue = 1
  else
    iValue = 0
  endIf

  JValue_solveIntSetter(gDebugObj, gCore.cPregnant, iValue)
  SetToggleOptionValueST(iValue == 1)
endEvent

endState
;-------
state DebugUpdateActor

event OnSelectST()
  gCore.UpdateActorByIndex(gDebugIndex)
endEvent

endState
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
