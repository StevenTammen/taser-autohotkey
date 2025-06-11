#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

; Change Masking Key
;-------------------------------------------------

; Prevents masked Hotkeys from sending LCtrls that can interfere with the script.
; See https://autohotkey.com/docs/commands/_MenuMaskKey.htm
#MenuMaskKey VKFF

; General Variables
;-------------------------------------------------

; For tracking autospacing after ,;: and .?! and so on
; Possible values: {"autospaced", "cap-autospaced", "not-autospaced"}
global autospacing := "not-autospaced"

; For tracking the language being typed
; Possible values: {"english"}
; Eventually (?): {"english", "ancient-greek", "biblical-hebrew", "russian"}
global language := "english"

; For tracking prose markup language
; Possible values: {"markdown"}
; Eventually (?): {"markdown", "org", "html", "asciidoc"}
global prose_language := "markdown"

; For tracking code language
; Possible values: {"python", "elisp"}
; Eventually (?): {"python", "elisp", "xonsh", "javascript", "typescript", "c#", "java"}
global code_language := "python"

; For tracking whether or not matched pair characters
; are entered together, or tracked and then entered through ).
; The former is almost always better in practice (if you navigate away,
; you actually save keypresses), but you need the latter to be able
; to pratice in typing test sort of environments, which is why we
; implement it both ways, and then make it toggleable
global manually_automatching := True

; We store the current set of characters to match as an array stack
; (last character in array == top of stack). Used in implementing
; intelligent automatching behavior with the ) key
global automatching_stack := []

; Layer Variables
;-------------------------------------------------

; For tracking what I call layer leader behavior.
; Compare one shot keys in QMK firmware: https://docs.qmk.fm/#/one_shot_keys
; Possible values: {"shift", "caps", "number", "command", "function", "actions"}
global leader := ""

; For tracking what I call layer lock behavior.
; Compare layers in QMK firmware: https://docs.qmk.fm/#/feature_layers
; Possible values: {"base", "caps", "number", "function", "actions", "selection"}
global locked := "base"

; Used in making leader keys completely stateless (i.e., making it so that double
; tapping leader keys gives you leader behavior, rather than setting leader := ""
; and leading to base lock behavior)
global is_leader_press := False

; State Variables
;-------------------------------------------------

; For tracking text input state
; Possible values: {"prose", "code"}
global input_state := "prose"

; For entering characters without autospacing. "" means that we are not in
; any sort of raw state, so characters will be autospaced.
; Possible values: {"", "leader", "locked"}
global raw_state := ""

; For entering modifier combinations. "" means that we are not in
; any sort of modifier state, so keypresses will not be modified.
; Possible values: {"", "leader", "locked"}
global modifier_state := ""

; These three variables are used to track which combination of modifiers
; are active
global mod_control_down := False
global mod_alt_down := False
global mod_shift_down := False

; Backspacing Variables
;-------------------------------------------------

; For tracking locked state X keypresses back. Used in implementing intelligent backspacing behavior
global locked_state_history_stack := []

; For tracking automatching state X keypresses back. Used in implementing intelligent backspacing behavior
global automatching_state_history_stack := []

; For tracking autospacing state X key presses back. Used in implementing intelligent backspacing behavior
global autospacing_state_history_stack := []

; For tracking how to undo sent keys X key presses back. Used in implementing intelligent backspacing behavior
global undo_sent_keys_stack := []

; Hotstring Variables
;-------------------------------------------------

; For tracking sent keys X key presses back. Used in implementing intelligent hotstring behavior.
; Many types of key presses (such as modifiers and function keys) simply aren't tracked. As a rule of thumb, if a
; key press outputs something to the screen (adds something to the bytes in a file), it is tracked, and otherwise not.
global sent_keys_stack := []

; See the included files for the full list of hotstrings
global hotstrings := {}
#Include <hotstrings/markup>
#Include <hotstrings/templates>
#Include <hotstrings/contractions>
#Include <hotstrings/regular-hotstrings/single-letter>
#Include <hotstrings/regular-hotstrings/multi-letter>
#Include <hotstrings/q-hotstrings/single-letter>
#Include <hotstrings/q-hotstrings/multi-letter>

