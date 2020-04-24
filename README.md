# ProjetSignal
Dépot GIT du Projet Signal 2020 du Groupe GE4_FPTD

## Description
Projet de Reconnaissance Optique de Caractère en utilisant l'intercorrélation entre deux signaux représentant des images

## Objectifs
Réaliser un script complet permettant de renvoyer le texte contenu dans une image

## Réalisation
Le script est réalisé en utilisant le logiciel GNU-Octave
Les paquets _signal_, _image_ et _matgeo_ sont nécessaires  


## Images
Les images sont crées avec le logiciel de dessin Inkscape.
La police utilisée est _Bitstream Vera Sans Mono_, de taille quelconque, l'algorithme détermine la taille de la police automatiquement.
La détermination du nombre de caractères lorsque l'image ne contient qu'une seul ligne de texte ou des espaces alignés verticalement pose problème, c'est donc à éviter.

#Exécution
`octave main.m`
Il est ensuite demandé l'adresse de l'image (des exemples sont disponibles dans _Data/_
Si l'image est un positif ou en négatif (fond foncé/écriture claire ou l'inverse)
Si le texte ne contient que des majuscules afin de gagner du temps de processus
