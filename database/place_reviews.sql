-- Tabla para almacenar reseñas de lugares de Google Places
-- Esta tabla complementa el sistema de reviews existente

CREATE TABLE IF NOT EXISTS place_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    place_id TEXT NOT NULL, -- Google Place ID
    place_name TEXT NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_place_reviews_place_id ON place_reviews(place_id);
CREATE INDEX IF NOT EXISTS idx_place_reviews_user_id ON place_reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_place_reviews_created_at ON place_reviews(created_at DESC);

-- Evitar múltiples reviews del mismo usuario para el mismo lugar
CREATE UNIQUE INDEX IF NOT EXISTS idx_place_reviews_unique ON place_reviews(user_id, place_id);

-- RLS (Row Level Security)
ALTER TABLE place_reviews ENABLE ROW LEVEL SECURITY;

-- Políticas de seguridad
-- Cualquiera puede leer las reseñas
CREATE POLICY "Las reseñas son públicas" ON place_reviews
    FOR SELECT USING (true);

-- Solo usuarios autenticados pueden insertar reseñas
CREATE POLICY "Los usuarios pueden crear reseñas" ON place_reviews
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Los usuarios solo pueden actualizar sus propias reseñas
CREATE POLICY "Los usuarios pueden actualizar sus reseñas" ON place_reviews
    FOR UPDATE USING (auth.uid() = user_id);

-- Los usuarios solo pueden eliminar sus propias reseñas
CREATE POLICY "Los usuarios pueden eliminar sus reseñas" ON place_reviews
    FOR DELETE USING (auth.uid() = user_id);

-- Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_place_reviews_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER place_reviews_updated_at
    BEFORE UPDATE ON place_reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_place_reviews_updated_at();

-- Comentarios
COMMENT ON TABLE place_reviews IS 'Reseñas de lugares de Google Places por usuarios de la app';
COMMENT ON COLUMN place_reviews.place_id IS 'ID del lugar en Google Places API';
COMMENT ON COLUMN place_reviews.rating IS 'Calificación de 1 a 5 estrellas';
