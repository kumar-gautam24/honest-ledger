// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the client-side tool-calling loop.
///
/// Each `send` re-sends the whole conversation + tool schemas to the backend
/// proxy. When the model asks for a (read) tool, we run it locally, feed the
/// result back, and loop until the model answers in plain text or we hit the
/// iteration cap. The provider key never touches the client — only the proxy
/// does (see [AiService]).

@ProviderFor(AssistantController)
final assistantControllerProvider = AssistantControllerProvider._();

/// Drives the client-side tool-calling loop.
///
/// Each `send` re-sends the whole conversation + tool schemas to the backend
/// proxy. When the model asks for a (read) tool, we run it locally, feed the
/// result back, and loop until the model answers in plain text or we hit the
/// iteration cap. The provider key never touches the client — only the proxy
/// does (see [AiService]).
final class AssistantControllerProvider
    extends $NotifierProvider<AssistantController, AssistantState> {
  /// Drives the client-side tool-calling loop.
  ///
  /// Each `send` re-sends the whole conversation + tool schemas to the backend
  /// proxy. When the model asks for a (read) tool, we run it locally, feed the
  /// result back, and loop until the model answers in plain text or we hit the
  /// iteration cap. The provider key never touches the client — only the proxy
  /// does (see [AiService]).
  AssistantControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assistantControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assistantControllerHash();

  @$internal
  @override
  AssistantController create() => AssistantController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssistantState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssistantState>(value),
    );
  }
}

String _$assistantControllerHash() =>
    r'cf1286a3fa6690650983bd3d062f3627aa690fb4';

/// Drives the client-side tool-calling loop.
///
/// Each `send` re-sends the whole conversation + tool schemas to the backend
/// proxy. When the model asks for a (read) tool, we run it locally, feed the
/// result back, and loop until the model answers in plain text or we hit the
/// iteration cap. The provider key never touches the client — only the proxy
/// does (see [AiService]).

abstract class _$AssistantController extends $Notifier<AssistantState> {
  AssistantState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AssistantState, AssistantState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AssistantState, AssistantState>,
              AssistantState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
