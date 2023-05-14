scriptName mmf_Debug Hidden

import ConsoleUtil

function Log(string msg) global
  string s = "[mmf]:" + msg
  Debug.Trace(s)
  CLog(s)
endFunction

function LogSrc(string script, string msg) global
  string s = "[mmf:"+script+"]" + msg
  Debug.Trace(s)
  CLog(s)
endFunction

function LogSrcFunc(string script, string func, string msg) global
  string s = "[mmf:"+script+":"+func+"]" + msg
  Debug.Trace(s)
  CLog(s)
endFunction

function Fatal(string msg) global
  string s = "Fatal [mmf]:\n" + msg
  Debug.MessageBox(s)
  CLog("[mmf:fatal]:" + msg)
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