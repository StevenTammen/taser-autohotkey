; Utility Functions
;-------------------------------------------------

; Remove escape characters so that we loop the right number of times
; when iterating over a string of characters. This is necessary because
; escape characters are not sent (i.e., in SendInput) but nevertheless
; contribute to the length of the string. If you iterate over a string
; to send {Left} or {Right} or {Backspace} or {Delete} or whatever to enable
; automatching or intelligent backspacing functionality, you'll get the wrong
; thing when adding these things to keys_to_return or undo_keys unless you use
; this function.
rm_esc_chars(input_string) {
    return RegExReplace(input_string, "{(.)}", "$1")
}

build_modifier_combo(key_to_combine, can_be_modified := True) {

    ; Take the symbols that are accessed via Shift on the
    ; number row on QWERTY. It is not possible to have Ctrl + @,
    ; for example. That would just be Ctrl + Shift + 2. So when
    ; we set up all our generic re-usable functions, it makes
    ; sense to be able to disable the modifier behavior for
    ; keys like this. We simply "eat" the keypress, as that
    ; will probably lead to the least unexpected behavior
    ; overall. In UX design, cf. "the principle of least surprise"
    if(not can_be_modified) {
        return ""
    }

    combination := ""

    if(mod_control_down) {
        combination := combination . "^"
        if(modifier_state == "leader") {
            mod_control_down := False
        }
    }
    if(mod_alt_down) {
        combination := combination . "!"
        if(modifier_state == "leader") {
            mod_alt_down := False
        }
    } 
    if(mod_shift_down) {
        combination := combination . "+"
        if(modifier_state == "leader") {
            mod_shift_down := False
        }
    }

    combination := combination . key_to_combine

    if(modifier_state == "leader") {
        modifier_state := ""
    }

    return combination
}

is_number(character) {
    numbers := ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    return (contains(numbers, character))
}

is_hotstring_character(character) {
    return (contains(hostring_characters, character))
}

is_number_lock_press(pressed_key) {
    return contains(number_lock_keys, pressed_key)
}

is_caps_lock_press(pressed_key) {
    return contains(caps_lock_keys, pressed_key)
}

get_index(haystack, needle) {
    for index, value in haystack {
        if (value == needle) {
            return index
        }
    }
    return -1
}

contains(haystack, needle) {
    return get_index(haystack, needle) != -1
}

prose_mode_should_be_active() {
    ; Check if certain windows are open
    ; Terminal should always implicitly be code mode, for example
    ; File manager too
    ; if() {
    ;     return False
    ; }
    return (input_state == "prose")
}

in_raw_microstate() {
    ; Check if certain other conditions are met?
    ; if() {
    ;     return True
    ; }
    return ((raw_state == "lock") or in_raw_microstate)
}

; TODO function for seeing if a JetBrains editor is active = full AceJump

; TODO function for seeing if browser is active = set up bindings for SurfingKeys

reset_entry_related_variables() {
    ; Things relating to autospacing and automatching
    autospacing := "not-autospaced"
    automatching_stack := []
    
    ; Things related to hotstrings
    sent_keys_stack := []
    last_delimiter := ""
    current_brief := ""

    ; Things relating to intelligent backspacing
    locked_state_history_stack := []
    automatching_state_history_stack := []
    autospacing_state_history_stack := []
    undo_sent_keys_stack := []
}

just_starting_new_entry() {
    return (sent_keys_stack.Length() == 0)
}

; https://www.autohotkey.com/boards/viewtopic.php?t=68429
StrCmp(Str1, Op, Str2, CS:=1) { ; requires AutoHotkey v1.1.31+
    Local R, SCS := A_StringCaseSense
    StringCaseSense, % (CS := !!CS)
    Switch Op {
        Case ">" : R := (Str1 > Str2) 
        Case ">=" : R := (Str1 >= Str2)
        Case "<" : R := (Str1 < Str2)
        Case "<=" : R := (Str1 <= Str2)
        Case "==" : R := (Str1 == Str2)
        Case "!=","<>" : R := (Str1 != Str2)
        default : R := (CS ? (Str1 == Str2) : (Str1 = Str2)) 
    }
    StringCaseSense, %SCS%
    Return R
}

