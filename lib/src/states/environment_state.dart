import 'package:ets2_environments/src/entities/environment_entity.dart';

sealed class EnvironmentState {
  final EnvironmentEntity environment;

  EnvironmentState(this.environment);

  T when<T>({
    required T Function() onInitial,
    T? Function()? onLoading,
    T? Function(EnvironmentEntity environmentEntity)? onSuccess,
    T? Function(String message)? onError,
  }) {
    return switch (this) {
      InitialEnvironmentState _ => onInitial(),
      LoadingEnvironmentState _ => onLoading?.call() ?? onInitial(),
      SuccessEnvironmentState state => onSuccess?.call(state.environment) ?? onInitial(),
      ErrorEnvironmentState state => onError?.call(state.message) ?? onInitial(),
    };
  }
}

final class InitialEnvironmentState extends EnvironmentState {
  InitialEnvironmentState() : super(EnvironmentEntity.empty());
}

final class LoadingEnvironmentState extends EnvironmentState {
  LoadingEnvironmentState() : super(EnvironmentEntity.empty());
}

final class SuccessEnvironmentState extends EnvironmentState {
  SuccessEnvironmentState(super.environment);
}

final class ErrorEnvironmentState extends EnvironmentState {
  final String message;

  ErrorEnvironmentState(this.message) : super(EnvironmentEntity.empty());
}
