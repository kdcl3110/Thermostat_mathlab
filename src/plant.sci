
function T_next = plant_step(T, u, Text, dt, alpha, betaa)
    T_next = T + dt * (alpha * u - betaa * (T - Text));
endfunction
