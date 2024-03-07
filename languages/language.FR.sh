#!/usr/bin/env bash

################################################################################
# Whiptail Selection Menu texts                                                #
################################################################################
wtActions="Actions à réaliser"
wmActions="Sélectionner les actions à réaliser:"

################################################################################
# Selection Menu A : Install                                                   #
################################################################################
woSelA1="Changer la langue"
woSelA2="Réinitialisation de la configuration"
woSelA3="Installation de SDL"
woSelA4="installation des polices TrueType pour SDL"
woSelA5="Installation de MAME"
woSelA6="Installation de SFML"
woSelA7="Installation de Attract Mode+"
woSelA8="Installation de Arcadeflow"

################################################################################
# Selection Menu B : Setup                                                     #
################################################################################
woSelB1="Configuration de MAME"
woSelB2="Configuration de Attract Mode+"
woSelB3="Configuration de Arcade Flow"

################################################################################
# Reset choice                                                                 #
################################################################################
wtReset="Réinitialisation de la configuration"
wmReset="Cette activité permettra de réinitialisation le status d'installation des logiciels.\nCelà peut être utile en cas de problème.\n\nSouhaiez-vous l'exécuter?"

################################################################################
# Install script messages                                                      #
################################################################################
ln_get_software_version="Obtention des versions les plus récente des logiciels à partir de leur 'dépôt' Git."
ln_get_software_table_title="LOGICIEL      | VERSION LOCALE  | VERSION GIT     | METTRE A JOUR |"
ln_download_software="Téléchargement des logiciels depuis leur 'dépôt' Git."
ln_download_software_table_title="SOFTWARE      | VERSION GIT     | NOM DU ZIP              |"
ln_unzip_software="Décompression des logiciels."
ln_unzip_software_table_title="LOGICIEL      | FICHIER                 | DESTINATION                              |"
ln_install_start="Démarrage du script d'installation de : "
ln_script_finished_successfully="La procédure s'est terminée avec succès."
ln_script_attract_required="Attract Mode+ n'est pas installé ou configuré."

################################################################################
# Setup ATTRACT script messages                                                #
################################################################################
ln_setup_start="Démarrage du script de configuration de : "
ln_setup_mame_generated="La configuration de MAME est faite."
ln_setup_attract_mame_generate="Generation de la liste des jeux..."
ln_setup_attract_mame_version="Version MAME installée :"
ln_setup_attract_mame_games="Nombre de jeux analysés :"
ln_setup_attract_mame_import="importation des jeux..."
ln_setup_attract_done="La configuration de ATTRACT est faite."
