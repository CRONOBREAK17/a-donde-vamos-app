-- ============================================
-- MIGRACIÓN: SISTEMA PREMIUM V2.0
-- ============================================
-- Fecha: 2025-12-08
-- Descripción: Actualización del sistema de límites
--              De: "búsquedas con filtros" (3/día)
--              A: "búsquedas totales" (3/día)

-- ============================================
-- PASO 1: ELIMINAR COLUMNAS ANTIGUAS (si existen)
-- ============================================

-- Si ya ejecutaste el SQL anterior, elimina las columnas viejas
ALTER TABLE users 
DROP COLUMN IF EXISTS daily_filter_searches_used,
DROP COLUMN IF EXISTS last_filter_search_reset;

-- Eliminar índice antiguo si existe
DROP INDEX IF EXISTS idx_users_filter_searches;

-- ============================================
-- PASO 2: CREAR NUEVAS COLUMNAS
-- ============================================

-- Agregar columnas para límite de búsquedas TOTALES
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS daily_searches_used INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_search_reset TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- ============================================
-- PASO 3: CREAR ÍNDICE
-- ============================================

-- Crear índice para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_users_daily_searches 
ON users(id, daily_searches_used, last_search_reset);

-- ============================================
-- PASO 4: AGREGAR COMENTARIOS
-- ============================================

COMMENT ON COLUMN users.daily_searches_used IS 
'Número de búsquedas TOTALES usadas hoy (usuarios gratuitos tienen límite de 3 por día, premium ilimitadas)';

COMMENT ON COLUMN users.last_search_reset IS 
'Última vez que se reinició el contador de búsquedas (se resetea automáticamente cada 24 horas)';

-- ============================================
-- FUNCIONALIDAD DEL SISTEMA V2.0
-- ============================================

-- Usuarios GRATUITOS:
--   ✅ Máximo 3 búsquedas TOTALES por día
--   ✅ Al alcanzar límite, botón "Vámonos!!" se deshabilita
--   ✅ Muestra modal para adquirir premium
--   ✅ Temporizador visible mostrando próximo reseteo
--   ✅ Contador se resetea automáticamente cada 24 horas
--   ✅ Insignia "GRATUITO" (sin brillo, estilo simple)
--   ✅ Contador visible: "X/3 búsquedas"

-- Usuarios PREMIUM:
--   ⭐ Búsquedas ilimitadas
--   ⭐ Sin anuncios
--   ⭐ Filtros avanzados desbloqueados
--   ⭐ Insignia "PREMIUM" (dorada con brillo)
--   ⭐ Sin restricciones

-- PRECIO PREMIUM:
--   💰 $30 MXN/mes (o equivalente en moneda local)
--   💰 Detección automática de país para mostrar precio correcto
--   💰 Soporta: MXN, USD, ARS, CLP, COP, PEN, EUR, GBP, BRL, VES

-- ============================================
-- VERIFICACIÓN
-- ============================================

-- Verificar que las columnas se crearon correctamente
SELECT 
    column_name, 
    data_type, 
    column_default,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'users' 
AND column_name IN ('daily_searches_used', 'last_search_reset')
ORDER BY column_name;

-- Ver estado actual de los usuarios
SELECT 
    id,
    username,
    is_premium,
    daily_searches_used,
    last_search_reset,
    EXTRACT(EPOCH FROM (NOW() - last_search_reset))/3600 as hours_since_reset,
    CASE 
        WHEN is_premium THEN 'PREMIUM (ilimitadas)'
        WHEN daily_searches_used >= 3 THEN 'LÍMITE ALCANZADO'
        ELSE CONCAT(3 - daily_searches_used, ' búsquedas restantes')
    END as status
FROM users
ORDER BY is_premium DESC, daily_searches_used DESC
LIMIT 20;

-- ============================================
-- QUERIES ÚTILES
-- ============================================

-- Resetear búsquedas de un usuario específico (para testing)
-- UPDATE users 
-- SET 
--     daily_searches_used = 0,
--     last_search_reset = NOW()
-- WHERE id = 'USER_ID_AQUI';

-- Resetear búsquedas de todos los usuarios (cuidado!)
-- UPDATE users 
-- SET 
--     daily_searches_used = 0,
--     last_search_reset = NOW()
-- WHERE is_premium = false;

-- Ver usuarios que necesitan reseteo (más de 24 horas)
SELECT 
    username,
    daily_searches_used,
    last_search_reset,
    EXTRACT(EPOCH FROM (NOW() - last_search_reset))/3600 as hours_since_reset
FROM users
WHERE 
    is_premium = false 
    AND EXTRACT(EPOCH FROM (NOW() - last_search_reset))/3600 >= 24
ORDER BY hours_since_reset DESC;

-- Estadísticas de uso
SELECT 
    is_premium,
    COUNT(*) as total_users,
    AVG(daily_searches_used) as avg_searches,
    MAX(daily_searches_used) as max_searches,
    COUNT(CASE WHEN daily_searches_used >= 3 THEN 1 END) as users_at_limit
FROM users
GROUP BY is_premium;

-- ============================================
-- FUNCIÓN DE RESETEO AUTOMÁTICO (OPCIONAL)
-- ============================================
-- Puedes crear una función que se ejecute periódicamente
-- para resetear automáticamente los contadores

CREATE OR REPLACE FUNCTION reset_daily_searches()
RETURNS void AS $$
BEGIN
    UPDATE users
    SET 
        daily_searches_used = 0,
        last_search_reset = NOW()
    WHERE 
        is_premium = false 
        AND EXTRACT(EPOCH FROM (NOW() - last_search_reset))/3600 >= 24;
END;
$$ LANGUAGE plpgsql;

-- Ejecutar manualmente:
-- SELECT reset_daily_searches();

-- O configurar en Supabase Edge Functions / Cron Job para ejecutar cada hora

-- ============================================
-- ROLLBACK (si algo sale mal)
-- ============================================
-- Para volver atrás, ejecuta:
-- ALTER TABLE users 
-- DROP COLUMN IF EXISTS daily_searches_used,
-- DROP COLUMN IF EXISTS last_search_reset;
-- DROP INDEX IF EXISTS idx_users_daily_searches;

-- ============================================
-- FIN DE LA MIGRACIÓN
-- ============================================

-- ✅ Si todo salió bien, deberías ver:
-- - Columnas: daily_searches_used, last_search_reset
-- - Índice: idx_users_daily_searches
-- - Valores por defecto: 0 y NOW()

COMMENT ON TABLE users IS 'Tabla de usuarios con sistema de límites de búsqueda y premium (actualizado v2.0)';
