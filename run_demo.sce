exec("src/plant.sci", -1);
exec("src/controller.sci", -1);
exec("src/sensor.sci", -1);
exec("src/filter.sci", -1);
exec("src/safety.sci", -1);
exec("src/fsm.sci", -1);

dt    = 1;
t_end = 30 * 60;
Text  = 18;
alpha = 0.035;
betaa = 0.002;

// Paramètres thermostat
Tset = 22;
h    = 1;
Tlow  = Tset - h/2;
Thigh = Tset + h/2;

// Paramètres capteur
cfg.offset     = 0.3;
cfg.sigma      = 0.2;
cfg.p_glitch   = 0.01;
cfg.glitch_amp = 5;

// Paramètre filtre
tau = 10;

// Paramètres sécurité
safety_cfg.Tmin       = -10;
safety_cfg.Tmax       = 60;
safety_cfg.stuck_eps  = 0.02;
safety_cfg.stuck_N    = 30;
safety_cfg.win_N      = 60;
safety_cfg.glitch_max = 5;
safety_cfg.recover_N  = 30;

N = t_end / dt;

T_true   = zeros(1, N+1);
T_meas   = zeros(1, N);
T_filt   = zeros(1, N);
u_raw    = zeros(1, N);
u_final  = zeros(1, N);
glitch   = zeros(1, N);
state_vec = zeros(1, N);
t        = (0:N) * dt;

T_true(1) = 20;
heat_on   = %f;

// Initialiser l'état de la sécurité
st.last_meas     = T_true(1);
st.stuck_count   = 0;
st.glitch_win    = zeros(1, safety_cfg.win_N);
st.latched       = %f;
st.recover_count = 0;
st.last_code     = 0;

// Journal d'événements
events = [];

// Premier pas
[T_meas(1), g] = sensor_read(T_true(1), cfg);
glitch(1) = bool2s(g);
T_filt(1) = T_meas(1);
[u_raw(1), heat_on] = thermostat_step(T_filt(1), heat_on, Tset, h);
[fault, code, st] = safety_step(T_meas(1), g, st, safety_cfg);
[state_vec(1), u_final(1), lg] = fsm_step(fault, code, u_raw(1), 0, 0);
if lg ~= [] then
    events = [events; lg];
end
T_true(2) = plant_step(T_true(1), u_final(1), Text, dt, alpha, betaa);

for k = 2:N
    temps_s = (k-1) * dt;
    temps_min = temps_s / 60;

    // --- INJECTION DE PANNE : capteur gelé entre 18 et 20 min ---
    if temps_min >= 18 & temps_min < 20 then
        T_meas(k) = T_meas(k-1);   // on force la même valeur
        g = %f;
    else
        [T_meas(k), g] = sensor_read(T_true(k), cfg);
    end
    glitch(k) = bool2s(g);

    // 2. Filtre
    T_filt(k) = iir_step(T_meas(k), T_filt(k-1), tau, dt);

    // 3. Thermostat → u_raw
    [u_raw(k), heat_on] = thermostat_step(T_filt(k), heat_on, Tset, h);

    // 4. Sécurité + FSM → u_final
    [fault, code, st] = safety_step(T_meas(k), g, st, safety_cfg);
    [state_vec(k), u_final(k), lg] = fsm_step(fault, code, u_raw(k), state_vec(k-1), temps_s);
    if lg ~= [] then
        events = [events; lg];
    end

    // 5. Modèle avec u_final
    T_true(k+1) = plant_step(T_true(k), u_final(k), Text, dt, alpha, betaa);
end

// --- Conversion en minutes ---
t_min = t / 60;

// === FIGURE 1 : Températures + seuils ===
scf(1);
clf;
plot(t_min(1:N), T_meas, "c-");
plot(t_min(1:N), T_filt, "m-");
plot(t_min, T_true, "b-");
plot([0 t_min($)], [Tlow Tlow], "g--");
plot([0 t_min($)], [Thigh Thigh], "r--");
xlabel("Temps (minutes)");
ylabel("Température (°C)");
title("T vraie / T mesurée / T filtrée + seuils");
legend("T mesurée", "T filtrée", "T vraie", "Tlow", "Thigh");
xgrid();
a = gca();
a.data_bounds = [0, min(T_meas) - 1; t_min($), max(T_meas) + 1];

// === FIGURE 2 : u_raw et u_final ===
scf(2);
clf;
plot(t_min(1:N), u_raw, "b-");
plot(t_min(1:N), u_final, "r-");
xlabel("Temps (minutes)");
ylabel("Commande (0=OFF, 1=ON)");
title("Commande thermostat (u raw) vs commande finale (u final)");
xgrid();
legend("u raw", "u final");
a = gca();
a.data_bounds = [0, -0.1; t_min($), 1.1];

// === FIGURE 3 : État (NORMAL / SAFE) ===
scf(3);
clf;
plot(t_min(1:N), state_vec, "k-");
xlabel("Temps (minutes)");
ylabel("État (0=NORMAL, 1=SAFE)");
title("Machine à états : NORMAL / SAFE");
xgrid();
a = gca();
a.data_bounds = [0, -0.1; t_min($), 1.1];

// === EXPORTS ===

// 1) demo_output_s4.csv
header = "t_s,T_true,T_meas,T_filt,u_raw,u_final,state";
data = [t(1:N)', T_true(1:N)', T_meas', T_filt', u_raw', u_final', state_vec'];
csvWrite(data, "demo_output_s4.csv");
// Ajouter le header manuellement
fd = mopen("demo_output_s4.csv", "r");
content = mgetl(fd);
mclose(fd);
fd = mopen("demo_output_s4.csv", "w");
mputl(header, fd);
mputl(content, fd);
mclose(fd);

// 2) events_s4.csv
fd = mopen("events_s4.csv", "w");
mputl("t_s,event_code,reason_code", fd);
if events ~= [] then
    for i = 1:size(events, 1)
        line = string(events(i,1)) + "," + string(events(i,2)) + "," + string(events(i,3));
        mputl(line, fd);
    end
end
mclose(fd);

// 3) summary_s4.txt
total_safe = sum(state_vec) * dt;
nb_events = 0;
if events ~= [] then
    nb_events = size(events, 1);
end
fd = mopen("summary_s4.txt", "w");
mputl("=== Résumé Séance 4 ===", fd);
mputl("Temps total en SAFE : " + string(total_safe) + " secondes", fd);
mputl("Nombre d événements : " + string(nb_events), fd);
mclose(fd);

disp("Simulation terminée. Fichiers exportés : demo_output_s4.csv, events_s4.csv, summary_s4.txt");
