function y_f = iir_step(y, y_f_prev, tau, dt)
    // Filtre passe-bas IIR du 1er ordre
    //
    // Entrées :
    //   y        : mesure actuelle
    //   y_f_prev : valeur filtrée précédente
    //   tau      : constante de temps du filtre (s)
    //   dt       : pas de temps (s)
    //
    // Sortie :
    //   y_f : nouvelle valeur filtrée

    a = dt / (tau + dt);
    y_f = y_f_prev + a * (y - y_f_prev);
endfunction
