; Base
;-------------------------------------------------

; Left Top
;-------------------------------------------------

left_top_pinky_extension_base_lock() {
    return base_lock()
}

left_top_pinky_base_lock() {
    return lowercase_b()
}

left_top_ring_base_lock() {
    return lowercase_y()
}

left_top_middle_base_lock() {
    return lowercase_o()
}

left_top_index_base_lock() {
    return lowercase_u()
}

left_top_index_extension_base_lock() {
    ; TODO
}

; Right Top
;-------------------------------------------------

right_top_index_extension_base_lock() {
    return lowercase_k()
}

right_top_index_base_lock() {
    return lowercase_d()
}

right_top_middle_base_lock() {
    return lowercase_c()
}

right_top_ring_base_lock() {
    return lowercase_l()
}

right_top_pinky_base_lock() {
    return lowercase_p()
}

right_top_pinky_extension_base_lock() {
    return caps_leader()
}

; Left Middle
;-------------------------------------------------

left_middle_pinky_extension_base_lock() {
    return enter()
}

left_middle_pinky_base_lock() {
    return lowercase_h()
}

left_middle_ring_base_lock() {
    return lowercase_i()
}

left_middle_middle_base_lock() {
    return lowercase_e()
}

left_middle_index_base_lock() {
    return lowercase_a()
}

left_middle_index_extension_base_lock() {
    return period()
}

; Right Middle
;-------------------------------------------------

right_middle_index_extension_base_lock() {
    return lowercase_m()
}

right_middle_index_base_lock() {
    return lowercase_t()
}

right_middle_middle_base_lock() {
    return lowercase_s()
}

right_middle_ring_base_lock() {
    return lowercase_r()
}

right_middle_pinky_base_lock() {
    return lowercase_n()
}

right_middle_pinky_extension_base_lock() {
    return lowercase_v()
}

; Left Bottom
;-------------------------------------------------

left_bottom_pinky_extension_base_lock() {
    return move_microstate()
}

left_bottom_pinky_base_lock() {
    return lowercase_x()
}

left_bottom_ring_base_lock() {
    ; You chain modifiers using the bottom row keys on the base layer
    if(modifier_state == "leader" or modifier_state == "locked") {
        return mod_control()
    }
    else {
        return quotes()
    }
}

left_bottom_middle_base_lock() {
    ; You chain modifiers using the bottom row keys on the base layer
    if(modifier_state == "leader" or modifier_state == "locked") {
        return mod_alt()
    }
    else {
        return close_parenthesis()
    }
}

left_bottom_index_base_lock() {
    ; You chain modifiers using the bottom row keys on the base layer
    if(modifier_state == "leader" or modifier_state == "locked") {
        return mod_shift()
    }
    else {
        return comma()
    }
}

left_bottom_index_extension_base_lock() {
    return open_parenthesis()
}

; Right Bottom
;-------------------------------------------------

right_bottom_index_extension_base_lock() {
    return lowercase_w()
}

right_bottom_index_base_lock() {
    return lowercase_g()
}

right_bottom_middle_base_lock() {
    return lowercase_f()
}

right_bottom_ring_base_lock() {
    return lowercase_j()
}

right_bottom_pinky_base_lock() {
    return lowercase_z()
}

right_bottom_pinky_extension_base_lock() {
    return lowercase_q()
}

; Left Thumbs
;-------------------------------------------------

left_thumb_inner_base_lock() {
    return actions_microstate()
}

left_thumb_neutral_base_lock() {
    return space()
}

left_thumb_outer_base_lock() {
    return selection_lock()
}

; Right Thumbs
;-------------------------------------------------

right_thumb_outer_base_lock() {
    return number_leader()
}

right_thumb_neutral_base_lock() {
    return backspace()
}

right_thumb_inner_base_lock() {
    return shift_leader()
}