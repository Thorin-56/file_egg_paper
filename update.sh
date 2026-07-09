#!/bin/ash
PROJECT=paper
USER_AGENT="Pterodactyl (contact: ptero@thorin-56.fr)"

cd /home/container

# Télécharge jq en binaire statique si absent
if ! which jq >/dev/null 2>&1; then
    if [ ! -f /home/container/jq ]; then
        echo "Téléchargement de jq..."
        curl -sL -o /home/container/jq https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64
        chmod +x /home/container/jq
    fi
    JQ=/home/container/jq
else
    JQ=jq
fi

# Résolution de "latest" en vraie version si besoin
if [ "${MINECRAFT_VERSION}" == "latest" ]; then
    echo -e "Résolution de la dernière version de Paper..."
    MINECRAFT_VERSION=`curl --user-agent "${USER_AGENT}" -s https://fill.papermc.io/v3/projects/${PROJECT} | ${JQ} -r '.versions | to_entries | .[0].value[0]'`
    echo -e "Version résolue : ${MINECRAFT_VERSION}"
fi

echo -e "Recherche du dernier build stable pour Paper ${MINECRAFT_VERSION}..."

BUILDS_JSON=`curl --user-agent "${USER_AGENT}" -s https://fill.papermc.io/v3/projects/${PROJECT}/versions/${MINECRAFT_VERSION}/builds`

DOWNLOAD_URL=`echo "${BUILDS_JSON}" | ${JQ} -r '[.[] | select(.channel == "STABLE")][0].downloads."server:default".url'`

if [ -z "${DOWNLOAD_URL}" ] || [ "${DOWNLOAD_URL}" == "null" ]; then
    echo -e "Aucun build stable trouvé. Le serveur va démarrer avec le jar actuel."
    exit 0
fi

if [ -f ${SERVER_JARFILE} ]; then
    mv ${SERVER_JARFILE} ${SERVER_JARFILE}.old
fi

echo -e "Téléchargement en cours..."
curl --user-agent "${USER_AGENT}" -o ${SERVER_JARFILE} ${DOWNLOAD_URL}

echo -e "Mise à jour terminée."
