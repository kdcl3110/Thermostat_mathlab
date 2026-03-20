
function [state, u_final, log] = fsm_step(fault, code, u_raw, prev_state, t_s)
    // Machine à états : NORMAL(0) / SAFE(1)
    //
    // Entrées :
    //   fault      : %t si défaut actif
    //   code       : code du défaut
    //   u_raw      : commande du thermostat
    //   prev_state : état précédent (0 ou 1)
    //   t_s        : temps actuel en secondes
    //
    // Sorties :
    //   state   : nouvel état (0 ou 1)
    //   u_final : commande finale
    //   log     : [] ou [t_s, event_code, reason_code]

    log = [];

    if fault then
        state = 1;       // SAFE
        u_final = 0;     // chauffage coupé
        if prev_state == 0 then
            // On vient d'entrer en SAFE
            log = [t_s, 10, code];   // 10 = ENTER_SAFE
        end
    else
        state = 0;       // NORMAL
        u_final = u_raw;
        if prev_state == 1 then
            // On vient de sortir de SAFE
            log = [t_s, 11, 0];      // 11 = EXIT_SAFE
        end
    end
endfunction
