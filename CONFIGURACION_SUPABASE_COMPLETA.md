# 🚀 GUÍA PASO A PASO: Configuración de Supabase para Sistema de Cotizaciones

## 📋 Resumen de la Integración

Se ha integrado exitosamente **Supabase** en el panel de "Gestionar tipos de trabajo" del sistema de cotizaciones, permitiendo:

- ✅ **Sincronización en tiempo real** entre múltiples dispositivos
- ✅ **Funcionamiento offline** con cache local
- ✅ **Operaciones CRUD completas** (Crear, Leer, Actualizar, Eliminar)
- ✅ **Fallback automático** a datos locales cuando no hay conexión
- ✅ **Interfaz visual** con indicadores de estado de conexión

---

## 🛠️ PASO A PASO: Configuración de Supabase

### PASO 1: Crear Cuenta y Proyecto en Supabase

1. **Ir a Supabase:**
   - Visita: https://supabase.com
   - Crea una cuenta gratuita

2. **Crear Nuevo Proyecto:**
   - Clic en "New project"
   - Nombre del proyecto: `cotizador-gigantografia` (o el que prefieras)
   - Selecciona una región cercana
   - Establece una contraseña fuerte para la base de datos
   - Clic en "Create new project"

3. **Esperar Inicialización:**
   - El proyecto tardará 1-2 minutos en estar listo

### PASO 2: Obtener Credenciales del Proyecto

1. **Ir a Settings:**
   - En el panel lateral, clic en "Settings"
   - Luego en "API"

2. **Copiar Credenciales:**
   - **URL del Proyecto:** `https://[tu-proyecto-id].supabase.co`
   - **API Key (anon/public):** `eyJhbGciOiJIUzI1...` (clave larga)

3. **Guardar Credenciales:**
   - Anota estas credenciales, las necesitarás en el PASO 4

### PASO 3: Configurar Base de Datos

1. **Ir al SQL Editor:**
   - En el panel lateral, clic en "SQL Editor"
   - Clic en "New query"

2. **Ejecutar Script de Configuración:**
   - Abre el archivo `supabase_setup.sql` de tu proyecto
   - Copia TODO el contenido
   - Pégalo en el editor SQL de Supabase
   - Clic en "Run" (botón verde en la esquina inferior derecha)

3. **Verificar Creación:**
   - Ve a "Table Editor" en el panel lateral
   - Deberías ver la tabla `tipos_trabajo` creada
   - La tabla debería tener algunos datos de ejemplo

### PASO 4: Configurar la Aplicación Flutter

1. **Abrir archivo de configuración:**
   - Navega a: `lib/config/supabase_config.dart`

2. **Reemplazar credenciales:**
   ```dart
   class SupabaseConfig {
     // REEMPLAZA con tu URL real de Supabase
     static const String supabaseUrl = 'https://tu-proyecto-id.supabase.co';
     
     // REEMPLAZA con tu API Key real
     static const String supabaseAnonKey = 'tu-clave-anon-key-completa';
     
     // ... resto del código no cambiar
   }
   ```

3. **Ejemplo de configuración correcta:**
   ```dart
   static const String supabaseUrl = 'https://abcdefghijk.supabase.co';
   static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTg0MjAwMDAsImV4cCI6MjAxMzk5NjAwMH0.ejemplo-completo-de-clave';
   ```

### PASO 5: Probar la Aplicación

1. **Ejecutar la aplicación:**
   ```bash
   flutter run
   ```

2. **Verificar inicialización:**
   - En la consola deberías ver: `✅ Supabase inicializado correctamente`
   - Si ves `⚠️ Supabase no está configurado`, revisa el PASO 4

3. **Probar funcionalidades:**
   - Abre el panel "Gestionar tipos de trabajo" (⚙️)
   - Deberías ver un ícono verde (🟢) indicando conexión exitosa
   - Añade, edita o elimina tipos de trabajo
   - Los cambios se sincronizan automáticamente

---

## 🎯 VERIFICACIÓN DE LA CONFIGURACIÓN

### ✅ Indicadores Visuales en la App

1. **En la barra superior:**
   - 🟢 **Ícono verde:** Conectado y sincronizado con Supabase
   - 🟠 **Ícono naranja:** Supabase configurado pero sin conexión
   - Sin ícono: Solo funcionamiento local

2. **En el panel de gestión:**
   - Etiqueta "Sincronizado" verde cuando está conectado
   - Botón de sincronización (🔄) disponible

3. **Mensajes de confirmación:**
   - "✅ Trabajo añadido y sincronizado"
   - "✅ Datos sincronizados con Supabase"

### ✅ Verificar en Supabase Dashboard

1. **Ir a Table Editor:**
   - Abre tu proyecto en supabase.com
   - Ve a "Table Editor" > "tipos_trabajo"
   - Deberías ver los datos que añadiste desde la app

