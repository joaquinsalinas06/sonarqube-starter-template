# Vulture whitelist configuration for Python projects
# Add false positives here (e.g., framework entrypoints, FastAPI event handlers, Pydantic fields)

# Common framework attributes
_.dict  # unused attribute
_.model_dump  # Pydantic v2
_.model_validate  # Pydantic v2
_.Config  # Pydantic inner config class
_.lifespan  # FastAPI lifespan context
_.app  # ASGI/WSGI entry point
