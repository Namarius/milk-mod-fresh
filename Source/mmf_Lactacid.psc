scriptName mmf_Lactacid extends ActiveMagicEffect

import mmf_Domain
import mmf_Debug

mmf_Core property gCore auto

event OnEffectStart(Actor pTarget, Actor pCaster)
  float dur = self.GetDuration()
  float mag = self.GetMagnitude()

  LogSrc("mmf_Lactacid", "OnEffectStart:mag=" + mag + ",dur=" + dur + ",act=" + pTarget)

  int obj = JFormDB_findEntry(gCore.cBASE, pTarget)
  if obj == 0
    return
  endIf

  float fValue = JValue_solveFlt(obj, gCore.cLactacid)
  fValue += mag
  JValue_solveFltSetter(obj, gCore.cLactacid, fValue)

  gCore.updateActor(pTarget)
endEvent
