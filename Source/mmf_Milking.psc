scriptName mmf_Milking extends ActiveMagicEffect

import mmf_Debug

Spell property gSpell auto
mmf_Core property gCore auto

event OnEffectStart(Actor pTarget, Actor pCaster)
  LogSrcFunc("milking", "OnEffectStart", "target=" + pTarget + ",self=" + self)
  RegisterForSingleUpdate(1.0)
endEvent

event OnEffectFinish(Actor pTarget, Actor pCaster)
  LogSrcFunc("milking", "OnEffectFinish", "target=" + pTarget + ",self=" + self)
endEvent

event OnUpdate()
  Actor act = GetTargetActor()
  Form obj = gCore.MilkActorOnce(act)

  LogSrcFunc("milking", "OnUpdate", "act=" + act + ",obj=" + obj)

  if obj == None
    act.RemoveSpell(gSpell)
    return
  endIf

  act.AddItem(obj)

  RegisterForSingleUpdate(5.0)
endEvent
