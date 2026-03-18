exec("src/plant.sci", -1);
exec("src/controller.sci", -1);
exec("src/sensor.sci", -1);
exec("src/filter.sci", -1);

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

// Paramètres du capteur
cfg.offset     = 0.3;
cfg.sigma      = 0.2;
cfg.p_glitch   = 0.01;
cfg.glitch_amp = 5;

// Paramètre du filtre
tau = 10;

N = t_end / dt;

T_true = zeros(1, N+1);   // vraie température
T_meas = zeros(1, N);     // température mesurée (bruitée)
T_filt = zeros(1, N);     // température filtrée
u      = zeros(1, N);     // commande chauffage
glitch = zeros(1, N);     // 1 si glitch, 0 sinon
t      = (0:N) * dt;

T_true(1) = 20;
heat_on   = %f;

// Initialiser le filtre avec la première mesure
[T_meas(1), g] = sensor_read(T_true(1), cfg);
glitch(1) = bool2s(g);
T_filt(1) = T_meas(1);

// Commande au premier pas
[u(1), heat_on] = thermostat_step(T_filt(1), heat_on, Tset, h);
T_true(2) = plant_step(T_true(1), u(1), Text, dt, alpha, betaa);

for k = 2:N
    // 1. Capteur : mesure bruitée
    [T_meas(k), g] = sensor_read(T_true(k), cfg);
    glitch(k) = bool2s(g);

    // 2. Filtre : lisser la mesure
    T_filt(k) = iir_step(T_meas(k), T_filt(k-1), tau, dt);

    // 3. Thermostat : décide sur T_filt
    [u(k), heat_on] = thermostat_step(T_filt(k), heat_on, Tset, h);

    // 4. Modèle : calcule la vraie température suivante
    T_true(k+1) = plant_step(T_true(k), u(k), Text, dt, alpha, betaa);
end

// --- Conversion en minutes ---
t_min = t / 60;

// --- Figure 1 : Températures + seuils ---
scf(1);
clf;

plot(t_min(1:N), T_meas, "c-");    // mesure bruitée en cyan
plot(t_min(1:N), T_filt, "m-");    // filtrée en magenta
plot(t_min, T_true, "b-");         // vraie en bleu (épaisse)
plot([0 t_min($)], [Tlow Tlow], "g--");
plot([0 t_min($)], [Thigh Thigh], "r--");

// Bonus : marquer les glitches
idx_g = find(glitch == 1);
if idx_g ~= [] then
    plot(t_min(idx_g), T_meas(idx_g), "ko");
end

xgrid();
xlabel("Temps (minutes)");
ylabel("Température (°C)");
title("T vraie / T mesurée / T filtrée + seuils");
legend("T mesurée", "T filtrée", "T vraie", "Tlow", "Thigh");
a = gca();
a.data_bounds = [0, min(T_meas) - 1; t_min($), max(T_meas) + 1];

// --- Figure 2 : Commande chauffage ---
scf(2);
clf;
plot(t_min(1:N), u, "r-");
xgrid();
xlabel("Temps (minutes)");
ylabel("Commande u (0=OFF, 1=ON)");
title("Commande du chauffage (thermostat sur T filtrée)");
a = gca();
a.data_bounds = [0, -0.1; t_min($), 1.1];
