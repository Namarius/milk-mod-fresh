scriptName mmf_Debug Hidden

import ConsoleUtil

function Log(string msg) global
  string s = "[mmf]:" + msg
  Debug.Trace(s)
  CLog(s)
endFunction

function LogScr(string script, string msg) global
  string s = "[mmf:"+script+"]" + msg
  Debug.Trace(s)
  CLog(s)
endFunction

function Unreachable() global
  Debug.TraceStack("[mmf]:unreachable code detected")
endFunction

function CLog(string msg) global
  if DoConsoleLog()
    PrintMessage(msg)
  endIf
endFunction

bool function DoConsoleLog() global
  return true
endFunction