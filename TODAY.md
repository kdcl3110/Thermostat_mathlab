# Séance 2 — Bilan
 
## Ce qui marche
- Thermostat ON/OFF avec hystérésis (controller.sci)
- Température oscille entre Tlow (21.5) et Thigh (22.5)
- Deux graphes : T(t) avec seuils + commande u(t)
 
# Séance 3 — Bilan
 
## Ce qui marche
- Capteur bruité simulé (offset + bruit gaussien + glitches)
- Filtre IIR passe-bas (tau = 10s)
- Thermostat fonctionne sur la température filtrée
- Figure 1 : T vraie, T mesurée, T filtrée + seuils
- Bonus : glitches marqués avec des cercles noirs
 
 
# Séance 4 — Bilan
 
## Ce qui marche
- Détection de défauts : hors bornes, capteur gelé, trop de glitches
- Machine à états NORMAL/SAFE avec latch + recovery
- Injection de panne : capteur gelé entre 18-20 min → SAFE se déclenche
- 3 figures : températures+seuils, u_raw/u_final, état FSM
- 3 exports : demo_output_s4.csv, events_s4.csv, summary_s4.txt
 
