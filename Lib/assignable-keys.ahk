
/*







*/



/*

Test Number Lock and Caps Lock autolocking behavior
DONE


Ellipsis and capital ellipsis
DONE

Test automatching of normal stuff likes parentheses and quotes, but also all the new inline styles
Especially test adding Markdown links (two blank behavior)
DONE

Make it so double tapping leader keys does not reset leader.
DONE

Remove {} characters from opening/between/closing character strings when looping across length, so that
the iterations come out right when sending Left/Right
DONE

Add option to not pass through capitalization for matched pair and two blank things
DONE

Re-test hotstrings now that they are organized in includes
DONE

Headers h1-h6 with hotstrings. Verify hotstring behavior with hotstrings including numbers,
and also backspacing and backspacing by word
DONE




Test raw leader and raw lock
DONE

Test cancel key (to get out of modes/inlines styles, and also to just reset layer)
DONE

Test prose mode and code mode
DONE

Test manually getting back to base layer using Base Lock key
DONE

Verifying hotstrings don't fire on Caps uppercase letters
DONE

Test action layer leader
DONE

Make underscore on shift layer not break out of caps lock (so it can be used in NAMED_CONSTANTS)
DONE

Storing locked state for resetting when backspacing/backspacing by word like auto matching and autospacing.
(Don't have leader state saving, since it doesn't do anything). So that typos when on Caps or Number Locked
; can be more easily fixed
DONE

Testing for the above: investigate backspacing behavior with shift leader, raw leader, etc.
=> Keyboard state is completely predicatable from where cursor is in what has been entered.
Backspace always takes you exactly one key state back. So if in the last key state you had base locked, that's
where you'll be. If Caps, Caps will be re-locked. If Number, Number will be re-locked.
DONE

Testing same general thing, except now backspacing by word

- Investigate issue that can randomly cause whole layout to lock up. See if can figure out how to consistly replicate
One thing that can cause this is trying to trigger something on the selection lock layer that is not defined. Since it is a lock
Not a leader, that will keep you seeminly stuck on the layer until you pressed append or insert. Another possibility seems to be related to backspacing further back than the sent_keys_stack goes. My guess is that I didn't properly handle 
the case that the array is empty, or something like that.
DONE. Fixed in backspace() function.


---------------------------------------


Investigate autospacing == "cap-autospaced" persisting through raw lock with Enter? Maybe?
Maybe need to set up conditionals for raw in letter presses? Or should raw leader/lock reset autospacing? Both?

Make it so that hundred, thousand, etc. do not add commas if the press that comes before the number sequence
is a letter, capital letter, hyphen, etc. So that can do like MPE-4000 without a comma getting added.

Make it so no commas added if in code mode (rather than prose mode), or if raw lock or in raw microstate

Make it so that dot does not break out of Caps, just like underscore. (dot on base layer will, though = dot operator)

Make new assignable key for dot on base layer. Just a normal key, does not call number formatting like dot.
What should it be called?

Hotstrings for states, countries, including all possessive forms of these. New file called proper-nouns.ahk

Hotstrings for us, usa, uae, dod, af, spers, and so on. New file called abbreviations.ahk

Set up q hotstrings for all @'s for work chat message drafting. New file called mentions.ahk


*/



/*

Test function keys, function lock accessed from command layer

Test selection layer lock as it is currently
DONE

Including with modified arrow key presses

Test modifier leader and lock

Action layer lock

Test modified mouse clicks

*/




/*

Properly do hint actuation cases, including for Tab, Enter, Actions, Space, Selections

Set up jumpselect word/WORD and jumpextend to word/WORD in Emacs

*/




/*
Adjusting genetic algorithm keyboard layout optimizers to replace all words typed with briefs with their brief form, rather than the words themselves



Investigate issue that can randomly cause characters you just typed to somehow get duplicated. See if can consistently replicate this one as well.

Investigate issue that can randomly make keyboard disconnect, with some drive pop up. RJ45 cable or something?
Reconnecting keyboard seems to fix
*/


; ----------------------------

; lowercase_letter, uppercase_letter

; DONE

; ----------------------------

; Allow for nested leader key presses (so can access Caps Leader > Inline Styles Leader, e.g.)
; without leader getting set to "" in key callbacks. Use a flag variable called is_leader_press
; and then do (if not is_leader_press leader := ""). Then always set is_leader_press := False
; in the universal key hook

; Allows accessing leader layers from other leader layers, basically

; DONE

; ----------------------------

; autospacing_stack -> autospacing_state_history_stack
; automatching_stack -> automatching_state_history_stack
; automatching -> automatching_stack

; DONE

; ----------------------------

; Inline styling: For now just get it working when in typing stream/insert
; = when accessed via Caps Leader

; Inline code, Bold, Italic, Bold Italic
; Link, inline LaTeX, definition/glossary shortcode
; Underline, strikethrough

; LaTeX:
; inlineMath: [['\\(', '\\)']],
; displayMath: [["\\[", "\\]"]],

; DONE

; ----------------------------

; Refactor Number and Caps layers to account for having only regular and autlocking versions of keys (no locked versions)

; DONE

; ----------------------------

; CapSpacing ellipsis with first press being ; on Shift layer
; Refactor dot()

; DONE

; ----------------------------

; Number sequence entry

; Hundreds, thousands, millions, billions, trillions
; Add comma separators
; Dollar currency formatting

; DONE

; ----------------------------

; Voice recognition
; Rucking pack set up

; ----------------------------

; Layer Keys
;-------------------------------------------------

; leaders = ["shift", "caps", "number", "command", "function", "actions", "inline_styles"]

shift_leader() {
    is_leader_press := True
    leader := "shift"
    locked := "base"
    return completely_internal_key()
}

caps_leader() {
    is_leader_press := True
    leader := "caps"
    locked := "base"
    return completely_internal_key()
}

number_leader() {
    is_leader_press := True
    leader := "number"
    locked := "base"
    return completely_internal_key()
}

command_leader() {
    is_leader_press := True
    leader := "command"
    locked := "base"
    return completely_internal_key()
}

function_leader() {
    is_leader_press := True
    leader := "function"
    locked := "base"
    return completely_internal_key()
}

actions_leader() {
    is_leader_press := True
    leader := "actions"
    locked := "base"
    return completely_internal_key()
}

inline_styles_leader() {
    is_leader_press := True
    leader := "inline_styles"
    locked := "base"
    return completely_internal_key()
}

; locks = ["base", "caps", "number", "function", "actions", "selection"]

base_lock() {
    leader := ""
    locked := "base"
    return completely_internal_key()
}

caps_lock() {
    leader := ""
    locked := "caps"
    return completely_internal_key()
}

number_lock() {
    leader := ""
    locked := "number"
    return completely_internal_key()
}

function_lock() {
    leader := ""
    locked := "function"
    return completely_internal_key()
}

actions_lock() {
    leader := ""
    locked := "actions"
    return completely_internal_key()
}

selection_lock() {
    leader := ""
    locked := "selection"
    return completely_internal_key()
}

; State Cancel Keys
;-------------------------------------------------

cancel() {
    leader := ""
    locked := "base"

    raw_state := ""
    in_raw_microstate := False

    modifier_state := ""
    mod_control_down := False
    mod_alt_down := False
    mod_shift_down := False

    return completely_internal_key()
}

insert_before() {
    leader := ""
    locked := "base"
    return completely_internal_key()
}

append_after() {
    leader := ""
    locked := "base"
    return completely_internal_key()
}

; Input State Keys
;-------------------------------------------------

toggle_prose() {
    leader := ""
    locked := "base"
    input_state := "prose"
    return completely_internal_key()
}

toggle_code() {
    leader := ""
    locked := "base"
    input_state := "code"
    return completely_internal_key()
}

; Raw state Keys
;-------------------------------------------------

raw_leader() {
    leader := ""
    locked := "base"
    raw_state := "leader"
    return completely_internal_key()
}

raw_lock() {
    leader := ""
    locked := "base"
    raw_state := "lock"
    return completely_internal_key()
}

