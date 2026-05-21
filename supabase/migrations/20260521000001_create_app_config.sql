-- Migration: Create app_config table for remote version management and maintenance mode.
-- Table: public.app_config

CREATE TABLE IF NOT EXISTS public.app_config (
  id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  platform      TEXT NOT NULL CHECK (platform IN ('android', 'ios')),
  latest_version TEXT NOT NULL DEFAULT '1.0.0',
  minimum_required_version TEXT NOT NULL DEFAULT '1.0.0',
  force_update  BOOLEAN NOT NULL DEFAULT FALSE,
  update_url    TEXT NOT NULL DEFAULT '',
  maintenance_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  maintenance_message TEXT NOT NULL DEFAULT '',
  optional_update_message TEXT NOT NULL DEFAULT '',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Unique constraint: one config row per platform.
CREATE UNIQUE INDEX IF NOT EXISTS app_config_platform_uniq ON public.app_config (platform);

-- Updated_at trigger.
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS app_config_set_updated_at ON public.app_config;
CREATE TRIGGER app_config_set_updated_at
  BEFORE UPDATE ON public.app_config
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Enable RLS.
ALTER TABLE public.app_config ENABLE ROW LEVEL SECURITY;

-- Anyone can read app_config (needed by the Flutter app before login).
CREATE POLICY "app_config_select_public" ON public.app_config
  FOR SELECT USING (true);

-- Only authenticated admins/service role can modify app_config.
-- Adjust the role check to match your admin setup.
CREATE POLICY "app_config_insert_admin" ON public.app_config
  FOR INSERT WITH CHECK (auth.role() = 'service_role');

CREATE POLICY "app_config_update_admin" ON public.app_config
  FOR UPDATE USING (auth.role() = 'service_role');

CREATE POLICY "app_config_delete_admin" ON public.app_config
  FOR DELETE USING (auth.role() = 'service_role');

-- Seed default rows.
INSERT INTO public.app_config (platform, latest_version, minimum_required_version, update_url)
VALUES
  ('android', '1.0.2', '1.0.0', 'https://play.google.com/store/apps/details?id=com.the360ghar.flatmates360'),
  ('ios', '1.0.2', '1.0.0', '')
ON CONFLICT (platform) DO NOTHING;

COMMENT ON TABLE public.app_config IS 'Remote app configuration for version checks, force updates, and maintenance mode.';
