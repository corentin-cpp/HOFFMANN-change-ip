# TP HOFFMANN Corentin

## Utilsation du script
> Ce script permet de changer facilement son adresse IP de son Poste

> Ce Script a été testé sur une machine debian

## Problème potentiel
Il se peut qu'après avoir éxécuté le script des paramètres de la carte réseau soit changé et provoquer des erreurs. Pour régler le problème vous devez aller dans les paramètres et recréer un profile de la carte réseau dans les paramètres Debian et spécifiant une IP valide ou en DHCP pour être sûr.

## Lancement su script
Création du script :
`nano HOFFMANN-TP1.sh` Puis collez le contenu du script


Attribuer les droits admin :
`chmod +x HOFFMANN-TP1.sh`


Lancer le script : 
`./HOFFMANN-TP1.sh`
