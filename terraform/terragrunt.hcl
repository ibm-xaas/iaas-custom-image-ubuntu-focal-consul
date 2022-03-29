retryable_errors = [
"Error: No image found with name",
".*StatusCode.*409.*",
"ERRO.*error occurred:"
]

retry_max_attempts = 3
retry_sleep_interval_sec = 60
