#!/usr/bin/env bash
# Testa todas as páginas e recursos do site localmente

PORT=8099

echo "Iniciando servidor local na porta $PORT..."
npx serve . --listen $PORT --no-clipboard &
SERVER_PID=$!

# Aguarda o servidor subir
sleep 2

echo ""
echo "Rodando verificação de links e recursos..."
echo "============================================"
npx broken-link-checker http://localhost:$PORT --recursive --verbose 2>&1

echo ""
echo "Encerrando servidor..."
kill $SERVER_PID 2>/dev/null