; Modifier State Keys
;-------------------------------------------------

mod_control_leader() {
    leader := ""
    locked := "base"
    modifier_state := "leader"
    mod_control_down := True
    return completely_internal_key()
}

mod_alt_leader() {
    leader := ""
    locked := "base"
    modifier_state := "leader"
    mod_alt_down := True
    return completely_internal_key()
}

mod_shift_leader() {
    leader := ""
    locked := "base"
    modifier_state := "leader"
    mod_shift_down := True
    return completely_internal_key()
}

mod_control_lock() {
    leader := ""
    locked := "base"
    modifier_state := "lock"
    mod_control_down := True
    return completely_internal_key()
}

mod_alt_lock() {
    leader := ""
    locked := "base"
    modifier_state := "lock"
    mod_alt_down := True
    return completely_internal_key()
}

mod_shift_lock() {
    leader := ""
    locked := "base"
    modifier_state := "lock"
    mod_shift_down := True
    return completely_internal_key()
}

mod_control() {
    ; Actuated from base layer, so no need to lock it
    mod_control_down := True
    return completely_internal_key()
}

mod_alt() {
    ; Actuated from base layer, so no need to lock it
    mod_alt_down := True
    return completely_internal_key()
}

mod_shift() {
    ; Actuated from base layer, so no need to lock it
    mod_shift_down := True
    return completely_internal_key()
}

; Lowercase Letters
;-------------------------------------------------

; ASCII 97 (base 10)
lowercase_a() {
    return lowercase_letter_key("a", "A")
}

; ASCII 98 (base 10)
lowercase_b() {
    return lowercase_letter_key("b", "B")
}

; ASCII 99 (base 10)
lowercase_c() {
    return lowercase_letter_key("c", "C")
}

; ASCII 100 (base 10)
lowercase_d() {
    return lowercase_letter_key("d", "D")
}

; ASCII 101 (base 10)
lowercase_e() {
    return lowercase_letter_key("e", "E")
}

; ASCII 102 (base 10)
lowercase_f() {
    return lowercase_letter_key("f", "F")
}

; ASCII 103 (base 10)
lowercase_g() {
    return lowercase_letter_key("g", "G")
}

; ASCII 104 (base 10)
lowercase_h() {
    return lowercase_letter_key("h", "H")
}

; ASCII 105 (base 10)
lowercase_i() {
    return lowercase_letter_key("i", "I")
}

; ASCII 106 (base 10)
lowercase_j() {
    return lowercase_letter_key("j", "J")
}

; ASCII 107 (base 10)
lowercase_k() {
    return lowercase_letter_key("k", "K")
}

; ASCII 108 (base 10)
lowercase_l() {
    return lowercase_letter_key("l", "L")
}

; ASCII 109 (base 10)
lowercase_m() {
    return lowercase_letter_key("m", "M")
}

; ASCII 110 (base 10)
lowercase_n() {
    return lowercase_letter_key("n", "N")
}

; ASCII 111 (base 10)
lowercase_o() {
    return lowercase_letter_key("o", "O")
}

; ASCII 112 (base 10)
lowercase_p() {
    return lowercase_letter_key("p", "P")
}

; ASCII 113 (base 10)
lowercase_q() {
    return lowercase_letter_key("q", "Q")
}

; ASCII 114 (base 10)
lowercase_r() {
    return lowercase_letter_key("r", "R")
}

; ASCII 115 (base 10)
lowercase_s() {
    return lowercase_letter_key("s", "S")
}

; ASCII 116 (base 10)
lowercase_t() {
    return lowercase_letter_key("t", "T")
}

; ASCII 117 (base 10)
lowercase_u() {
    return lowercase_letter_key("u", "U")
}

; ASCII 118 (base 10)
lowercase_v() {
    return lowercase_letter_key("v", "V")
}

; ASCII 119 (base 10)
lowercase_w() {
    return lowercase_letter_key("w", "W")
}

; ASCII 120 (base 10)
lowercase_x() {
    return lowercase_letter_key("x", "X")
}

; ASCII 121 (base 10)
lowercase_y() {
    return lowercase_letter_key("y", "Y")
}

; ASCII 122 (base 10)
lowercase_z() {
    return lowercase_letter_key("z", "Z")
}

; Uppercase Letters
;-------------------------------------------------

; ASCII 65 (base 10)
uppercase_a() {
    return uppercase_letter_key("A")
}

; ASCII 66 (base 10)
uppercase_b() {
    return uppercase_letter_key("B")
}

; ASCII 67 (base 10)
uppercase_c() {
    return uppercase_letter_key("C")
}

; ASCII 68 (base 10)
uppercase_d() {
    return uppercase_letter_key("D")
}

; ASCII 69 (base 10)
uppercase_e() {
    return uppercase_letter_key("E")
}

; ASCII 70 (base 10)
uppercase_f() {
    return uppercase_letter_key("F")
}

; ASCII 71 (base 10)
uppercase_g() {
    return uppercase_letter_key("G")
}

; ASCII 72 (base 10)
uppercase_h() {
    return uppercase_letter_key("H")
}

; ASCII 73 (base 10)
uppercase_i() {
    return uppercase_letter_key("I")
}

; ASCII 74 (base 10)
uppercase_j() {
    return uppercase_letter_key("J")
}

; ASCII 75 (base 10)
uppercase_k() {
    return uppercase_letter_key("K")
}

; ASCII 76 (base 10)
uppercase_l() {
    return uppercase_letter_key("L")
}

; ASCII 77 (base 10)
uppercase_m() {
    return uppercase_letter_key("M")
}

; ASCII 78 (base 10)
uppercase_n() {
    return uppercase_letter_key("N")
}

; ASCII 79 (base 10)
uppercase_o() {
    return uppercase_letter_key("O")
}

; ASCII 80 (base 10)
uppercase_p() {
    return uppercase_letter_key("P")
}

; ASCII 81 (base 10)
uppercase_q() {
    return uppercase_letter_key("Q")
}

; ASCII 82 (base 10)
uppercase_r() {
    return uppercase_letter_key("R")
}

; ASCII 83 (base 10)
uppercase_s() {
    return uppercase_letter_key("S")
}

; ASCII 84 (base 10)
uppercase_t() {
    return uppercase_letter_key("T")
}

; ASCII 85 (base 10)
uppercase_u() {
    return uppercase_letter_key("U")
}

; ASCII 86 (base 10)
uppercase_v() {
    return uppercase_letter_key("V")
}

; ASCII 87 (base 10)
uppercase_w() {
    return uppercase_letter_key("W")
}

; ASCII 88 (base 10)
uppercase_x() {
    return uppercase_letter_key("X")
}

; ASCII 89 (base 10)
uppercase_y() {
    return uppercase_letter_key("Y")
}

; ASCII 90 (base 10)
uppercase_z() {
    return uppercase_letter_key("Z")
}

caps_lock_a() {
    return caps_lock_letter_key("A")
}

caps_lock_b() {
    return caps_lock_letter_key("B")
}

caps_lock_c() {
    return caps_lock_letter_key("C")
}

caps_lock_d() {
    return caps_lock_letter_key("D")
}

caps_lock_e() {
    return caps_lock_letter_key("E")
}

caps_lock_f() {
    return caps_lock_letter_key("F")
}

caps_lock_g() {
    return caps_lock_letter_key("G")
}

caps_lock_h() {
    return caps_lock_letter_key("H")
}

caps_lock_i() {
    return caps_lock_letter_key("I")
}

caps_lock_j() {
    return caps_lock_letter_key("J")
}

caps_lock_k() {
    return caps_lock_letter_key("K")
}

caps_lock_l() {
    return caps_lock_letter_key("L")
}

caps_lock_m() {
    return caps_lock_letter_key("M")
}

caps_lock_n() {
    return caps_lock_letter_key("N")
}

caps_lock_o() {
    return caps_lock_letter_key("O")
}

caps_lock_p() {
    return caps_lock_letter_key("P")
}

