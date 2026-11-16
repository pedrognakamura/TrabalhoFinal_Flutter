# Saborê — Aplicativo de Receitas

Aplicativo Flutter para Android que permite **descobrir receitas, pesquisar pelo nome, ler ingredientes e modo de preparo e guardar favoritas**. Os dados vêm da API pública [DummyJSON Recipes](https://dummyjson.com/docs/recipes).

Trabalho final da disciplina de Flutter. O objetivo é aplicar a um domínio novo (receitas) os conceitos vistos em aula: consumo de API REST, tratamento de estados e navegação.

## Funcionalidades

| Requisito | Como foi atendido |
|---|---|
| **RF01 · Tela principal** | Aba **Explorar** com a marca "Saborê", campo **Buscar pelo nome** e botão **Buscar receitas** logo no topo, seguidos da lista. O carregamento das receitas começa na abertura do app, em `main()`. A navegação principal é a barra inferior **Explorar / Favoritos**. |
| **RF02 · Listagem** | "Receitas disponíveis" em lista rolável. Cada card mostra imagem, nome, tempo total, dificuldade, nota (ex.: "4,6 / 5") e coração. Quando a imagem não existe ou falha ao carregar, aparece um ícone no lugar. Nomes longos são cortados em 2 linhas no card e aparecem inteiros nos detalhes. |
| **RF03 · Pesquisa** | Tela **Pesquisar receitas** com busca remota em `/recipes/search?q=`. A consulta é aparada (`trim`). Uma consulta vazia é recusada e o campo mostra em vermelho "Digite um nome para pesquisar.". Nos resultados há **Limpar pesquisa**; sem resultados, há **Ver todas as receitas**. |
| **RF04 · Detalhes** | Imagem, nome, culinária, dificuldade e nota. Blocos com **tempo total**, **porções** e situação nos **favoritos**. Abaixo vêm preparo e cozimento separados, calorias, tipo de refeição, ingredientes e passos numerados na ordem original. A tela inteira rola, o que garante a leitura de conteúdo longo. |
| **RF05 · Favoritos** | Coração na lista e nos detalhes. Os favoritos são guardados por `id`, sem duplicatas, durante a sessão. A aba **Favoritos** lista as receitas salvas, e a barra inferior mostra um contador. |
| **RF06 · Carregamento** | Cards "esqueleto" com a mensagem "Carregando receitas…". O botão **Pesquisar** fica desabilitado enquanto a busca carrega, e toques repetidos num item não abrem a mesma tela duas vezes. |
| **RF07 · Erros** | Tela "Não foi possível carregar as receitas." com mensagens diferentes para **falha de rede ou tempo esgotado**, **status HTTP de erro** e **resposta em formato inesperado**, sempre com o botão **Tentar novamente**. |
| **RF08 · Ausência de resultados** | Três telas distintas: **"Nenhum resultado"** para busca sem correspondência (com **Alterar pesquisa** e **Ver todas as receitas**), a tela de **erro** com o ícone "!" e **"Nenhum favorito"** (com **Explorar receitas**). |
| **RF09 · Navegação** | A pesquisa abre dentro da aba Explorar e os detalhes abrem por cima. O botão voltar retorna à tela anterior com a consulta, os resultados e a rolagem preservados. Trocar de aba também não perde o contexto. |

O layout segue o guia visual de telas fornecido: fundo creme, verde-escuro como cor principal, coração em laranja-avermelhado e barra inferior Explorar/Favoritos.

## Decisões técnicas

### Detalhes: reaproveitamento do objeto da lista
As respostas de `/recipes` e `/recipes/search` **já trazem a receita completa**: ingredientes, instruções, tempos, porções, avaliação e assim por diante. Por isso a tela de detalhes **reaproveita o objeto `Recipe` recebido na listagem ou na pesquisa** e não chama `/recipes/{id}`. Uma segunda requisição traria os mesmos dados, com mais espera e mais um ponto de falha.

### Requisições e validação
`RecipeApi` (`lib/services/recipe_api.dart`) faz um `GET` assíncrono com timeout de 15 s e:
1. converte falhas de conexão (`SocketException`, `ClientException`, `TimeoutException`) em `NetworkException`;
2. verifica se o status é **200**; se não for, lança `HttpStatusException`;
3. decodifica o JSON e verifica se é um objeto com a lista `recipes`; se não for, lança `InvalidResponseException`.

A interface só é atualizada depois dessas verificações.

### Leitura tolerante dos campos
`Recipe.tryParse` (`lib/models/recipe.dart`):
- `id` é obrigatório; itens sem `id` válido são descartados.
- `name` ausente vira "Receita sem nome".
- `ingredients` e `instructions` preservam a ordem e ignoram itens nulos ou vazios; quando ausentes, a tela mostra "não informados".
- `image` só é usada se for uma URL http(s).
- `prepTimeMinutes` e `cookTimeMinutes` são verificados (int, double inteiro ou texto numérico). Quando ausentes, ficam `null` e a tela mostra **"não informado"**, nunca 0. O **total só é calculado quando os dois tempos existem**; caso contrário, aparece "não calculável".
- `servings` só é exibido quando é um número positivo.
- `rating` é lido como `num`, aceitando `4.6` ou `5`.
- `mealType` é tratado como lista; uma `String` solta também é aceita.

### Estado e concorrência
- **Fonte única de verdade:** `RecipesController` (listagem e pesquisa) e `FavoritesStore` (favoritos) são criados uma única vez em `main()` e compartilhados com todas as telas por um `InheritedWidget` (`AppScope`). As telas reagem com `ListenableBuilder`.
- **Sem recarregar a cada rebuild:** a listagem é pedida uma única vez em `main()`. Chamar `loadCatalog()` de novo não faz nada se ela já estiver carregando ou carregada; só "Tentar novamente" força uma nova busca.
- **Consultas concorrentes:** cada pesquisa recebe um número de geração. Se o usuário pesquisa "bolo" e logo depois "pizza", a resposta atrasada de "bolo" é descartada, e só a consulta mais recente atualiza a tela. Repetir a mesma pesquisa enquanto ela carrega é ignorado.
- **Favoritos** ficam em memória (`Map<int, Recipe>`, indexado por `id`) durante a sessão.

## Estrutura do projeto

```
lib/
├── main.dart                     # Inicialização e AppScope
├── models/
│   └── recipe.dart               # Modelo e conversão tolerante do JSON
├── services/
│   ├── api_exception.dart        # Erros de rede, de status e de formato
│   └── recipe_api.dart           # Cliente HTTP da DummyJSON
├── state/
│   ├── app_scope.dart            # InheritedWidget com os objetos de estado
│   ├── favorites_store.dart      # Favoritos da sessão
│   ├── load_state.dart           # Idle / InProgress / Success / Failure
│   └── recipes_controller.dart   # Listagem, pesquisa e concorrência
├── screens/
│   ├── root_shell.dart           # Barra inferior Explorar / Favoritos
│   ├── explore_screen.dart       # RF01, RF02
│   ├── search_screen.dart        # RF03, RF08
│   ├── recipe_detail_screen.dart # RF04
│   ├── favorites_screen.dart     # RF05
│   └── navigation.dart           # Navegação protegida contra toque duplo
├── theme/
│   └── app_theme.dart            # Cores e estilos do guia visual
├── utils/
│   └── formatters.dart           # Tempo, nota ("4,6 / 5") e dificuldade
└── widgets/
    ├── favorite_button.dart      # Coração de favorito
    ├── recipe_card.dart          # Card da lista
    ├── recipe_image.dart         # Imagem com alternativa visual
    └── status_views.dart         # Cabeçalho, esqueleto, erro e vazio
test/                             # Testes de modelo, API, estado e widget
```

## Dependências

| Pacote | Versão | Uso |
|---|---|---|
| [`http`](https://pub.dev/packages/http) | ^1.6.0 | Requisições à API (e `MockClient` nos testes) |
| `cupertino_icons` | ^1.0.8 | Ícones padrão do template |
| `flutter_lints` *(dev)* | ^6.0.0 | Regras de análise estática |
| `flutter_test` *(dev)* | SDK | Testes |

O estado é gerenciado com recursos nativos do Flutter (`ChangeNotifier`, `InheritedWidget` e `ListenableBuilder`), sem pacotes extras.

## SDK utilizado

- **Flutter** 3.44.9 (canal stable)
- **Dart** 3.12.2
- **Android SDK** 36 (build-tools 36.0.0), Gradle 9.1
- Plataforma alvo: **Android**

## Como executar

Pré-requisitos: Flutter SDK instalado e um emulador Android ou um celular com depuração USB ativada. Verifique o ambiente com `flutter doctor`.

```bash
# 1. Clonar o repositório
git clone https://github.com/pedrognakamura/TrabalhoFinal_Flutter.git
cd TrabalhoFinal_Flutter

# 2. Baixar as dependências
flutter pub get

# 3. Rodar no emulador ou no celular conectado
flutter devices        # lista os dispositivos disponíveis
flutter run

# Gerar o APK de release (sai em build/app/outputs/flutter-apk/app-release.apk)
flutter build apk --release
```

O app precisa de internet para buscar as receitas. A permissão `INTERNET` já está declarada no `AndroidManifest.xml`.

### Testes

```bash
flutter analyze
flutter test
```

Os testes cobrem a leitura tolerante do JSON, os erros da API (rede, status e corpo inválido), a recusa de pesquisa vazia, o descarte de respostas antigas, os favoritos sem duplicatas e os fluxos de tela: Explorar → detalhes → favoritar, pesquisa vazia, com resultado e sem resultado, e favoritos vazios.
