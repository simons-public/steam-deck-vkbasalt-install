#!/usr/bin/bash
#
# vkbasalt_install.sh
#
# Author: Chris Simons <chris@simonsmail.net>
# Platform: Steam Deck SteamOS
#
# Description: Installs vkBasalt on a Steam Deck in the deck home
# directory without modifying the immutable OS filesystem.
#

set -eo pipefail

if ! grep -q SteamOS /etc/os-release ; then
        echo "This script should only be run on a Steam Deck running SteamOS"
        exit 1
fi
if [ "$EUID" -eq 0 ]; then
        echo "This script should not be run as root"
        exit 1
fi

DECK_HOME='/home/deck'
AUR_BASE='https://builds.garudalinux.org/repos/chaotic-aur/x86_64/'

VKBASALT_PKG_VER=$(curl ${AUR_BASE} 2>/dev/null | grep -o 'vkbasalt-.*-x86_64' | head -1)
VKBASALT_PKG="${VKBASALT_PKG_VER}.pkg.tar.zst"
VKBASALT_LIB32_PKG="lib32-${VKBASALT_PKG}"
VKBASALT_PKG_FILE=$(mktemp /tmp/vkbasalt.XXXXXX.tar.zst)
VKBASALT_LIB32_PKG_FILE=$(mktemp /tmp/vkbasalt.XXXXXX.lib32.tar.zst)

wget "${AUR_BASE}${VKBASALT_PKG}" -O ${VKBASALT_PKG_FILE}
wget "${AUR_BASE}${VKBASALT_LIB32_PKG}" -O ${VKBASALT_LIB32_PKG_FILE}

mkdir -p ${DECK_HOME}/.local/{lib,lib32,share/vulkan/implicit_layer.d}
mkdir -p ${DECK_HOME}/.config/{vkBasalt,reshade}

tar xf ${VKBASALT_PKG_FILE} --strip-components=2 \
        --directory=${DECK_HOME}/.local/lib/ usr/lib/libvkbasalt.so
tar xf ${VKBASALT_LIB32_PKG_FILE} --strip-components=2 \
        --directory=${DECK_HOME}/.local/lib32/ usr/lib32/libvkbasalt.so

tar xf ${VKBASALT_PKG_FILE} --to-stdout usr/share/vulkan/implicit_layer.d/vkBasalt.json \
        | sed -e "s|libvkbasalt.so|${DECK_HOME}/.local/lib/libvkbasalt.so|" \
              -e "s/ENABLE_VKBASALT/SteamDeck/" \
              > ${DECK_HOME}/.local/share/vulkan/implicit_layer.d/vkBasalt.json

tar xf ${VKBASALT_LIB32_PKG_FILE} --to-stdout usr/share/vulkan/implicit_layer.d/vkBasalt.x86.json \
        | sed -e "s|libvkbasalt.so|${DECK_HOME}/.local/lib32/libvkbasalt.so|" \
              -e "s/ENABLE_VKBASALT/SteamDeck/" \
              > ${DECK_HOME}/.local/share/vulkan/implicit_layer.d/vkBasalt.x86.json


tar xf ${VKBASALT_PKG_FILE} --to-stdout usr/share/vkBasalt/vkBasalt.conf.example \
        | sed -e "s|/opt/reshade/textures|/home/deck/.config/reshade/Textures|" \
              -e "s|/opt/reshade/shaders|/home/deck/.config/reshade/Shaders|" \
              > ${DECK_HOME}/.config/vkBasalt/vkBasalt.conf.example


rm ${VKBASALT_PKG_FILE} ${VKBASALT_LIB32_PKG_FILE}

echo "vkBasalt installed. Example configuration file in ~/.config/vkBasalt. Download"
echo "shaders to ~/.config/reshade/. vkBasalt is now enabled by default, to disable for"
echo "a specific game, use \"DISABLE_VKBASALT=1 %command%\" in the Steam launch options."
echo "Default keyboard shortcut to toggle vkBasalt on/off is the Home key."