caps_lock_q() {
    return caps_lock_letter_key("Q")
}

caps_lock_r() {
    return caps_lock_letter_key("R")
}

caps_lock_s() {
    return caps_lock_letter_key("S")
}

caps_lock_t() {
    return caps_lock_letter_key("T")
}

caps_lock_u() {
    return caps_lock_letter_key("U")
}

caps_lock_v() {
    return caps_lock_letter_key("V")
}

caps_lock_w() {
    return caps_lock_letter_key("W")
}

caps_lock_x() {
    return caps_lock_letter_key("X")
}

caps_lock_y() {
    return caps_lock_letter_key("Y")
}

caps_lock_z() {
    return caps_lock_letter_key("Z")
}

caps_lock_a_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("A")
}

caps_lock_b_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("B")
}

caps_lock_c_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("C")
}

caps_lock_d_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("D")
}

caps_lock_e_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("E")
}

caps_lock_f_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("F")
}

caps_lock_g_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("G")
}

caps_lock_h_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("H")
}

caps_lock_i_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("I")
}

caps_lock_j_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("J")
}

caps_lock_k_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("K")
}

caps_lock_l_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("L")
}

caps_lock_m_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("M")
}

caps_lock_n_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("N")
}

caps_lock_o_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("O")
}

caps_lock_p_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("P")
}

caps_lock_q_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("Q")
}

caps_lock_r_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("R")
}

caps_lock_s_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("S")
}

caps_lock_t_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("T")
}

caps_lock_u_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("U")
}

caps_lock_v_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("V")
}

caps_lock_w_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("W")
}

caps_lock_x_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("X")
}

caps_lock_y_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("Y")
}

caps_lock_z_autolock_caps_layer() {
    return caps_lock_letter_key_autolock_caps_layer("Z")
}

; Numbers
;-------------------------------------------------

; ASCII 48 (base 10)
zero() {
    return number_key("0")
}

; ASCII 49 (base 10)
one() {
    return number_key("1")
}

; ASCII 50 (base 10)
two() {
    return number_key("2")
}

; ASCII 51 (base 10)
three() {
    return number_key("3")
}

; ASCII 52 (base 10)
four() {
    return number_key("4")
}

; ASCII 53 (base 10)
five() {
    return number_key("5")
}

; ASCII 54 (base 10)
six() {
    return number_key("6")
}

; ASCII 55 (base 10)
seven() {
    return number_key("7")
}

; ASCII 56 (base 10)
eight() {
    return number_key("8")
}

; ASCII 57 (base 10)
nine() {
    return number_key("9")
}

zero_autolock_number_layer() {
    return number_key_autolock_number_layer("0")
}

one_autolock_number_layer() {
    return number_key_autolock_number_layer("1")
}

two_autolock_number_layer() {
    return number_key_autolock_number_layer("2")
}

three_autolock_number_layer() {
    return number_key_autolock_number_layer("3")
}

four_autolock_number_layer() {
    return number_key_autolock_number_layer("4")
}

five_autolock_number_layer() {
    return number_key_autolock_number_layer("5")
}

six_autolock_number_layer() {
    return number_key_autolock_number_layer("6")
}

seven_autolock_number_layer() {
    return number_key_autolock_number_layer("7")
}

eight_autolock_number_layer() {
    return number_key_autolock_number_layer("8")
}

nine_autolock_number_layer() {
    return number_key_autolock_number_layer("9")
}

; Prose Punctuation
;-------------------------------------------------

; Cannot just use normal_key() since apostrophe needs to be a hotstring character key
; ASCII 39 (base 10)
apostrophe() {
    if(modifier_state == "leader" or modifier_state == "locked") {
        keys_to_return := build_modifier_combo("'", can_be_modified)
        return hotstring_trigger_action_key_untracked_reset_entry_related_variables("'", keys_to_return)
    }
    ; In AceJump flags, it is only ever the first press that
    ; may end up a non-letter character. This is because the 
    ; plugin uses the capitalization of the second character
    ; (always a letter) to control its jump_selecting behavior.
    else if(presses_left_until_hint_actuation == 2) {
        presses_left_until_hint_actuation := presses_left_until_hint_actuation - 1
        ; Always comes after jump key that clears sent_keys_stack
        return hotstring_neutral_key("'", "'")
    }
    else {
        autospacing := "not-autospaced"
        keys_to_return := "'"
        undo_keys := "{Backspace}"
        return hotstring_character_key("'", keys_to_return, undo_keys)
    }
}

; ASCII 45 (base 10)
hyphen() {
    return inactive_delimiter_key("-")
}

en_dash() {
    return normal_key("–", False)
}

em_dash() {
    return normal_key("—", False)
}

; ASCII 47 (base 10)
back_slash() {
    return normal_key("/")
}

; ASCII 44 (base 10)
comma() {
    ; Autospaces in code too. One of the few things to do so
    return no_cap_punctuation_key(",")
}

; ASCII 59 (base 10)
semicolon() {
    ; Autospaces in code too. One of the few things to do so
    return no_cap_punctuation_key(";")
}

; ASCII 58 (base 10)
colon() {
    ; Autospaces in code too. One of the few things to do so
    ; Used for properties in CSS, and also used a lot in JSON.
    ; Also used for declaring types in Typescript
    return no_cap_punctuation_key(":", False)
}

; ASCII 46 (base 10)
period() {
    if(prose_mode_should_be_active()) {

        is_modifiers_press := (modifier_state == "leader" or modifier_state == "locked")
        is_hint_actuation_press := presses_left_until_hint_actuation > 0
        is_raw_press := (raw_state == "leader" or raw_state == "lock" or in_raw_microstate())
        expect_autospaced_period :=  (not is_modifiers_press) and (not is_hint_actuation_press) and (not is_raw_press)

        ; Don't even do checks for ellipsis expansion unless actually going to enter
        ; a period character (as opposed to a modifier combo, etc.)
        if(expect_autospaced_period) {
            sent_keys_stack_length := sent_keys_stack.Length()
            one_key_back := ""
            if(sent_keys_stack_length >= 1) {
                one_key_back := sent_keys_stack[sent_keys_stack_length]
            }
            ; Multiple consecutive presses = transform into ellipsis *without* capitalization
            if(one_key_back == ".") {
                autospacing := "autospaced"
                keys_to_return := "{Backspace}" . "." . "{Space}"
                undo_keys := "{Backspace 2}{Space}"
                return hotstring_trigger_delimiter_key_tracked(".", keys_to_return, undo_keys)
            }
            ; Multiple consecutive presses after pressing Shift Leader = transform into ellipsis *with* capitalization.
            ; Semicolon is the character on the same position as period on Shift Leader, which is why we check
            ; its value when looking at one_key_back
            else if(one_key_back == ";") {
                autospacing := "cap-autospaced"
                keys_to_return := "{Backspace 2}" . ".." . "{Space}"
                undo_keys := "{Backspace 3};{Space}"
                ; The name we use for the keypress on the stack is important. It can't simply be "."
                ; because then we would trigger the non-capitlized ellipsis conditional case above.
                ; Using this name means we'll fall through to the normal behavior below on the third press,
                ; which is what we want since that will complete an autospaced autocapitalized ellipsis.
                return hotstring_trigger_delimiter_key_tracked("cap-ellipsis", keys_to_return, undo_keys)
            }
            ; Normal period behavior
            else {
                return cap_punctuation_key(".")
            }
        }
        ; It also follows the normal pattern for all modifier, hint actuation, and raw presses
        else {
            return cap_punctuation_key(".")
        }
    }
    ; Becomes dot operator in code
    else { ; Code mode is active
        return normal_key(".")
    }
}

; ASCII 63 (base 10)
question_mark() {
    if(prose_mode_should_be_active()) {
        return cap_punctuation_key("?", False)
    }
    ; Used as a null indicator in some programming languages,
    ; and is also used as part of the syntax for ternary operator
    ; in some programming languages
    else { ; Code mode is active
        return normal_key("?", False)
    }
}

