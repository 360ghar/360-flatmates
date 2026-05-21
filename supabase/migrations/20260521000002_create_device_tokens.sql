-- Migration: Create device_tokens table for FCM token management.
-- Table: public.device_tokens

CREATE TABLE IF NOT EXISTS public.device_tokens (
  id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fcm_token     TEXT NOT NULL,
  platform      TEXT NOT NULL CHECK (platform IN ('android', 'ios', 'web')),
  device_id     TEXT,
  app_version   TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Fast lookup: find all tokens for a user.
CREATE INDEX IF NOT EXISTS device_tokens_user_id_idx ON public.device_tokens (user_id);

-- Prevent duplicate tokens.
CREATE UNIQUE INDEX IF NOT EXISTS device_tokens_fcm_token_uniq ON public.device_tokens (fcm_token);

-- Updated_at trigger (reuses the function from the app_config migration).
DROP TRIGGER IF EXISTS device_tokens_set_updated_at ON public.device_tokens;
CREATE TRIGGER device_tokens_set_updated_at
  BEFORE UPDATE ON public.device_tokens
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Enable RLS.
ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;

-- Users can only CRUD their own device tokens.
CREATE POLICY "device_tokens_select_own" ON public.device_tokens
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "device_tokens_insert_own" ON public.device_tokens
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "device_tokens_update_own" ON public.device_tokens
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "device_tokens_delete_own" ON public.device_tokens
  FOR DELETE USING (auth.uid() = user_id);

-- Service role can read all tokens (for sending notifications from backend).
CREATE POLICY "device_tokens_select_service" ON public.device_tokens
  FOR SELECT USING (auth.role() = 'service_role');

COMMENT ON TABLE public.device_tokens IS 'FCM device tokens for push notifications, linked to authenticated users.';
