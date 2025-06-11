; Shift
;-------------------------------------------------

; Left Top
;-------------------------------------------------

left_top_pinky_extension_selection_lock() {
    return append_after()
}

left_top_pinky_selection_lock() {
    ; TODO
}

left_top_ring_selection_lock() {
    ; TODO
}

left_top_middle_selection_lock() {
    ; TODO
}

left_top_index_selection_lock() {
    ; TODO
}

left_top_index_extension_selection_lock() {
    ; TODO
}

; Right Top
;-------------------------------------------------

right_top_index_extension_selection_lock() {
    ; TODO
}

right_top_index_selection_lock() {
    ; TODO
}

right_top_middle_selection_lock() {
    ; TODO
}

right_top_ring_selection_lock() {
    ; TODO
}

right_top_pinky_selection_lock() {
    ; TODO
}

right_top_pinky_extension_selection_lock() {
    ; TODO
}

; Left Middle
;-------------------------------------------------

left_middle_pinky_extension_selection_lock() {
    ; TODO
}

left_middle_pinky_selection_lock() {
    ; TODO
}

left_middle_ring_selection_lock() {
    ; TODO
}

left_middle_middle_selection_lock() {
    ; TODO
}

left_middle_index_selection_lock() {
    ; TODO
}

left_middle_index_extension_selection_lock() {
    ; TODO
}

; Right Middle
;-------------------------------------------------

right_middle_index_extension_selection_lock() {
    ; TODO
}

right_middle_index_selection_lock() {
    ; TODO
}

right_middle_middle_selection_lock() {
    ; TODO
}

right_middle_ring_selection_lock() {
    ; TODO
}

right_middle_pinky_selection_lock() {
    ; TODO
}

right_middle_pinky_extension_selection_lock() {
    ; TODO
}

; Left Bottom
;-------------------------------------------------

left_bottom_pinky_extension_selection_lock() {
    return move_microstate()
}

left_bottom_pinky_selection_lock() {
    return undo()
}

left_bottom_ring_selection_lock() {
    return redo()
}

left_bottom_middle_selection_lock() {
    ; TODO
}

left_bottom_index_selection_lock() {
    ; TODO
}

left_bottom_index_extension_selection_lock() {
    ; TODO
}

; Right Bottom
;-------------------------------------------------

right_bottom_index_extension_selection_lock() {
    ; TODO
}

right_bottom_index_selection_lock() {
    ; TODO
}

right_bottom_middle_selection_lock() {
    ; TODO
}

right_bottom_ring_selection_lock() {
    ; TODO
}

right_bottom_pinky_selection_lock() {
    ; TODO
}

right_bottom_pinky_extension_selection_lock() {
    ; TODO
}

; Left Thumbs
;-------------------------------------------------

left_thumb_inner_selection_lock() {
    return actions_microstate()
}

left_thumb_neutral_selection_lock() {
    return insert_before()
}

left_thumb_outer_selection_lock() {
    return selection_lock()
}

; Right Thumbs
;-------------------------------------------------

right_thumb_outer_selection_lock() {
    ; TODO
}

right_thumb_neutral_selection_lock() {
    ; TODO
}

right_thumb_inner_selection_lock() {
    ; TODO
}