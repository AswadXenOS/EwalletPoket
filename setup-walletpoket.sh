#!/data/data/com.termux/files/usr/bin/bash
 
# ===============================================
 
# 🚀 EwalletPoket Auto Setup (Penuh & Lengkap)
 
# ===============================================
 
# [1] Konfigurasi Asas
 
export PROJECT="EwalletPoket" export GITHUB_USERNAME="AswadXenOS" export GITHUB_TOKEN="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" export DB_FILE="shared/ewallet.db"
 
# [2] Cipta folder & klon repo
 
cd $HOME rm -rf $PROJECT mkdir -p $PROJECT && cd $PROJECT
 
git init GIT_REPO="[https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$PROJECT.git](https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$PROJECT.git)" git remote add origin $GIT_REPO
 
# [3] Struktur direktori utama
 
mkdir -p auth-service/src/{controllers,models,middleware,routes} mkdir -p user-service/src/{controllers,models,routes} mkdir -p wallet-service/src/{controllers,models,routes} mkdir -p shared frontend/src/pages telegram-bot scripts
 
touch shared/db.js shared/verifyToken.js
 
# [4] Fail utama
 
cat > auth-service/server.js <<'EOF' const express = require('express'); const cors = require('cors'); const jwt = require('jsonwebtoken'); const bcrypt = require('bcryptjs'); const app = express(); app.use(cors()); app.use(express.json()); const users = [{ username: 'aswad', password: bcrypt.hashSync('aswad123'), wallet: 1000 }];
 
app.post('/auth/login', (req, res) => { const { username, password } = req.body; const user = users.find(u => u.username === username); if (user && bcrypt.compareSync(password, user.password)) { const token = jwt.sign({ username }, 'secret'); return res.json({ token }); } res.status(401).json({ error: 'Invalid credentials' }); });
 
app.listen(3000, () => console.log('🔐 Auth running on 3000')); EOF
 
cat > user-service/server.js <<'EOF' const express = require('express'); const cors = require('cors'); const app = express(); app.use(cors()); app.use(express.json()); const users = [{ username: 'aswad', wallet: 1000 }];
 
app.get('/users', (req, res) => { res.json(users); });
 
app.listen(3001, () => console.log('👤 User running on 3001')); EOF
 
cat > wallet-service/server.js <<'EOF' const express = require('express'); const cors = require('cors'); const app = express(); app.use(cors()); app.use(express.json()); const users = [{ username: 'aswad', wallet: 1000 }];
 
app.post('/wallet/transfer', (req, res) => { const { to, amount } = req.body; const sender = users.find(u => u.username === 'aswad'); const receiver = users.find(u => u.username === to); if (sender.wallet >= amount && receiver) { sender.wallet -= amount; receiver.wallet += amount; return res.json({ message: 'Transfer berjaya' }); } res.status(400).json({ message: 'Gagal transfer' }); });
 
app.listen(3002, () => console.log('💰 Wallet running on 3002')); EOF
 
# [5] Frontend setup (React + QR Pay)
 
cd $HOME/$PROJECT/frontend npm create vite@latest . -- --template react --force npm install --legacy-peer-deps npm install axios react-router-dom qrcode.react
 
cat > src/index.css <<'EOF' body { font-family: sans-serif; margin: 0; background: #f1f5f9; } input, button { width: 100%; margin: 0.5rem 0; padding: 0.6rem; border-radius: 6px; border: 1px solid #ccc; } button { background: #007bff; color: white; font-weight: bold; cursor: pointer; } EOF
 
cat > src/main.jsx <<'EOF' import React from 'react'; import ReactDOM from 'react-dom/client'; import { BrowserRouter, Routes, Route } from 'react-router-dom'; import LoginPage from './pages/LoginPage'; import DashboardPage from './pages/DashboardPage'; import './index.css';
 
ReactDOM.createRoot(document.getElementById('root')).render(       ); EOF
 
cat > src/pages/LoginPage.jsx <<'EOF' import React, { useState } from 'react'; import { useNavigate } from 'react-router-dom';
 
export default function LoginPage() { const [username, setUsername] = useState(''); const [password, setPassword] = useState(''); const navigate = useNavigate();
 
const login = async () => { const res = await fetch('[http://localhost:3000/auth/login](http://localhost:3000/auth/login)', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ username, password }) }); if (res.ok) { const data = await res.json(); localStorage.setItem('token', data.token); localStorage.setItem('username', username); navigate('/dashboard'); } else alert('Login gagal'); };
 
