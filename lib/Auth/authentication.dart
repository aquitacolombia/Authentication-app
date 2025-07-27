import 'dart:convert';
import 'package:http/http.dart' as http;

class Authentication {
  late String sessionId = "404";
  String? username;
  String? password;

  Future<String> getSessionId() async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('http://127.0.0.1:8000/api-token-auth/'));
    request.body = json.encode({"username": username, "password": password});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var respuesta = await response.stream.bytesToString();
      Map<String, dynamic> objeto = jsonDecode(respuesta);
      print(respuesta);
      print(objeto);

      if (objeto.containsKey("token")) {
        sessionId = objeto["token"];

        return sessionId;
      } else {
        throw Exception("no has iniciado sesion");
      }
      //print(sessionId);
    } else {
      throw Exception("error en el servidor");
    }
  }

  Future<void> login(nombreusuario, secreto) async {
    username = nombreusuario;
    password = secreto;
    sessionId = await getSessionId();
  }
}
