from confz import ConfZ, ConfZEnvSource

class FNanoApp(ConfZ):
    api_username:str
    api_password:str
    api_secret_key:str
    api_algorithm:str
    api_access_token_expire_minutes:int
    host:str
    port:int
    CONFIG_SOURCES = ConfZEnvSource(allow_all=True)