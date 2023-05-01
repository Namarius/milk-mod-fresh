scriptName mmf_Core extends ReferenceAlias
{
  Autor: Namarius
  Purpose: core functionality for MMF
}

string property cLEVEL = "Level" autoReadOnly
string property cFILL = "Fill" autoReadOnly

int mSelectKey = 9

string[] gSliderLevelName
float[] gSliderLevelLow
float[] gSliderLevelHigh

string[] gSliderFillName
float[] gSliderFillLow
float[] gSliderFillHigh

import mmf_Debug

event OnInit()
  if mSelectKey != 0
    RegisterForKey(mSelectKey)
  endIf
endEvent

string[] function GetSliderNames(string pGroup)
  if pGroup == cLEVEL
    return gSliderLevelName
  elseif pGroup == cFILL
    return gSliderFillName
  endif
  
  Unreachable()
endFunction

float[] function GetSliderLow(string pGroup)
  if pGroup == cLEVEL
    return gSliderLevelLow
  elseif pGroup == cFILL
    return gSliderFillLow
  endif

  Unreachable()
endFunction

float[] function GetSliderHigh(string pGroup)
  if pGroup == cLEVEL
    return gSliderLevelHigh
  elseif pGroup == cFILL
    return gSliderFillHigh
  endif

  Unreachable()
endFunction

bool function AddSlider(string pGroup, string pName, float pLow, float pHigh)
  if pGroup == cLEVEL
    return AddSliderLevel(pName, pLow, pHigh)
  elseif pGroup == cFILL
    return AddSliderFill(pName, pLow, pHigh)
  endif

  Unreachable()
  return false
endFunction

bool function RemoveSlider(string pGroup, string pName)
  if pGroup == cLEVEL
    return RemoveSliderLevel(pName)
  elseif pGroup == cFILL
    return RemoveSliderFill(pName)
  endif

  Unreachable()
  return false
endFunction

int function RenameSlider(string pGroup, string pOldName, string pNewName)
  if pGroup == cLEVEL
    return RenameSliderLevel(pOldName, pNewName)
  elseif pGroup == cFILL
    return RenameSliderFill(pOldName, pNewName)
  endif

  Unreachable()
  return -1
endFunction

bool function ReplaceSliders(string pGroup, string[] pNames, float[] pLows, float[] pHighs)
  if pGroup == cLEVEL
    return ReplaceSlidersLevel(pNames, pLows, pHighs)
  elseif pGroup == cFILL
    return ReplaceSlidersFill(pNames, pLows, pHighs)
  endif

  Unreachable()
  return false
endFunction

bool function AddSliderFill(string pName, float pLow, float pHigh)
  int index = 0
  int maxIndex = gSliderFillName.Length

  while index < maxIndex
    if gSliderFillName[index] == pName
      gSliderFillLow[index] = pLow
      gSliderFillHigh[index] = pHigh
      return true
    endif

    index += 1
  endWhile

  gSliderFillName = Utility.ResizeStringArray(gSliderFillName, maxIndex + 1, pName)
  gSliderFillLow = Utility.ResizeFloatArray(gSliderFillLow, maxIndex + 1, pLow)
  gSliderFillHigh = Utility.ResizeFloatArray(gSliderFillHigh, maxIndex + 1, pHigh)
  return true
endFunction

bool function AddSliderLevel(string pName, float pLow, float pHigh)
  int index = 0
  int maxIndex = gSliderLevelName.Length

  while index < maxIndex
    if gSliderLevelName[index] == pName
      gSliderLevelLow[index] = pLow
      gSliderLevelHigh[index] = pHigh
      return true
    endif

    index += 1
  endWhile

  gSliderLevelName = Utility.ResizeStringArray(gSliderLevelName, maxIndex + 1, pName)
  gSliderLevelLow = Utility.ResizeFloatArray(gSliderLevelLow, maxIndex + 1, pLow)
  gSliderLevelHigh = Utility.ResizeFloatArray(gSliderLevelHigh, maxIndex + 1, pHigh)
  return true
endFunction

bool function RemoveSliderFill(string pName)
  int index = 0
  int maxIndex = gSliderFillName.Length

  bool copy = false
  bool found = false

  while index < maxIndex
    if copy 
      gSliderFillName[index - 1] = gSliderFillName[index]
      gSliderFillLow[index - 1] = gSliderFillLow[index]
      gSliderFillHigh[index - 1] = gSliderFillHigh[index]
    elseIf gSliderFillName[index] == pName
      copy = true
      found = true
    endif

    index += 1
  endWhile

  if found 
    gSliderFillName = Utility.ResizeStringArray(gSliderFillName, maxIndex - 1)
    gSliderFillLow = Utility.ResizeFloatArray(gSliderFillLow, maxIndex - 1)
    gSliderFillHigh = Utility.ResizeFloatArray(gSliderFillHigh, maxIndex - 1)
  endIf

  return found
