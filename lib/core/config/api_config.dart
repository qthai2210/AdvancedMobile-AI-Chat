class ApiConfig {
  static const String authBaseUrl = 'https://auth-api.dev.jarvis.cx/api/v1';
  static const String jarvisBaseUrl = 'https://api.dev.jarvis.cx/api/v1';
  static const String knowledgeUrl = 'https://knowledge-api.dev.jarvis.cx';

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'X-Stack-Access-Type': 'client',
    'X-Stack-Project-Id': 'a914f06b-5e46-4966-8693-80e4b9f4f409',
    'X-Stack-Publishable-Client-Key':
        'pck_tqsy29b64a585km2g4wnpc57ypjprzzdch8xzpq0xhayr',
  };
}
