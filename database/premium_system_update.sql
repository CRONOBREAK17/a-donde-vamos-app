-- ============================================
-- SISTEMA DE PREMIUM Y LÍMITES DE BÚSQUEDA
-- ============================================
-- Fecha: 2025-12-08
-- Descripción: Agregar columnas para controlar el límite de búsquedas 
--              con filtros para usuarios gratuitos (3 por día)

-- Agregar columnas para el sistema de límite de búsquedas con filtros
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS daily_filter_searches_used INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_filter_search_reset TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Crear índice para mejorar el rendimiento de las consultas
CREATE INDEX IF NOT EXISTS idx_users_filter_searches 
ON users(id, daily_filter_searches_used, last_filter_search_reset);

-- Comentarios para documentar las columnas
COMMENT ON COLUMN users.daily_filter_searches_used IS 
'Número de búsquedas con filtros usadas hoy (usuarios gratuitos tienen límite de 3 por día)';

COMMENT ON COLUMN users.last_filter_search_reset IS 
'Última vez que se reinició el contador de búsquedas con filtros (se resetea cada 24 horas)';

-- ============================================
-- FUNCIONALIDAD DEL SISTEMA
-- ============================================
-- Usuarios GRATUITOS:
--   - Máximo 3 búsquedas con filtros por día
--   - Después de las 3 búsquedas, las búsquedas son completamente aleatorias:
--     * Tipo aleatorio (bar, restaurante o café)
--     * Radio extendido (50km)
--     * Sin aplicar filtros de horario, compañía, etc.
--   - Contador se resetea automáticamente cada 24 horas
--   - Insignia "GRATUITO" (sin brillo, estilo simple)
--   - Contador visible: "2/3 con filtros"

-- Usuarios PREMIUM ($30 MXN/mes):
--   - Búsquedas ilimitadas con filtros
--   - Sin anuncios
--   - Insignia "PREMIUM" (dorada con brillo y animación)
--   - Todas las funciones desbloqueadas

-- ============================================
-- VERIFICACIÓN
-- ============================================
-- Para verificar que las columnas se crearon correctamente:
SELECT 
    column_name, 
    data_type, 
    column_default,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'users' 
AND column_name IN ('daily_filter_searches_used', 'last_filter_search_reset')
ORDER BY column_name;

-- Para ver el estado actual de los usuarios:
SELECT 
    id,
    username,
    is_premium,
    daily_filter_searches_used,
    last_filter_search_reset
FROM users
ORDER BY is_premium DESC, username
LIMIT 10;
