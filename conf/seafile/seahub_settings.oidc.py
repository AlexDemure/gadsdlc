import os


ENABLE_OAUTH = True
OAUTH_CREATE_UNKNOWN_USER = True
OAUTH_ACTIVATE_USER_AFTER_CREATION = True
OAUTH_CLIENT_ID = os.environ["SEAFILE_OIDC_CLIENT_ID"]
OAUTH_CLIENT_SECRET = os.environ["SEAFILE_OIDC_CLIENT_SECRET"]
OAUTH_REDIRECT_URL = f"{os.environ['SEAFILE_URL']}/oauth/callback/"
OAUTH_PROVIDER = "authentik"
OAUTH_AUTHORIZATION_URL = f"{os.environ['AUTHENTIK_URL']}/application/o/authorize/"
OAUTH_TOKEN_URL = f"{os.environ['AUTHENTIK_URL']}/application/o/token/"
OAUTH_USER_INFO_URL = f"{os.environ['AUTHENTIK_URL']}/application/o/userinfo/"
OAUTH_SCOPE = ["openid", "profile", "email"]
OAUTH_ATTRIBUTE_MAP = {
    "sub": (True, "uid"),
    "name": (False, "name"),
    "email": (False, "contact_email"),
}
