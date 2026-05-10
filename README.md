```text
Browser
  |
  v
Traefik (HTTPS, Let's Encrypt)
  |
  +--> Homarr
  +--> authentik
  +--> GitLab
  +--> Outline
  +--> Kaneo

authentik
  +--> OIDC for GitLab
  +--> OIDC for Outline
  +--> OIDC for Kaneo
  +--> OIDC for Homarr

Data:
authentik -> PostgreSQL
Outline   -> PostgreSQL + Redis
Kaneo     -> PostgreSQL
GitLab    -> internal storage
Homarr    -> appdata
```

## Сервисы

| Сервис      | Для чего нужен                    | Домен           |
|-------------|-----------------------------------|-----------------|
| `Traefik`   | HTTPS, reverse proxy, сертификаты | `TRAEFIK_URL`   |
| `Homarr`    | стартовая панель со ссылками      | `HOMARR_URL`    |
| `authentik` | единый вход и OIDC provider       | `AUTHENTIK_URL` |
| `GitLab`    | репозитории, CI/CD, review apps   | `GITLAB_URL`    |
| `Outline`   | база знаний / документация        | `OUTLINE_URL`   |
| `Kaneo`     | задачи и доски                    | `KANEO_URL`     |

## Пример запуска

```bash
cp .env.example .env
./ssh.copy.sh or ./sshpass.copy.sh
./server.install.sh
```

## Заполнение `.env`

| Переменная                      | Пример                          | Для чего                                   | Генерация                 |
|---------------------------------|---------------------------------|--------------------------------------------|---------------------------|
| `DOMAIN`                        | `example.com`                   | основной домен                             | -                         |
| `LETSENCRYPT_EMAIL`             | `ops@example.com`               | email для сертификатов                     | -                         |
| `ADMIN_LOGIN`                   | `admin`                         | основной админ логин                       | -                         |
| `ADMIN_EMAIL`                   | `admin@example.com`             | email администратора                       | -                         |
| `ADMIN_PASSWORD`                | `S3curePass!42`                 | пароль администратора и внутренних логинов | `openssl rand -base64 24` |
| `OIDC_SHARED_CLIENT_SECRET`     | `w8m3...`                       | OIDC secret для приложений                 | `openssl rand -base64 32` |
| `SERVER_HOST`                   | `deploy.example.com`            | SSH host                                   | -                         |
| `SERVER_USER`                   | `deployer`                      | SSH пользователь                           | -                         |
| `SERVER_PASSWORD`               | `StrongPass!1`                  | только для `sshpass.copy.sh`               | `openssl rand -base64 24` |
| `REMOTE_DIR`                    | `~/sdlc`                        | директория на сервере                      | -                         |
| `TRAEFIK_DOMAIN`                | `traefik.example.com`           | домен Traefik                              | -                         |
| `TRAEFIK_URL`                   | `https://traefik.example.com`   | URL Traefik                                | -                         |
| `AUTHENTIK_DOMAIN`              | `authentik.example.com`         | домен authentik                            | -                         |
| `AUTHENTIK_URL`                 | `https://authentik.example.com` | URL authentik                              | -                         |
| `AUTHENTIK_POSTGRES_DB`         | `authentik`                     | БД authentik                               | -                         |
| `AUTHENTIK_POSTGRES_USER`       | `admin`                         | пользователь БД authentik                  | -                         |
| `AUTHENTIK_POSTGRES_PASSWORD`   | `S3curePass!42`                 | пароль БД authentik                        | `openssl rand -base64 24` |
| `AUTHENTIK_SECRET_KEY`          | `64-char-hex`                   | secret authentik                           | `openssl rand -hex 32`    |
| `GITLAB_DOMAIN`                 | `gitlab.example.com`            | домен GitLab                               | -                         |
| `GITLAB_URL`                    | `https://gitlab.example.com`    | URL GitLab                                 | -                         |
| `GITLAB_ROOT_PASSWORD`          | `S3curePass!42`                 | пароль `root` GitLab                       | `openssl rand -base64 24` |
| `GITLAB_OMNIAUTH_CLIENT_ID`     | `gitlab-oidc`                   | OIDC client id GitLab                      | -                         |
| `GITLAB_OMNIAUTH_CLIENT_SECRET` | `w8m3...`                       | OIDC client secret GitLab                  | `openssl rand -base64 32` |
| `OUTLINE_DOMAIN`                | `outline.example.com`           | домен Outline                              | -                         |
| `OUTLINE_URL`                   | `https://outline.example.com`   | URL Outline                                | -                         |
| `OUTLINE_POSTGRES_DB`           | `outline`                       | БД Outline                                 | -                         |
| `OUTLINE_POSTGRES_USER`         | `admin`                         | пользователь БД Outline                    | -                         |
| `OUTLINE_POSTGRES_PASSWORD`     | `S3curePass!42`                 | пароль БД Outline                          | `openssl rand -base64 24` |
| `OUTLINE_SECRET_KEY`            | `64-char-hex`                   | secret Outline                             | `openssl rand -hex 32`    |
| `OUTLINE_UTILS_SECRET`          | `64-char-hex`                   | utils secret Outline                       | `openssl rand -hex 32`    |
| `OUTLINE_OIDC_CLIENT_ID`        | `outline-oidc`                  | OIDC client id Outline                     | -                         |
| `OUTLINE_OIDC_CLIENT_SECRET`    | `w8m3...`                       | OIDC client secret Outline                 | `openssl rand -base64 32` |
| `KANEO_DOMAIN`                  | `kaneo.example.com`             | домен Kaneo                                | -                         |
| `KANEO_URL`                     | `https://kaneo.example.com`     | URL Kaneo                                  | -                         |
| `KANEO_API_URL`                 | `https://kaneo.example.com/api` | API URL Kaneo                              | -                         |
| `KANEO_POSTGRES_DB`             | `kaneo`                         | БД Kaneo                                   | -                         |
| `KANEO_POSTGRES_USER`           | `admin`                         | пользователь БД Kaneo                      | -                         |
| `KANEO_POSTGRES_PASSWORD`       | `S3curePass!42`                 | пароль БД Kaneo                            | `openssl rand -base64 24` |
| `KANEO_AUTH_SECRET`             | `64-char-hex`                   | secret Kaneo                               | `openssl rand -hex 32`    |
| `KANEO_OIDC_CLIENT_ID`          | `kaneo-oidc`                    | OIDC client id Kaneo                       | -                         |
| `KANEO_OIDC_CLIENT_SECRET`      | `w8m3...`                       | OIDC client secret Kaneo                   | `openssl rand -base64 32` |
| `HOMARR_DOMAIN`                 | `example.com`                   | домен Homarr                               | -                         |
| `HOMARR_URL`                    | `https://example.com`           | URL Homarr                                 | -                         |
| `HOMARR_SECRET_ENCRYPTION_KEY`  | `64-char-hex`                   | secret Homarr                              | `openssl rand -hex 32`    |
| `HOMARR_OIDC_CLIENT_ID`         | `homarr-oidc`                   | OIDC client id Homarr                      | -                         |
| `HOMARR_OIDC_CLIENT_SECRET`     | `w8m3...`                       | OIDC client secret Homarr                  | `openssl rand -base64 32` |

