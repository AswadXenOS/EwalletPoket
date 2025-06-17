#!/data/data/com.termux/files/usr/bin/bash

==================================================

🚀 FINAL AUTO-SETUP SCRIPT: EwalletPoket SUPER ✅

==================================================

--- [1] Konfigurasi Global ---

REPO_NAME="EwalletPoket" GITHUB_USERNAME="AswadXenOS" GITHUB_TOKEN="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" PROJECT_DIR="$HOME/$REPO_NAME" BOT_TOKEN="7731637512:AAG6MnAuHWkSQjvIQ3XQpKuS_k5fy8vAgt8"

--- [2] Keperluan Termux ---

pkg update -y && pkg upgrade -y pkg install -y git nodejs nano termux-api python npm i -g pm2

--- [3] Cipta Projek & Direktori ---

rm -rf $PROJECT_DIR mkdir -p $PROJECT_DIR/{backend,cli,frontend/public,frontend/src/{pages,components},logs,telegram-bot,plugins} cd $PROJECT_DIR

--- [4] Fail .env & .gitignore ---

echo "PORT=3000 JWT_SECRET=aswad-ewallet-secret ADMIN_USERNAME=aswad ADMIN_PASSWORD=aswad123 TELEGRAM_BOT_TOKEN=$BOT_TOKEN" > .env

echo "node_modules/ .env logs/" > .gitignore

--- [5] Backend API ---

cat > backend/server.js <<'EOF' // Express backend: server.js const express = require('express'); const cors = require('cors'); const dotenv = require('dotenv'); const jwt = require('jsonwebtoken'); const fs = require('fs'); const bcrypt = require('bcryptjs'); dotenv.config();

const app = express(); app.use(cors()); app.use(express.json());

const USERS_FILE = './backend/users.json'; const LOG_FILE = './logs/audit.log';

function readUsers() { return JSON.parse(fs.readFileSync(USERS_FILE)); }

function writeUsers(users) { fs.writeFileSync(USERS_FILE, JSON.stringify(users, null, 2)); }

function logAction(action) { const logs = JSON.parse(fs.readFileSync(LOG_FILE)); logs.push({ action, time: new Date().toISOString() }); fs.writeFileSync(LOG_FILE, JSON.stringify(logs, null, 2)); }

function verifyToken(req, res, next) { const auth = req.headers.authorization; if (!auth) return res.status(401).json({ message: 'Token required' }); try { const decoded = jwt.verify(auth.split(' ')[1], process.env.JWT_SECRET); req.user = decoded; next(); } catch { return res.status(403).json({ message: 'Invalid token' }); } }

app.post('/auth/register', (req, res) => { const { username, password } = req.body; const users = readUsers(); if (users.find(u => u.username === username)) { return res.status(400).json({ message: 'User exists' }); } const hashed = bcrypt.hashSync(password, 8); users.push({ username, password: hashed, wallet: 100 }); writeUsers(users); logAction(Register: ${username}); res.json({ message: 'Registered' }); });

app.post('/auth/login', (req, res) => { const { username, password } = req.body; const users = readUsers(); const user = users.find(u => u.username === username); if (!user || !bcrypt.compareSync(password, user.password)) { return res.status(401).json({ message: 'Login failed' }); } const token = jwt.sign({ username }, process.env.JWT_SECRET); logAction(Login: ${username}); res.json({ token }); });

app.post('/wallet/transfer', verifyToken, (req, res) => { const { to, amount } = req.body; const users = readUsers(); const sender = users.find(u => u.username === req.user.username); const receiver = users.find(u => u.username === to);

if (!receiver) return res.status(404).json({ message: 'Receiver not found' }); if (sender.wallet < amount) return res.status(400).json({ message: 'Insufficient balance' });

sender.wallet -= amount; receiver.wallet += amount; writeUsers(users); logAction(Transfer ${amount} from ${sender.username} to ${receiver.username}); res.json({ message: 'Transferred', from: sender.username, to: receiver.username, amount }); });

app.get('/users', verifyToken, (req, res) => { const users = readUsers().map(u => ({ username: u.username, wallet: u.wallet })); res.json(users); });

app.listen(process.env.PORT, () => console.log(🚀 API listening on port ${process.env.PORT})); EOF

--- [6] Dummy Users & Log ---

echo '[{"username":"aswad","password":"$2a$08$aswad","wallet":1000}]' > backend/users.json echo '[]' > logs/audit.log

--- [7] Telegram Bot ---

cat > telegram-bot/bot.js <<EOF require('dotenv').config(); const TelegramBot = require('node-telegram-bot-api'); const fs = require('fs');

const bot = new TelegramBot(process.env.TELEGRAM_BOT_TOKEN, { polling: true });

