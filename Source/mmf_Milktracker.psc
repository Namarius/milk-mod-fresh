scriptName mmf_Milktracker extends ActiveMagicEffect

import mmf_Debug

mmf_Core property gCore auto

string sSelf = "mmf_Milktracker"

event OnEffectStart(Actor pTarget, Actor pCaster)
  Log("EffectStart:"+pTarget)
endEvent

event OnEffectFinish(Actor pTarget, Actor pCaster)
  Log("EffectStop:"+pTarget)
endEvent

event OnObjectEquipped(Form pBaseObject, ObjectReference pRef)
  LogScr(sSelf, "Base: " + pBaseObject + ", Ref:" + pRef)
endEvent
