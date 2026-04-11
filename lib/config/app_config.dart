// Configuration constants for the app
// Update these values based on your environment

class AppConfig {
  // Backend API Configuration
  static const String backendBaseUrl = 'http://192.168.1.122:4000/api';

  // For Android Emulator use: 'http://10.0.2.2:4000/api'
  // For Real Device use: 'http://YOUR_BACKEND_IP:4000/api'
  // For Production use: 'https://your-production-api.com/api'

  // Supabase Configuration
  static const String supabaseUrl = 'https://yegnkojcbmvavoltjgot.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InllZ25rb2pjYm12YXZvbHRqZ290Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU3ODA1MjksImV4cCI6MjA5MTM1NjUyOX0.eMBgrw9wJKM8CoQmAjARfIp5Mh1RDSvWKkx0VUUEq9w';
  static const String storageImageBucket = 'image';

  // API Endpoints
  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';
  static const String casesEndpoint = '/cases';
  static const String diseaseLabelsEndpoint = '/disease-labels';

  // JWT Configuration
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';

  // Request timeout in seconds
  static const int requestTimeoutSeconds = 10;

  // App Configuration
  static const String appName = 'NeTy - Animal Disease AI';
  static const String appVersion = '1.0.0';

  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxEmailLength = 254;
  static const int maxNameLength = 100;

  // File Upload Configuration
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10 MB
  static const List<String> allowedImageMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
  ];
}
