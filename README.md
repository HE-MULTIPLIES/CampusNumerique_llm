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

### 1. Launch the containers

```bash
make dev-up
```

or check

### 2. Reach the localhost of n8n and fill the credentials using your N8N_EMAIL and N8N_PASSWORD in .env file

### 3. Fill the form appearing with your campus adress in order to activate the evaluation account with more feature

### 4. Confirm the evaluation account on your email

### 5. Reach the pg admin and fill the with these credentials and validate the connexion

### 6. Create Manually in your n8n interface the following folder architecture (If you didnt activate your account you cant create folder, that will be a bit messy)

📁 Exercices<br>
├── 📁 1. Webhook & Requests<br>
├── 📁 2. Data Manipulation<br>
├── 📁 3. Workflow & SubWorkflow<br>
├── 📁 4. Credentials & Database<br>
└── 📁 5. Agent IA<br>
|
📁 Correction<br>
├── 📁 1. Webhook & Requests<br>
├── 📁 2. Data Manipulation<br>
├── 📁 3. Workflow & SubWorkflow<br>
├── 📁 4. Credentials & Database<br>
└── 📁 5. Agent IA<br>

### 7. Now that the folders are created, you can import the workflows using the make commands

```bash
make n8n-import-exercices
make n8n-import-corrections <-- Only available for the teacher that have the workflows .json in the correction folder
```

### 8. Manually position the workflows in the folders following their tags

- correction
- exercices

And then:

- webhook & requests
- data manipulation
- workflow & subworkflow
- credentials & database
- agent IA

### 9. You can now start using the n8n interface to create your own workflows
