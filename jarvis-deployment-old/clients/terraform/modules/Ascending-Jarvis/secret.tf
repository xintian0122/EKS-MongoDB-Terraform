locals {
  jarvis_env_variables = [
    "HOST",
    "PORT",
    "DOMAIN_CLIENT",
    "DOMAIN_SERVER",
    "NO_INDEX",
    "CONSOLE_JSON",
    "DEBUG_LOGGING",
    "DEBUG_CONSOLE",
    "SEARCH",
    "MEILI_NO_ANALYTICS",
    "MEILI_HOST",
    "DEBUG_PLUGINS",
    "ALLOW_EMAIL_LOGIN",
    "ALLOW_REGISTRATION",
    "ALLOW_SOCIAL_LOGIN",
    "ALLOW_SOCIAL_REGISTRATION",
    "ALLOW_PASSWORD_RESET",
    "ALLOW_ACCOUNT_DELETION",
    "ALLOW_UNVERIFIED_EMAIL_LOGIN",
    "ALLOW_SHARED_LINKS",
    "ALLOW_SHARED_LINKS_PUBLIC",
    "RAG_PORT",
    "RAG_API_URL",
    "APP_TITLE",
    "CUSTOM_FOOTER",
    "HELP_AND_FAQ_URL",
    "EMAIL_SERVICE",
    "EMAIL_HOST",
    "EMAIL_PORT",
    "EMAIL_ENCRYPTION",
    "EMAIL_USERNAME",
    "EMAIL_PASSWORD",
    "EMAIL_FROM_NAME",
    "EMAIL_FROM",
    "GOOGLE_CLIENT_ID",
    "GOOGLE_CLIENT_SECRET",
    "GOOGLE_CALLBACK_URL",
    "ENDPOINTS",
    "AWS_BUCKET_NAME",
    "MONGO_URI",
    "CREDS_KEY",
    "CREDS_IV",
    "JWT_SECRET",
    "JWT_REFRESH_SECRET",
    "DB_HOST",
    "OPENAI_API_KEY",
    "ANALYTICS_GTM_ID"
  ]
}

resource "aws_secretsmanager_secret" "jarvis_secret" {
  name = "${var.app_name}/jarvis-env"  
}

resource "aws_secretsmanager_secret_version" "jarvis_secret_version" {
  secret_id = aws_secretsmanager_secret.jarvis_secret.id
  secret_string = jsonencode({
    for key in local.jarvis_env_variables : key => ""
  })
  lifecycle {
    ignore_changes = [secret_string]
  }
}