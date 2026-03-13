function [u, heat_on] = thermostat_step(T, heat_on, Tset, h)
    // Calcule la commande du thermostat avec hystérésis
    //
    // Entrées :
    //   T       : température actuelle (°C)
    //   heat_on : état actuel du chauffage (%t ou %f)
    //   Tset    : température de consigne (°C)
    //   h       : hystérésis totale (°C)
    //
    // Sorties :
    //   u       : commande chauffage (0 ou 1)
    //   heat_on : nouvel état du chauffage (%t ou %f)

    Tlow  = Tset - h/2;   // seuil bas
    Thigh = Tset + h/2;   // seuil haut

    if heat_on & T >= Thigh then
        heat_on = %f;       // trop chaud
    elseif ~heat_on & T <= Tlow then
        heat_on = %t;       // trop froid
    end
    
    if heat_on then
        u = 1;
    else
        u = 0;
    end
endfunction
