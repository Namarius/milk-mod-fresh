scriptName mmf_Milktracker extends ActiveMagicEffect

import mmf_Debug

mmf_Core property gCore auto

string sSelf = "mmf_Milktracker"

event OnEffectStart(Actor pTarget, Actor pCaster)
  LogSrc("mmf_Milktracker", "OnEffectStart:target="+pTarget+",self="+self)
  gCore.AddTrackingActor(pTarget)
endEvent

event OnDeath(Actor pKiller)
  LogSrc("mmf_Milktracker", "OnDeath")
  gCore.RemoveDirtyTrackingActor(self.GetTargetActor())
endEvent

event OnEffectEnd(Actor pTarget, Actor pCaster)
  LogSrc("mmf_Milktracker", "OnEffectEnd:act=" + pTarget)
endEvent
