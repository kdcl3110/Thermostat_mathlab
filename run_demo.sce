exec("src/plant.sci", -1);
exec("src/controller.sci", -1);

dt    = 1;
t_end = 30 * 60;
Text  = 18;
alpha = 0.035;
betaa = 0.002;

// Paramètres du thermostat
Tset = 22;
h    = 1;
Tlow  = Tset - h/2;
Thigh = Tset + h/2;

N = t_end / dt;

T = zeros(1, N+1);   // vecteur température
u = zeros(1, N);      // vecteur commande
t = (0:N) * dt;       // vecteur temps en secondes

T(1) = 20; // Température initiale
heat_on = %f;

for k = 1:N
    [u(k), heat_on] = thermostat_step(T(k), heat_on, Tset, h);
    T(k+1) = plant_step(T(k), u(k), Text, dt, alpha, betaa);
end

// --- Conversion du temps en minutes pour les graphes ---
t_min = t / 60;

// --- Température + seuils ---
scf(1);
clf;

plot(t_min, T, "b-");
plot([0 t_min($)], [Tlow Tlow], "g--");
plot([0 t_min($)], [Thigh Thigh], "r--");
xgrid();
xlabel("Temps (minutes)");
ylabel("Température (°C)");
title("Température avec thermostat à hystérésis");
legend("T(t)", "Tlow = " + string(Tlow), "Thigh = " + string(Thigh));
a = gca();
a.data_bounds = [0, T(1) - 1; t_min($), max(T) + 1];

// --- Commande chauffage ---
scf(2);
clf;
plot(t_min(1:N), u, "r-");
xgrid();
xlabel("Temps (minutes)");
ylabel("Commande u (0=OFF, 1=ON)");
title("Commande du chauffage (thermostat)");

a = gca();
a.data_bounds = [0, -0.1; 20, 1.1];
