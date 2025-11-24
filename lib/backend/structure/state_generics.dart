abstract class IGenericoState{}

class InitialState extends IGenericoState {}

class LoadingState extends IGenericoState {}
class FailedState extends IGenericoState implements Exception {
  final String erro;

  FailedState(this.erro);
}
class SuccessState<T> extends IGenericoState {
  final T? data;

  SuccessState({this.data});
}