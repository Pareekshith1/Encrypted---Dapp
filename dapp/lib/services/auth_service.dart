import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/access_token_response.dart';

class OAuthService {
  final OAuth2Client _client = OAuth2Client(
    authorizeUrl: 'https://accounts.google.com/o/oauth2/auth',
    tokenUrl: 'https://oauth2.googleapis.com/token',
    redirectUri: 'com.example.app:/oauth2redirect',
    customUriScheme: 'com.example.app',
  );

  Future<AccessTokenResponse?> authenticate() async {
    try {
      final token = await _client.getTokenWithAuthCodeFlow(
        clientId: 'your-client-id',
        clientSecret: 'your-client-secret',
        scopes: ['openid', 'profile', 'email'],
      );
      return token;
    } catch (e) {
      print('OAuth Error: $e');
      return null;
    }
  }
}
