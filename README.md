```text
Browser
  |
  v
nginx (HTTP)
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
| `authentik` | единый вход и OIDC provider       | `http://authentik.dcu.aicareer.info` |
| `GitLab`    | репозитории, CI/CD, review apps   | `http://gitlab.dcu.aicareer.info`    |
| `Outline`   | база знаний / документация        | `http://outline.dcu.aicareer.info`   |
| `Kaneo`     | задачи и доски                    | `http://kaneo.dcu.aicareer.info`     |
| `Homarr`    | стартовая панель со ссылками      | `http://homarr.dcu.aicareer.info`    |
| `Seafile`   | файловое облако и синхронизация   | `http://seafile.dcu.aicareer.info`   |
| `Zerobyte`  | централизованные backup jobs      | `http://zerobyte.dcu.aicareer.info`  |

## Запуск

```bash
cp .env.example .env
./server.install.sh
```

После запуска контейнеров установи конфиги nginx:

```bash
cd .nginx
./install.sh
```

## `.env`

Используемые переменные:

| Переменная | Пример |
|------------|--------|
| `AUTHENTIK_URL` | `http://authentik.dcu.aicareer.info` |
| `GITLAB_DOMAIN` | `gitlab.dcu.aicareer.info` |
| `GITLAB_URL` | `http://gitlab.dcu.aicareer.info` |
| `OUTLINE_URL` | `http://outline.dcu.aicareer.info` |
| `KANEO_URL` | `http://kaneo.dcu.aicareer.info` |
| `KANEO_API_URL` | `http://kaneo.dcu.aicareer.info/api` |
| `HOMARR_URL` | `http://homarr.dcu.aicareer.info` |
| `SEAFILE_DOMAIN` | `seafile.dcu.aicareer.info` |
| `SEAFILE_URL` | `http://seafile.dcu.aicareer.info` |
| `ZEROBYTE_URL` | `http://zerobyte.dcu.aicareer.info` |

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
| HTTP proxy | только HTTP upstream без TLS-логики |
| TLS | настраивается отдельно вне этих файлов |
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
| `GitLab` | `gitlab-oidc` | `GITLAB_OMNIAUTH_CLIENT_SECRET` | `GITLAB_URL/users/auth/openid_connect/callback` |
| `Outline` | `outline-oidc` | `OUTLINE_OIDC_CLIENT_SECRET` | `OUTLINE_URL/auth/oidc.callback` |
| `Kaneo` | `kaneo-oidc` | `KANEO_OIDC_CLIENT_SECRET` | `KANEO_URL/api/auth/oauth2/callback/custom` |
| `Homarr` | `homarr-oidc` | `HOMARR_OIDC_CLIENT_SECRET` | `HOMARR_URL/api/auth/callback/oidc` |
| `Seafile` | `seafile-oidc` | `SEAFILE_OIDC_CLIENT_SECRET` | `SEAFILE_URL/oauth/callback/` |
| `Zerobyte` | настроить в UI | настроить в UI | взять callback URL из UI Zerobyte |

Для `Seafile` OIDC-конфиг лежит в [`conf/seafile/seahub_settings.py`](/home/alex/git/gadsdlc/conf/seafile/seahub_settings.py) и монтируется в контейнер как `read-only`.
