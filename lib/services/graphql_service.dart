import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:captain_app_flutter/config/api_config.dart';
import 'package:captain_app_flutter/services/storage_service.dart';

class GraphQLService {
  final StorageService _storageService = StorageService();

  Future<GraphQLClient> _getClient() async {
    final token = await _storageService.getToken();

    final HttpLink httpLink = HttpLink(ApiConfig.graphqlUrl);

    final AuthLink authLink = AuthLink(
      getToken: () async => token != null ? 'Bearer $token' : null,
    );

    final Link link = authLink.concat(httpLink);

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  Future<QueryResult> performMutation(String query, {Map<String, dynamic> variables = const {}}) async {
    final client = await _getClient();
    final MutationOptions options = MutationOptions(
      document: gql(query),
      variables: variables,
      fetchPolicy: FetchPolicy.noCache,
    );
    return await client.mutate(options);
  }

  Future<QueryResult> performQuery(String query, {Map<String, dynamic> variables = const {}}) async {
    final client = await _getClient();
    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: variables,
      fetchPolicy: FetchPolicy.noCache,
    );
    return await client.query(options);
  }
}
