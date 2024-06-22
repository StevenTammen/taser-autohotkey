#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%



*f::
    sent_keys_stack := ["a", "a"]
    sent_keys_stack.pop()
    MsgBox % sent_keys_stack.Length()
return

; *f::
;     currency_map := {}

;     dollars := {}
;     dollars["symbol"] := "$"
;     dollars["symbol_location"] := "prefix"
;     dollars["decimal"] := "."
;     dollars["thousands_separator"] := ","
;     currency_map["dollars"] := dollars

;     currency := "dollars"
;     currency_properties := currency_map[currency]
;     currency_symbol := currency_properties["symbol"]
;     symbol_location := currency_properties["symbol_location"]

;     MsgBox % currency_symbol . "`n`n" . symbol_location
; return

; *f::
;     automatch_characters := "{{}{{}% def %{}}{}}"
;     automatch_characters_for_looping := RegExReplace(automatch_characters, "{(.)}", "$1")
;     MsgBox % automatch_characters_for_looping
; return


; *f::
;     opening_characters := "**"
;     closing_characters := "**"
;     keys_to_return := opening_characters . closing_characters
;     MsgBox % StrLen(closing_characters)
;     Loop % StrLen(closing_characters) {
;         keys_to_return := keys_to_return . "{Left}"
;     }
;     ;MsgBox %keys_to_return%
; return

; *f::
;     test_stack := []
;     ; test_stack.Push(["a", "b", "c"])
;     ; test_stack.Push(["1", "2", "3"])
;     some_array := ["a", "b", "c"]
;     test_stack.push(some_array)
;     popped := test_stack.Pop()
;     MsgBox % popped[2]
; return

; global myVar := Object("i'm", "I'm")
; global hotstrings := {} ;Object("btw", "by the way", "i", "I", "i'd", "I'd", "i'll", "I'll", "i'm", "I'm", "i've", "I've")

; hotstrings["btw"] := "by the way"

; myFunc(uppercase_letter) {
;     MsgBox % uppercase_letter
; }

; *f::
;     x := "B"
;     y := "b"
;     MsgBox % (x == y)
; return

; global numLeader := False
; global numDownNoUp := False

; *7::
;     numLeader := True
;     numDownNoUp := True
;     return

; *7 Up::
;     numDownNoUp := False
;     return

; *t::
;     if(numLeader) {
;         numLeader := False
;         SendInput % "0"
;     }
;     else if (numDownNoUp) {
;         SendInput % "0"
;     }
;     else {
;         SendInput % "t"
;     }
;     return

; Backspace before . so can do like MyFunc().AnotherChainedFunc()

; > for Task<List[]>, => lambdas. Need to send Backspace there, and also autospace?

; ; for functionCall(); Need to send Backspace there

; Allow for spaces after ([{ for like [ 1, 2, 3 ] or { property: "value" }
; Also quotes for when concatenating spaces in string

; Need to allow for >= and <= and == and != given equals sign autospacing

; Don't delete space before : if one_key_back was Space. So can do like `public class AmrTaskService : IAmrTaskService`
; Still need to delete normally though, because of myFunc(): in Python
; Also ternary operator like (condition) ? onething : anotherThing