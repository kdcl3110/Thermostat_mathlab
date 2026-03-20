
function [fault, code, st] = safety_step(T_meas, is_glitch, st, cfg)
    // Surveillance capteur avec latch + recovery
    //
    // Entrées :
    //   T_meas    : mesure actuelle
    //   is_glitch : %t si glitch détecté par le capteur
    //   st        : structure d'état interne (mémoire)
    //   cfg       : paramètres de sécurité
    //
    // Sorties :
    //   fault : %t si défaut actif
    //   code  : 0=OK, 1=hors bornes, 2=capteur gelé, 3=trop de glitches
    //   st    : état interne mis à jour

    raw_fault = %f;
    code = 0;

    // --- 1) Hors bornes ---
    if T_meas < cfg.Tmin | T_meas > cfg.Tmax then
        raw_fault = %t;
        code = 1;
    end

    // --- 2) Capteur gelé ---
    if abs(T_meas - st.last_meas) < cfg.stuck_eps then
        st.stuck_count = st.stuck_count + 1;
    else
        st.stuck_count = 0;
    end
    st.last_meas = T_meas;

    if st.stuck_count >= cfg.stuck_N then
        raw_fault = %t;
        code = 2;
    end

    // --- 3) Trop de glitches (fenêtre glissante) ---
    // Décaler la fenêtre et ajouter le nouveau glitch
    st.glitch_win = [st.glitch_win(2:$), bool2s(is_glitch)];

    if sum(st.glitch_win) > cfg.glitch_max then
        raw_fault = %t;
        code = 3;
    end

    // --- Latch + Recovery ---
    if raw_fault then
        st.latched = %t;
        st.recover_count = 0;
    else
        if st.latched then
            st.recover_count = st.recover_count + 1;
            if st.recover_count >= cfg.recover_N then
                st.latched = %f;
                st.recover_count = 0;
            end
        end
    end

    fault = st.latched;
    if fault & code == 0 then
        code = st.last_code;
    end
    if code ~= 0 then
        st.last_code = code;
    end
endfunction
