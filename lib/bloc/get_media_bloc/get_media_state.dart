part of 'get_media_bloc.dart';

sealed class GetMediaState extends Equatable {
  const GetMediaState();

  @override
  List<Object> get props => [];
}

class GetMediaInitialState extends GetMediaState {}

class GetMediaLoadingState extends GetMediaState {}

class GetMediaSuccessState extends GetMediaState {
  final List<MediaVideoModel> mediaList;

  const GetMediaSuccessState({required this.mediaList});
}

class GetMediaFailedState extends GetMediaState {
  final String message;

  const GetMediaFailedState(this.message);
}

class GetMediaExceptionState extends GetMediaState {
  final String message;

  const GetMediaExceptionState(this.message);
}
