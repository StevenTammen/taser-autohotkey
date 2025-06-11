; Shift
;-------------------------------------------------

; Left Top
;-------------------------------------------------

left_top_pinky_extension_caps_leader() {
    return base_lock()
}

left_top_pinky_caps_leader() {
    return caps_lock_b_autolock_caps_layer()
}

left_top_ring_caps_leader() {
    return caps_lock_y_autolock_caps_layer()
}

left_top_middle_caps_leader() {
    return caps_lock_o_autolock_caps_layer()
}

left_top_index_caps_leader() {
    return caps_lock_u_autolock_caps_layer()
}

left_top_index_extension_caps_leader() {
    ; TODO
}

; Right Top
;-------------------------------------------------

right_top_index_extension_caps_leader() {
    return caps_lock_k_autolock_caps_layer()
}

right_top_index_caps_leader() {
    return caps_lock_d_autolock_caps_layer()
}

right_top_middle_caps_leader() {
    return caps_lock_c_autolock_caps_layer()
}

right_top_ring_caps_leader() {
    return caps_lock_l_autolock_caps_layer()
}

right_top_pinky_caps_leader() {
    return caps_lock_p_autolock_caps_layer()
}

right_top_pinky_extension_caps_leader() {
    return caps_leader()
}

; Left Middle
;-------------------------------------------------

left_middle_pinky_extension_caps_leader() {
    return backtick()
}

left_middle_pinky_caps_leader() {
    return caps_lock_h_autolock_caps_layer()
}

left_middle_ring_caps_leader() {
    return caps_lock_i_autolock_caps_layer()
}

left_middle_middle_caps_leader() {
    return caps_lock_e_autolock_caps_layer()
}

left_middle_index_caps_leader() {
    return caps_lock_a_autolock_caps_layer()
}

left_middle_index_extension_caps_leader() {
    ; TODO
}

; Right Middle
;-------------------------------------------------

right_middle_index_extension_caps_leader() {
    return caps_lock_m_autolock_caps_layer()
}

right_middle_index_caps_leader() {
    return caps_lock_t_autolock_caps_layer()
}

right_middle_middle_caps_leader() {
    return caps_lock_s_autolock_caps_layer()
}

right_middle_ring_caps_leader() {
    return caps_lock_r_autolock_caps_layer()
}

right_middle_pinky_caps_leader() {
    return caps_lock_n_autolock_caps_layer()
}

right_middle_pinky_extension_caps_leader() {
    return caps_lock_v_autolock_caps_layer()
}

; Left Bottom
;-------------------------------------------------

left_bottom_pinky_extension_caps_leader() {
    return move_microstate()
}

left_bottom_pinky_caps_leader() {
    return caps_lock_x_autolock_caps_layer()
}

left_bottom_ring_caps_leader() {
    ; You access the modified versions of the bottom row base layer keys
    ; from the Caps layer
    if(modifier_state == "leader" or modifier_state == "locked") {
        keys_to_return := build_modifier_combo("""", False)
        return hotstring_trigger_action_key_untracked_reset_entry_related_variables("""", keys_to_return)
    }
    else {
        ; TODO
    }
}

left_bottom_middle_caps_leader() {
    ; You access the modified versions of the bottom row base layer keys
    ; from the Caps layer
    if(modifier_state == "leader" or modifier_state == "locked") {
        keys_to_return := build_modifier_combo(")", False)
        return hotstring_trigger_action_key_untracked_reset_entry_related_variables(")", keys_to_return)
    }
    else {
        ; TODO
    }
}

left_bottom_index_caps_leader() {
    ; You access the modified versions of the bottom row base layer keys
    ; from the Caps layer
    if(modifier_state == "leader" or modifier_state == "locked") {
        keys_to_return := build_modifier_combo(",")
        return hotstring_trigger_action_key_untracked_reset_entry_related_variables(",", keys_to_return)
    }
    else {
        ; TODO
    }
}

left_bottom_index_extension_caps_leader() {
    ; TODO
}

; Right Bottom
;-------------------------------------------------

right_bottom_index_extension_caps_leader() {
    return caps_lock_w_autolock_caps_layer()
}

right_bottom_index_caps_leader() {
    return caps_lock_g_autolock_caps_layer()
}

right_bottom_middle_caps_leader() {
    return caps_lock_f_autolock_caps_layer()
}

right_bottom_ring_caps_leader() {
    return caps_lock_j_autolock_caps_layer()
}

right_bottom_pinky_caps_leader() {
    return caps_lock_z_autolock_caps_layer()
}

right_bottom_pinky_extension_caps_leader() {
    return caps_lock_q_autolock_caps_layer()
}

; Left Thumbs
;-------------------------------------------------

left_thumb_inner_caps_leader() {
    return actions_microstate()
}

left_thumb_neutral_caps_leader() {
    ; TODO - raw backspace
}

left_thumb_outer_caps_leader() {
    return selection_lock()
}

; Right Thumbs
;-------------------------------------------------

right_thumb_outer_caps_leader() {
    return number_leader()
}

right_thumb_neutral_caps_leader() {
    return backspace()
}

right_thumb_inner_caps_leader() {
    return caps_leader()
}