scriptName mmf_Debug Hidden

function Log(string msg) global
  Debug.Trace("[mmf]:" + msg)
endFunction

function Unreachable() global
  Debug.TraceStack("[mmf]:unreachable code detected")
endFunction
