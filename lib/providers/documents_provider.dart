import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:captain_app_flutter/services/graphql_service.dart';

class DriverDoc {
  final String id;
  final String type;
  final String documentUrl;
  final String status;
  final String? rejectionReason;

  DriverDoc({
    required this.id,
    required this.type,
    required this.documentUrl,
    required this.status,
    this.rejectionReason,
  });

  factory DriverDoc.fromJson(Map<String, dynamic> json) {
    return DriverDoc(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      documentUrl: json['documentUrl'] as String? ?? '',
      status: json['status'] as String? ?? 'Not Uploaded',
      rejectionReason: json['rejectionReason'] as String?,
    );
  }
}

class DocumentsState {
  final bool isLoading;
  final String? errorMessage;
  final List<DriverDoc> documents;

  DocumentsState({
    this.isLoading = false,
    this.errorMessage,
    this.documents = const [],
  });

  DocumentsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<DriverDoc>? documents,
  }) {
    return DocumentsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      documents: documents ?? this.documents,
    );
  }
}

class DocumentsNotifier extends StateNotifier<DocumentsState> {
  final GraphQLService _graphQLService = GraphQLService();

  DocumentsNotifier() : super(DocumentsState());

  Future<void> fetchDocuments() async {
    state = state.copyWith(isLoading: true);
    try {
      const String query = r'''
        query GetDriverDocuments {
          getDriverDocuments {
            id
            type
            documentUrl
            status
            rejectionReason
          }
        }
      ''';

      final response = await _graphQLService.performQuery(query);
      if (response.hasException) {
        final errorMsg = response.exception?.graphqlErrors.isNotEmpty == true
            ? response.exception!.graphqlErrors.first.message
            : 'Failed to fetch documents';
        state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        return;
      }

      final list = response.data?['getDriverDocuments'] as List<dynamic>?;
      if (list != null) {
        final docs = list.map((json) => DriverDoc.fromJson(json as Map<String, dynamic>)).toList();
        state = DocumentsState(documents: docs, isLoading: false);
      } else {
        state = DocumentsState(documents: [], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> uploadDocument(String type, String documentUrl) async {
    state = state.copyWith(isLoading: true);
    try {
      const String mutation = r'''
        mutation UploadDocument($type: String!, $documentUrl: String!) {
          uploadDocument(type: $type, documentUrl: $documentUrl) {
            id
            type
            documentUrl
            status
          }
        }
      ''';

      final response = await _graphQLService.performMutation(
        mutation,
        variables: {
          'type': type,
          'documentUrl': documentUrl,
        },
      );

      if (response.hasException) {
        final errorMsg = response.exception?.graphqlErrors.isNotEmpty == true
            ? response.exception!.graphqlErrors.first.message
            : 'Failed to upload document';
        state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        return false;
      }

      await fetchDocuments();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteDocument(String type) async {
    state = state.copyWith(isLoading: true);
    try {
      const String mutation = r'''
        mutation DeleteDocument($type: String!) {
          deleteDocument(type: $type)
        }
      ''';

      final response = await _graphQLService.performMutation(
        mutation,
        variables: {
          'type': type,
        },
      );

      if (response.hasException) {
        final errorMsg = response.exception?.graphqlErrors.isNotEmpty == true
            ? response.exception!.graphqlErrors.first.message
            : 'Failed to delete document';
        state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        return false;
      }

      await fetchDocuments();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final documentsProvider = StateNotifierProvider<DocumentsNotifier, DocumentsState>((ref) {
  return DocumentsNotifier();
});
