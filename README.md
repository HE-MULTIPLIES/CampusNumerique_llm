# Introduction au low-code

## Prerequisites

- Docker
- Docker Compose
- Git
- Make

## Installation

1. Clone the repository

```bash
git clone https://github.com/HE-MULTIPLIES/pnl-maker.git
cd pnl-maker
```

2. Installation of Make package

```bash
brew install make
```

or

```bash
sudo apt update && sudo apt install make
```

## Setup the environment variables

1. Copy the .env.example file to .env
2. Modify the email to use your campus email and chose a password

## Run the containers

```bash
docker compose up -d
```

or check

3. Reach the localhost of n8n and fill the with these credentials
4. Fill the form appearing with your campus adress in order to activate the evaluation account with more feature
5. Confirm the evaluation account on your email
6. Reach the pg admin and fill the with these credentials and valiodate the connexion
