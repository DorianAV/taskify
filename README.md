# Taskify - Documentación del Proyecto

**Taskify** es una aplicación de gestión de tareas desarrollada en Flutter. Utiliza una arquitectura moderna y escalable basada en capas, gestión de estado con Riverpod, y comunicación con API REST mediante Dio y Retrofit.

## 🏗️ Estructura del Proyecto

El código fuente se encuentra en la carpeta `lib/` y está organizado de la siguiente manera:

```
lib/
├── data/                  # Capa de Datos (Modelos, API, Repositorios)
│   ├── api/               # Configuración de red
│   ├── models/            # Modelos de datos (Clases Dart)
│   └── repositories/      # Lógica de acceso a datos
├── providers/             # Gestión de Estado (Riverpod)
├── router/                # Navegación (GoRouter)
├── ui/                    # Interfaz de Usuario (Pantallas y Widgets)
│   ├── screens/
│   └── widgets/
├── utils/                 # Utilidades (Manejo de errores, etc.)
└── main.dart              # Punto de entrada de la aplicación
```

---

## 📂 Detalle de Archivos y Funcionalidad

A continuación se explica qué hace cada archivo y por qué es importante.

### 1. Punto de Entrada
*   **`main.dart`**: Es el corazón de la app.
    *   Inicializa Flutter.
    *   Configura el `ProviderScope` (necesario para que Riverpod funcione).
    *   Define el tema visual (colores, fuentes).
    *   Configura las rutas usando `app_router.dart`.

### 2. Capa de Datos (`lib/data/`)
Esta capa se encarga de todo lo relacionado con la información (traerla, guardarla y convertirla).

#### `api/` (Conexión con el Servidor)
*   **`api_client.dart`**: Configura `Dio`, que es el cliente HTTP.
    *   Define la `baseUrl` (la dirección de tu servidor/ngrok).
    *   Añade un **Interceptor** para inyectar automáticamente el token JWT en el header `Authorization` de cada petición.
*   **`api_service.dart`**: Define la interfaz de la API usando `Retrofit`.
    *   Aquí escribes los métodos como `login`, `getTasks`, `createTask` y les asignas su endpoint (`@GET('/api/tasks')`).
*   **`api_service.g.dart`**: **(Generado)** Código automático que implementa la interfaz anterior. Es quien realmente hace el trabajo sucio de conectar con la red.

#### `models/` (Estructura de Datos)
*   **`user.dart`**: Define cómo es un Usuario (`username`, `email`, `password`).
*   **`task.dart`**: Define cómo es una Tarea (`id`, `title`, `description`, `status`).
*   **`*.g.dart`**: **(Generado)** Archivos creados por `json_serializable` para convertir automáticamente tus objetos a JSON (para enviar a la API) y viceversa.

#### `repositories/` (Lógica de Negocio de Datos)
Los repositorios son intermediarios. El resto de la app no llama a la API directamente, llama a los repositorios.
*   **`auth_repository.dart`**: Maneja la autenticación.
    *   Llama a la API para login/registro.
    *   Guarda el token de sesión en el dispositivo de forma segura usando `flutter_secure_storage`.
*   **`task_repository.dart`**: Maneja las operaciones de tareas (crear, leer, actualizar, borrar).

### 3. Gestión de Estado (`lib/providers/`)
Usamos **Riverpod** para manejar la "memoria" de la app y reactivar la interfaz cuando los datos cambian.

*   **`providers.dart`**: Inyección de Dependencias. Aquí se crean las instancias únicas de `Dio`, `ApiService`, `AuthRepository`, etc., para que estén disponibles en toda la app.
*   **`auth_provider.dart`**: Controla el estado de la sesión.
    *   ¿El usuario está logueado? ¿Cargando? ¿Hubo error?
    *   Contiene la lógica de `login`, `register` y `logout`.
    *   Usa `ErrorHandler` para procesar errores.
*   **`task_provider.dart`**: Controla la lista de tareas.
    *   Almacena la lista de tareas y el filtro actual (Todas, Pendientes, etc.).
    *   Tiene funciones para `fetchTasks`, `addTask`, `updateTask`, `deleteTask`.

### 4. Navegación (`lib/router/`)
*   **`app_router.dart`**: Configura **GoRouter**.
    *   Define las rutas (`/`, `/login`).
    *   **Lógica de Redirección**: Si el usuario no tiene sesión iniciada, lo manda a `/login`. Si ya tiene sesión, lo manda al Home.

### 5. Interfaz de Usuario (`lib/ui/`)

#### `screens/` (Pantallas Completas)
*   **`login_screen.dart`**: Pantalla de inicio de sesión y registro.
    *   Maneja el formulario y llama a `authProvider`.
    *   Muestra errores (Snackbars) si fallan las credenciales.
*   **`home_screen.dart`**: Pantalla principal.
    *   Muestra la lista de tareas.
    *   Tiene los filtros (Chips) en la parte superior.
    *   Tiene el botón flotante (+) para crear tareas.

#### `widgets/` (Componentes Reutilizables)
*   **`task_tile.dart`**: El diseño de cada tarjetita de tarea en la lista.
    *   Muestra título, descripción y estado.
    *   Tiene el checkbox para completar rápido y el menú para editar/borrar.
*   **`task_dialog.dart`**: La ventana emergente (modal) que sale cuando creas o editas una tarea.

### 6. Utilidades (`lib/utils/`)
*   **`error_handler.dart`**: Una clase de ayuda para traducir los errores técnicos (404, 500, Timeouts) a mensajes amigables en español para el usuario (ej: "Verifique su conexión a internet").

---

## 🔄 Flujo de Funcionamiento (Ejemplo: Login)

1.  **UI**: El usuario ingresa datos en `LoginScreen` y pulsa "Entrar".
2.  **Provider**: `LoginScreen` llama a `authProvider.notifier.login()`.
3.  **Repository**: El provider llama a `authRepository.login()`.
4.  **API Service**: El repositorio llama a `apiService.login()`.
5.  **API Client**: `Dio` envía la petición HTTP POST al servidor.
6.  **Respuesta**:
    *   **Éxito**: El servidor devuelve un token. El repositorio lo guarda. El provider actualiza el estado a `authenticated`. El router detecta el cambio y redirige a `HomeScreen`.
    *   **Error**: `Dio` lanza una excepción. El provider la captura, usa `ErrorHandler` para obtener el mensaje en español y actualiza el estado con el error. La UI muestra un `SnackBar` con el mensaje.

## 🛠️ Comandos Útiles

*   **Generar código** (necesario si cambias modelos o API):
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
*   **Correr la app**:
    ```bash
    flutter run
    ```