; If the character passed in is not an lowercase letter, returns ""
; Otherwise, returns the uppercase version of the lowercase letter passed in
get_uppercase(character) {
    if(StrCmp(character, "==", "a")) 
        return "A"
    else if(StrCmp(character, "==", "b")) 
        return "B"
    else if(StrCmp(character, "==", "c")) 
        return "C"
    else if(StrCmp(character, "==", "d")) 
        return "D"
    else if(StrCmp(character, "==", "e")) 
        return "E"
    else if(StrCmp(character, "==", "f")) 
        return "F"
    else if(StrCmp(character, "==", "g")) 
        return "G"
    else if(StrCmp(character, "==", "h")) 
        return "H"
    else if(StrCmp(character, "==", "i")) 
        return "I"
    else if(StrCmp(character, "==", "j")) 
        return "J"
    else if(StrCmp(character, "==", "k")) 
        return "K"
    else if(StrCmp(character, "==", "l")) 
        return "L"
    else if(StrCmp(character, "==", "m")) 
        return "M"
    else if(StrCmp(character, "==", "n")) 
        return "N"
    else if(StrCmp(character, "==", "o")) 
        return "O"
    else if(StrCmp(character, "==", "p")) 
        return "P"
    else if(StrCmp(character, "==", "q")) 
        return "Q"
    else if(StrCmp(character, "==", "r")) 
        return "R"
    else if(StrCmp(character, "==", "s")) 
        return "S"
    else if(StrCmp(character, "==", "t")) 
        return "T"
    else if(StrCmp(character, "==", "u")) 
        return "U"
    else if(StrCmp(character, "==", "v")) 
        return "V"
    else if(StrCmp(character, "==", "w")) 
        return "W"
    else if(StrCmp(character, "==", "x")) 
        return "X"
    else if(StrCmp(character, "==", "y")) 
        return "Y"
    else if(StrCmp(character, "==", "z")) 
        return "Z"
    else
        return ""
}

; If the character passed in is not an uppercase letter, returns ""
; Otherwise, returns the lowercase version of the uppercase letter passed in
get_lowercase(character) {
    if (StrCmp(character, "==", "A"))
        return "a"
    else if (StrCmp(character, "==", "B"))
        return "b"
    else if (StrCmp(character, "==", "C"))
        return "c"
    else if (StrCmp(character, "==", "D"))
        return "d"
    else if (StrCmp(character, "==", "E"))
        return "e"
    else if (StrCmp(character, "==", "F"))
        return "f"
    else if (StrCmp(character, "==", "G"))
        return "g"
    else if (StrCmp(character, "==", "H"))
        return "h"
    else if (StrCmp(character, "==", "I"))
        return "i"
    else if (StrCmp(character, "==", "J"))
        return "j"
    else if (StrCmp(character, "==", "K"))
        return "k"
    else if (StrCmp(character, "==", "L"))
        return "l"
    else if (StrCmp(character, "==", "M"))
        return "m"
    else if (StrCmp(character, "==", "N"))
        return "n"
    else if (StrCmp(character, "==", "O"))
        return "o"
    else if (StrCmp(character, "==", "P"))
        return "p"
    else if (StrCmp(character, "==", "Q"))
        return "q"
    else if (StrCmp(character, "==", "R"))
        return "r"
    else if (StrCmp(character, "==", "S"))
        return "s"
    else if (StrCmp(character, "==", "T"))
        return "t"
    else if (StrCmp(character, "==", "U"))
        return "u"
    else if (StrCmp(character, "==", "V"))
        return "v"
    else if (StrCmp(character, "==", "W"))
        return "w"
    else if (StrCmp(character, "==", "X"))
        return "x"
    else if (StrCmp(character, "==", "Y"))
        return "y"
    else if (StrCmp(character, "==", "Z"))
        return "z"
    else
        return ""
}

get_hotstring_text() {

    ; Short-circuit in certain conditions
    if((not prose_mode_should_be_active()) or in_raw_microstate()) {
        return ""
    }
    else if(current_brief == "")
    { 
        return ""
    }

    first_character_of_brief_is_uppercase := False
    lowercaseCharacter := get_lowercase(SubStr(current_brief, 1, 1))
    ; It could already be lowercase. For briefs, the first character will always be a letter,
    ; at least in my system
    if(lowercaseCharacter != "") {
        first_character_of_brief_is_uppercase := True
        current_brief[1] := lowercaseCharacter
    }

    hotstring_text := hotstrings[current_brief]
    if(hotstring_text != "") {
        ; If the opening delimiter is not one of the "inactive" ones = those that shouldn't activate hotstrings
        if(not contains(inactive_delimiters, last_delimiter)) {
            if(first_character_of_brief_is_uppercase) {
                ; The first letter of the brief might not be the same as the first character of the hotstring
                uppercase_character := get_uppercase(SubStr(hotstring_text, 1, 1))
                ; It could already be uppercase (due to the first character of the hotstring always being capitalized, as with 
                ; "I'm", or because the hotstring is for an all-caps acronym like "PBI"), or might not be a letter, etc.
                if(uppercase_character != "") {
                    hotstring_text := uppercase_character . SubStr(hotstring_text, 2)
                }
            }
            return hotstring_text
        }
    }

    return ""
}

