-- Sistema de referidos con recompensas de 40 puntos

-- 1. Agregar campo de código de referido único a la tabla users
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS referral_code VARCHAR(10) UNIQUE,
ADD COLUMN IF NOT EXISTS referred_by UUID REFERENCES users(id),
ADD COLUMN IF NOT EXISTS referral_points_earned INT DEFAULT 0;

-- 2. Crear tabla para tracking de referidos
CREATE TABLE IF NOT EXISTS referrals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  referrer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  referred_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  referral_code VARCHAR(10) NOT NULL,
  points_awarded INT DEFAULT 40,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(referred_id) -- Un usuario solo puede ser referido una vez
);

-- 3. Crear índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_referrals_referrer ON referrals(referrer_id);
CREATE INDEX IF NOT EXISTS idx_referrals_referred ON referrals(referred_id);
CREATE INDEX IF NOT EXISTS idx_users_referral_code ON users(referral_code);

-- 4. Función para generar código de referido único
CREATE OR REPLACE FUNCTION generate_referral_code()
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  result TEXT := '';
  i INT;
BEGIN
  FOR i IN 1..8 LOOP
    result := result || substr(chars, floor(random() * length(chars) + 1)::int, 1);
  END LOOP;
  RETURN result;
END;
$$;

-- 5. Función para generar código de referido al crear usuario
CREATE OR REPLACE FUNCTION create_user_referral_code()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  new_code TEXT;
  code_exists BOOLEAN;
BEGIN
  -- Generar código único
  LOOP
    new_code := generate_referral_code();
    SELECT EXISTS(SELECT 1 FROM users WHERE referral_code = new_code) INTO code_exists;
    EXIT WHEN NOT code_exists;
  END LOOP;
  
  NEW.referral_code := new_code;
  RETURN NEW;
END;
$$;

-- 6. Trigger para generar código al insertar usuario
DROP TRIGGER IF EXISTS trigger_create_referral_code ON users;
CREATE TRIGGER trigger_create_referral_code
  BEFORE INSERT ON users
  FOR EACH ROW
  EXECUTE FUNCTION create_user_referral_code();

-- 7. Función para aplicar código de referido
CREATE OR REPLACE FUNCTION apply_referral_code(
  referred_user_id UUID,
  referral_code_input TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  referrer_user_id UUID;
  referrer_points INT := 40;  -- Puntos para quien invitó
  referred_points INT := 20;  -- Puntos para el nuevo usuario
  result JSONB;
BEGIN
  -- Verificar que el usuario referido no haya sido referido antes
  IF EXISTS(SELECT 1 FROM users WHERE id = referred_user_id AND referred_by IS NOT NULL) THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Ya has usado un código de referido'
    );
  END IF;

  -- Buscar el referrer por código
  SELECT id INTO referrer_user_id
  FROM users
  WHERE referral_code = UPPER(referral_code_input);

  -- Verificar que el código existe
  IF referrer_user_id IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Código de referido inválido'
    );
  END IF;

  -- Verificar que no se refiera a sí mismo
  IF referrer_user_id = referred_user_id THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'No puedes usar tu propio código de referido'
    );
  END IF;

  -- Actualizar usuario referido
  UPDATE users
  SET referred_by = referrer_user_id
  WHERE id = referred_user_id;

  -- Otorgar 40 puntos al referrer (quien invitó)
  UPDATE users
  SET 
    activity_points = activity_points + referrer_points,
    referral_points_earned = referral_points_earned + referrer_points
  WHERE id = referrer_user_id;

  -- Otorgar 20 puntos al nuevo usuario (quien usó el código)
  UPDATE users
  SET activity_points = activity_points + referred_points
  WHERE id = referred_user_id;

  -- Registrar el referido con los puntos de ambos
  INSERT INTO referrals (referrer_id, referred_id, referral_code, points_awarded)
  VALUES (referrer_user_id, referred_user_id, UPPER(referral_code_input), referrer_points);

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Código de referido aplicado correctamente',
    'referrer_points', referrer_points,
    'referred_points', referred_points
  );
END;
$$;

-- 8. Función para obtener estadísticas de referidos
CREATE OR REPLACE FUNCTION get_referral_stats(user_id_input UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  total_referrals INT;
  total_points INT;
  result JSONB;
BEGIN
  SELECT 
    COUNT(*),
    COALESCE(SUM(points_awarded), 0)
  INTO total_referrals, total_points
  FROM referrals
  WHERE referrer_id = user_id_input;

  result := jsonb_build_object(
    'total_referrals', total_referrals,
    'total_points', total_points,
    'referral_code', (SELECT referral_code FROM users WHERE id = user_id_input)
  );

  RETURN result;
END;
$$;

-- 9. Permisos
GRANT EXECUTE ON FUNCTION apply_referral_code(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_referral_stats(UUID) TO authenticated;
GRANT SELECT ON referrals TO authenticated;

-- 10. Políticas de seguridad (RLS)
ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own referrals"
  ON referrals FOR SELECT
  USING (auth.uid() = referrer_id OR auth.uid() = referred_id);

-- Comentarios
COMMENT ON TABLE referrals IS 'Tabla para tracking de referidos y recompensas';
COMMENT ON FUNCTION apply_referral_code(UUID, TEXT) IS 'Aplica un código de referido y otorga 40 puntos al referrer';
COMMENT ON FUNCTION get_referral_stats(UUID) IS 'Obtiene estadísticas de referidos de un usuario';
