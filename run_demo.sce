exec("src/plant.sci", -1);

dt    = 1;
t_end = 20 * 60;
Text  = 10;
alpha = 0.1;
betaa  = 0.005;

N = t_end / dt;

T = zeros(1, N+1);   // vecteur température
u = zeros(1, N);      // vecteur commande
t = (0:N) * dt;       // vecteur temps en secondes

T(1) = 7; // Température initiale

for k = 1:N
    temps_min = (k-1) * dt / 60;
    if temps_min < 5 then
        u(k) = 1;
    elseif temps_min < 12 then
        u(k) = 0;
    else
        u(k) = 1;
    end
    
    T(k+1) = plant_step(T(k), u(k), Text, dt, alpha, betaa);
end


// --- 7) Conversion du temps en minutes pour les graphes ---
t_min = t / 60;

// --- Température ---
scf(1);
clf;

plot(t_min, T, "b-");  //  courbe de température
plot([0 t_min($)], [Text Text], "r--"); // courbe de la température extérieure
xlabel("Temps (minutes)");
ylabel("Température (°C)");
title("Évolution de la température de la pièce");
legend("T(t)", "T extérieure");
a = gca();
a.data_bounds = [0, T(1) - 1; t_min($), max(T) + 1];


// --- Commande chauffage ---
scf(2);
clf;
plot(t_min(1:N), u, "r-");,
xlabel("Temps (minutes)");
ylabel("Commande u (0=OFF, 1=ON)");
title("Commande du chauffage");

a = gca();
a.data_bounds = [0, -0.1; 20, 1.1];
