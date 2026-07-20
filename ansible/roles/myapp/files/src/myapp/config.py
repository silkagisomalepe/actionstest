import boto3
from botocore.exceptions import BotoCoreError, ClientError
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import SecretStr


class Settings(BaseSettings):
    # Reference to the secret in AWS Secrets Manager — never the value itself
    APP_SECRET_ID: str
    AWS_REGION: str = "eu-west-1"
    DEBUG: bool = False

    # Resolved from Secrets Manager at boot, not read from .env
    APP_SECRET: SecretStr = SecretStr("")

    # Automatically looks for a .env file
    model_config = SettingsConfigDict(env_file=".env")


def _fetch_app_secret(secret_id: str, region: str) -> SecretStr:
    # On EC2 this picks up credentials from the instance profile — no keys to manage
    client = boto3.client("secretsmanager", region_name=region)
    try:
        response = client.get_secret_value(SecretId=secret_id)
    except (ClientError, BotoCoreError) as e:
        raise RuntimeError(f"could not retrieve secret '{secret_id}': {e}") from e
    return SecretStr(response["SecretString"])


try:
    settings = Settings()
    settings.APP_SECRET = _fetch_app_secret(settings.APP_SECRET_ID, settings.AWS_REGION)
    print("Environment validated, secret resolved.")
except Exception as e:
    print(f"Boot Error: {e}")
    exit(1)
