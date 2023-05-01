scriptName mmf_MCM extends SKI_ConfigBase

mmf_Core property gCore auto

import mmf_Domain
import mmf_Debug

string gSliderGroup ; currently displayed slider groups (Fill,Level)
string[] gPresetList ; list of all slider presets from B
int[] gSliderMapOptionIndex ; list of all slider option indexes for a single slider view

string gChangeSliderName ; global name holder for subpage to change sliders
float gChangeSliderLow ; global low holder for subpage to change sliders
float gChangeSliderHigh ; global high holder for subpage to change sliders
int gSliderChangeIndex ; global index holder for subpage to change sliders

string cPageHello = "Hello"
string cPageLevelSlider = "Level Sliders"
string cPageFillSliders = "Fill Sliders"
string cPageOptions = "Options"

event OnConfigOpen()
  gSliderGroup = ""
  gSliderChangeIndex = -1
  gSliderMapOptionIndex = Utility.CreateIntArray(0)
endEvent

event OnConfigInit()
  ModName = "Milk Mod Fresh"

  Pages = new string [4]
  Pages[0] = cPageHello
  Pages[1] = cPageLevelSlider
  Pages[2] = cPageFillSliders
  Pages[3] = cPageOptions
endEvent

event OnPageReset(string pPage)
  if pPage == Pages[0]
    DisplayPageHello()
    return
  elseIf pPage == Pages[1]
    DisplayPageLevelSliders()
    return
  elseIf pPage == Pages[2]
    DisplayPageFillSliders()
    return
  elseIf pPage == Pages[3]
    DisplayPageOptions()
    return
  elseIf pPage == ""
    Log("[mcm]:empty page")
    return
  endIf

  Unreachable()
  Log(pPage)
endEvent

;
; Display Functions
;

function DisplayPageHello()
  SetCursorFillMode(LEFT_TO_RIGHT)
  SetCursorPosition(0)

  AddHeaderOption("Hello")
endFunction

function DisplayPageLevelSliders()
  string[] names = gCore.GetSliderNames(gCore.cLEVEL)
  float[] low = gCore.GetSliderLow(gCore.cLEVEL)
  float[] high = gCore.GetSliderHigh(gCore.cLEVEL)

  if gSliderGroup != gCore.cLEVEL
    gSliderGroup = gCore.cLEVEL
    gSliderChangeIndex = -1
  endif

  if gSliderChangeIndex < 0
    DisplayPageSliderOverview(names, low, high)
  else
    DisplaySubpageChangeSlider(names[gSliderChangeIndex], low[gSliderChangeIndex], high[gSliderChangeIndex])
  endIf
endFunction

function DisplayPageFillSliders()
  string[] names = gCore.GetSliderNames(gCore.cFILL)
  float[] low = gCore.GetSliderLow(gCore.cFILL)
  float[] high = gCore.GetSliderHigh(gCore.cFILL)

  if gSliderGroup != gCore.cFILL
    gSliderGroup = gCore.cFILL
    gSliderChangeIndex = -1
  endIf

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