endfunction

bool function RemoveSliderLevel(string pName)
  int index = 0
  int maxIndex = gSliderLevelName.Length

  bool copy = false
  bool found = false

  while index < maxIndex
    Log("index:" + index + ",copy" + copy + ",found" + found)
    if copy 
      gSliderLevelName[index - 1] = gSliderLevelName[index]
      gSliderLevelLow[index - 1] = gSliderLevelLow[index]
      gSliderLevelHigh[index - 1] = gSliderLevelHigh[index]
    elseIf gSliderLevelName[index] == pName
      copy = true
      found = true
    endif

    index += 1
  endWhile

  if found
    gSliderLevelName = Utility.ResizeStringArray(gSliderLevelName, maxIndex - 1)
    gSliderLevelLow = Utility.ResizeFloatArray(gSliderLevelLow, maxIndex - 1)
    gSliderLevelHigh = Utility.ResizeFloatArray(gSliderLevelHigh, maxIndex - 1)
  endIf

  return found
endfunction

bool function ReplaceSlidersFill(string[] pNames, float[] pLows, float[] pHighs)
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
    gSliderFillName = Utility.ResizeStringArray(pNames, min)
    gSliderFillLow = Utility.ResizeFloatArray(pLows, min)
    gSliderFillHigh = Utility.ResizeFloatArray(pHighs, min)
  else
    gSliderFillName = pNames
    gSliderFillLow = pLows
    gSliderFillHigh = pHighs
  endif

  return true
endFunction

bool function ReplaceSlidersLevel(string[] pNames, float[] pLows, float[] pHighs)
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
    gSliderLevelName = Utility.ResizeStringArray(pNames, min)
    gSliderLevelLow = Utility.ResizeFloatArray(pLows, min)
    gSliderLevelHigh = Utility.ResizeFloatArray(pHighs, min)
  else
    gSliderLevelName = pNames
    gSliderLevelLow = pLows
    gSliderLevelHigh = pHighs
  endif

  return true
endFunction

int function RenameSliderFill(string pOldName, string pNewName)
  int index = 0
  int oldIndex = -1
  int newIndex = -1
  int indexMax = gSliderFillName.Length

  while index < indexMax
    if gSliderFillName[index] == pOldName
      oldIndex = index
    endif

    if gSliderFillName[index] == pNewName
      newIndex = index
    endif

    index += 1
  endWhile

  if oldIndex < 0
    return -1
  endIf

  if oldIndex >= 0 && newIndex < 0
    gSliderFillName[oldIndex] = pNewName
    return oldIndex
  endIf

  RemoveSliderFill(pNewName)
  gSliderFillName[oldIndex] = pNewName
  return oldIndex

endFunction

int function RenameSliderLevel(string pOldName, string pNewName)
  int index = 0
  int oldIndex = -1
  int newIndex = -1
  int indexMax = gSliderLevelName.Length

  while index < indexMax
    if gSliderLevelName[index] == pOldName
      oldIndex = index
    endif

    if gSliderLevelName[index] == pNewName
      newIndex = index
    endif

    index += 1
  endWhile

  if oldIndex < 0
    return -1
  endIf

  if oldIndex >= 0 && newIndex < 0
    gSliderLevelName[oldIndex] = pNewName
    return oldIndex
  endIf

  RemoveSliderLevel(pNewName)
  gSliderLevelName[oldIndex] = pNewName
  return oldIndex

endFunction

;---------------------------
; select and interaction key
;---------------------------

int function GetSelectKey()
  return mSelectKey
endFunction

function SetSelectKey(int pKeyCode) 
  UnregisterForAllKeys()
  
  mSelectKey = pKeyCode

  if mSelectKey != 0
    RegisterForKey(mSelectKey)
  endIf
endFunction

event OnKeyUp(int pKeyCode, float pHoldTime) 
  if Utility.IsInMenuMode() 
    return
  endIf

  ObjectReference ref = Game.GetCurrentCrosshairRef()

  if ref != None
    Debug.MessageBox("Reference is: " + ref)
  endIf

endEvent

;--

