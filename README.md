# Backend Interview Project

This is a scaffold for Hatch's backend interview project. It includes basic setup for development, testing, and deployment.

## Guidelines

At Hatch, we work with several message providers to offer a unified way for our Customers to  communicate to their Contacts. Today we offer SMS, MMS, email, voice calls, and voicemail drops. Your task is to implement an HTTP service that supports the core messaging functionality of Hatch, on a much smaller scale. Specific instructions and guidelines on completing the project are below.

### General Guidelines

- You may use whatever programming language, libraries, or frameworks you'd like. 
- We strongly encourage you to use whatever you're most familiar with so that you can showcase your skills and know-how. Candidates will not receive any kind of 'bonus points' or 'red flags' regarding their specific choices of language.
- You are welcome to use AI, Google, StackOverflow, etc as resources while you're developing. We just ask that you understand the code very well, because we will continue developing on it during your onsite interview.
- For ease of assessment, we strongly encourage you to use the `start.sh` script provided in the `bin/` directory, and implement it to run your service. We will run this script to start your project during our assessment. 

### Project-specific guidelines

- Assume that a provider may return HTTP error codes like 500, 429 and plan accordingly
- Conversations consist of messages from multiple providers. Feel free to consult providers such as Twilio or Sendgrid docs when designing your solution, but all external resources should be mocked out by your project. We do not expect you to actually integrate with a third party provider as part of this project.
- It's OK to use Google or a coding assistant to produce your code. Just make sure you know it well, because the next step will be to code additional features in this codebase with us during your full interview.

## Requirements

The service should implement:

- **Unified Messaging API**: HTTP endpoints to send and receive messages from both SMS/MMS and Email providers
  - Support sending messages through the appropriate provider based on message type
  - Handle incoming webhook messages from both providers
- **Conversation Management**: Messages should be automatically grouped into conversations based on participants (from/to addresses)
- **Data Persistence**: All conversations and messages must be stored in a relational database with proper relationships and indexing

### Providers

**SMS & MMS**

**Example outbound payload to send an SMS or MMS**

```json
{
    "from": "from-phone-number",
    "to": "to-phone-number",
    "type": "mms" | "sms",
    "body": "text message",
    "attachments": ["attachment-url"] | [] | null,
    "timestamp": "2024-11-01T14:00:00Z" // UTC timestamp
}
```

**Example inbound SMS**

```json
{
    "from": "+18045551234",
    "to": "+12016661234",
    "type": "sms",
    "messaging_provider_id": "message-1",
    "body": "text message",
    "attachments": null,
    "timestamp": "2024-11-01T14:00:00Z" // UTC timestamp
}
```

**Example inbound MMS**

```json
{
    "from": "+18045551234",
    "to": "+12016661234",
    "type": "mms",
    "messaging_provider_id": "message-2",
    "body": "text message",
    "attachments": ["attachment-url"] | [],
    "timestamp": "2024-11-01T14:00:00Z" // UTC timestamp
}
```

**Email Provider**

**Example Inbound Email**

```json
{
    "from": "[user@usehatchapp.com](mailto:user@usehatchapp.com)",
    "to": "[contact@gmail.com](mailto:contact@gmail.com)",
    "xillio_id": "message-2",
    "body": "<html><body>html is <b>allowed</b> here </body></html>",  "attachments": ["attachment-url"] | [],
    "timestamp": "2024-11-01T14:00:00Z" // UTC timestamp
}
```

**Example Email Payload**

```json
{
    "from": "[user@usehatchapp.com](mailto:user@usehatchapp.com)",
    "to": "[contact@gmail.com](mailto:contact@gmail.com)",
    "body": "text message with or without html",
    "attachments": ["attachment-url"] | [],
    "timestamp": "2024-11-01T14:00:00Z" // UTC timestamp
}
```

### Project Structure

This project structure is laid out for you already. You are welcome to move or change things, just update the Makefile, scripts, and/or docker resources accordingly. As part of the evaluation of your code, we will run 

```
.
├── bin/                    # Scripts and executables
│   ├── start.sh           # Application startup script
│   └── test.sh            # API testing script with curl commands
├── docker-compose.yml      # PostgreSQL database setup
├── Makefile               # Build and development commands with docker-compose integration
└── README.md              # This file
```

## Getting Started

1. Clone the repository
2. Run `make setup` to initialize the project
3. Run `docker-compose up -d` to start the PostgreSQL database, or modify it to choose a database of your choice
4. Run `make run` to start the application
5. Run `make test` to run tests

## Development

- Use `docker-compose up -d` to start the PostgreSQL database
- Use `make run` to start the development server
- Use `make test` to run tests
- Use `docker-compose down` to stop the database

## API Endpoints

All endpoints are versioned under `/api/v1`.

