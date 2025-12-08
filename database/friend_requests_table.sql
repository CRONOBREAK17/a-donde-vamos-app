-- Crear tabla de solicitudes de amistad
CREATE TABLE IF NOT EXISTS friend_requests (
    id BIGSERIAL PRIMARY KEY,
    sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Evitar solicitudes duplicadas
    UNIQUE(sender_id, receiver_id),
    
    -- No permitir que un usuario se envíe solicitud a sí mismo
    CHECK (sender_id != receiver_id)
);

-- Índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_friend_requests_sender ON friend_requests(sender_id);
CREATE INDEX IF NOT EXISTS idx_friend_requests_receiver ON friend_requests(receiver_id);
CREATE INDEX IF NOT EXISTS idx_friend_requests_status ON friend_requests(status);

-- Políticas de seguridad RLS (Row Level Security)
ALTER TABLE friend_requests ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios pueden ver sus solicitudes enviadas
CREATE POLICY "Users can view their sent requests"
ON friend_requests FOR SELECT
USING (auth.uid() = sender_id);

-- Política: Los usuarios pueden ver sus solicitudes recibidas
CREATE POLICY "Users can view their received requests"
ON friend_requests FOR SELECT
USING (auth.uid() = receiver_id);

-- Política: Los usuarios pueden enviar solicitudes
CREATE POLICY "Users can send friend requests"
ON friend_requests FOR INSERT
WITH CHECK (auth.uid() = sender_id);

-- Política: Los usuarios pueden actualizar solicitudes que recibieron (aceptar/rechazar)
CREATE POLICY "Users can update received requests"
ON friend_requests FOR UPDATE
USING (auth.uid() = receiver_id);

-- Política: Los usuarios pueden eliminar solicitudes que enviaron (cancelar)
CREATE POLICY "Users can delete sent requests"
ON friend_requests FOR DELETE
USING (auth.uid() = sender_id);

-- Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_friend_requests_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER friend_requests_updated_at
BEFORE UPDATE ON friend_requests
FOR EACH ROW
EXECUTE FUNCTION update_friend_requests_updated_at();

-- Comentarios para documentación
COMMENT ON TABLE friend_requests IS 'Almacena las solicitudes de amistad entre usuarios';
COMMENT ON COLUMN friend_requests.status IS 'Estado de la solicitud: pending, accepted, rejected';
