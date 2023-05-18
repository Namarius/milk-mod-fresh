scriptName mmf_Milktracker extends ActiveMagicEffect

import mmf_Debug

mmf_Core property gCore auto

string sSelf = "mmf_Milktracker"

event OnEffectStart(Actor pTarget, Actor pCaster)
  LogSrcFunc("milktracker", "OnEffectStart", "target=" + pTarget + ",self=" + self)
  gCore.AddTrackingActor(pTarget)
endEvent

event OnDeath(Actor pKiller)
  LogSrcFunc("milktracker", "OnDeath", "killer=" + pKiller)
  gCore.RemoveDirtyTrackingActor(self.GetTargetActor())
endEvent

event OnEffectFinish(Actor pTarget, Actor pCaster)
  LogSrcFunc("milktracker", "OnEffectFinish", "act=" + pTarget)
endEvent
