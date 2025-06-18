#!/data/data/com.termux/files/usr/bin/bash
# ==========================================================
# 🚀 EwalletPoket ULTIMATE PRO V7 - AUTO SETUP 1 PERINTAH
# ==========================================================

set -e

# === [1] Konfigurasi Projek ===
export PROJECT="EwalletPoket"
export REPO_NAME="ewalletpoket-v7"
export GITHUB_USERNAME="AswadXenOS"
export GITHUB_TOKEN="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"
export REPO_AUTH="https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$REPO_NAME.git"
export EMAIL_SENDER="aswadxenist@gmail.com"
export EMAIL_PASS="AswadArmani"
export TELEGRAM_TOKEN="7731637512:AAG6MnAuHWkSQjvIQ3XQpKuS_k5fy8vAgt8"
export TELEGRAM_CHAT_ID="ISI_SENDIRI_NANTI"
export WHATSAPP_NUMBER="60123456789"
export TOYYIBPAY_SECRET_KEY="vu7wytw4-gjvt"
export OPENAI_API_KEY="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"

# === [2] Keperluan Termux ===
echo "📦 Memasang keperluan Termux..."
pkg update -y && pkg install -y git nodejs ffmpeg python tsu
npm i -g nodemon

# === [3] Klon Repo atau Init Baru ===
if [ -d "$PROJECT" ]; then
  echo "📁 Projek sedia ada dijumpai. Masuk ke folder..."
  cd $PROJECT
else
  echo "📁 Klon projek $REPO_NAME dari GitHub..."
  git clone $REPO_AUTH
  cd $REPO_NAME || mkdir $PROJECT && cd $PROJECT
fi

# === [4] Buat Struktur Folder ===
mkdir -p backend/db backend/routes backend/utils frontend/public gpt-cli telegram-bot ~/.shortcuts

# === [5] Fail .env Backend ===
cat > .env <<EOF
TELEGRAM_BOT_TOKEN=$TELEGRAM_TOKEN
TELEGRAM_CHAT_ID=$TELEGRAM_CHAT_ID
WHATSAPP_NUMBER=$WHATSAPP_NUMBER
EMAIL_SENDER=$EMAIL_SENDER
EMAIL_PASSWORD=$EMAIL_PASS
TOYYIBPAY_SECRET_KEY=$TOYYIBPAY_SECRET_KEY
OPENAI_API_KEY=$OPENAI_API_KEY
EOF

# === [6] Fail Database Dummy ===
echo '{}' > backend/db/users.json
echo '{}' > backend/db/wallet.json
echo '[]' > backend/db/transactions.json

# === [7] Fail Utama Backend ===
cat > backend/index.js <<'EOF'
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const fs = require('fs');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(bodyParser.json());

const PORT = 3000;

app.get('/', (req, res) => res.send('✅ EwalletPoket API Online'));

app.use('/api/auth', require('./routes/auth'));
app.use('/api/wallet', require('./routes/wallet'));

app.listen(PORT, () => console.log(`🚀 Server berjalan di http://localhost:${PORT}`));
EOF

# === [8] Pasang Dependencies Backend ===
cd backend
npm init -y
npm install express cors body-parser dotenv bcryptjs node-fetch nodemailer pdfkit
cd ..

# === [9] Fail API Wallet & Auth ===
cat > backend/routes/auth.js <<'EOF'
const express = require('express');
const router = express.Router();
const { logEvent } = require('../utils/audit');

router.post('/login', (req, res) => {
  const { username } = req.body;
  if (username === "superadmin") {
    logEvent('LOGIN_ATTEMPT', username);
    res.json({ status: "otp_sent" });
  } else {
    res.status(401).json({ error: "Unauthorized" });
  }
});

module.exports = router;
EOF

cat > backend/routes/wallet.js <<'EOF'
const express = require('express');
const router = express.Router();
const fs = require('fs');
const db = require('../db/wallet.json');

router.get('/balance/:user', (req, res) => {
  const user = req.params.user;
  const balance = db[user] || 0;
  res.json({ balance });
});

module.exports = router;
EOF

# === [10] GPT CLI Bot ===
cat > gpt-cli/bot.js <<EOF
import readline from 'readline';
import fetch from 'node-fetch';
import dotenv from 'dotenv';
dotenv.config();

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

async function chatWithGPT(prompt) {
  const res = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: \`Bearer \${process.env.OPENAI_API_KEY}\`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      model: 'gpt-4',
      messages: [{ role: 'user', content: prompt }]
    })
  });
  const data = await res.json();
  console.log('🤖:', data.choices[0].message.content);
}

rl.setPrompt('💬 Prompt> ');
rl.prompt();

rl.on('line', async (line) => {
  await chatWithGPT(line.trim());
  rl.prompt();
});
EOF

# === [11] Shortcut GPT dalam Termux ===
cat > ~/.shortcuts/🧠_GPT_Assistant <<EOF
cd ~/$PROJECT/gpt-cli
node bot.js
EOF
chmod +x ~/.shortcuts/🧠_GPT_Assistant

# === [12] Alias CLI & Banner ===
cat >> ~/.bashrc <<'EOF'

# 🏦 EwalletPoket CLI Alias
alias ewpbot='cd ~/EwalletPoket/gpt-cli && node bot.js'
alias ewpstart='cd ~/EwalletPoket/backend && node index.js'

# 🎉 Welcome Banner
echo "======================================="
echo "🚀 Selamat Datang ke EwalletPoket CLI!"
echo "📦 Guna ewpstart untuk mula backend"
echo "🤖 Guna ewpbot untuk bantu GPT Admin"
echo "======================================="
EOF

# === [13] Git Init dan Push ke GitHub ===
echo ".env" >> .gitignore
git init
git remote remove origin 2>/dev/null || true
git remote add origin $REPO_AUTH
git add .
git commit -m "🚀 V7 Auto Setup EwalletPoket Ultimate Pro"
git branch -M main
git push -u origin main --force

# === [14] Tamat ===
echo ""
echo "✅ SETUP LENGKAP EwalletPoket V7 SIAP!"
echo "➡ Mula backend: ewpstart"
echo "➡ GPT bot: ewpbot atau guna Termux Widget"
echo ""
