/// Falhas possíveis ao consultar a API, cada uma com uma mensagem
/// compreensível para quem usa o app.
sealed class ApiException implements Exception {
  const ApiException();

  String get title;
  String get message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Sem conexão, DNS falhou ou o servidor não respondeu a tempo.
class NetworkException extends ApiException {
  const NetworkException({this.timedOut = false});

  final bool timedOut;

  @override
  String get title => timedOut ? 'O servidor demorou demais' : 'Sem conexão';

  @override
  String get message => timedOut
      ? 'O servidor demorou demais para responder. Verifique sua conexão e tente novamente.'
      : 'Verifique sua conexão e tente novamente.';
}

/// O servidor respondeu, mas com um status diferente de 200.
class HttpStatusException extends ApiException {
  const HttpStatusException(this.statusCode);

  final int statusCode;

  @override
  String get title => 'Erro no servidor ($statusCode)';

  @override
  String get message {
    if (statusCode == 404) {
      return 'O conteúdo pedido não foi encontrado no servidor.';
    }
    if (statusCode == 429) {
      return 'Muitas solicitações em pouco tempo. Aguarde um instante e tente novamente.';
    }
    if (statusCode >= 500) {
      return 'O servidor de receitas está com problemas no momento. Tente novamente em instantes.';
    }
    return 'O servidor recusou a solicitação. Tente novamente.';
  }
}

/// A resposta chegou, mas o corpo não é o JSON esperado.
class InvalidResponseException extends ApiException {
  const InvalidResponseException();

  @override
  String get title => 'Resposta inesperada';

  @override
  String get message =>
      'Recebemos dados num formato que o app não reconhece. Tente novamente mais tarde.';
}
