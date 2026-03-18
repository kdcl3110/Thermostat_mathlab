function [y, is_glitch] = sensor_read(T_true, cfg)
    // Simule une mesure bruitée
    //
    // Entrées :
    //   T_true : vraie température (°C)
    //   cfg    : structure avec offset, sigma, p_glitch, glitch_amp
    //
    // Sorties :
    //   y         : température mesurée (°C)
    //   is_glitch : %t si un glitch s'est produit

    // Mesure = vraie temp + offset + bruit gaussien
    y = T_true + cfg.offset + cfg.sigma * rand(1,1,"normal");

    // Glitch rare : avec probabilité p_glitch
    is_glitch = %f;
    if rand() < cfg.p_glitch then
        // Ajouter +5 ou -5 au hasard
        if rand() > 0.5 then
            y = y + cfg.glitch_amp;
        else
            y = y - cfg.glitch_amp;
        end
        is_glitch = %t;
    end
endfunction
