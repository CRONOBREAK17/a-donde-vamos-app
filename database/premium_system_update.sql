-- ============================================
-- SISTEMA DE PREMIUM Y LÍMITES DE BÚSQUEDA
-- ============================================
-- Fecha: 2025-12-08
-- Descripción: Agregar columnas para controlar el límite de búsquedas 
--              con filtros para usuarios gratuitos (3 por día)

-- Agregar columnas para el sistema de límite de búsquedas TOTALES
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS daily_searches_used INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_search_reset TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Crear índice para mejorar el rendimiento de las consultas
CREATE INDEX IF NOT EXISTS idx_users_daily_searches 
ON users(id, daily_searches_used, last_search_reset);

-- Comentarios para documentar las columnas
COMMENT ON COLUMN users.daily_searches_used IS 
'Número de búsquedas TOTALES usadas hoy (usuarios gratuitos tienen límite de 3 por día)';

COMMENT ON COLUMN users.last_search_reset IS 
'Última vez que se reinició el contador de búsquedas (se resetea cada 24 horas)';

-- ============================================
-- FUNCIONALIDAD DEL SISTEMA
-- ============================================
-- Usuarios GRATUITOS:
--   - Máximo 3 búsquedas TOTALES por día
--   - Después de las 3 búsquedas, el botón se deshabilita
--   - Muestra modal para adquirir premium
--   - Contador se resetea automáticamente cada 24 horas
--   - Insignia "GRATUITO" (sin brillo, estilo simple)
--   - Contador visible: "2/3 búsquedas"
--   - Temporizador mostrando tiempo restante para próximo reseteo

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
AND column_name IN ('daily_searches_used', 'last_search_reset')
ORDER BY column_name;

-- Para ver el estado actual de los usuarios:
SELECT 
    id,
    username,
    is_premium,
    daily_searches_used,
    last_search_reset,
    EXTRACT(EPOCH FROM (NOW() - last_search_reset))/3600 as hours_since_reset
FROM users
ORDER BY is_premium DESC, username
LIMIT 10;
