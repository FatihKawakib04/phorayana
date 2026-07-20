-- Migration: Add history tracking columns to trips table
-- ponytail: simple numeric and jsonb columns to track distance and route path

ALTER TABLE public.trips 
  ADD COLUMN IF NOT EXISTS distance_km NUMERIC(5,2) DEFAULT 0.00,
  ADD COLUMN IF NOT EXISTS route_path JSONB DEFAULT '[]'::jsonb;