bot.onText(//wallet/, (msg) => { const userId = msg.from.username || msg.from.first_name; const users = JSON.parse(fs.readFileSync('./backend/users.json')); const user = users.find(u => u.username === userId); if (user) { bot.sendMessage(msg.chat.id, 💰 Wallet ${user.username}: RM${user.wallet}); } else { bot.sendMessage(msg.chat.id, ❌ Akaun ${userId} tiada dalam sistem.); } }); EOF

--- [8] CLI SuperAdmin ---

cat > cli/superadmin-cli.js <<EOF #!/usr/bin/env node console.log("🛠️ Superadmin CLI ready. Tambah command di sini."); EOF chmod +x cli/superadmin-cli.js

--- [9] package.json & Install ---

cat > package.json <<EOF { "name": "$REPO_NAME", "version": "1.0.0", "main": "backend/server.js", "scripts": { "start": "node backend/server.js", "bot": "node telegram-bot/bot.js", "cli": "node cli/superadmin-cli.js" }, "dependencies": { "express": "^4.18.2", "cors": "^2.8.5", "dotenv": "^16.3.1", "jsonwebtoken": "^9.0.2", "bcryptjs": "^2.4.3", "node-telegram-bot-api": "^0.61.0" } } EOF npm install

--- [10] start.sh & Shortcut ---

cat > start.sh <<EOF #!/data/data/com.termux/files/usr/bin/bash pm2 start backend/server.js --name api -f pm2 start telegram-bot/bot.js --name bot -f pm2 save EOF chmod +x start.sh

mkdir -p ~/.shortcuts ln -sf $PROJECT_DIR/start.sh ~/.shortcuts/EwalletStart termux-reload-settings

--- [11] GitHub Push ---

git init git config user.name "$GITHUB_USERNAME" git config user.email "aswad@example.com" git remote add origin https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$REPO_NAME.git git add . git commit -m "🚀 Auto init EwalletPoket" git branch -M main git push -u origin main

--- [12] Run All ---

bash start.sh sleep 2 curl -s http://localhost:3000 && echo "✅ API READY"

--- [13] Notifikasi ---

termux-notification --title "✅ Siap EwalletPoket" --content "Sistem ewallet siap 100%" || echo "🔔 Notification not supported"

✅ Done!

echo "🟢 SIAP! Cuba login dengan:" echo 'curl -X POST http://localhost:3000/auth/login -H "Content-Type: application/json" -d '{"username":"aswad","password":"aswad123"}'


#!/data/data/com.termux/files/usr/bin/bash
# ================================================
# 🚀 FINAL AUTO-SETUP SCRIPT: EwalletPoket SUPER ✅
# ================================================

REPO_NAME="EwalletPoket"
GITHUB_USERNAME="AswadXenOS"
GITHUB_TOKEN="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"
PROJECT_DIR="$HOME/$REPO_NAME"
BOT_TOKEN="7731637512:AAG6MnAuHWkSQjvIQ3XQpKuS_k5fy8vAgt8"

# [1] Install keperluan
pkg update -y && pkg upgrade -y
pkg install -y git nodejs nano openssh termux-api jq
npm i -g pm2

# [2] Struktur projek
mkdir -p $PROJECT_DIR/{backend/{routes,controllers,models,middleware},frontend,cli,telegram-bot,logs,plugins}
cd $PROJECT_DIR

# [3] Config .env & .gitignore
echo "PORT=3000
JWT_SECRET=aswad-ewallet-secret
ADMIN_USERNAME=aswad
ADMIN_PASSWORD=aswad123
TELEGRAM_BOT_TOKEN=$BOT_TOKEN" > .env
echo "node_modules/
.env
logs/" > .gitignore

# [4] Backend API
cat > backend/server.js <<'EOF'
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const jwt = require('jsonwebtoken');
const fs = require('fs');
const bcrypt = require('bcryptjs');
dotenv.config();
const app = express();
app.use(cors());
app.use(express.json());

const USERS_FILE = './backend/users.json';
const LOG_FILE = './logs/audit.log';

function readUsers() {
  return JSON.parse(fs.readFileSync(USERS_FILE));
}
function writeUsers(users) {
  fs.writeFileSync(USERS_FILE, JSON.stringify(users, null, 2));
}
function logAction(action) {
  const logs = JSON.parse(fs.readFileSync(LOG_FILE));
  logs.push({ action, time: new Date().toISOString() });
  fs.writeFileSync(LOG_FILE, JSON.stringify(logs, null, 2));
}
function verifyToken(req, res, next) {
  const auth = req.headers.authorization;
  if (!auth) return res.status(401).json({ message: 'Token required' });
  try {
    const decoded = jwt.verify(auth.split(' ')[1], process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch {
    return res.status(403).json({ message: 'Invalid token' });
  }
}

app.post('/auth/register', (req, res) => {
  const { username, password } = req.body;
  const users = readUsers();
  if (users.find(u => u.username === username)) {
    return res.status(400).json({ message: 'User exists' });
  }
  const hashed = bcrypt.hashSync(password, 8);
  users.push({ username, password: hashed, wallet: 100 });
  writeUsers(users);
  logAction(`Register: ${username}`);
  res.json({ message: 'Registered' });
});

app.post('/auth/login', (req, res) => {
  const { username, password } = req.body;
  const users = readUsers();
  const user = users.find(u => u.username === username);
  if (!user || !bcrypt.compareSync(password, user.password)) {
    return res.status(401).json({ message: 'Login failed' });
  }
  const token = jwt.sign({ username }, process.env.JWT_SECRET);
  logAction(`Login: ${username}`);
  res.json({ token });
});

app.post('/wallet/transfer', verifyToken, (req, res) => {
  const { to, amount } = req.body;
  const users = readUsers();
  const sender = users.find(u => u.username === req.user.username);
  const receiver = users.find(u => u.username === to);
  if (!receiver) return res.status(404).json({ message: 'Receiver not found' });
  if (sender.wallet < amount) return res.status(400).json({ message: 'Insufficient balance' });
  sender.wallet -= amount;
  receiver.wallet += amount;
  writeUsers(users);
  logAction(`Transfer ${amount} from ${sender.username} to ${receiver.username}`);
  res.json({ message: 'Transferred', from: sender.username, to: receiver.username, amount });
});

app.get('/users', verifyToken, (req, res) => {
  const users = readUsers().map(u => ({ username: u.username, wallet: u.wallet }));
  res.json(users);
});

app.get('/', (req, res) => res.send('✅ EwalletPoket API OK'));
app.listen(process.env.PORT, () => console.log(`🚀 Server running on port ${process.env.PORT}`));
EOF

# [5] Dummy Users & Log
echo '[]' > logs/audit.log
echo '[{"username":"aswad","password":"$2a$08$aswad","wallet":1000}]' > backend/users.json

# [6] Telegram Bot
cat > telegram-bot/bot.js <<EOF
require('dotenv').config();
const TelegramBot = require('node-telegram-bot-api');
const fs = require('fs');
const bot = new TelegramBot(process.env.TELEGRAM_BOT_TOKEN, { polling: true });

bot.onText(/\/wallet/, (msg) => {
  const userId = msg.from.username || msg.from.first_name;
  const users = JSON.parse(fs.readFileSync('./backend/users.json'));
  const user = users.find(u => u.username === userId);
  if (user) {
    bot.sendMessage(msg.chat.id, \`💰 Wallet \${user.username}: RM\${user.wallet}\`);
  } else {
    bot.sendMessage(msg.chat.id, \`❌ Akaun \${userId} tiada dalam sistem.\`);
  }
});
EOF

# [7] CLI Placeholder
echo '#!/usr/bin/env node
console.log("🛠️ Superadmin CLI ready. Tambah command di sini.");' > cli/superadmin-cli.js
chmod +x cli/superadmin-cli.js

# [8] package.json + install
cat > package.json <<EOF
{
  "name": "$REPO_NAME",
  "version": "1.0.0",
  "main": "backend/server.js",
  "scripts": {
    "start": "node backend/server.js",
    "bot": "node telegram-bot/bot.js",
    "cli": "node cli/superadmin-cli.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3",
    "node-telegram-bot-api": "^0.61.0"
  }
}
EOF
npm install

# [9] Auto start.sh
echo '#!/data/data/com.termux/files/usr/bin/bash
pm2 start backend/server.js --name api
pm2 start telegram-bot/bot.js --name bot
pm2 save' > start.sh
chmod +x start.sh

mkdir -p ~/.shortcuts
ln -sf $PROJECT_DIR/start.sh ~/.shortcuts/EwalletStart
termux-reload-settings

# [10] GitHub push
git init
git config user.name "$GITHUB_USERNAME"
git config user.email "aswad@example.com"
git remote remove origin 2>/dev/null
git remote add origin https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$REPO_NAME.git
git add .
git commit -m "🚀 Auto init EwalletPoket"
git branch -M main
git push -u origin main

# [11] Run API
bash start.sh
sleep 2
curl -s http://localhost:3000 && echo "✅ API READY"

# [12] Notifikasi
termux-notification --title "✅ EwalletPoket Siap" --content "Sistem EwalletPoket telah siap 100%"

echo "🟢 Login Test:"
echo 'curl -X POST http://localhost:3000/auth/login -H "Content-Type: application/json" -d '\''{"username":"aswad","password":"aswad123"}'\'''