2. **Probar desde múltiples dispositivos:**
   - Ejecuta la app en diferentes dispositivos
   - Los cambios en uno se reflejan automáticamente en el otro

---

## 🔧 FUNCIONALIDADES IMPLEMENTADAS

### 1. **Gestión Completa de Tipos de Trabajo**
- ➕ **Crear:** Añadir nuevos tipos con nombre y costo
- ✏️ **Actualizar:** Modificar tipos existentes
- 🗑️ **Eliminar:** Remover tipos no necesarios
- 📋 **Listar:** Ver todos los tipos disponibles

### 2. **Sincronización Inteligente**
- 🔄 **Automática:** Al conectarse después de estar offline
- 🔄 **Manual:** Botón de sincronización en la interfaz
- 🔄 **Bidireccional:** Cambios locales suben, cambios remotos bajan

### 3. **Funcionamiento Offline**
- 💾 **Cache local:** Datos guardados con SharedPreferences
- 🔄 **Cola de sincronización:** Cambios pendientes se aplican al reconectar
- 🎯 **Fallback automático:** Usa datos locales si no hay conexión

### 4. **Seguridad y Validación**
- 🔐 **Row Level Security (RLS)** configurado en Supabase
- ✅ **Validaciones:** Nombres únicos, costos positivos
- 🛡️ **Políticas de acceso** para operaciones CRUD

---

## 🐛 SOLUCIÓN DE PROBLEMAS COMUNES

### ❌ Error: "Supabase no está configurado"
**Solución:** 
1. Verifica que `supabase_config.dart` tenga tus credenciales reales
2. Asegúrate de NO dejar los valores placeholder
3. Reinicia la aplicación después de cambiar la configuración

### ❌ Error: "No se puede conectar a Supabase"
**Solución:**
1. Verifica tu conexión a internet
2. Confirma que la URL del proyecto es correcta
3. Revisa que el proyecto de Supabase esté activo
4. Verifica que la API Key no haya expirado

### ❌ Error: "Tabla 'tipos_trabajo' no existe"
**Solución:**
1. Ve al SQL Editor de Supabase
2. Ejecuta completamente el script `supabase_setup.sql`
3. Verifica en "Table Editor" que la tabla existe

### ❌ Los datos no se sincronizan
**Solución:**
1. Usa el botón de sincronización manual (🔄)
2. Verifica que RLS esté configurado correctamente
3. Revisa las políticas de seguridad en Supabase
4. Comprueba los logs de la consola para errores específicos

### ⚠️ La app funciona pero sin sincronización
**Causa:** Es normal, la app funciona completamente offline
**Acción:** Configura Supabase siguiendo los pasos anteriores para habilitar sincronización

---

## 📊 ESTRUCTURA DE DATOS

### Tabla: tipos_trabajo
```sql
CREATE TABLE tipos_trabajo (
    id SERIAL PRIMARY KEY,              -- ID único automático
    nombre VARCHAR(255) NOT NULL UNIQUE, -- Nombre del tipo (único)
    costo DECIMAL(10,2) NOT NULL,       -- Costo por m² en bolivianos
    created_at TIMESTAMP DEFAULT NOW(), -- Fecha de creación
    updated_at TIMESTAMP DEFAULT NOW()  -- Fecha de actualización
);
```

### Ejemplo de Datos:
| id | nombre | costo | created_at | updated_at |
|----|--------|-------|------------|------------|
| 1 | Impresión Vinilo | 15.50 | 2024-01-01 | 2024-01-01 |
| 2 | Impresión Lona | 12.00 | 2024-01-01 | 2024-01-01 |

---

## 🔄 ARQUITECTURA DE SINCRONIZACIÓN

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │◄──►│ TipoTrabajo     │◄──►│   Supabase      │
│   (Local UI)    │    │ Provider        │    │   (Cloud DB)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                       │                       │
        ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ SharedPrefs     │    │ Cache Logic +   │    │ PostgreSQL +    │
│ (Offline Cache) │    │ Sync Queue      │    │ Real-time API   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## 🎉 ¡CONFIGURACIÓN COMPLETADA!

Una vez completados todos los pasos, tendrás:

- ✅ **Sistema de cotizaciones** funcionando offline y online
- ✅ **Sincronización automática** entre dispositivos
- ✅ **Base de datos en la nube** con Supabase
- ✅ **Interfaz moderna** con indicadores de estado
- ✅ **Gestión completa** de tipos de trabajo
- ✅ **Respaldo local** para funcionamiento offline

**¡Disfruta de tu sistema de cotizaciones sincronizado!** 🚀

---

## 📞 SOPORTE

Si tienes problemas:
1. Revisa los logs de la consola de Flutter
2. Verifica los logs en el dashboard de Supabase
3. Consulta la documentación oficial de Supabase
4. Asegúrate de que todas las dependencias estén actualizadas

**Recuerda:** La aplicación funciona perfectamente sin Supabase en modo local, la sincronización es una funcionalidad adicional que mejora la experiencia multi-dispositivo.
