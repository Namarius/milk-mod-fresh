scriptName mmf_Lactacid extends ActiveMagicEffect

import mmf_Domain
import mmf_Debug

mmf_Core property gCore auto

event OnEffectStart(Actor pTarget, Actor pCaster)
  float dur = self.GetDuration()
  float mag = self.GetMagnitude()

  LogSrcFunc("lactacid", "OnEffectStart", "mag=" + mag + ",dur=" + dur + ",act=" + pTarget)

  int obj = JFormDB_findEntry(gCore.cBASE, pTarget)
  if obj == 0
    return
  endIf

  float fValue = JValue_solveFlt(obj, gCore.cStomach)
  fValue += mag
  JValue_solveFltSetter(obj, gCore.cStomach, fValue)

  gCore.updateActor(pTarget)
endEvent
