
-- =====================================================
-- Project: Insurance Analytics & Risk Intelligence
-- Script: 01_create_database.sql
-- Database: MySQL 8.0
-- =====================================================

CREATE DATABASE IF NOT EXISTS insurance_analytics
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

USE insurance_analytics;

-- Verify database selection
SELECT DATABASE() AS current_database;
