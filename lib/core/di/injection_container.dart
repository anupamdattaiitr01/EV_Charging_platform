import 'package:get_it/get_it.dart';
import '../network/api_client.dart';

// Auth Feature
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import 'package:multi_page_ev_charge/features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/bloc/auth_cubit.dart';

// Wallet Feature
import '../../features/wallet/domain/repositories/i_wallet_repository.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/presentation/bloc/wallet_cubit.dart';

// --- NEW IMPORTS: Dashboard Feature ---
import '../../features/dashboard/data/datasources/weather_remote_datasource.dart';
import '../../features/dashboard/domain/repositories/i_weather_repository.dart';
import '../../features/dashboard/data/repositories/weather_repository_impl.dart';
import '../../features/dashboard/presentation/bloc/dashboard_cubit.dart';

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

  // --- NEW REGISTRATIONS: Dashboard Feature ---
  // 1. Register the Remote Data Source
  sl.registerLazySingleton<WeatherRemoteDataSource>(() => WeatherRemoteDataSource());

  // 2. Register the Repository (Injecting the data source)
  sl.registerLazySingleton<IWeatherRepository>(() => WeatherRepositoryImpl(sl<WeatherRemoteDataSource>()));

  // 3. Register the Cubit (Injecting the repository)
  sl.registerFactory<DashboardCubit>(() => DashboardCubit(sl<IWeatherRepository>()));
}