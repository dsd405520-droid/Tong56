import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';

/// Single shared client with cookies enabled. The browser will automatically
/// attach the httpOnly `access_token` cookie to every request made with this
/// client, as long as the backend's CORS `allow_origins` matches this app's
/// origin exactly and `allow_credentials=True` is set.
final http.Client apiClient = BrowserClient()..withCredentials = true;
