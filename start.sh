#!/bin/ash
cd /home/container

echo -e "=== Vérification des mises à jour Paper ==="
bash update.sh

echo -e "=== Démarrage du serveur ==="
exec java -Xms128M -XX:MaxRAMPercentage=95.0 -Dterminal.jline=false -Dterminal.ansi=true -jar ${SERVER_JARFILE} nogui
