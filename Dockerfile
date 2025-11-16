FROM python:3.10

# -----------------------------
# Environment variables for Python
# -----------------------------
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=off
ENV ALEMBIC_CONFIG=/usr/src/alembic/alembic.ini
ENV PATH=$PATH:/root/go/bin

# -----------------------------
# Install system dependencies
# -----------------------------
RUN apt update && apt install -y \
    gcc \
    libpq-dev \
    netcat-openbsd \
    postgresql-client \
    dos2unix \
    golang-go \
    && apt clean

# -----------------------------
# Install Poetry
# -----------------------------
RUN python -m pip install --upgrade pip && \
    pip install poetry

# -----------------------------
# Copy dependency files
# -----------------------------
COPY ./poetry.lock /usr/src/poetry/poetry.lock
COPY ./pyproject.toml /usr/src/poetry/pyproject.toml
COPY ./alembic.ini /usr/src/alembic/alembic.ini

# -----------------------------
# Configure Poetry to avoid virtualenv
# -----------------------------
RUN poetry config virtualenvs.create false

# -----------------------------
# Set working directory for Poetry install
# -----------------------------
WORKDIR /usr/src/poetry

# -----------------------------
# Install dependencies
# -----------------------------
RUN poetry lock
RUN poetry install --no-root --only main

# -----------------------------
# Set working directory for app
# -----------------------------
WORKDIR /usr/src/fastapi

# -----------------------------
# Copy source code
# -----------------------------
COPY ./src .

# -----------------------------
# Copy commands
# -----------------------------
COPY ./commands /commands

# -----------------------------
# Ensure Unix-style line endings for scripts
# -----------------------------
RUN dos2unix /commands/*.sh

# -----------------------------
# Add execute permission for scripts
# -----------------------------
RUN chmod +x /commands/*.sh

# -----------------------------
# Install MailHog
# -----------------------------
RUN go install github.com/mailhog/MailHog@latest

