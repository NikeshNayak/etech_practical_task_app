part of 'get_media_detail_bloc.dart';

sealed class GetMediaDetailState extends Equatable {
  const GetMediaDetailState();

  @override
  List<Object> get props => [];
}

class GetMediaDetailInitialState extends GetMediaDetailState {}

class GetMediaDetailLoadingState extends GetMediaDetailState {}

class GetMediaDetailSuccessState extends GetMediaDetailState {
  final MediaVideoModel mediaVideoModel;

  const GetMediaDetailSuccessState({required this.mediaVideoModel});
}

class GetMediaDetailFailedState extends GetMediaDetailState {
  final String message;

  const GetMediaDetailFailedState(this.message);
}

class GetMediaDetailExceptionState extends GetMediaDetailState {
  final String message;

  const GetMediaDetailExceptionState(this.message);
}