return (
 
## Login
 
<input placeholder="Username" onChange={e => setUsername(e.target.value)} /> <input placeholder="Password" onChange={e => setPassword(e.target.value)} /> Login ); } EOF
 
cat > src/pages/DashboardPage.jsx <<'EOF' import React, { useEffect, useState } from 'react'; import QRCode from 'qrcode.react';
 
export default function DashboardPage() { const [user, setUser] = useState(null); const [to, setTo] = useState(''); const [amount, setAmount] = useState(''); const token = localStorage.getItem('token');
 
const fetchUser = async () => { const res = await fetch('[http://localhost:3001/users](http://localhost:3001/users)'); const data = await res.json(); const username = localStorage.getItem('username'); setUser(data.find(u => u.username === username)); };
 
const transfer = async () => { const res = await fetch('[http://localhost:3002/wallet/transfer](http://localhost:3002/wallet/transfer)', { method: 'POST', headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` }, body: JSON.stringify({ to, amount: Number(amount) }) }); const data = await res.json(); alert(data.message); fetchUser(); };
 
useEffect(() => { if (token) fetchUser(); }, []);
 
return (
 
## Welcome {user?.username}
 
Wallet: RM {user?.wallet} <QRCode value={user?.username || ''} />
 
### Transfer Duit
 
<input placeholder="Kepada (username)" onChange={e => setTo(e.target.value)} /> <input placeholder="Jumlah RM" type="number" onChange={e => setAmount(e.target.value)} /> Transfer ); } EOF
 
# [6] Jalankan semua servis
 
cd $HOME/$PROJECT termux-open-url "[http://localhost:5173](http://localhost:5173)"
 
pm2 start auth-service/server.js --name auth -f pm2 start user-service/server.js --name user -f pm2 start wallet-service/server.js --name wallet -f cd frontend && pm2 start npm -- run dev --name frontend -f
 
# [7] Git push ke repo
 
cd $HOME/$PROJECT git add . git commit -m "🚀 Init full EwalletPoket setup" git branch -M main git push -f -u origin main
 
termux-notification --title "✅ Setup Siap" --content "Buka frontend di browser: [http://localhost:5173](http://localhost:5173)" echo "🎉 SEMUA SELESAI. UI: [http://localhost:5173](http://localhost:5173)" #!/data/data/com.termux/files/usr/bin/bash
 
# =====================================================
 
# 🚀 EwalletPoket Auto Setup (Penuh & Lengkap)
 
# =====================================================
 
# [1] Konfigurasi Asas
 
export PROJECT="EwalletPoket" export GITHUB_USERNAME="AswadXenOS" export GITHUB_TOKEN="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" export DB_FILE="shared/ewallet.db"
 
# [2] Cipta folder & klon repo
 
cd $HOME rm -rf $PROJECT mkdir -p $PROJECT && cd $PROJECT
 
git init GIT_REPO="[https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$PROJECT.git](https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$PROJECT.git)" git remote add origin $GIT_REPO
 
# [3] Struktur direktori utama
 
mkdir -p auth-service/src/{controllers,models,middleware,routes} mkdir -p user-service/src/{controllers,models,routes} mkdir -p wallet-service/src/{controllers,models,routes} mkdir -p shared frontend/src/{pages,components,styles} mkdir -p telegram-bot scripts
 
touch shared/db.js shared/verifyToken.js
 
# [4] Fail utama: Backend minimal
 
cat > auth-service/server.js <<'EOF' const express = require('express'); const cors = require('cors'); const jwt = require('jsonwebtoken'); const bcrypt = require('bcryptjs');
 
const app = express(); app.use(cors()); app.use(express.json());
 
const users = [{ username: 'aswad', password: bcrypt.hashSync('aswad123'), wallet: 1000 }];
 
app.post('/auth/login', (req, res) => { const { username, password } = req.body; const user = users.find(u => u.username === username); if (user && bcrypt.compareSync(password, user.password)) { const token = jwt.sign({ username }, 'secret'); return res.json({ token }); } res.status(401).json({ error: 'Invalid credentials' }); });
 
app.listen(3000, () => console.log('🔐 Auth running on 3000')); EOF
 
cat > user-service/server.js <<'EOF' const express = require('express'); const cors = require('cors'); const app = express(); app.use(cors()); app.use(express.json());
 
const users = [{ username: 'aswad', wallet: 1000 }];
 
app.get('/users', (req, res) => { res.json(users); });
 
app.listen(3001, () => console.log('👤 User running on 3001')); EOF
 
cat > wallet-service/server.js <<'EOF' const express = require('express'); const cors = require('cors'); const app = express(); app.use(cors()); app.use(express.json());
 
const users = [{ username: 'aswad', wallet: 1000 }, { username: 'x', wallet: 100 }];
 
app.post('/wallet/transfer', (req, res) => { const { to, amount } = req.body; const sender = users.find(u => u.username === 'aswad'); const receiver = users.find(u => u.username === to); if (sender.wallet >= amount && receiver) { sender.wallet -= amount; receiver.wallet += amount; return res.json({ message: 'Transfer berjaya' }); } res.status(400).json({ message: 'Gagal transfer' }); });
 
app.listen(3002, () => console.log('💰 Wallet running on 3002')); EOF
 
# [5] Frontend setup (React + Vite + QR)
 
cd $HOME/$PROJECT/frontend npm create vite@latest . -- --template react --force npm install --legacy-peer-deps npm install axios react-router-dom qrcode.react
 
cat > src/index.css <<'EOF' body { font-family: sans-serif; margin: 0; background: #f1f5f9; } input, button { width: 100%; margin: 0.5rem 0; padding: 0.6rem; border-radius: 6px; border: 1px solid #ccc; } button { background: #007bff; color: white; font-weight: bold; cursor: pointer; } EOF
 
cat > src/main.jsx <<'EOF' import React from 'react'; import ReactDOM from 'react-dom/client'; import { BrowserRouter, Routes, Route } from 'react-router-dom'; import LoginPage from './pages/LoginPage'; import DashboardPage from './pages/DashboardPage'; import './index.css';
 
ReactDOM.createRoot(document.getElementById('root')).render(   <Route path="/" element={} /> <Route path="/dashboard" element={} />   ); EOF
 
cat > src/pages/LoginPage.jsx <<'EOF' import React, { useState } from 'react'; import { useNavigate } from 'react-router-dom';
 
export default function LoginPage() { const [username, setUsername] = useState(''); const [password, setPassword] = useState(''); const navigate = useNavigate();
 
const login = async () => { const res = await fetch('[http://localhost:3000/auth/login](http://localhost:3000/auth/login)', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ username, password }), }); if (res.ok) { const data = await res.json(); localStorage.setItem('token', data.token); localStorage.setItem('username', username); navigate('/dashboard'); } else alert('Login gagal'); };
 
return ( <> 
## Login
 <input placeholder="Username" onChange={e => setUsername(e.target.value)} /> <input placeholder="Password" onChange={e => setPassword(e.target.value)} type="password" /> Login </> ); } EOF
 
cat > src/pages/DashboardPage.jsx <<'EOF' import React, { useEffect, useState } from 'react'; import QRCode from 'qrcode.react';
 
export default function DashboardPage() { const [user, setUser] = useState(null); const [to, setTo] = useState(''); const [amount, setAmount] = useState(''); const token = localStorage.getItem('token');
 
const fetchUser = async () => { const res = await fetch('[http://localhost:3001/users](http://localhost:3001/users)'); const data = await res.json(); const username = localStorage.getItem('username'); setUser(data.find(u => u.username === username)); };
 
const transfer = async () => { const res = await fetch('[http://localhost:3002/wallet/transfer](http://localhost:3002/wallet/transfer)', { method: 'POST', headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}`, }, body: JSON.stringify({ to, amount: Number(amount) }), }); const data = await res.json(); alert(data.message); fetchUser(); };
 
useEffect(() => { if (token) fetchUser(); }, []);
 
return ( <> 
## Welcome {user?.username}
 
Wallet: RM {user?.wallet}
 <QRCode value={user?.username || ''} /> 
### Transfer Duit
 <input placeholder="Kepada (username)" onChange={e => setTo(e.target.value)} /> <input placeholder="Jumlah RM" type="number" onChange={e => setAmount(e.target.value)} /> Transfer </> ); } EOF
 
# [6] Jalankan semua servis
 
cd $HOME/$PROJECT
 
pm2 start auth-service/server.js --name auth -f pm2 start user-service/server.js --name user -f pm2 start wallet-service/server.js --name wallet -f cd frontend && pm2 start npm -- run dev --name frontend -f
 
# [7] Git push ke repo
 
cd $HOME/$PROJECT git add . git commit -m "🚀 Init full EwalletPoket setup" git branch -M main git push -f -u origin main
 
# [8] Notifikasi
 
termux-notification --title "✅ Setup Siap" --content "Buka frontend di browser: [http://localhost:5173](http://localhost:5173)" echo "🎉 SEMUA SELESAI. UI: [http://localhost:5173](http://localhost:5173)"
