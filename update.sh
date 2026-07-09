#!/bin/ash
PROJECT=paper
USER_AGENT="Pterodactyl (https://Pterodactyl.io)"

cd /home/container

echo -e "Checking latest build for Paper ${MINECRAFT_VERSION}..."

# Récupère la liste des builds et prend le premier (le plus récent)
BUILDS_JSON=`curl --user-agent "${USER_AGENT}" -s https://fill.papermc.io/v3/projects/${PROJECT}/versions/${MINECRAFT_VERSION}`
LATEST_BUILD=`echo "${BUILDS_JSON}" | grep -o '"builds":\[[0-9,]*\]' | grep -o '[0-9]\+' | head -1`

if [ -z "${LATEST_BUILD}" ]; then
    echo -e "Impossible de récupérer le dernier build. Le serveur va démarrer avec le jar actuel."
    exit 0
fi

echo -e "Dernier build disponible : ${LATEST_BUILD}"

# Récupère l'URL de téléchargement pour ce build précis
BUILD_JSON=`curl --user-agent "${USER_AGENT}" -s https://fill.papermc.io/v3/projects/${PROJECT}/versions/${MINECRAFT_VERSION}/builds/${LATEST_BUILD}`
DOWNLOAD_URL=`echo "${BUILD_JSON}" | grep -o '"server:default":{[^}]*}' | grep -o '"url":"[^"]*"' | cut -d'"' -f4`

if [ -z "${DOWNLOAD_URL}" ]; then
    echo -e "Impossible de récupérer l'URL de téléchargement. Le serveur va démarrer avec le jar actuel."
    exit 0
fi

if [ -f ${SERVER_JARFILE} ]; then
    mv ${SERVER_JARFILE} ${SERVER_JARFILE}.old
fi

echo -e "Téléchargement du build ${LATEST_BUILD}..."
curl --user-agent "${USER_AGENT}" -o ${SERVER_JARFILE} ${DOWNLOAD_URL}

echo -e "Mise à jour terminée."
