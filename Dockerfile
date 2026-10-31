# syntax=docker/dockerfile:1
# All versions are pinned. Change them on purpose only, then rebuild and re-run the smoke tests.

# --- base: Python + uv, no project dependencies ---
FROM python:3.12.16-slim-trixie AS base

COPY --from=ghcr.io/astral-sh/uv:0.13.1 /uv /uvx /bin/

ENV UV_PYTHON_DOWNLOADS=never \
    UV_PROJECT_ENVIRONMENT=/opt/venv \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    LITELLM_LOCAL_MODEL_COST_MAP=True

# Run as a non-root user (least privilege). Packages in /opt/venv stay root-owned,
# so the container cannot modify its own dependencies at run time.
RUN useradd --create-home --uid 1000 app
WORKDIR /app


# --- dev: base + exact dependencies from uv.lock ---
FROM base AS dev

COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-install-project

USER app
