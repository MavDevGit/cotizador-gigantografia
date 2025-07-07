-- =============================================
-- Script de configuración para Supabase
-- Sistema de Cotizaciones - Tipos de Trabajo
-- =============================================

-- Crear la tabla tipos_trabajo
CREATE TABLE IF NOT EXISTS tipos_trabajo (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL UNIQUE,
    costo DECIMAL(10,2) NOT NULL CHECK (costo >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Crear índices para optimizar consultas
CREATE INDEX IF NOT EXISTS idx_tipos_trabajo_nombre ON tipos_trabajo(nombre);
CREATE INDEX IF NOT EXISTS idx_tipos_trabajo_created_at ON tipos_trabajo(created_at);

-- Crear función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Crear trigger para actualizar updated_at
DROP TRIGGER IF EXISTS update_tipos_trabajo_updated_at ON tipos_trabajo;
CREATE TRIGGER update_tipos_trabajo_updated_at
    BEFORE UPDATE ON tipos_trabajo
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Habilitar Row Level Security (RLS)
ALTER TABLE tipos_trabajo ENABLE ROW LEVEL SECURITY;

-- Crear políticas de seguridad
-- Política para SELECT (leer datos)
CREATE POLICY "Allow read access for all users" ON tipos_trabajo
    FOR SELECT
    USING (true);

-- Política para INSERT (crear nuevos registros)
CREATE POLICY "Allow insert for all users" ON tipos_trabajo
    FOR INSERT
    WITH CHECK (true);

-- Política para UPDATE (actualizar registros existentes)
CREATE POLICY "Allow update for all users" ON tipos_trabajo
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Política para DELETE (eliminar registros)
CREATE POLICY "Allow delete for all users" ON tipos_trabajo
    FOR DELETE
    USING (true);

-- Insertar algunos datos de ejemplo (opcional)
INSERT INTO tipos_trabajo (nombre, costo) VALUES
    ('Impresión Vinilo', 15.50),
    ('Impresión Lona', 12.00),
    ('Impresión Banner', 8.75),
    ('Impresión Tela', 18.25),
    ('Ploteo Vinilo', 22.00),
    ('Gigantografía Básica', 10.50),
    ('Gigantografía Premium', 25.00)
ON CONFLICT (nombre) DO NOTHING;

-- Crear vista para estadísticas (opcional)
CREATE OR REPLACE VIEW tipos_trabajo_stats AS
SELECT 
    COUNT(*) as total_tipos,
    AVG(costo) as costo_promedio,
    MIN(costo) as costo_minimo,
    MAX(costo) as costo_maximo,
    SUM(costo) as costo_total
FROM tipos_trabajo;

-- Comentarios en las columnas
COMMENT ON TABLE tipos_trabajo IS 'Tabla que almacena los tipos de trabajo disponibles para cotizaciones';
COMMENT ON COLUMN tipos_trabajo.id IS 'Identificador único del tipo de trabajo';
COMMENT ON COLUMN tipos_trabajo.nombre IS 'Nombre descriptivo del tipo de trabajo';
COMMENT ON COLUMN tipos_trabajo.costo IS 'Costo base por metro cuadrado en bolivianos';
COMMENT ON COLUMN tipos_trabajo.created_at IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN tipos_trabajo.updated_at IS 'Fecha y hora de la última actualización';

-- Función para verificar la conexión (útil para debugging)
CREATE OR REPLACE FUNCTION test_connection()
RETURNS TEXT AS $$
BEGIN
    RETURN 'Conexión exitosa a Supabase - ' || CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- Crear función para obtener estadísticas
CREATE OR REPLACE FUNCTION get_tipos_trabajo_stats()
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'total_tipos', COUNT(*),
        'costo_promedio', COALESCE(AVG(costo), 0),
        'costo_minimo', COALESCE(MIN(costo), 0),
        'costo_maximo', COALESCE(MAX(costo), 0),
        'ultima_actualizacion', MAX(updated_at)
    ) INTO result
    FROM tipos_trabajo;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Función para validar datos antes de inserción
CREATE OR REPLACE FUNCTION validate_tipo_trabajo()
RETURNS TRIGGER AS $$
BEGIN
    -- Validar que el nombre no esté vacío
    IF NEW.nombre IS NULL OR trim(NEW.nombre) = '' THEN
        RAISE EXCEPTION 'El nombre del tipo de trabajo no puede estar vacío';
    END IF;
    
    -- Validar que el costo sea positivo
    IF NEW.costo < 0 THEN
        RAISE EXCEPTION 'El costo debe ser un valor positivo';
    END IF;
    
    -- Limpiar espacios en el nombre
    NEW.nombre = trim(NEW.nombre);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger de validación
DROP TRIGGER IF EXISTS validate_tipos_trabajo_trigger ON tipos_trabajo;
CREATE TRIGGER validate_tipos_trabajo_trigger
    BEFORE INSERT OR UPDATE ON tipos_trabajo
    FOR EACH ROW
    EXECUTE FUNCTION validate_tipo_trabajo();

-- Grants (permisos) para usuarios autenticados
GRANT ALL ON tipos_trabajo TO authenticated;
GRANT ALL ON tipos_trabajo TO anon;
GRANT USAGE ON SEQUENCE tipos_trabajo_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE tipos_trabajo_id_seq TO anon;

-- Mensaje de confirmación
SELECT 'Base de datos configurada exitosamente para Sistema de Cotizaciones' as status;
