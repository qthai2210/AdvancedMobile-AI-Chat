# Email Reply Suggestion API Integration

This document describes how to use the email reply suggestion API in the app.

## Overview

The email reply suggestion API allows you to get AI-generated reply ideas for emails. This is particularly useful when users need inspiration for how to respond to an email.

## API Endpoint

The API endpoint used is:

```
/ai-email/reply-ideas
```

## Models

The following models are used:

- `EmailReplySuggestionRequest`: Contains the email content, metadata, action and model
- `AiEmailReplyIdeasMetadata`: Contains context, subject, sender, receiver, and language
- `AssistantDto`: Optional assistant configuration (id, model)
- `EmailReplySuggestionResponse`: Contains the response with suggested ideas

## Example Usage

### Basic Usage

```dart
// Get the EmailApiService from the dependency injection container
final emailApiService = sl<EmailApiService>();

// Create metadata
final metadata = AiEmailReplyIdeasMetadata(
  context: [],
  subject: 'Meeting Request',
  sender: 'john@example.com',
  receiver: 'jane@example.com',
  language: 'english',
);

// Create request
final request = EmailReplySuggestionRequest(
  email: "Hi Jane, I'd like to schedule a meeting to discuss our project...",
  action: "Suggest 3 ideas for this email",
  metadata: metadata,
  model: "dify",
);

// Call the API and get suggestions
final response = await emailApiService.getSuggestionReplies(request: request);

// Use the suggestions
for (var idea in response.ideas) {
  print(idea);
}
```

### Using the Helper Class

For convenience, you can use the `EmailReplySuggestionHelper` class:

```dart
// Create a request using the helper
final request = EmailReplySuggestionHelper.createRequest(
  emailContent: "Hi Jane, I'd like to schedule a meeting...",
  subject: "Meeting Request",
  sender: "john@example.com",
  receiver: "jane@example.com",
  language: "english",
);

// Call the API and get suggestions
final response = await emailApiService.getSuggestionReplies(request: request);
```

### Example with Vietnamese Email

The app includes an example with a Vietnamese email from a university student support center:

```dart
// Use the helper to create a request with the example Vietnamese email
final request = EmailReplySuggestionHelper.createExampleRequest();

// Call the API and get suggestions
final response = await emailApiService.getSuggestionReplies(request: request);
```

## Demo Screen

A demo screen is available at the route `/email/reply-suggestions-demo` that demonstrates the API with the Vietnamese email example. You can access it by adding this to your code:

```dart
context.push('/email/reply-suggestions-demo');
```

## API Request Parameters

| Parameter | Type   | Description                                                    |
| --------- | ------ | -------------------------------------------------------------- |
| email     | String | The email content                                              |
| action    | String | The action to perform (e.g., "Suggest 3 ideas for this email") |
| metadata  | Object | Contains context, subject, sender, receiver, language          |
| model     | String | The model to use (e.g., "dify")                                |
| assistant | Object | Optional assistant configuration                               |

## API Response

The API returns a JSON object with an "ideas" array containing the suggested replies.

Example response:

```json
{
  "ideas": [
    "Thank you for the information about the Student and Business Day event. I will register and attend.",
    "I appreciate the details about the upcoming event. Could you provide more information about the participating companies?",
    "Thanks for sharing this opportunity. I'm interested in attending the workshops - are there any specific topics that will be covered?"
  ]
}
```
