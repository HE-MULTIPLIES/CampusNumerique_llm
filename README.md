# Introduction au low-code

## Prerequisites

- Docker
- Docker Compose
- Git
- Python 3.11
- Poetry
- Make

## Installation

1. Clone the repository

```bash
git clone https://github.com/HE-MULTIPLIES/pnl-maker.git
cd pnl-maker
```

2. Installation of poetry on the machine
   1. MacOS

   ```bash
   brew install poetry
   ```

   2. Linux

   ```bash
   curl -sSL https://install.python-poetry.org | python3 -
   ```

   open your bashrc and add this line

   ```bash
   export PATH="${HOME}/.local/bin:$PATH"
   ```

   then reload your bashrc

   ```bash
   source ~/.bashrc
   ```

   verify the installation

   ```bash
   poetry --version
   ```

3. Installation of python 3.11 for poetry
Make sur you have python 3.11 installed on your machine and then run

```bash
poetry env use 3.11
```

4. Installation of the dependencies

```bash
poetry install
```

5. Installation of Make package

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
