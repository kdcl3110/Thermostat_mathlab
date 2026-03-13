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
 
