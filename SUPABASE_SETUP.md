# 📋 Sistema de Cotizaciones con Supabase

## 🌟 Características Principales

- ✅ **Gestión de Tipos de Trabajo** sincronizada con Supabase
- ✅ **Funcionamiento Offline** con sincronización automática
- ✅ **Interfaz Responsive** para desktop y móvil
- ✅ **Modo Oscuro/Claro** personalizable
- ✅ **Sincronización en Tiempo Real** entre dispositivos
- ✅ **Fallback Local** cuando no hay conexión a internet

## 🔧 Configuración de Supabase

### Paso 1: Crear Proyecto en Supabase

1. Ve a [supabase.com](https://supabase.com) y crea una cuenta
2. Crea un nuevo proyecto
3. Anota tu **URL del proyecto** y **API Key (anon/public)**

### Paso 2: Configurar Base de Datos

1. Ve al **SQL Editor** en tu proyecto de Supabase
2. Copia y ejecuta el contenido del archivo `supabase_setup.sql`
3. Verifica que la tabla `tipos_trabajo` se haya creado correctamente

### Paso 3: Configurar la Aplicación

1. Abre el archivo `lib/config/supabase_config.dart`
2. Reemplaza los valores placeholder con tus credenciales:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://tu-proyecto.supabase.co';
  static const String supabaseAnonKey = 'tu-clave-anon-key-aqui';
  
  // ... resto del código
}
```

### Paso 4: Ejecutar la Aplicación

```bash
flutter pub get
flutter run
```

## 📱 Uso de la Aplicación

### Gestión de Tipos de Trabajo

1. **Añadir Nuevo Tipo:**
   - Haz clic en el ícono de configuración (⚙️)
   - Ingresa el nombre y costo del trabajo
   - Clic en "Añadir"

2. **Actualizar Tipo Existente:**
   - Selecciona un tipo de la lista
   - Modifica los campos necesarios
   - Clic en "Actualizar"

3. **Eliminar Tipo:**
   - Selecciona un tipo de la lista
   - Clic en "Eliminar"

### Sincronización con Supabase

- **Automática:** La app intenta sincronizar automáticamente
- **Manual:** Usa el botón de sincronización (🔄) en la barra superior
- **Indicadores:**
  - 🟢 **Verde:** Conectado y sincronizado
  - 🟠 **Naranja:** Supabase configurado pero sin conexión
  - Sin ícono: Solo funcionamiento local

## 🏗️ Estructura del Proyecto

```
lib/
├── config/
│   └── supabase_config.dart      # Configuración de Supabase
├── models/
│   └── tipo_trabajo.dart         # Modelo de datos
├── providers/
│   └── tipo_trabajo_provider.dart # Lógica de negocio y cache
├── services/
│   └── supabase_service.dart     # Comunicación con Supabase
└── main.dart                     # Aplicación principal
```

## 🔄 Flujo de Sincronización

1. **Carga Inicial:**
   - Intenta cargar desde Supabase
   - Si no hay conexión, usa datos locales

2. **Operaciones CRUD:**
   - Si hay conexión: operación inmediata en Supabase
   - Si no hay conexión: operación local + marcado para sincronización

3. **Sincronización:**
   - Se ejecuta automáticamente al recuperar conexión
   - También se puede activar manualmente

## 🛠️ Desarrollo y Debugging

### Logs Útiles

La aplicación muestra logs útiles en la consola:
- ✅ Confirmación de operaciones exitosas
- ❌ Errores de conexión o operaciones
- ⚠️ Advertencias sobre configuración

### Modo de Desarrollo

Para probar sin Supabase:
1. Deja las configuraciones como están en `supabase_config.dart`
2. La app funcionará solo localmente
3. Los datos se guardarán usando SharedPreferences

## 📊 Tabla de Base de Datos

### tipos_trabajo

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | SERIAL | Identificador único |
| nombre | VARCHAR(255) | Nombre del tipo de trabajo |
| costo | DECIMAL(10,2) | Costo por metro cuadrado |
| created_at | TIMESTAMP | Fecha de creación |
| updated_at | TIMESTAMP | Fecha de actualización |

### Índices

- `idx_tipos_trabajo_nombre`: Optimiza búsquedas por nombre
- `idx_tipos_trabajo_created_at`: Optimiza consultas por fecha

## 🔐 Seguridad

- **Row Level Security (RLS)** habilitado
- **Políticas de acceso** configuradas para operaciones CRUD
- **Validación de datos** en triggers de base de datos

## 🚀 Funcionalidades Avanzadas

### Estadísticas

```sql
SELECT * FROM tipos_trabajo_stats;
```

### Función de Prueba

```sql
SELECT test_connection();
```

### Obtener Estadísticas

```sql
SELECT get_tipos_trabajo_stats();
```

## 🔧 Solución de Problemas

### Error: "Supabase no está configurado"

**Solución:** Verifica que `supabase_config.dart` tenga tus credenciales reales.

### Error: "No se puede conectar a Supabase"

**Solución:** 
1. Verifica tu conexión a internet
2. Confirma que la URL y API Key son correctas
3. Revisa que el proyecto de Supabase esté activo

### Error: "Tabla no encontrada"

**Solución:** Ejecuta el script `supabase_setup.sql` en el SQL Editor de Supabase.

### Los datos no se sincronizan

**Solución:**
1. Verifica que RLS esté configurado correctamente
2. Revisa las políticas de seguridad
3. Usa el botón de sincronización manual

## 📝 Notas Importantes

- La aplicación funciona completamente offline
- Los datos se sincronizan automáticamente cuando hay conexión
- Se mantiene un cache local para mejor rendimiento
- Los datos locales persisten usando SharedPreferences

---

## 🎯 Próximos Pasos

1. **Configurar Supabase** siguiendo los pasos anteriores
2. **Probar la aplicación** en diferentes escenarios de conectividad
3. **Personalizar tipos de trabajo** según tus necesidades
4. **Opcional:** Configurar autenticación de usuarios para mayor seguridad

¡Disfruta de tu sistema de cotizaciones sincronizado! 🚀
