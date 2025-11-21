import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/user.dart';
import '../models/task.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // Auth
  @POST('/api/auth/register')
  Future<AuthResponse> register(@Body() User user);

  @POST('/api/auth/login')
  Future<AuthResponse> login(@Body() LoginRequest request);

  // Tasks
  @GET('/api/tasks')
  Future<List<Task>> getTasks();

  @POST('/api/tasks')
  Future<Task> createTask(@Body() Task task);

  @PUT('/api/tasks/{id}')
  Future<Task> updateTask(@Path('id') int id, @Body() Task task);

  @DELETE('/api/tasks/{id}')
  Future<void> deleteTask(@Path('id') int id);
}
