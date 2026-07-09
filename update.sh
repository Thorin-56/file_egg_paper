#!/bin/ash
PROJECT=paper
USER_AGENT="Pterodactyl (https://Pterodactyl.io)"

cd /home/container

# Si MINECRAFT_VERSION est "latest", on résout la vraie dernière version
if [ "${MINECRAFT_VERSION}" == "latest" ]; then
    echo -e "Résolution de la dernière version de Paper..."
    VERSIONS_JSON=`curl --user-agent "${USER_AGENT}" -s https://fill.papermc.io/v3/projects/${PROJECT}`
    # Prend le dernier groupe de versions, puis la dernière version de ce groupe
    RESOLVED_VERSION=`echo "${VERSIONS_JSON}" | grep -o '"versions":{[^}]*}[^}]*}' | grep -o '\[[^]]*\]' | tail -1 | grep -o '"[0-9][^"]*"' | tail -1 | tr -d '"'`
    if [ -z "${RESOLVED_VERSION}" ]; then
        echo -e "Impossible de résoudre 'latest'. Le serveur va démarrer avec le jar actuel."
        exit 0
    fi
    echo -e "Version résolue : ${RESOLVED_VERSION}"
    MINECRAFT_VERSION=${RESOLVED_VERSION}
fi

echo -e "Checking latest build for Paper ${MINECRAFT_VERSION}..."

BUILDS_JSON=`curl --user-agent "${USER_AGENT}" -s https://fill.papermc.io/v3/projects/${PROJECT}/versions/${MINECRAFT_VERSION}`
LATEST_BUILD=`echo "${BUILDS_JSON}" | grep -o '"builds":\[[0-9,]*\]' | grep -o '[0-9]\+' | head -1`

if [ -z "${LATEST_BUILD}" ]; then
    echo -e "Impossible de récupérer le dernier build. Le serveur va démarrer avec le jar actuel."
    exit 0
fi

echo -e "Dernier build disponible : ${LATEST_BUILD}"

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