- POST `/api/v1/messages/sms`
  - Request:
    ```json
    {
      "from": "+12016661234",
      "to": "+18045551234",
      "type": "sms" | "mms",
      "body": "text",
      "attachments": ["https://example.com/image.jpg"] | [] | null,
      "timestamp": "2024-11-01T14:00:00Z"
    }
    ```
  - Response: `202 Accepted`
    ```json
    {
      "id": 123,
      "conversation_id": 1,
      "kind": "sms",
      "direction": "outbound",
      "status": "queued",
      "from": "+12016661234",
      "to": "+18045551234",
      "body": "text",
      "attachments": [],
      "sent_at": null
    }
    ```

- POST `/api/v1/messages/email`
  - Request:
    ```json
    {
      "from": "user@usehatchapp.com",
      "to": "contact@gmail.com",
      "body": "text or HTML",
      "attachments": ["https://example.com/document.pdf"],
      "timestamp": "2024-11-01T14:00:00Z"
    }
    ```
  - Response: `202 Accepted` — same shape as SMS (with `kind: "email"`).

- POST `/api/v1/webhooks/sms`
  - Request (inbound):
    ```json
    {
      "from": "+18045551234",
      "to": "+12016661234",
      "type": "sms" | "mms",
      "messaging_provider_id": "message-1",
      "body": "text",
      "attachments": null,
      "timestamp": "2024-11-01T14:00:00Z"
    }
    ```
  - Response: `200 OK`
    ```json
    {
      "received": true,
      "message": {
        "id": 456,
        "conversation_id": 1,
        "kind": "sms",
        "direction": "inbound",
        "status": "queued",
        "from": "+18045551234",
        "to": "+12016661234",
        "body": "text",
        "attachments": [],
        "sent_at": "2024-11-01T14:00:00Z"
      }
    }
    ```

- POST `/api/v1/webhooks/email`
  - Request:
    ```json
    {
      "from": "contact@gmail.com",
      "to": "user@usehatchapp.com",
      "xillio_id": "message-3",
      "body": "<html>…</html>",
      "attachments": ["https://example.com/received-document.pdf"],
      "timestamp": "2024-11-01T14:00:00Z"
    }
    ```
  - Response: `200 OK` — same shape as SMS webhook (with `kind: "email"`).

- GET `/api/v1/conversations`
  - Query params: `page`, `per_page` (default 20, max 100)
  - Response: `200 OK`
    - Headers: `X-Total-Count`, `X-Total-Pages`, `X-Page`, `X-Per-Page`, optional `Link` (RFC 5988)
    - Body example:
      ```json
      [
        { "id": 1, "participants": ["+12016661234", "+18045551234"], "last_message_at": "2024-11-01T14:00:00Z" }
      ]
      ```

- GET `/api/v1/conversations/:id/messages`
  - Query params: `page`, `per_page` (default 50, max 200)
  - Response headers same as above; body is an array of Message resources.

## API Responses & Errors

- Outbound send endpoints return `202 Accepted` and a message resource with `status: "queued"`. The send runs asynchronously.
- Webhook endpoints return `200 OK` with `{ "received": true, "message": { ... } }`.
- Validation errors return `422 Unprocessable Entity` with a standardized shape:

Example 202 Accepted (SMS):
```json
{
  "id": 123,
  "conversation_id": 1,
  "kind": "sms",
  "direction": "outbound",
  "status": "queued",
  "from": "+12016661234",
  "to": "+18045551234",
  "body": "Hello",
  "attachments": [],
  "sent_at": null
}
```

Example 422 Error:
```json
{
  "errors": [
    { "field": "kind", "message": "is not included in the list" }
  ]
}
```

## API Pagination

List endpoints support simple pagination via query params:
- `page` (default: 1, min: 1)
- `per_page` (conversations: default 20, max 100; messages: default 50, max 200)

Responses include pagination metadata headers:
- `X-Total-Count`: total items in the collection
- `X-Page`: current page
- `X-Per-Page`: applied per-page limit
- `Link`: RFC 5988 links for `rel="next"` and/or `rel="prev"` when applicable

Examples:
```
GET /api/v1/conversations?page=2&per_page=20
GET /api/v1/conversations/1/messages?per_page=100
```

## Database

The application uses PostgreSQL as its database. The docker-compose.yml file sets up:
- PostgreSQL 15 with Alpine Linux
- Database: `messaging_service`
- User: `messaging_user`
- Password: `messaging_password`
- Port: host `55432` mapped to container `5432`

To connect to the database directly:
```bash
docker-compose exec postgres psql -U messaging_user -d messaging_service
psql -h 127.0.0.1 -p 55432 -U messaging_user -d messaging_service
```

Again, you are welcome to make changes here, as long as they're in the docker-compose.yml
