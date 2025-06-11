; Shift
;-------------------------------------------------

; Left Top
;-------------------------------------------------

left_top_pinky_extension_shift_leader() {
    return base_lock()
}

left_top_pinky_shift_leader() {
    return uppercase_b()
}

left_top_ring_shift_leader() {
    return uppercase_y()
}

left_top_middle_shift_leader() {
    return uppercase_o()
}

left_top_index_shift_leader() {
    return uppercase_u()
}

left_top_index_extension_shift_leader() {
    ; TODO
}

; Right Top
;-------------------------------------------------

right_top_index_extension_shift_leader() {
    return uppercase_k()
}

right_top_index_shift_leader() {
    return uppercase_d()
}

right_top_middle_shift_leader() {
    return uppercase_c()
}

right_top_ring_shift_leader() {
    return uppercase_l()
}

right_top_pinky_shift_leader() {
    return uppercase_p()
}

right_top_pinky_extension_shift_leader() {
    return caps_leader()
}

; Left Middle
;-------------------------------------------------

left_middle_pinky_extension_shift_leader() {
    return apostrophe()
}

left_middle_pinky_shift_leader() {
    return uppercase_h()
}

left_middle_ring_shift_leader() {
    return uppercase_i()
}

left_middle_middle_shift_leader() {
    return uppercase_e()
}

left_middle_index_shift_leader() {
    return uppercase_a()
}

left_middle_index_extension_shift_leader() {
    return semicolon()
}

; Right Middle
;-------------------------------------------------

right_middle_index_extension_shift_leader() {
    return uppercase_m()
}

right_middle_index_shift_leader() {
    return uppercase_t()
}

right_middle_middle_shift_leader() {
    return uppercase_s()
}

right_middle_ring_shift_leader() {
    return uppercase_r()
}

right_middle_pinky_shift_leader() {
    return uppercase_n()
}

right_middle_pinky_extension_shift_leader() {
    return uppercase_v()
}

; Left Bottom
;-------------------------------------------------

left_bottom_pinky_extension_shift_leader() {
    return move_microstate()
}

left_bottom_pinky_shift_leader() {
    return uppercase_x()
}

left_bottom_ring_shift_leader() {
    return question_mark()
}

left_bottom_middle_shift_leader() {
    return exclamation_mark()
}

left_bottom_index_shift_leader() {
    return em_dash()
}

left_bottom_index_extension_shift_leader() {
    ; TODO
}

; Right Bottom
;-------------------------------------------------

right_bottom_index_extension_shift_leader() {
    return uppercase_w()
}

right_bottom_index_shift_leader() {
    return uppercase_g()
}

right_bottom_middle_shift_leader() {
    return uppercase_f()
}

right_bottom_ring_shift_leader() {
    return uppercase_j()
}

right_bottom_pinky_shift_leader() {
    return uppercase_z()
}

right_bottom_pinky_extension_shift_leader() {
    return uppercase_q()
}

; Left Thumbs
;-------------------------------------------------

left_thumb_inner_shift_leader() {
    return actions_microstate()
}

left_thumb_neutral_shift_leader() {
    return internal_backspace_by_word()
}

left_thumb_outer_shift_leader() {
    return selection_lock()
}

; Right Thumbs
;-------------------------------------------------

right_thumb_outer_shift_leader() {
    return number_leader()
}

right_thumb_neutral_shift_leader() {
    return backspace()
}

right_thumb_inner_shift_leader() {
    return shift_leader()
}