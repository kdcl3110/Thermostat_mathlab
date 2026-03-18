# Séance 2 — Bilan
 
## Ce qui marche
- Thermostat ON/OFF avec hystérésis (controller.sci)
- Température oscille entre Tlow (21.5) et Thigh (22.5)
- Deux graphes : T(t) avec seuils + commande u(t)
 
## Comment tester
- Fichiers : src/plant.sci + src/controller.sci + run_demo.sce
- Commande : `exec("run_demo.sce", -1)`
 
## Reste à faire / idées
- Bonus : afficher les instants de bascule ON/OFF
- Tester d'autres valeurs de Tset et h
 
# Séance 3 — Bilan
 
## Ce qui marche
- Capteur bruité simulé (offset + bruit gaussien + glitches)
- Filtre IIR passe-bas (tau = 10s)
- Thermostat fonctionne sur la température filtrée
- Figure 1 : T vraie, T mesurée, T filtrée + seuils
- Bonus : glitches marqués avec des cercles noirs
 
## Comment tester
- Fichiers : src/plant.sci, src/controller.sci, src/sensor.sci, src/filter.sci + run_demo.sce
- Commande : `exec("run_demo.sce", -1)`
 
## Reste à faire / idées
- Séance 4 : sécurité + machine à états