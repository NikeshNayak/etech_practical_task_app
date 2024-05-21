import 'package:etech_practical_task_app/bloc/get_media_bloc/get_media_bloc.dart';
import 'package:etech_practical_task_app/bloc/get_media_detail_bloc/get_media_detail_bloc.dart';
import 'package:etech_practical_task_app/bloc_observer.dart';
import 'package:etech_practical_task_app/utils/network_manager.dart';
import 'package:etech_practical_task_app/view/page/media_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

final networkManager = NetworkManager();
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true,
  );
  Bloc.observer = SimpleBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: GetMediaBloc(),
        ),
        BlocProvider.value(
          value: GetMediaDetailBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Practical Task',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: false,
        ),
        navigatorObservers: [routeObserver],
        home: const MediaListPage(),
      ),
    );
  }
}
