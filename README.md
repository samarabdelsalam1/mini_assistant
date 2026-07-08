# mini_assistant

mini_assistant is a proof-of-concept Rails application for experimenting with LLM interactions, function calling, and agentic loops.

## Purpose

This project demonstrates how an assistant can:
- send prompts to an LLM,
- receive tool/function call requests,
- execute local tool logic,
- continue an agentic loop until a final answer is produced.

It is intended as a simple playground for learning and prototyping conversational AI flows.

## Tech Stack

- Ruby on Rails
- Docker
- OpenAI-compatible API client

## Environment Variables

Create a `.env` file in the project root before starting the app.

Copy the values from `.env.example` and replace them with the appropriate values for your environment.

Example variables:
- `OPENAI_API_KEY`: API key for the LLM provider
- `OPENAI_BASE_URL`: base URL for the OpenAI-compatible endpoint
- `OPENAI_MODEL`: model name to use for chat requests

## Setup

1. Create the environment file:
   ```bash
   cp .env.example .env
   ```
2. Edit `.env` and set your own values.
3. Build and start the containers:
   ```bash
   docker compose up --build
   ```
4. The app should be available in the web container.

## Running Tests

Run tests inside the web container:

```bash
docker exec mini_assistant_web bundle exec rails test
```

## Notes

- This project is a POC, so the implementation is intentionally simple and focused on demonstrating the LLM + tool-calling flow.
- Developers should customize the `.env` values according to their own local or container setup.

