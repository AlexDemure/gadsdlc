```text
Browser
  |
  v
nginx (HTTPS, Let's Encrypt)
  |
  +--> authentik
  +--> gitlab
  +--> outline
  +--> kaneo
  +--> homarr
  +--> seafile
  +--> zerobyte

authentik
  +--> OIDC for GitLab
  +--> OIDC for Outline
  +--> OIDC for Kaneo
  +--> OIDC for Homarr
  +--> OAuth/OIDC for Seafile
  +--> OIDC for Zerobyte
```

## Сервисы

| Сервис      | Для чего нужен                    | Домен                               |
|-------------|-----------------------------------|-------------------------------------|
| `authentik` | единый вход и OIDC provider       | `https://authentik.dcu.aicareer.info` |
| `GitLab`    | репозитории, CI/CD, review apps   | `https://gitlab.dcu.aicareer.info`    |
| `Outline`   | база знаний / документация        | `https://outline.dcu.aicareer.info`   |
| `Kaneo`     | задачи и доски                    | `https://kaneo.dcu.aicareer.info`     |
| `Homarr`    | стартовая панель со ссылками      | `https://homarr.dcu.aicareer.info`    |
| `Seafile`   | файловое облако и синхронизация   | `https://seafile.dcu.aicareer.info`   |
| `Zerobyte`  | централизованные backup jobs      | `https://zerobyte.dcu.aicareer.info`  |

## Запуск

```bash
cp .env.example .env
./ssh.copy.sh
./server.install.sh
```

После запуска контейнеров установи конфиги nginx:

```bash
cd .nginx
./install.sh
```

## `.env`

Основные переменные:

| Переменная | Пример |
|------------|--------|
| `DOMAIN` | `dcu.aicareer.info` |
| `LETSENCRYPT_EMAIL` | `ops@aicareer.info` |
| `ADMIN_LOGIN` | `admin` |
| `ADMIN_EMAIL` | `admin@aicareer.info` |
| `ADMIN_PASSWORD` | `openssl rand -base64 24` |
| `OIDC_SHARED_CLIENT_SECRET` | `openssl rand -base64 32` |
| `SERVER_HOST` | `deploy.example.com` |
| `SERVER_USER` | `deployer` |
| `SERVER_PASSWORD` | `StrongPass!1` |
| `REMOTE_DIR` | `~/dcu` |

Домены должны совпадать с `nginx` конфигами из [`.nginx`](/home/alex/git/gadsdlc/.nginx).

## nginx

В каталоге [`.nginx`](/home/alex/git/gadsdlc/.nginx) лежат готовые сайты:

| Файл | Домен | Upstream |
|------|-------|----------|
| `authentik.dcu.conf` | `authentik.dcu.aicareer.info` | `127.0.0.1:51000` |
| `gitlab.dcu.conf` | `gitlab.dcu.aicareer.info` | `127.0.0.1:51080` |
| `outline.dcu.conf` | `outline.dcu.aicareer.info` | `127.0.0.1:53000` |
| `kaneo.dcu.conf` | `kaneo.dcu.aicareer.info` | `127.0.0.1:55173` и `127.0.0.1:51337` |
| `homarr.dcu.conf` | `homarr.dcu.aicareer.info` | `127.0.0.1:52575` |
| `seafile.dcu.conf` | `seafile.dcu.aicareer.info` | `127.0.0.1:50080` |
| `zerobyte.dcu.conf` | `zerobyte.dcu.aicareer.info` | `127.0.0.1:54096` |

Все конфиги:

| Что делают | Детали |
|------------|--------|
| HTTP -> HTTPS redirect | `listen 80` с `return 301` |
| TLS | сертификаты и SSL-директивы подключаются отдельно |
| Proxy headers | пробрасывают `Host`, `X-Forwarded-*`, `Upgrade` |

## GitLab

| Действие | Что сделать |
|----------|-------------|
| открыть | зайти в `GITLAB_URL` |
| локальный админ вход | логин `root`, пароль `GITLAB_ROOT_PASSWORD` |
| SSH доступ | использовать порт `52222` |

## Таблица портов

| Сервис | Назначение | Host port | Bind | Container port |
|--------|------------|-----------|------|----------------|
| `authentik` | HTTP upstream для nginx | `51000` | `127.0.0.1` | `9000` |
| `gitlab` | HTTP upstream для nginx | `51080` | `127.0.0.1` | `80` |
| `gitlab` | SSH | `52222` | `0.0.0.0` | `22` |
| `outline` | HTTP upstream для nginx | `53000` | `127.0.0.1` | `3000` |
| `kaneo-api` | API upstream для nginx | `51337` | `127.0.0.1` | `1337` |
| `kaneo-web` | Web upstream для nginx | `55173` | `127.0.0.1` | `5173` |
| `homarr` | HTTP upstream для nginx | `52575` | `127.0.0.1` | `7575` |
| `seafile` | HTTP upstream для nginx | `50080` | `127.0.0.1` | `80` |
| `zerobyte` | HTTP upstream для nginx | `54096` | `127.0.0.1` | `4096` |
| `nginx` | HTTP public | `80` | `0.0.0.0` | `80` |
| `nginx` | HTTPS public | `443` | `0.0.0.0` | `443` |

## OIDC

Общие настройки provider в authentik:

| Поле | Значение |
|------|----------|
| `Provider type` | `OAuth2/OpenID Connect` |
| `Client type` | `Confidential` |
| `Scopes` | `openid`, `profile`, `email` |

Приложения:

| Приложение | Client ID | Client Secret | Redirect URI |
|------------|-----------|---------------|--------------|
| `GitLab` | `gitlab-oidc` | `OIDC_SHARED_CLIENT_SECRET` | `GITLAB_URL/users/auth/openid_connect/callback` |
| `Outline` | `outline-oidc` | `OIDC_SHARED_CLIENT_SECRET` | `OUTLINE_URL/auth/oidc.callback` |
| `Kaneo` | `kaneo-oidc` | `OIDC_SHARED_CLIENT_SECRET` | `KANEO_URL/api/auth/oauth2/callback/custom` |
| `Homarr` | `homarr-oidc` | `OIDC_SHARED_CLIENT_SECRET` | `HOMARR_URL/api/auth/callback/oidc` |
| `Seafile` | `seafile-oidc` | `SEAFILE_OIDC_CLIENT_SECRET` | `SEAFILE_URL/oauth/callback/` |
| `Zerobyte` | `zerobyte-oidc` | `ZEROBYTE_OIDC_CLIENT_SECRET` | взять callback URL из UI Zerobyte |