; Only letters, numbers, and the apostrophe key are used in hotstrings.
; All other tracked key presses (see sent_keys_stack just below) serve as delimiters.
global hostring_characters := ["'", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

; Certain delimiters disable hostring behavior implicitly. Think characters used in usernames and email addresses,
; but not much else. Helps prevent undesirable "surprising" behavior
global inactive_delimiters := ["-", "_", "dot", "@"]

global last_delimiter := ""

global current_brief := ""

; Microstate Variables
;-------------------------------------------------

; In my terminology, when you are in a microstate, some keypresses are a bit different
; than normal in some way, until an exit condition is met. For example, for the hint 
; microstate, the number of keypresses until hint actuation is tracked, so that raw keys
; are sent when actuating hints (regardless of normal autospacing behavior). As another
; example, all autospacing is disabled when the raw microstate is active.
; Escape, Enter, and Tab are common means of exiting microstates

; What are hints? See, for example, https://github.com/abo-abo/avy?tab=readme-ov-file#avy-goto-word-0
; ---
; This variable is for tracking hint state for the purpose of actuating things via hints:
; when typing (always two-character) hints, autospacing needs to be disabled
; ---
; Possible values: {0, 1, 2}. Hints themselves are two presses. 2 means we still need
; to type 2 characters to actuate the hint. 1 means only one more character. And 0 means
; the hint microstate is not active
global presses_left_until_hint_actuation := 0

; For tracking the raw microstate. This is conceptually similar to the raw layer,
; but is completely automatic. It is mostly used when entering filenames and 
; the like for fuzzy search etc., so that various characters will not be autospaced
global in_raw_microstate := False

; Set Definition Variables
;-------------------------------------------------

global caps_lock_keys := []

; Top row, left to right
caps_lock_keys.Push("caps_lock_B")
caps_lock_keys.Push("caps_lock_Y")
caps_lock_keys.Push("caps_lock_O")
caps_lock_keys.Push("caps_lock_U")
caps_lock_keys.Push("caps_lock_K")
caps_lock_keys.Push("caps_lock_D")
caps_lock_keys.Push("caps_lock_C")
caps_lock_keys.Push("caps_lock_L")
caps_lock_keys.Push("caps_lock_P")
caps_lock_keys.Push("caps_lock_Q")

; Middle row, left to right
caps_lock_keys.Push("caps_lock_H")
caps_lock_keys.Push("caps_lock_I")
caps_lock_keys.Push("caps_lock_E")
caps_lock_keys.Push("caps_lock_A")
caps_lock_keys.Push("caps_lock_M")
caps_lock_keys.Push("caps_lock_T")
caps_lock_keys.Push("caps_lock_S")
caps_lock_keys.Push("caps_lock_R")
caps_lock_keys.Push("caps_lock_N")
caps_lock_keys.Push("caps_lock_V")

; Bottom row, left to right
caps_lock_keys.Push("caps_lock_X")
caps_lock_keys.Push("caps_lock_W")
caps_lock_keys.Push("caps_lock_G")
caps_lock_keys.Push("caps_lock_F")
caps_lock_keys.Push("caps_lock_J")
caps_lock_keys.Push("caps_lock_Z")

global dispersed_caps_lock_keys = []

dispersed_caps_lock_keys.Push("_")

global number_lock_keys := []

; Top row, left to right
number_lock_keys.Push("/")
number_lock_keys.Push("number_lock_colon")
number_lock_keys.Push("8")
number_lock_keys.Push("en_dash")
number_lock_keys.Push("9")
number_lock_keys.Push("dot")
number_lock_keys.Push("%")
number_lock_keys.Push("add_commas")

; Middle row, left to right
number_lock_keys.Push("1")
number_lock_keys.Push("3")
number_lock_keys.Push("5")
number_lock_keys.Push("7")
number_lock_keys.Push("dollars")
number_lock_keys.Push("0")
number_lock_keys.Push("6")
number_lock_keys.Push("4")
number_lock_keys.Push("2")

; Bottom row, left to right
number_lock_keys.Push("write_out")
number_lock_keys.Push("trillion")
number_lock_keys.Push("billion")
number_lock_keys.Push("million")
number_lock_keys.Push("thousand")
number_lock_keys.Push("hundred")

global dispersed_number_lock_keys = []

global currency_map := {}

dollars := {}
dollars["symbol"] := "$"
dollars["symbol_location"] := "prefix"
dollars["decimal"] := "."
dollars["thousands_separator"] := ","
currency_map["dollars"] := dollars

global capitalize_after_expansions := []

; Header hotstrings followed by Space
capitalize_after_expansions.Push("{#}{Space}")
capitalize_after_expansions.Push("{#}{#}{Space}")
capitalize_after_expansions.Push("{#}{#}{#}{Space}")
capitalize_after_expansions.Push("{#}{#}{#}{#}{Space}")
capitalize_after_expansions.Push("{#}{#}{#}{#}{#}{Space}")
capitalize_after_expansions.Push("{#}{#}{#}{#}{#}{#}{Space}")


; Imports: Libraries
;-------------------------------------------------

#Include <utility-functions>
#Include <key-types>
#Include <reusable-key-templates>
#Include <assignable-keys>

; Imports: Layers
;-------------------------------------------------

#Include <layers/base-lock>
#Include <layers/caps-lock>
#Include <layers/number-lock>
#Include <layers/function-lock>
#Include <layers/selection-lock>

#Include <layers/shift-leader>
#Include <layers/caps-leader>
#Include <layers/number-leader>
#Include <layers/move-microstate>
#Include <layers/function-leader>
#Include <layers/actions-microstate>

#Include <layers/pop-up-display-leaders/inline-styles-leader>

; Mouse Behavior
;-------------------------------------------------

LButton::
    reset_entry_related_variables()
    SendInput {LButton Down}
	return

LButton Up::
    SendInput {LButton Up}
	return 

RButton::
    reset_entry_related_variables()
    SendInput {RButton Down}
	return

RButton Up::
    SendInput {RButton Up}
	return

; Main Layout
;-------------------------------------------------

;------ Top Row ------

; Left Top

*Tab::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_top_pinky_extension_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_top_pinky_extension_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_top_pinky_extension_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_top_pinky_extension_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_top_pinky_extension_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_top_pinky_extension_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_top_pinky_extension_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_top_pinky_extension_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_top_pinky_extension_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_top_pinky_extension_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_top_pinky_extension_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_top_pinky_extension_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*b::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_top_pinky_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_top_pinky_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_top_pinky_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_top_pinky_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_top_pinky_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_top_pinky_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_top_pinky_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_top_pinky_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_top_pinky_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_top_pinky_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_top_pinky_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_top_pinky_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*y::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_top_ring_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_top_ring_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_top_ring_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_top_ring_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_top_ring_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_top_ring_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_top_ring_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_top_ring_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_top_ring_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_top_ring_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_top_ring_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_top_ring_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*o::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_top_middle_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_top_middle_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_top_middle_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_top_middle_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_top_middle_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_top_middle_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_top_middle_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_top_middle_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_top_middle_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_top_middle_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_top_middle_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_top_middle_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*u::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_top_index_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_top_index_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_top_index_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_top_index_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_top_index_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_top_index_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_top_index_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_top_index_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_top_index_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_top_index_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_top_index_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_top_index_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*'::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_top_index_extension_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_top_index_extension_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_top_index_extension_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_top_index_extension_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_top_index_extension_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_top_index_extension_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_top_index_extension_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_top_index_extension_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_top_index_extension_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_top_index_extension_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_top_index_extension_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_top_index_extension_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

; Right Top

*k::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_top_index_extension_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_top_index_extension_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_top_index_extension_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_top_index_extension_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_top_index_extension_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_top_index_extension_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_top_index_extension_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_top_index_extension_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_top_index_extension_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_top_index_extension_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_top_index_extension_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_top_index_extension_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*d::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_top_index_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_top_index_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_top_index_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_top_index_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_top_index_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_top_index_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_top_index_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_top_index_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_top_index_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_top_index_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_top_index_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_top_index_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*c::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_top_middle_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_top_middle_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_top_middle_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_top_middle_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_top_middle_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_top_middle_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_top_middle_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_top_middle_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_top_middle_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_top_middle_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_top_middle_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_top_middle_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*l::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_top_ring_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_top_ring_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_top_ring_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_top_ring_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_top_ring_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_top_ring_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_top_ring_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_top_ring_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_top_ring_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_top_ring_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_top_ring_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_top_ring_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*p::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_top_pinky_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_top_pinky_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_top_pinky_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_top_pinky_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_top_pinky_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_top_pinky_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_top_pinky_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_top_pinky_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_top_pinky_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_top_pinky_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_top_pinky_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_top_pinky_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*q::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_top_pinky_extension_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_top_pinky_extension_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_top_pinky_extension_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_top_pinky_extension_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_top_pinky_extension_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_top_pinky_extension_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_top_pinky_extension_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_top_pinky_extension_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_top_pinky_extension_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_top_pinky_extension_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_top_pinky_extension_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_top_pinky_extension_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

;------ Middle Row ------

; Left Middle

*1::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_middle_pinky_extension_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_middle_pinky_extension_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_middle_pinky_extension_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_middle_pinky_extension_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_middle_pinky_extension_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_middle_pinky_extension_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_middle_pinky_extension_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_middle_pinky_extension_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_middle_pinky_extension_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_middle_pinky_extension_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_middle_pinky_extension_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_middle_pinky_extension_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*h::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_middle_pinky_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_middle_pinky_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_middle_pinky_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_middle_pinky_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_middle_pinky_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_middle_pinky_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_middle_pinky_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_middle_pinky_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_middle_pinky_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_middle_pinky_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_middle_pinky_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_middle_pinky_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*i::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_middle_ring_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_middle_ring_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_middle_ring_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_middle_ring_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_middle_ring_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_middle_ring_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_middle_ring_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_middle_ring_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_middle_ring_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_middle_ring_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_middle_ring_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_middle_ring_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*e::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_middle_middle_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_middle_middle_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_middle_middle_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_middle_middle_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_middle_middle_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_middle_middle_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_middle_middle_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_middle_middle_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_middle_middle_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_middle_middle_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_middle_middle_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_middle_middle_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*a::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_middle_index_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_middle_index_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_middle_index_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_middle_index_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_middle_index_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_middle_index_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_middle_index_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_middle_index_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_middle_index_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_middle_index_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_middle_index_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_middle_index_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*.::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_middle_index_extension_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_middle_index_extension_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_middle_index_extension_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_middle_index_extension_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_middle_index_extension_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_middle_index_extension_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_middle_index_extension_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_middle_index_extension_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_middle_index_extension_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_middle_index_extension_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_middle_index_extension_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_middle_index_extension_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

; Right Middle

*m::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_middle_index_extension_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_middle_index_extension_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_middle_index_extension_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_middle_index_extension_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_middle_index_extension_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_middle_index_extension_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_middle_index_extension_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_middle_index_extension_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_middle_index_extension_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_middle_index_extension_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_middle_index_extension_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_middle_index_extension_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*t::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_middle_index_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_middle_index_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_middle_index_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_middle_index_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_middle_index_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_middle_index_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_middle_index_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_middle_index_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_middle_index_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_middle_index_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_middle_index_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_middle_index_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*s::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_middle_middle_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_middle_middle_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_middle_middle_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_middle_middle_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_middle_middle_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_middle_middle_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_middle_middle_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_middle_middle_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_middle_middle_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_middle_middle_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_middle_middle_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_middle_middle_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*r::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_middle_ring_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_middle_ring_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_middle_ring_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_middle_ring_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_middle_ring_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_middle_ring_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_middle_ring_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_middle_ring_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_middle_ring_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_middle_ring_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_middle_ring_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_middle_ring_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*n::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_middle_pinky_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_middle_pinky_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_middle_pinky_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_middle_pinky_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_middle_pinky_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_middle_pinky_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_middle_pinky_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_middle_pinky_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_middle_pinky_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_middle_pinky_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_middle_pinky_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_middle_pinky_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*v::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_middle_pinky_extension_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_middle_pinky_extension_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_middle_pinky_extension_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_middle_pinky_extension_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_middle_pinky_extension_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_middle_pinky_extension_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_middle_pinky_extension_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_middle_pinky_extension_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_middle_pinky_extension_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_middle_pinky_extension_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_middle_pinky_extension_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_middle_pinky_extension_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

;------ Bottom Row ------

; Left Bottom

*2::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_bottom_pinky_extension_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_bottom_pinky_extension_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_bottom_pinky_extension_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_bottom_pinky_extension_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_bottom_pinky_extension_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_bottom_pinky_extension_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_bottom_pinky_extension_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_bottom_pinky_extension_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_bottom_pinky_extension_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_bottom_pinky_extension_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_bottom_pinky_extension_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_bottom_pinky_extension_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*x::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_bottom_pinky_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_bottom_pinky_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_bottom_pinky_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_bottom_pinky_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_bottom_pinky_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_bottom_pinky_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_bottom_pinky_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_bottom_pinky_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_bottom_pinky_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_bottom_pinky_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_bottom_pinky_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_bottom_pinky_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*3::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_bottom_ring_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_bottom_ring_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_bottom_ring_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_bottom_ring_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_bottom_ring_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_bottom_ring_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_bottom_ring_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_bottom_ring_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_bottom_ring_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_bottom_ring_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_bottom_ring_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_bottom_ring_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*4::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_bottom_middle_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_bottom_middle_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_bottom_middle_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_bottom_middle_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_bottom_middle_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_bottom_middle_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_bottom_middle_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_bottom_middle_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_bottom_middle_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_bottom_middle_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_bottom_middle_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_bottom_middle_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*,::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_bottom_index_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_bottom_index_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_bottom_index_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_bottom_index_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_bottom_index_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_bottom_index_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_bottom_index_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_bottom_index_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_bottom_index_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_bottom_index_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_bottom_index_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_bottom_index_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*5::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_bottom_index_extension_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_bottom_index_extension_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_bottom_index_extension_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_bottom_index_extension_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_bottom_index_extension_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_bottom_index_extension_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_bottom_index_extension_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_bottom_index_extension_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_bottom_index_extension_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_bottom_index_extension_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_bottom_index_extension_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_bottom_index_extension_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

; Right Bottom

*w::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_bottom_index_extension_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_bottom_index_extension_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_bottom_index_extension_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_bottom_index_extension_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_bottom_index_extension_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_bottom_index_extension_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_bottom_index_extension_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_bottom_index_extension_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_bottom_index_extension_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_bottom_index_extension_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_bottom_index_extension_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_bottom_index_extension_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*g::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_bottom_index_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_bottom_index_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_bottom_index_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_bottom_index_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_bottom_index_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_bottom_index_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_bottom_index_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_bottom_index_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_bottom_index_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_bottom_index_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_bottom_index_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_bottom_index_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*f::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_bottom_middle_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_bottom_middle_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_bottom_middle_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_bottom_middle_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_bottom_middle_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_bottom_middle_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_bottom_middle_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_bottom_middle_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_bottom_middle_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_bottom_middle_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_bottom_middle_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_bottom_middle_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*j::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_bottom_ring_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_bottom_ring_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_bottom_ring_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_bottom_ring_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_bottom_ring_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_bottom_ring_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_bottom_ring_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_bottom_ring_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_bottom_ring_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_bottom_ring_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_bottom_ring_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_bottom_ring_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*z::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_bottom_pinky_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_bottom_pinky_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_bottom_pinky_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_bottom_pinky_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_bottom_pinky_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_bottom_pinky_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_bottom_pinky_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_bottom_pinky_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_bottom_pinky_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_bottom_pinky_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_bottom_pinky_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_bottom_pinky_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*6::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_bottom_pinky_extension_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_bottom_pinky_extension_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_bottom_pinky_extension_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_bottom_pinky_extension_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_bottom_pinky_extension_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_bottom_pinky_extension_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_bottom_pinky_extension_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_bottom_pinky_extension_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_bottom_pinky_extension_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_bottom_pinky_extension_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_bottom_pinky_extension_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_bottom_pinky_extension_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

;------ Thumbs Row ------

; Left Thumbs

*7::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_thumb_inner_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_thumb_inner_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_thumb_inner_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_thumb_inner_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_thumb_inner_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_thumb_inner_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_thumb_inner_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_thumb_inner_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_thumb_inner_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_thumb_inner_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_thumb_inner_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_thumb_inner_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*Space::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_thumb_neutral_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_thumb_neutral_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_thumb_neutral_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_thumb_neutral_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_thumb_neutral_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_thumb_neutral_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_thumb_neutral_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_thumb_neutral_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_thumb_neutral_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_thumb_neutral_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_thumb_neutral_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_thumb_neutral_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*8::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := left_thumb_outer_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := left_thumb_outer_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := left_thumb_outer_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := left_thumb_outer_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := left_thumb_outer_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := left_thumb_outer_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := left_thumb_outer_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := left_thumb_outer_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := left_thumb_outer_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := left_thumb_outer_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := left_thumb_outer_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := left_thumb_outer_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

; Right Thumbs

*Enter::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_thumb_outer_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_thumb_outer_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_thumb_outer_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_thumb_outer_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_thumb_outer_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_thumb_outer_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_thumb_outer_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_thumb_outer_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_thumb_outer_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_thumb_outer_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_thumb_outer_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_thumb_outer_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*Backspace::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_thumb_neutral_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_thumb_neutral_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_thumb_neutral_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_thumb_neutral_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_thumb_neutral_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_thumb_neutral_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_thumb_neutral_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_thumb_neutral_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_thumb_neutral_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_thumb_neutral_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_thumb_neutral_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_thumb_neutral_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return

*9::
	keys_to_return := ""

	; Leaders
	if(leader != "") {
		initial_leader_state := leader

		if(leader == "shift") {
			keys_to_return := right_thumb_inner_shift_leader()
		}
		else if(leader == "caps") {
			keys_to_return := right_thumb_inner_caps_leader()
		}
		else if(leader == "number") {
			keys_to_return := right_thumb_inner_number_leader()
		}
		else if(leader == "command") {
			keys_to_return := right_thumb_inner_move_microstate()
		}
		else if(leader == "function") {
			keys_to_return := right_thumb_inner_function_leader()
		}
		else if(leader == "actions") {
			keys_to_return := right_thumb_inner_actions_microstate()
		}
		else if(leader == "inline_styles") {
			keys_to_return := right_thumb_inner_inline_styles_leader()
		}

		; The leader state will get reset after a single
		; press on a leader layer. That is what this does
		if((leader == initial_leader_state) and (not is_leader_press)) {
			leader := ""
		}
		; Unless a different leader was actuated on a leader layer
		; (that is, if leader != initial_leader_state). In that case,
		; we should not clear the new leader state, but just leave it alone.
	}

	; Locks
	else {
		if(locked == "base") {
			keys_to_return := right_thumb_inner_base_lock()
		}
		else if(locked == "caps") {
			keys_to_return := right_thumb_inner_caps_lock()
		}
		else if(locked == "number") {
			keys_to_return := right_thumb_inner_number_lock()
		}
		else if(locked == "function") {
			keys_to_return := right_thumb_inner_function_lock()
		}
		else if(locked == "selection") {
			keys_to_return := right_thumb_inner_selection_lock()
		}
	}

	is_leader_press := False
	SendInput %keys_to_return%
	return
