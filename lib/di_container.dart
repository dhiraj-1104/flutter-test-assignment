import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_assignment/core/network/api_client.dart';
import 'package:flutter_assignment/core/network/network_info.dart';
import 'package:flutter_assignment/features/users/data/datasource/local_datasource.dart';
import 'package:flutter_assignment/features/users/data/datasource/remote_datasource.dart';
import 'package:flutter_assignment/features/users/data/repositories/respositories_impl.dart';
import 'package:flutter_assignment/features/users/domain/repository/repository.dart';
import 'package:flutter_assignment/features/users/domain/usecases/get_user_usecase.dart';
import 'package:flutter_assignment/features/users/presentation/bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => http.Client());

  sl.registerLazySingleton(() => ApiClient(sl()));
  sl.registerLazySingleton(() => Connectivity());
  await Hive.initFlutter();

  final userbox = await Hive.openBox('users_box');
  sl.registerLazySingleton(() => userbox);

  sl.registerLazySingleton<RemoteDatasource>(() => MockApi());

  sl.registerLazySingleton<NetworkConnectivity>(
    () => NetworkConnectivityImpl(connectivity: sl()),
  );

  sl.registerLazySingleton<LocalDatasource>(
    () => HiveDatasoureImpl(box: userbox),
  );

  sl.registerLazySingleton<UserRepository>(
    () => RespositoriesImpl(
      connectivity: sl(),
      localDatasource: sl(),
      remoteDatasource: sl(),
    ),
  );

  sl.registerLazySingleton<GetUserUsecase>(
    () => GetUserUsecase(userRepository: sl()),
  );

  sl.registerFactory(() => UserBloc(getUserUsecase: sl()));
}