add_hotstring_expansion_if_triggering_hotstring(keys_to_return, hotstring_text) {
    if(hotstring_text != "") {
        ; The brief will be backspaced before the hotstring text is entered. (See below).
        ; We concatenate in reverse here since we are adding to the front of the return keys
        keys_to_return := hotstring_text . keys_to_return

        ; This handles a small set of markup/template hotstrings that need to
        ; capitalize whatever is typed afterwards. For example, the h1-h6
        ; hotstrings define headers in Markdown/Org. The next word after the
        ; header hotstrings should always be capitalized, even though these
        ; hotstrings will be triggered with Space and would not ordinarily
        ; capitalize the next thing.
        if(contains(capitalize_after_expansions, keys_to_return)) {
            autospacing := "cap-autospaced"
        }

        ; Whether or not we capitalize the next thing, we need to backspace the
        ; brief before sending the expansion and triggering delimiter
        Loop % StrLen(current_brief)
        {
            keys_to_return := "{Backspace}" . keys_to_return
        }
    }

    return keys_to_return
}

; Should only be called on things that can trigger hostrings *and* do not reset entry variables
add_undo_keys_for_hotstring_expansion_if_triggering_hotstring(undo_keys, hotstring_text) {
    if(hotstring_text != "") {
        ; The hotstring text will be backspaced before the brief text will be re-added
        ; All this happens *after* the undo behavior of the trigger key
        Loop % StrLen(rm_esc_chars(hotstring_text))
        {
            undo_keys := undo_keys . "{Backspace}"
        }
        undo_keys := undo_keys . current_brief
    }
    return undo_keys
}

; Test for:
; - Empty stack
; - Clean case: several hotstring characters on top of stack, with a delimiter under them
; - Just delimiters: only delimiters on stack
; - Mixed: delimiters on top of stack, but hotstring characters under them, and then a delimiter under them
; - Bottom of stack rather than delimiter as cutoff point
update_hotstring_state_based_on_current_sent_keys_stack() {
    current_brief := ""
    index := sent_keys_stack.Length()
    While True {
        ; If you reach the end of the stack without having hit a delimiter,
        ; short circuit before trying to grab another lower thing on the stack,
        ; since there is no other lower thing on the stack
        if(index == 0) {
            last_delimiter := ""
            break
        }
        else {
            character_on_stack := sent_keys_stack[index]
            if(is_hotstring_character(character_on_stack)) {
                current_brief := character_on_stack . current_brief
            }
            else { ; character is delimiter
                last_delimiter := character_on_stack
                break
            }
        }
        index := index - 1
    }
}

