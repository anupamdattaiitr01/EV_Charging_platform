import 'package:get_it/get_it.dart';
import '../network/api_client.dart';

// Auth Feature
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/bloc/auth_cubit.dart';

// Wallet Feature
import '../../features/wallet/domain/repositories/i_wallet_repository.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/presentation/bloc/wallet_cubit.dart';

// Dashboard Feature
import '../../features/dashboard/data/datasources/weather_remote_datasource.dart';
import '../../features/dashboard/domain/repositories/i_weather_repository.dart';
import '../../features/dashboard/data/repositories/weather_repository_impl.dart';
import '../../features/dashboard/presentation/bloc/dashboard_cubit.dart';

// Manager Feature
import '../../features/manager/data/datasources/manager_remote_datasource.dart';
import '../../features/manager/domain/repositories/i_manager_repository.dart';
import '../../features/manager/data/repositories/manager_repository_impl.dart';
import '../../features/manager/presentation/bloc/manager_filter_cubit.dart';
import '../../features/manager/presentation/bloc/analytics_cubit.dart';

// Charging Feature
import '../../features/charging/data/datasources/charging_remote_datasource.dart';
import '../../features/charging/domain/repositories/i_charging_repository.dart';
import '../../features/charging/data/repositories/charging_repository_impl.dart';
import '../../features/charging/presentation/bloc/charging_cubit.dart';

// Map Feature (add to top imports)
import '../../features/map/data/datasources/map_remote_datasource.dart';
import '../../features/map/domain/repositories/i_map_repository.dart';
import '../../features/map/data/repositories/map_repository_impl.dart';
import '../../features/map/presentation/bloc/map_cubit.dart';

// Profile Feature (imports)
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/domain/repositories/i_profile_repository.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/presentation/bloc/profile_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core Network
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // --- Auth Feature ---
  sl.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl());
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl<IAuthRepository>()));

  // --- Wallet Feature ---
  sl.registerLazySingleton<IWalletRepository>(() => WalletRepositoryImpl());
  sl.registerFactory<WalletCubit>(() => WalletCubit(sl<IWalletRepository>()));

  // --- Dashboard Feature ---
  sl.registerLazySingleton<WeatherRemoteDataSource>(() => WeatherRemoteDataSource());
  sl.registerLazySingleton<IWeatherRepository>(() => WeatherRepositoryImpl(sl<WeatherRemoteDataSource>()));
  sl.registerFactory<DashboardCubit>(() => DashboardCubit(sl<IWeatherRepository>()));

  // --- Manager Feature ---
  sl.registerLazySingleton<ManagerRemoteDataSource>(() => ManagerRemoteDataSource());
  sl.registerLazySingleton<IManagerRepository>(() => ManagerRepositoryImpl(sl<ManagerRemoteDataSource>()));
  sl.registerFactory<ManagerFilterCubit>(() => ManagerFilterCubit(sl<IManagerRepository>()));
  sl.registerFactory<AnalyticsCubit>(() => AnalyticsCubit(sl<IManagerRepository>()));

  // --- Charging Feature ---
  sl.registerLazySingleton<ChargingRemoteDataSource>(() => ChargingRemoteDataSource());
  sl.registerLazySingleton<IChargingRepository>(() => ChargingRepositoryImpl(sl<ChargingRemoteDataSource>()));
  sl.registerLazySingleton<ChargingCubit>(() => ChargingCubit(sl<IChargingRepository>()));

  // Map Feature (add inside init())
  sl.registerLazySingleton<MapRemoteDataSource>(() => MapRemoteDataSource());
  sl.registerLazySingleton<IMapRepository>(() => MapRepositoryImpl(sl<MapRemoteDataSource>()));
  sl.registerFactory<MapCubit>(() => MapCubit(sl<IMapRepository>()));

  // Profile Feature (inside init())
  sl.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSource());
  sl.registerLazySingleton<IProfileRepository>(() => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()));
  sl.registerFactory<ProfileCubit>(() => ProfileCubit(sl<IProfileRepository>()));
}