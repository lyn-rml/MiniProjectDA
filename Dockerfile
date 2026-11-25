
# Image de départ
#FROM alpine:3.20

# Répertoire de travail
#WORKDIR /app

# Installation des paquets système
#RUN apk add --no-cache nodejs npm

# Création de l'utilisateur et du groupe node
#RUN addgroup -S node && \
#    adduser -S -G node node && \
 #   chown node:node /app

# Réduction des privilèges
#USER node

# Copie des fichiers du projet
#COPY --chown=node:node . .

# Installation des dépendances
#RUN npm ci

# Compilation TypeScript
#RUN npm run build

# Exécution de l'application
#CMD ["npm", "start"]

#---------

# Stage 1 : compilation
FROM alpine:3.20 AS builder

WORKDIR /app

# Outils nécessaires à la construction
RUN apk add --no-cache nodejs npm

# Installer les dépendances avant de copier les sources
COPY package.json package-lock.json ./
RUN npm ci

COPY tsconfig.json ./
COPY src ./src

# Compiler uniquement les fichiers nécessaires à l'exécution
RUN npm run build -- --declaration false --sourceMap false --incremental false


# Stage 2 : exécution
FROM alpine:3.20 AS runner

WORKDIR /app

# Node.js suffit pour exécuter le JavaScript
RUN apk add --no-cache nodejs

RUN addgroup -S node && \
    adduser -S -G node node

# Récupérer uniquement le résultat de compilation
COPY --from=builder --chown=node:node /app/dist ./dist

USER node

CMD ["node", "dist/index.js"]