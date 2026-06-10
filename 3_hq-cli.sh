#!/bin/bash
# ============================================
# МОДУЛЬ 3 — HQ-CLI (только проверки)
# ============================================

echo "=== ПРОВЕРКИ МОДУЛЯ 3 ==="

echo "--- Проверка DNS ---"
host web.au-team.irpo
host docker.au-team.irpo

echo "--- Проверка сайтов ---"
curl -s -o /dev/null -w "web.au-team.irpo: %{http_code}\n" http://web.au-team.irpo
curl -s -o /dev/null -w "docker.au-team.irpo: %{http_code}\n" http://docker.au-team.irpo

echo "=== Проверки завершены ==="