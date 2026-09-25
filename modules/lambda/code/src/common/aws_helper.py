import boto3


# Globally scoped variables and resources
_SECRETS_CLIENT = boto3.client("secretsmanager")

def get_secret_value(name, version=None):
    """Gets the value of a secret.

    Version (if defined) is used to retrieve a particular version of
    the secret.

    """
    kwargs = {'SecretId': name}
    if version is not None:
        kwargs['VersionStage'] = version
    response = _SECRETS_CLIENT.get_secret_value(**kwargs)

    return response["SecretString"]