## Инструкции по работе

### 1. DNS и запуск

| Что сделать                   | Пример                                                                                                                          |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------|
| создать DNS записи            | `example.com`, `traefik.example.com`, `authentik.example.com`, `gitlab.example.com`, `outline.example.com`, `kaneo.example.com` |
| скопировать шаблон env        | `cp .env.example .env`                                                                                                          |
| заполнить `.env`              | подставить свои домены, пароли, secrets                                                                                         |
| отправить на сервер по ключу  | `./ssh.copy.sh`                                                                                                                 |
| отправить на сервер по паролю | `./sshpass.copy.sh`                                                                                                             |
| запустить на сервере          | `./server.install.sh`                                                                                                           |

### 2. authentik

| Действие              | Что сделать                                            |
|-----------------------|--------------------------------------------------------|
| открыть               | зайти в `AUTHENTIK_URL`                                |
| initial setup         | ввести `ADMIN_LOGIN`, `ADMIN_EMAIL`, `ADMIN_PASSWORD`  |
| создать пользователей | `Directory -> Users -> Create`                         |
| создать OIDC provider | `Applications -> Applications -> Create with Provider` |

### 3. OIDC для приложений

Общие настройки provider:

| Поле            | Значение                     |
|-----------------|------------------------------|
| `Provider type` | `OAuth2/OpenID Connect`      |
| `Client type`   | `Confidential`               |
| `Scopes`        | `openid`, `profile`, `email` |

Приложения:

| Приложение | Client ID      | Client Secret               | Redirect URI                                    |
|------------|----------------|-----------------------------|-------------------------------------------------|
| `GitLab`   | `gitlab-oidc`  | `OIDC_SHARED_CLIENT_SECRET` | `GITLAB_URL/users/auth/openid_connect/callback` |
| `Outline`  | `outline-oidc` | `OIDC_SHARED_CLIENT_SECRET` | `OUTLINE_URL/auth/oidc.callback`                |
| `Kaneo`    | `kaneo-oidc`   | `OIDC_SHARED_CLIENT_SECRET` | `KANEO_URL/api/auth/oauth2/callback/custom`     |
| `Homarr`   | `homarr-oidc`  | `OIDC_SHARED_CLIENT_SECRET` | `HOMARR_URL/api/auth/callback/oidc`             |

### 4. GitLab

| Действие             | Что сделать                                                     |
|----------------------|-----------------------------------------------------------------|
| открыть              | зайти в `GITLAB_URL`                                            |
| локальный админ вход | логин `root`, пароль `GITLAB_ROOT_PASSWORD`                     |
| SSH доступ           | использовать порт `2222`                                        |
| review apps          | публиковать через `Traefik` labels и поддомены `<env>.<DOMAIN>` |

### 5. Outline

| Действие   | Что сделать                          |
|------------|--------------------------------------|
| открыть    | зайти в `OUTLINE_URL`                |
| вход       | использовать вход через `authentik`  |
| назначение | вести документацию команды и проекта |

### 6. Kaneo

| Действие   | Что сделать                         |
|------------|-------------------------------------|
| открыть    | зайти в `KANEO_URL`                 |
| вход       | использовать вход через `authentik` |
| назначение | вести задачи и доски                |

### 7. Homarr

| Действие   | Что сделать                                      |
|------------|--------------------------------------------------|
| открыть    | зайти в `HOMARR_URL`                             |
| вход       | использовать вход через `authentik`              |
| назначение | сделать домашнюю страницу со ссылками на сервисы |