; ASCII 33 (base 10)
exclamation_mark() {
    if(prose_mode_should_be_active()) {
        return cap_punctuation_key("{!}", False)
    }
    ; Used sometimes as a postfix when defining parameters in Typescript.
    ; Otherwise mostly used in !=, which is consistent across many programming languages
    else { ; Code mode is active
        return normal_key("{!}", False)
    }
}

; ASCII 34 (base 10)
quotes() {
    if(prose_mode_should_be_active()) {
        return matched_pair_key("""", """", True, False)
    }
    ; Let text editors handle auto-pairing
    else { ; Code mode is active
        return normal_key("""", False)
    }
}

single_quotes() {
    if(prose_mode_should_be_active()) {
        return matched_pair_key("'", "'", True, False)
    }
    ; Let text editors handle auto-pairing
    else { ; Code mode is active
        return normal_key("'", False)
    }
}

; ASCII 40 (base 10)
open_parenthesis() {
    if(prose_mode_should_be_active()) {
        return matched_pair_key("(", ")", True, False)
    }
    ; Let text editors handle auto-pairing
    else { ; Code mode is active
        return normal_key("(", False)
    }
}

; ASCII 41 (base 10)
; Functions similarly in prose and code input modes.
; Just lacks the trailing {Space} and autospacing in code mode
close_parenthesis() {
    if(modifier_state == "leader" or modifier_state == "locked") {
        keys_to_return := build_modifier_combo(")", False)
        return hotstring_trigger_action_key_untracked_reset_entry_related_variables(")", keys_to_return)
    }
    else if(presses_left_until_hint_actuation == 2) {
        presses_left_until_hint_actuation := presses_left_until_hint_actuation - 1
        if(raw_state == "leader") {
            raw_state := ""
        }
        ; Always comes after jump key that clears sent_keys_stack
        return hotstring_neutral_key(")", ")")
    }
    else {
        if(manually_automatching) {
            return close_parenthesis_manual_automatching() 
        }
        else {
            return close_parenthesis_instant_automatching()
        }
    }
}

close_parenthesis_instant_automatching() {
    if(prose_mode_should_be_active()) {
        keys_to_return := ""
        undo_keys := ""
        if(raw_state == "leader") {
            keys_to_return := ")"
            undo_keys := "{Backspace}"
            raw_state := ""
        }
        else if((raw_state == "lock") or in_raw_microstate()) {
            keys_to_return := ")"
            undo_keys := "{Backspace}"
        }
        else {
            stack_entry := automatching_stack.Pop()
            first_character := SubStr(stack_entry, 1, 1)
            ; Representing the fact that this stack entry corresponds to between_characters
            ; rather than opening_characters or closing_characters
            is_between_characters_completion := first_character == "b"
            automatch_characters := ""
            if(is_between_characters_completion) {
                ; From second character in string to the end of the string
                automatch_characters := SubStr(stack_entry, 2)
            }
            else {
                ; No leading "b" in this case
                automatch_characters := stack_entry
            }
            if(autospacing == "autospaced" or autospacing == "cap-autospaced") {
                keys_to_return := "{Backspace}"
                Loop % StrLen(rm_esc_chars(automatch_characters)) {
                    keys_to_return := keys_to_return . "{Right}"
                }
                undo_keys := ""
                if(not is_between_characters_completion) {
                    keys_to_return := keys_to_return . "{Space}"
                    undo_keys := undo_keys . "{Backspace}"
                }
                Loop % StrLen(rm_esc_chars(automatch_characters)) {
                    undo_keys := undo_keys . "{Left}"
                }
                undo_keys := undo_keys . "{Space}"
            }
            else { ; autospacing == "not-autospaced"
                autospacing := "autospaced"
                keys_to_return := ""
                Loop % StrLen(rm_esc_chars(automatch_characters)) {
                    keys_to_return := keys_to_return . "{Right}"
                }
                undo_keys := ""
                if(not is_between_characters_completion) {
                    keys_to_return := keys_to_return . "{Space}"
                    undo_keys := undo_keys . "{Backspace}"
                }
                Loop % StrLen(rm_esc_chars(automatch_characters)) {
                    undo_keys := undo_keys . "{Left}"
                }
            }
        }
        return hotstring_trigger_delimiter_key_tracked(")", keys_to_return, undo_keys)
    }
    else { ; Code mode is active
        keys_to_return := ""
        undo_keys := ""
        autospacing := "not-autospaced"
        if(raw_state == "leader") {
            keys_to_return := ")"
            undo_keys := "{Backspace}"
            raw_state := ""
        }
        else if((raw_state == "lock") or in_raw_microstate()) {
            keys_to_return := ")"
            undo_keys := "{Backspace}"
        }
        else {
            keys_to_return := "{Right}"
            undo_keys := "{Left}"
        }
        return hotstring_trigger_delimiter_key_tracked(")", keys_to_return, undo_keys)
    }
}

close_parenthesis_manual_automatching() {
    if(prose_mode_should_be_active()) {
        keys_to_return := ""
        undo_keys := ""
        if(raw_state == "leader") {
            keys_to_return := ")"
            undo_keys := "{Backspace}"
            raw_state := ""
        }
        else if((raw_state == "lock") or in_raw_microstate()) {
            keys_to_return := ")"
            undo_keys := "{Backspace}"
        }
        else {
            ; When we are manually automatching = taking typing tests, we will never have
            ; between_characters completion to worry about. So we can keep this function
            ; a bit simpler than the instant automatching equivalent defined above
            automatch_characters := automatching_stack.Pop()
            if(autospacing == "autospaced" or autospacing == "cap-autospaced") {
                keys_to_return := "{Backspace}" . automatch_characters . "{Space}"
                undo_keys := "{Backspace}"
                Loop % StrLen(rm_esc_chars(automatch_characters)) {
                    undo_keys := undo_keys . "{Backspace}"
                }
                undo_keys := undo_keys . "{Space}"
            }
            else { ; autospacing == "not-autospaced"
                autospacing := "autospaced"
                keys_to_return := automatch_characters . "{Space}"
                undo_keys := "{Backspace}"
                Loop % StrLen(rm_esc_chars(automatch_characters)) {
                    undo_keys := undo_keys . "{Backspace}"
                }
            }
        }
        return hotstring_trigger_delimiter_key_tracked(")", keys_to_return, undo_keys)
    }
    else { ; Code mode is active
        keys_to_return := ""
        undo_keys := ""
        autospacing := "not-autospaced"
        if(raw_state == "leader") {
            keys_to_return := ")"
            undo_keys := "{Backspace}"
            raw_state := ""
        }
        else if((raw_state == "lock") or in_raw_microstate()) {
            keys_to_return := ")"
            undo_keys := "{Backspace}"
        }
        else {
            keys_to_return := "{Right}"
            undo_keys := "{Left}"
        }
        return hotstring_trigger_delimiter_key_tracked(")", keys_to_return, undo_keys)
    }
}

; ASCII 91 (base 10)
open_bracket() {
    if(prose_mode_should_be_active()) {
        return matched_pair_key("[", "]", True, True)
    }
    ; Let text editors handle auto-pairing
    else { ; Code mode is active
        return normal_key("[", True)
    }
}

; ASCII 93 (base 10)
close_bracket() {
    ; Not used much, since I use the base-layer ) key
    ; to "close" auto-paired things
    return normal_key("]", True)
}

; Symbols / Remaining Characters
;-------------------------------------------------

; This one is weird since we want the character saved in
; sent_keys_stack to be "dot" rather than ".", so that there
; is no confusion with period.
dot() {
    if(modifier_state == "leader" or modifier_state == "locked") {
        keys_to_return := build_modifier_combo(".", can_be_modified)
        return hotstring_trigger_action_key_untracked_reset_entry_related_variables("dot", keys_to_return)
    }
    ; In AceJump flags, it is only ever the first press that
    ; may end up a non-letter character. This is because the 
    ; plugin uses the capitalization of the second character
    ; (always a letter) to control its jump_selecting behavior.
    else if(presses_left_until_hint_actuation == 2) {
        presses_left_until_hint_actuation := presses_left_until_hint_actuation - 1
        ; Always comes after jump key that clears sent_keys_stack
        return hotstring_neutral_key("dot", ".")
    }
    else {
        return number_formatter("dot", "", "")
    }
}

; ASCII 35 (base 10)
number_sign() {
    return normal_key("{#}", False)
}

; ASCII 36 (base 10)
dollar_sign() {
    if(prose_mode_should_be_active()) {
        return space_before_key("$", False)
    }
    ; Not used in coding much at all, unless you write lots of Bash and Perl...
    else { ; Code mode is active
        return normal_key("$", False)
    }
}

; ASCII 37 (base 10)
percent_sign() {
    if(prose_mode_should_be_active()) {
        return space_after_key("%", False)
    }
    ; Can't autospace % (mod operator but also normal %). Also can't autospace
    ; - (kabob-casing), <> (HTML tags), & (when used in HTML like &nbsp;), etc.
    ; So just don't autospace operators to be consistent
    else { ; Code mode is active
        return normal_key("%", False)
    }
}

; ASCII 38 (base 10)
ampersand() {
    if(prose_mode_should_be_active()) {
        return space_before_and_after_key("&", False)
    }
    ; Can't autospace & (AND operator, but also used in HTML like &nbsp;). 
    ; Also can't autospace - (kabob-casing), <> (HTML tags), etc. So 
    ; just don't autospace operators to be consistent
    else { ; Code mode is active
        return normal_key("&", False)
    }
}

; ASCII 42 (base 10)
asterisk() {
    return normal_key("*", False)
}

; ASCII 43 (base 10)
plus_sign() {
    if(prose_mode_should_be_active()) {
        return space_before_and_after_key("{+}", False)
    }
    ; Could probably autospace +, but can't autospace - (kabob-casing), <> (HTML tags), 
    ; & (when used in HTML like &nbsp;), etc. So just don't autospace operators
    ; to be consistent
    else { ; Code mode is active
        return normal_key("{+}", False)
    }
}

; ASCII 60 (base 10)
less_than() {
    ; Let text editors handle auto-pairing when in HTML etc. files
    ; Can't autospace as an operator since it is also used
    ; for tags in HTML and XML, components in Angular, etc.
    return normal_key("<", False)
}

; TODO: handle with ! before it for not equals, and : after it (AutoHotkey)
; Also ==, <=, >= ?
; ASCII 61 (base 10)
equal_sign() {
    return space_before_and_after_key("=")
}

; ASCII 62 (base 10)
greater_than() {
    ; Used for block quotes in Markdown
    if(prose_mode_should_be_active()) {
        return space_after_key(">", False)
    }
    ; Can't autospace as an operator since it is also used
    ; for tags in HTML and XML, components in Angular, etc.
    else { ; Code mode is active
        return normal_key(">", False)
    }
}

; ASCII 64 (base 10)
at_sign() {
    return inactive_delimiter_key("@", False)
}

; ASCII 92 (base 10)
forward_slash() {
    ; Used in Windows file paths, and also for escaping things
    ; (be that in regular expressions or otherwise)
    return inactive_delimiter_key("\")
}

; ASCII 94 (base 10)
caret() {
    ; Could probably autospace ^, but can't autospace - (kabob-casing), <> (HTML tags), 
    ; & (when used in HTML like &nbsp;), etc. So just don't autospace operators
    ; to be consistent
    return normal_key("{^}", False)
}

; ASCII 95 (base 10)
underscore() {
    ; Used in the names of variables and constants in many programming languages
    return inactive_delimiter_key("_", False)
}

; ASCII 96 (base 10)
backtick() {
    return normal_key("``")
}

; ASCII 123 (base 10)
open_brace() {
    if(prose_mode_should_be_active()) {
        return matched_pair_key("{{}", "{}}", True, False)
    }
    ; Let text editors handle auto-pairing
    else { ; Code mode is active
        return normal_key("{{}", False)
    }
}

; ASCII 124 (base 10)
pipe() {
    if(prose_mode_should_be_active()) {
        return space_before_and_after_key("|", False)
    }
    ; Could probably autospace |, but can't autospace - (kabob-casing), <> (HTML tags), 
    ; & (when used in HTML like &nbsp;), etc. So just don't autospace operators
    ; to be consistent
    else { ; Code mode is active
        return normal_key("|", False)
    }
}

; ASCII 125 (base 10)
close_brace() {
    ; Not used much, since I use the base-layer ) key
    ; to "close" auto-paired things
    return normal_key("{}}", False)
}

; ASCII 126 (base 10)
tilde() {
    ; Used primarily for showing approximation, like "He'll be here in ~30 minutes"
    ; A different thing on the function layer handles ~~strikethrough~~ text in Markdown
    if(prose_mode_should_be_active()) {
        return space_before_key("~", False)
    }
    ; Not used much at all
    else { ; Code mode is active
        return normal_key("~", False)
    }
}

; Number Lock Special Keys
;-------------------------------------------------

number_lock_colon() {
    return normal_key(":", False)
}


str_join(separator, array_of_strings) {
    str := ""
    for index, item in array_of_strings
        str .= separator . item
    return SubStr(str, StrLen(separator) + 1)
}

add_commas_to_non_decimal_portion(non_decimal_portion) {
    num_digits := StrLen(non_decimal_portion)
    ; With three or less digits, we don't add any commas at all
    if(num_digits <= 3) {
        return non_decimal_portion
    }
    else{
        non_decimal_portion_with_commas := ""

        ; We loop from the end of the string to the beginning, since commas are added every three
        ; from the end, not every three from the beginning
        offset_from_end := 1
        Loop % num_digits {
            i := (num_digits + 1) - offset_from_end
            ; We add a comma before every third digit, unless that digit is the beginning of the non_decimal_portion
            if((Mod(offset_from_end, 3) == 0) and (offset_from_end != num_digits)) {
                non_decimal_portion_with_commas := "," . SubStr(non_decimal_portion, i, 1) . non_decimal_portion_with_commas
                offset_from_end := offset_from_end + 1
            }
            else {
                non_decimal_portion_with_commas := SubStr(non_decimal_portion, i, 1) . non_decimal_portion_with_commas
                offset_from_end := offset_from_end + 1
            }
        }
    return non_decimal_portion_with_commas
    }
}

; eleven thousand two hundred = 112{hundred} --> 11,200
; five hundred thousand = 5{hundred}{thousand} --> 500,000
; seven hundred dollars = 7{hundred}{dollars} --> $700

; This is a helper method used to do most of the number formatting
; If zeroes_to_add = "" this function will just add commas to
; the number. Otherwise, it will add zeroes, and then add commas.
; It is smart enough to not mess up if a currency operation (which auto-adds commas)
; follows an operation that has already added commas (thousand, e.g.).
; It will also eat presses that don't make sense (thousand followed by
; billion, e.g.).
number_formatter(operation_name, zeroes_to_add, currency) {

    ; Eat keypress if have nothing on sent_keys_stack := just moved location or whatever
    i := sent_keys_stack.Length()
    if(i == 0) {
        return eat_keypress()
    }

    ; Get string representing all the contiguous number-related presses on the top of the stack.
    ; Dot included, for decimal numbers.
    ; -----------------------------------------------------
    ; There are five cases we have, based upon how the number looks:
    ;   . (just decimal point, has_decimal == True)
    ;   111 (just non_decimal_portion, has_decimal == False)
    ;   111. (just non_decimal_portion, has_decimal == True)
    ;   .111 (just decimal_portion, has_decimal == True)
    ;   111.111 (both decimal and non_decimal portions, has_decimal == True)
    commas_already_added := False
    numbers := ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    includes_hundred_press := False
    has_decimal := False
    non_decimal_portion := ""
    decimal_portion := ""
    While (i >= 1) {
        stack_item := sent_keys_stack[i]
        ;MsgBox % sent_keys_stack[i] . "`n`n" . contains(numbers, stack_item)
        if(contains(numbers, stack_item)) {
            non_decimal_portion := stack_item . non_decimal_portion
            i := i - 1
        }
        else if(stack_item == "hundred") {
            ; Commas are only added with a hundreds press if there are at least two
            ; significant digits already. So we can't determinstically set
            ; commas_already_added here. We have to do a check at the end (see below)
            includes_hundred_press := True
            non_decimal_portion := "00" . non_decimal_portion
            i := i - 1
        }
        else if(stack_item == "thousand") {
            commas_already_added := True
            non_decimal_portion := "000" . non_decimal_portion
            i := i - 1
        }
        else if(stack_item == "million") {
            commas_already_added := True
            non_decimal_portion := "000000" . non_decimal_portion
            i := i - 1
        }
        else if(stack_item == "billion") {
            commas_already_added := True
            non_decimal_portion := "000000000" . non_decimal_portion
            i := i - 1
        }
        else if(stack_item == "trillion") {
            commas_already_added := True
            non_decimal_portion := "000000000000" . non_decimal_portion
            i := i - 1
        }
        else if(stack_item == "dot") {
            commas_already_added := True
            has_decimal := True
            decimal_portion := non_decimal_portion
            non_decimal_portion := ""
            i := i - 1
        }
        else if(stack_item == "add_commas") {
            commas_already_added := True
            i := i - 1
        }
        else {
            ; TODO: press_before_number_sequence := stack_item
            ; If letter, uppercase letter, caps_lock_letter, hyphen, then disable comma adding
            break
        }
    }

    ; This is where we set commas_already_added as applicable for the hundred case
    ; We only add commas (set commas_already_added to True) if there are two or more digits
    ; other than the zeroes (bringing the total to more than three)
    if(includes_hundred_press and StrLen(non_decimal_portion) >= 4) {
        commas_already_added := True
    }

    ; Short circuit if there are no number related presses on top of stack.
    ; Most operations will simply not do anything if they don't follow a number sequence.
    ; Dot is an exception, since it can be used after letters etc. in some cases (usernames, e.g.)
    if(non_decimal_portion == "" and decimal_portion == "" and (not has_decimal)) {
        if(operation_name == "dot") {
            return hotstring_inactive_delimiter_key_tracked("dot", ".", "{Backspace}")
        }
        else {
            return eat_keypress()
        }
    }

    ; Also short circuit if we are adding a decimal point but there are already one
    ; or more present in the number string. Cf. IP addresses and sections in documents
    ; (like section A.1.5, or whatever)
    if(operation_name == "dot" and has_decimal) {
        return hotstring_inactive_delimiter_key_tracked("dot", ".", "{Backspace}")
    }

    ; Also short circuit if we are adding a decimal point and we don't have any commas to add
    ; TODO: what if you have something like "Manual section 4200.1"? Raw dot then?
    if((operation_name == "dot") and (not commas_already_added) and (StrLen(non_decimal_portion) <= 3)) {
        return hotstring_inactive_delimiter_key_tracked("dot", ".", "{Backspace}")
    }

    ; Get string representing the old_number, including any added commas
    if(commas_already_added) {
        non_decimal_portion := add_commas_to_non_decimal_portion(non_decimal_portion)
    }
    old_number := non_decimal_portion
    if(has_decimal) {
        old_number := old_number . "." . decimal_portion
    }
     
    ; In practice, has_decimal controls whether zeroes get added to the decimal or
    ; non_decimal portion, and since commas only ever get added to the non-decimal
    ; portion, they are neither here nor there when it comes to the five cases
    ; enumerated above
    new_non_decimal_portion := ""
    new_decimal_portion := ""
    new_number := ""
    if(has_decimal) {
        ; First add zeroes, if applicable
        new_decimal_portion := decimal_portion . zeroes_to_add
        ; Then add commas, if applicable
        if(not commas_already_added) {
            new_non_decimal_portion := add_commas_to_non_decimal_portion(non_decimal_portion)
        }
        else {
            new_non_decimal_portion := non_decimal_portion
        }
        new_number := new_non_decimal_portion . "." . new_decimal_portion
        ; Then add currency symbol, if applicable
        if(currency != "") {
            currency_properties := currency_map[currency]
            currency_symbol := currency_properties["symbol"]
            symbol_location := currency_properties["symbol_location"]
            if(symbol_location == "prefix") {
                new_number := currency_symbol . new_number
            }
            else if(symbol_location == "postfix") {
                new_number := new_number . currency_symbol
            }
        }
    }
    else {
        ; First add zeroes, if applicable
        new_non_decimal_portion := non_decimal_portion . zeroes_to_add
        ; Then add commas, if applicable
        if(not commas_already_added) {
            new_non_decimal_portion := add_commas_to_non_decimal_portion(new_non_decimal_portion)
        }
        ; Then add decimal point, if applicable (will be mutually exclusive with adding
        ; zeroes, in practice. Dot operation vs. hundred, thousand, etc.)
        if(operation_name == "dot") {
            new_non_decimal_portion := new_non_decimal_portion . "."
        }
        new_number := new_non_decimal_portion
        ; Then add currency symbol, if applicable
        if(currency != "") {
            currency_properties := currency_map[currency]
            currency_symbol := currency_properties["symbol"]
            symbol_location := currency_properties["symbol_location"]
            if(symbol_location == "prefix") {
                new_number := currency_symbol . new_number
            }
            else if(symbol_location == "postfix") {
                new_number := new_number . currency_symbol
            }
        }
    }

    ; For efficiency's sake, we only want to be backspacing/re-adding the bare minimum.
    ; What that means: if the old_number and new number share the first few characters,
    ; there is no point in backspacing them only to add the exact same characters back.
    ; So we need to figure out how many "shared" characters there are. There are some additional
    ; wrinkles too:
    ;   - Any time you are using a currency with a prefix symbol location, there will be nothing
    ;     shared, since the currency symbol needs to go before everything else that was there.
    ;   - Commas count. In practice this mostly comes into play with the dot operator if it 
    ;     follows like hundred, thousand, etc., since commas would already have been added in
    ;     such a case.

    i := 1
    Loop % StrLen(old_number) {
        if(SubStr(old_number, i, 1) == SubStr(new_number, i, 1)) {
            i := i + 1
        }
        else {
            break
        }
    }

    old_number_with_shared_removed := SubStr(old_number, i)
    new_number_with_shared_removed := SubStr(new_number, i)

    ; For keys_to_return, we want to backspace the old number, and then send the
    ; new formatted number (with zeroes and/or commas added as applicable).
    keys_to_return := ""
    Loop % StrLen(old_number_with_shared_removed) {
        keys_to_return := keys_to_return . "{Backspace}"
    }
    keys_to_return := keys_to_return . new_number_with_shared_removed
    
    ; For undo_keys, we want to backspace the new number, and then re-send the
    ; old number
    undo_keys := ""
    Loop % StrLen(new_number_with_shared_removed) {
        undo_keys := undo_keys . "{Backspace}"
    }
    undo_keys := undo_keys . old_number_with_shared_removed

    ; We don't need to be triggering hotstrings with formatting operations on numbers
    return hotstring_inactive_delimiter_key_tracked(operation_name, keys_to_return, undo_keys)
}

number_lock_format_with_commas() {
    return number_formatter("add_commas", "", "")
}

number_lock_hundred() {
    return number_formatter("hundred", "00", "")
}

number_lock_thousand() {
    return number_formatter("thousand", "000", "")
}

number_lock_million() {
    return number_formatter("million", "000000", "")
}

number_lock_billion() {
    return number_formatter("billion", "000000000", "")
}

number_lock_trillion() {
    return number_formatter("trillion", "000000000000", "")
}

number_lock_format_as_dollars() {
    return number_formatter("dollars", "", "dollars")
}

number_lock_format_as_other_other_currency(currency) {
    return number_formatter(currency, "", currency)
}

number_lock_write_out_number() {
    ; TODO
}


; Inline things (bold styling, italic styling, links, footnotes, etc.)
;-------------------------------------------------

insert_bold() {
    if(prose_language == "markdown") {
        return matched_pair_key("**", "**", True, False)
    }
    else if(prose_language == "org") {
        return matched_pair_key("*", "*", True, False)
    }
}

insert_italic() {
    if(prose_language == "markdown") {
        return matched_pair_key("*", "*", True, False)
    }
    else if(prose_language == "org") {
        return matched_pair_key("/", "/", True, False)
    }
}

insert_bold_italic() {
    if(prose_language == "markdown") {
        return matched_pair_key("***", "***", True, False)
    }
    else if(prose_language == "org") {
        return matched_pair_key("*/", "/*", True, False)
    }
}

insert_inline_code() {
    if(prose_language == "markdown") {
        return matched_pair_key("``", "``", False, False)
    }
    else if(prose_language == "org") {
        return matched_pair_key("~", "~", False, False)
    }
}

insert_inline_latex() {
    if(prose_language == "markdown") {
        return matched_pair_key("\( ", " \)", False, False)
    }
    else if(prose_language == "org") {
        return matched_pair_key("\( ", " \)", False, False)
    }
}

insert_strikethrough() {
    if(prose_language == "markdown") {
        return matched_pair_key("~~", "~~", True, False)
    }
    else if(prose_language == "org") {
        return matched_pair_key("+", "+", True, False)
    }
}

insert_underline() {
    if(prose_language == "markdown") {
        return matched_pair_key("<u>", "</u>", True, False)
    }
    else if(prose_language == "org") {
        return matched_pair_key("_", "_", True, False)
    }
}

; You don't have to use this, since verbatim is often styled the same as code in practice.
; Some people do prefer to preserve a semantic distinction between the usages though. For example,
; In setting apart variable names vs. file paths.
; I personally just use code for everything, so don't have this bound in my layout.
; https://emacs.stackexchange.com/questions/77820/code-vs-verbatim
; https://stackoverflow.com/questions/18991981/difference-between-code-and-verbatim-in-org-mode
; https://irreal.org/blog/?p=11123
; https://www.wisdomandwonder.com/emacs/13918/choosing-between-code-and-verbatim-markup-in-org-mode
insert_verbatim() {
    if(prose_language == "markdown") {
        ; Does not exist in markdown
        return eat_keypress()
    }
    else if(prose_language == "org") {
        return matched_pair_key("=", "=", False, False)
    }
}

insert_link() {
    if(prose_language == "markdown") {
        return two_blank_construct("[", "](", ")", True, True)
    }
    else if(prose_language == "org") {
        return two_blank_construct("[[", "][", "]]", True, False)
    }
}

insert_footnote() {
    if(prose_language == "markdown") {
        return matched_pair_key("[{^}", "]", False, False)
    }
    else if(prose_language == "org") {
        return matched_pair_key("[fn:", "]", False, False)
    }
}

; This is a hugo shortcode I use
insert_definition_shortcode() {
    if(prose_language == "markdown") {
        return matched_pair_key("{{}{{}% def """, """ %{}}{}}", True, False)
    }
    else if(prose_language == "org") {
        return matched_pair_key("{{}{{}% def """, """ %{}}{}}", True, False)
    }
}

; Whitespace Characters (Space, Enter, Tab)
;-------------------------------------------------

; ASCII 32 (base 10)
space() {
    if(modifier_state == "leader" or modifier_state == "locked") {
        keys_to_return := build_modifier_combo("{Space}")
        return hotstring_trigger_action_key_untracked_reset_entry_related_variables("{Space}", keys_to_return)
    }
    else {
        keys_to_return := ""
        undo_keys := ""
        sent_keys_stack_length := sent_keys_stack.Length()
        one_key_back := ""
        if(sent_keys_stack_length >= 1) {
            one_key_back := sent_keys_stack[sent_keys_stack_length]
        }

        ; To prevent typos, if you press Space after something 
        ; that has been autospaced, just do nothing. Capitalization
        ; is passed through. We do want to allow for multiple spaces
        ; in a row, however, so there is a special case for that. There
        ; is also a special case for {Enter}, so that we can add spaces
        ; at the beginning of lines
        if(autospacing == "autospaced") {
            ; We have to use what is essentially the "pressed_keysStack"
            ; (not that I actually track that) here, since we don't actually
            ; actually add {Space} to the sent_keys_stack in the case that we
            ; are "eating" the press to prevent typos. But we still need some way
            ; to check if the last key we pressed (even if it wasn't sent) was
            ; {Space}, to properly handle this conditional case.
            last_triggered_hotkey := A_PriorHotkey
            if(last_triggered_hotkey == "*Space") {
                keys_to_return := "{Space}"
                undo_keys := "{Backspace}"
            }
            else { ; last_triggered_hotkey != "*Space", so not multiple spaces in a row
                return eat_keypress()
            }
        }
        ; We always pass through cap autospacing. We just don't do anything unless
        ; we are adding spaces to the beginning of a new line
        else if(autospacing == "cap-autospaced") {
            last_triggered_hotkey := A_PriorHotkey
            if(one_key_back == "{Enter}" or last_triggered_hotkey == "*Space") {
                keys_to_return := "{Space}"
                undo_keys := "{Backspace}"
            }
            else {
                return eat_keypress()
            }
        }
        else {
            autospacing := "autospaced"
            keys_to_return := "{Space}"
            undo_keys := "{Backspace}"
        }
        return hotstring_trigger_delimiter_key_tracked("{Space}", keys_to_return, undo_keys)
    }
}

enter() {
    if(modifier_state == "leader" or modifier_state == "locked") {
        keys_to_return := build_modifier_combo("{Enter}")
        return hotstring_trigger_action_key_untracked_reset_entry_related_variables("{Enter}", keys_to_return)
    }
    else {
        keys_to_return := ""
        undo_keys := ""
        sent_keys_stack_length := sent_keys_stack.Length()
        one_key_back := ""
        if(sent_keys_stack_length >= 1) {
            one_key_back := sent_keys_stack[sent_keys_stack_length]
        }
        if(autospacing == "autospaced") {
            autospacing := "cap-autospaced"
            keys_to_return := "{Backspace}" . "{Enter}"
            undo_keys := "{Backspace}{Space}"
        }
        else if(autospacing == "cap-autospaced") {
            if(one_key_back == "{Enter}") {
                keys_to_return := "{Enter}"
                undo_keys := "{Backspace}"
            }
            else { ; one_key_back != "{Enter}", so not multiple Enters in a row. Would happen after .?!
                keys_to_return := "{Backspace}" . "{Enter}"
                undo_keys := "{Backspace}{Space}"
            }
        }
        else {
            autospacing := "cap-autospaced"
            keys_to_return := "{Enter}"
            undo_keys := "{Backspace}"
        }

        ; Clears certain microstates
        in_raw_microstate := False

        return hotstring_trigger_delimiter_key_tracked("{Enter}", keys_to_return, undo_keys)
    }
}

tab() {
    if(modifier_state == "leader" or modifier_state == "locked") {
        keys_to_return := build_modifier_combo("{Tab}")
        return hotstring_trigger_action_key_untracked_reset_entry_related_variables("{Tab}", keys_to_return)
    }
    else {
        ; Clears certain microstates
        in_raw_microstate := False

        keys_to_return := "{Tab}"
        return hotstring_neutral_key("{Tab}", keys_to_return)
    }
}

; Backspace (by character and by word)
;-------------------------------------------------

; TODO: handle behavior when using colon as semicolon too
; TODO: make work with matchedPairStack

; TODO: make work with automatic locking of number and caps. Will have to track that state too, just like autospacing?

backspace() {
    keys_to_return := ""
    if(modifier_state == "leader" or modifier_state == "locked") {
        keys_to_return := build_modifier_combo("{Backspace}")
        return hotstring_trigger_action_key_untracked_reset_entry_related_variables("{Backspace}", keys_to_return)
    }
    else if(presses_left_until_hint_actuation == 1) { 
        presses_left_until_hint_actuation := presses_left_until_hint_actuation + 1
        keys_to_return := "{Backspace}"
    }
    else {
        if(just_starting_new_entry()) {
            keys_to_return := "{Backspace}"
        }
        else {
            key_being_undone := sent_keys_stack.pop()

            ; Since we are reverting the press completely, need to remove the top thing on all the
            ; history stacks
            locked_state_history_stack.pop()
            automatching_state_history_stack.pop()
            autospacing_state_history_stack.pop()

            ; If after the pop the length of the stacks == 0, then that means there is nothing to reset the things to (no "last"),
            ; since with this last backspace, one would reach the beginning of a new entry. So we need to set the variables
            ; equal to their default value. (To make it as if no keys had been pressed, it must be the reset to same state as
            ; when one first starts a new entry generally = on base layer and no automatching or autospacing).
            if(sent_keys_stack.Length() == 0) {
                locked := "base"
                automatching_stack := []
                autospacing := "not-autospaced"
            }
            ; Otherwise, these things need to be set to what they were *before* the keypress being
            ; undone
            else {
                locked := locked_state_history_stack[locked_state_history_stack.Length()]
                automatching_stack := automatching_state_history_stack[automatching_state_history_stack.Length()]
                autospacing := autospacing_state_history_stack[autospacing_state_history_stack.Length()]
            }
            
            keys_to_return := undo_sent_keys_stack.pop()

            ; Deal with updating variables controlling hotstring state, so that hotstrings
            ; work perfectly, even when backspacing is involved

            ; Could alternatively check if (not is_hotstring_character(key_being_undone)). That is
            ; logically equivalent to current_brief == ""
            if(current_brief == "") {
                update_hotstring_state_based_on_current_sent_keys_stack()
            }
            else {
                StringTrimRight, current_brief, current_brief, 1
            }
        }
    }
    return keys_to_return
}

; In this function, we define a "word" as any character that is not {Space} or {Enter}.
; This function will undo all keypresses up to but not including the last {Space} or {Enter}.
; All {Spaces} on top of the stack will be deleted, but an {Enter} on top of the stack will
; just remove that {Enter} alone, and not do anything else. Examples:
;
; If sent_keys_stack is 'one{Space}two{Enter}{Enter}', calling this function will yield 'one{Space}two{Enter}'
; If sent_keys_stack is 'one{Space}two{Enter}', calling this function will yield 'one{Space}two'
; If sent_keys_stack is 'one{Space}two{Space}{Space}', calling this function will yield 'one{Space}'
; If sent_keys_stack is 'one{Space}two{Space}', calling this function will yield 'one{Space}'
; If sent_keys_stack is 'one{Space}two', calling this function will yield 'one{Space}'
;
; You can replace the letters with any of the other characters that are tracked on sent_keys_stack, and so 
; long as they are not {Space} or {Enter}, they are treated no differently than letters. Thus:
;
; If sent_keys_stack is 'This{Space}is{Space}a{Space}sentence.', calling this function will yield 'This{Space}is{Space}a{Space}'
; If sent_keys_stack is 'Is{Space}it{Space}8:00?', calling this function will yield 'Is{Space}it{Space}'
;
; There is one other special case: backspacing all spaces on a new line, those used to indent something.
; If we have backspaced one or more spaces, and then hit an {Enter}, we stop there. This will leave us
; at the beginning of the line. For example:
;
; If sent_keys_stack is 'line{Space}one{Enter}{Space}{Space}', calling this function will yield 'line{Space}one{Enter}'
;
; Some programs use Control + Backspace to do something similar to what this function implements. I still favor using
; this function (as it does not behave inconsistently with non-letter characters = backspacing "through" some of them,
; yet stopping at others), and this internal function will also work in situations where Control + Backspace has been
; bound to a different action. One particularly notable example of such is Microsoft Excel, where rather than deleting
; one word back, Control + Backspace takes you back to the active cell (if you had scrolled such that it was out of view).
;
; Control + Backspace can still be accessible, just as one would expect. This function does not somehow override that
; key combination inherently, in other words. In my particular layout, I have this function mapped to the backspace key
; on my clipboard layer, and Control + Backspace (accessed through modifiers) works completely normally.
;
; In fact, if the sent_keys_stack is empty (as it would be if I just jumped somewhere), this function actually sends
; Control + Backspace. (I'll handle that Excel exception later).
;
; TODO: make work with matchedPairStack
internal_backspace_by_word() {
    ; Short circuit if the sent_keys_stack is empty
    if(sent_keys_stack.Length() == 0) {
        return "^{Backspace}"
    }

    keys_to_return := remove_word_from_top_of_stack()

    return keys_to_return
}

; Function Keys
;-------------------------------------------------

function_f1() {
    return modifiable_hotstring_trigger_action_key("{F1}")
}

function_f2() {
    return modifiable_hotstring_trigger_action_key("{F2}")
}

function_f3() {
    return modifiable_hotstring_trigger_action_key("{F3}")
}

function_f4() {
    return modifiable_hotstring_trigger_action_key("{F4}")
}

function_f5() {
    return modifiable_hotstring_trigger_action_key("{F5}")
}

function_f6() {
    return modifiable_hotstring_trigger_action_key("{F6}")
}

function_f7() {
    return modifiable_hotstring_trigger_action_key("{F7}")
}

function_f8() {
    return modifiable_hotstring_trigger_action_key("{F8}")
}

function_f9() {
    return modifiable_hotstring_trigger_action_key("{F9}")
}

function_f10() {
    return modifiable_hotstring_trigger_action_key("{F10}")
}

function_f11() {
    return modifiable_hotstring_trigger_action_key("{F11}")
}

function_f12() {
    return modifiable_hotstring_trigger_action_key("{F12}")
}

; Movement and Selection (including physical key actions Left/Up/Down/Right and Home/PgUp/PgDn/End)
;-------------------------------------------------

left() {
    return modifiable_hotstring_trigger_action_key("{Left}")
}

up() {
    return modifiable_hotstring_trigger_action_key("{Up}")
}

down() {
    return modifiable_hotstring_trigger_action_key("{Down}")
}

right() {
    return modifiable_hotstring_trigger_action_key("{Right}")
}

home() {
    return modifiable_hotstring_trigger_action_key("{Home}")
}

page_up() {
    return modifiable_hotstring_trigger_action_key("{PgUp}")
}

page_down() {
    return modifiable_hotstring_trigger_action_key("{PgDn}")
}

end() {
    return modifiable_hotstring_trigger_action_key("{End}")
}

; Actions (including physical key actions Del, Esc, Insert, Scroll Lock)
;-------------------------------------------------

delete() {
    return modifiable_hotstring_neutral_action_key("{Delete}")
}

escape() {
    if(modifier_state == "leader" or modifier_state == "locked") {
        keys_to_return := build_modifier_combo("{Escape}")
        return hotstring_trigger_action_key_untracked_reset_entry_related_variables("{Escape}", keys_to_return)
    }
    else {
        ; Clears certain microstates
        in_raw_microstate := False
        presses_left_until_hint_actuation := 0

        keys_to_return := "{Escape}"
        return hotstring_neutral_key("{Escape}", keys_to_return)
    }
}

insert() {
    return modifiable_hotstring_neutral_action_key("{Insert}")
}

scroll_lock() {
    return modifiable_hotstring_neutral_action_key("{ScrollLock}")
}

cut() {
    return hotstring_trigger_action_key_untracked_reset_entry_related_variables("cut", "^x")
}

copy() {
    return hotstring_trigger_action_key_untracked_reset_entry_related_variables("copy", "^c")
}

paste_after() {
    return hotstring_trigger_action_key_untracked_reset_entry_related_variables("paste_after", "^v")
}

paste_before() {
    return hotstring_trigger_action_key_untracked_reset_entry_related_variables("paste_before", "^v")
}

undo() {
    return hotstring_trigger_action_key_untracked_reset_entry_related_variables("undo", "^z")
}

redo() {
    return hotstring_trigger_action_key_untracked_reset_entry_related_variables("redo", "^y")
}