remove_word_from_top_of_stack() {
    keys_to_return := ""
    index := sent_keys_stack.Length()
    have_already_backspaced_word := False
    have_already_backspaced_space := False
    While True {
        ; If we have backspaced everything on the sent_keys_stack = are at the beginning of an entry,
        ; we stop backspacing stuff
        if(index == 0) {
            current_brief := ""
            last_delimiter := ""
            break
        }
        else {
            item_on_top_of_stack := sent_keys_stack[index]
            is_space := item_on_top_of_stack == "{Space}"
            is_enter := item_on_top_of_stack == "{Enter}"
            is_autospaced := (autospacing_state_history_stack[index] == "autospaced") or (autospacing_state_history_stack[index] == "cap-autospaced")

            ; If we have already backspaced a word and we hit a {Space} or {Enter} or a space
            ; coming from autospacing, we stop backspacing stuff
            if((is_space or is_enter or is_autospaced) and have_already_backspaced_word) {
                current_brief := ""
                last_delimiter := item_on_top_of_stack
                break
            }
            ; If we hit an {Enter} after backspacing one or more spaces (but have not yet
            ; backspaced a word), we still stop. This is the case of backspacing all leading
            ; spaces on a line, if they are used to indent something.
            else if(is_enter and have_already_backspaced_space) {
                current_brief := ""
                last_delimiter := item_on_top_of_stack
                break
            }
            ; This case is for backspacing leading {Spaces}. This one can be a terminal case if one
            ; the leading spaces (the one lowest on the stack, positionally) was a hotstring trigger.
            ; In such a case, we do backspace the hotstring expansion, but then stop there.
            else if(is_space) {
                sent_keys_stack.pop()
                locked_state_history_stack.pop()
                locked := locked_state_history_stack[index - 1]
                automatching_state_history_stack.pop()
                automatching_stack := automatching_state_history_stack[index - 1]
                autospacing_state_history_stack.pop()
                autospacing := autospacing_state_history_stack[index - 1]
                undo_keys := undo_sent_keys_stack.pop()
                keys_to_return := keys_to_return . undo_keys
                if(last_press_had_triggered_hotstring(undo_keys)) {
                    update_hotstring_state_based_on_current_sent_keys_stack()
                    break
                }
                else {
                    have_already_backspaced_space := True
                }
            }
            ; If an {Enter} is on top of the stack, we backspace it and stop right there. This {Enter}
            ; may have a triggered a hotstring, so we also have to deal with that.
            else if(is_enter and (not have_already_backspaced_word) and (not have_already_backspaced_space)) {
                sent_keys_stack.pop()
                locked_state_history_stack.pop()
                locked := locked_state_history_stack[index - 1]
                automatching_state_history_stack.pop()
                automatching_stack := automatching_state_history_stack[index - 1]
                autospacing_state_history_stack.pop()
                autospacing := autospacing_state_history_stack[index - 1]
                undo_keys := undo_sent_keys_stack.pop()
                keys_to_return := keys_to_return . undo_keys
                if(last_press_had_triggered_hotstring(undo_keys)) {
                    update_hotstring_state_based_on_current_sent_keys_stack()
                }
                break
            }
            ; Otherwise, item_on_top_of_stack is a subset of a word (a single character could compose the entire word,
            ; as with the English indefinite article 'a'; itc is a subset, not a proper subset). This one is not a 
            ; terminal conditional branch, so we don't need to adjust the hotstring variables at all. Note that this
            ; case *will* delete autospaced punctuation at the end of words, which is what we want. So if the 
            ; sent_keys_stack looked something like "one.two," and we were to trigger this function, this conditional
            ; case would actually remove the comma on top of the stack, but then the backspacing would stop with the
            ; period. (Since now have_already_backspaced_word would no longer be false). Clear as mud, right?
            else {
                sent_keys_stack.pop()
                locked_state_history_stack.pop()
                locked := locked_state_history_stack[index - 1]
                automatching_state_history_stack.pop()
                automatching_stack := automatching_state_history_stack[index - 1]
                autospacing_state_history_stack.pop()
                autospacing := autospacing_state_history_stack[index - 1]
                undo_keys := undo_sent_keys_stack.pop()
                keys_to_return := keys_to_return . undo_keys
                if(last_press_had_triggered_hotstring(undo_keys)) {
                    update_hotstring_state_based_on_current_sent_keys_stack()
                    break
                }
                else {
                    have_already_backspaced_word := True
                }
            }

            index := index -1
        }
    }
    return keys_to_return
}

last_press_had_triggered_hotstring(undo_keys){
    StringRight, last_character_in_undo_keys, undo_keys, 1
    ; The only time we would have hotstring characters = letters and numbers and apostrophe
    ; sent in the undo_keys (at the end = re-adding them) is when the last press
    ; had triggered a hotstring
    return is_hotstring_character(last_character_in_undo_keys)
}

had_triggered_hotstring(key, undo_keys) {
    space_undo_keys_if_not_triggering_hostring := ["{Backspace}"]
    enter_undo_keys_if_not_triggering_hostring := ["{Backspace}", "{Backspace}{Space}"]
    if(key == "{Space}") {
        return (not contains(space_undo_keys_if_not_triggering_hostring, undo_keys))
    }
    else { ; key == "{Enter}"
        return (not contains(enter_undo_keys_if_not_triggering_hostring, undo_keys))
    }
}

; For helping in debugging
arr_as_str(array) {
    string_representation := "`n"
    index := array.Length()
    while index >= 1 {
        string_representation := string_representation . "`n" . array[index]
        index := index -1
    }
    return string_representation
}
