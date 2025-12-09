-- Función para obtener el ranking de lugares más visitados
-- Esta función cuenta las visitas por lugar y devuelve los lugares ordenados por popularidad

CREATE OR REPLACE FUNCTION get_top_places(limit_count INT DEFAULT 50)
RETURNS TABLE (
  place_name TEXT,
  place_address TEXT,
  place_latitude DOUBLE PRECISION,
  place_longitude DOUBLE PRECISION,
  visit_count BIGINT
) 
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    up.place_name::TEXT,
    up.place_address::TEXT,
    up.place_latitude::DOUBLE PRECISION,
    up.place_longitude::DOUBLE PRECISION,
    COUNT(*)::BIGINT as visit_count
  FROM user_places up
  WHERE up.visited = true
  GROUP BY up.place_name, up.place_address, up.place_latitude, up.place_longitude
  ORDER BY visit_count DESC
  LIMIT limit_count;
END;
$$;

-- Dar permisos de ejecución a usuarios autenticados
GRANT EXECUTE ON FUNCTION get_top_places(INT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_top_places(INT) TO anon;

-- Comentario descriptivo
COMMENT ON FUNCTION get_top_places(INT) IS 'Devuelve el ranking de lugares más visitados por los usuarios, agrupados por nombre y ubicación';
