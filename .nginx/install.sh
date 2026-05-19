#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SITES_AVAILABLE_DIR="/etc/nginx/sites-available"
SITES_ENABLED_DIR="/etc/nginx/sites-enabled"
CONF_D_DIR="/etc/nginx/conf.d"

shopt -s nullglob
SOURCE_FILES=("${SCRIPT_DIR}"/*.dcu.conf)

if [[ "${#SOURCE_FILES[@]}" -eq 0 ]]; then
    echo "No .dcu.conf files found in ${SCRIPT_DIR}" >&2
    exit 1
fi

SUDO=""
if [[ "${EUID}" -ne 0 ]]; then
    SUDO="sudo"
fi

for source_conf in "${SOURCE_FILES[@]}"; do
    conf_name="$(basename "${source_conf}")"
    target_conf="${SITES_AVAILABLE_DIR}/${conf_name}"
    enabled_conf="${SITES_ENABLED_DIR}/${conf_name}"
    conf_d_conf="${CONF_D_DIR}/${conf_name}"

    if [[ ! -f "${source_conf}" ]]; then
        echo "Config not found: ${source_conf}" >&2
        exit 1
    fi

    if [[ -f "${conf_d_conf}" ]]; then
        backup_conf="${conf_d_conf}.bak.$(date +%Y%m%d%H%M%S)"
        ${SUDO} cp "${conf_d_conf}" "${backup_conf}"
        ${SUDO} rm -f "${conf_d_conf}"
        echo "Removed old ${conf_d_conf}, backup: ${backup_conf}"
    fi

    if [[ -L "${enabled_conf}" || -f "${enabled_conf}" ]]; then
        ${SUDO} rm -f "${enabled_conf}"
        echo "Removed old ${enabled_conf}"
    fi

    if [[ -f "${target_conf}" ]]; then
        backup_conf="${target_conf}.bak.$(date +%Y%m%d%H%M%S)"
        ${SUDO} cp "${target_conf}" "${backup_conf}"
        ${SUDO} rm -f "${target_conf}"
        echo "Backup created: ${backup_conf}"
    fi

    ${SUDO} cp "${source_conf}" "${target_conf}"
    ${SUDO} ln -sfn "${target_conf}" "${enabled_conf}"
    echo "Installed ${target_conf}"
    echo "Linked ${enabled_conf} -> ${target_conf}"
done

${SUDO} nginx -t

if command -v systemctl >/dev/null 2>&1; then
    ${SUDO} systemctl reload nginx
else
    ${SUDO} service nginx reload
fi

echo "Nginx reloaded"
