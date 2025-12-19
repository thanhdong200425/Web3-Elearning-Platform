# 📦 Hướng Dẫn Tách Project: Frontend & Blockchain

## 🎯 Mục Đích

Tách project hiện tại thành 2 project độc lập:
- **Frontend**: Web3-Elearning-Platform-Frontend (chỉ UI)
- **Blockchain**: Web3-Elearning-Platform-Contracts (smart contracts)

---

## 📋 Bước 1: Tạo Project Blockchain Mới

### 1.1. Tạo folder mới
```bash
# Tại thư mục d:\
mkdir Web3-Elearning-Platform-Contracts
cd Web3-Elearning-Platform-Contracts
```

### 1.2. Di chuyển các files/folders sau

#### **Files & Folders CẦN DI CHUYỂN** ✅

Di chuyển từ `Web3-Elearning-Platform-Frontend` sang `Web3-Elearning-Platform-Contracts`:

```
📁 contracts/                          → Di chuyển TOÀN BỘ
   ├── ElearningPlatform.sol
   └── MockCertificateNFT.sol

📁 scripts/                            → Di chuyển TOÀN BỘ
   ├── deploy.cjs
   └── deploy-mock-certificate.cjs

📁 artifacts/                          → Di chuyển TOÀN BỘ (hoặc xóa, sẽ tự generate lại)

📁 cache/                              → Di chuyển TOÀN BỘ (hoặc xóa, sẽ tự generate lại)

📄 hardhat.config.js                   → Di chuyển
📄 hardhat.config.cjs                  → Di chuyển
📄 HARDHAT_DEPLOY_GUIDE.md             → Di chuyển
📄 .env                                → SAO CHÉP (không di chuyển, cần ở cả 2 project)
```

#### **Files GIỮ LẠI ở Frontend** ❌ (KHÔNG di chuyển)

```
📁 src/                                → GIỮ LẠI
📁 public/                             → GIỮ LẠI
📄 index.html                          → GIỮ LẠI
📄 package.json                        → GIỮ LẠI (sẽ cleanup sau)
📄 vite.config.ts                      → GIỮ LẠI
📄 tsconfig.json                       → GIỮ LẠI
📄 tailwind.config.js                  → GIỮ LẠI
📄 postcss.config.js                   → GIỮ LẠI
📄 vercel.json                         → GIỮ LẠI
📄 .gitignore                          → GIỮ LẠI
📄 README.md                           → GIỮ LẠI
```

---

## 🔧 Bước 2: Setup Project Blockchain

### 2.1. Tạo package.json cho Blockchain Project

Tại folder `Web3-Elearning-Platform-Contracts`, tạo file `package.json`:

```json
{
  "name": "web3-elearning-contracts",
  "version": "1.0.0",
  "description": "Smart contracts for Web3 E-Learning Platform",
  "type": "commonjs",
  "scripts": {
    "compile": "hardhat compile",
    "test": "hardhat test",
    "node": "hardhat node",
    "deploy:local": "hardhat run scripts/deploy.cjs --network localhost",
    "deploy:sepolia": "hardhat run scripts/deploy.cjs --network sepolia",
    "deploy:mock": "hardhat run scripts/deploy-mock-certificate.cjs --network sepolia",
    "clean": "hardhat clean"
  },
  "devDependencies": {
    "@nomicfoundation/hardhat-toolbox": "^6.1.0",
    "hardhat": "^2.22.0",
    "dotenv": "^17.2.3"
  }
}
```

### 2.2. Install dependencies

```bash
npm install
```

### 2.3. Tạo .gitignore

Tạo file `.gitignore` trong `Web3-Elearning-Platform-Contracts`:

```
node_modules
.env
coverage
coverage.json
typechain
typechain-types

# Hardhat files
cache
artifacts
```

### 2.4. Tạo README.md

Tạo file `README.md` trong `Web3-Elearning-Platform-Contracts`:

```markdown
# Web3 E-Learning Platform - Smart Contracts

Smart contracts for the Web3 E-Learning Platform.

## Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Copy `.env.example` to `.env` and fill in your values:
   ```bash
   cp .env.example .env
   ```

## Commands

- `npm run compile` - Compile contracts
- `npm test` - Run tests
- `npm run node` - Start local Hardhat node
- `npm run deploy:local` - Deploy to local network
- `npm run deploy:sepolia` - Deploy to Sepolia testnet

## Contracts

- **ElearningPlatform.sol** - Main platform contract
- **MockCertificateNFT.sol** - Certificate NFT contract
```

---

## 🧹 Bước 3: Cleanup Frontend Project

### 3.1. Xóa files blockchain không cần thiết

Trong `Web3-Elearning-Platform-Frontend`, xóa các files/folders sau:

```bash
# Xóa sau khi đã di chuyển
rm -rf contracts
rm -rf scripts
rm -rf artifacts
rm -rf cache
rm hardhat.config.js
rm hardhat.config.cjs
rm HARDHAT_DEPLOY_GUIDE.md
```

### 3.2. Cleanup package.json

Mở `Web3-Elearning-Platform-Frontend/package.json` và:

#### **XÓA các scripts blockchain:**
```json
// XÓA những dòng này trong "scripts":
"compile": "hardhat compile --config hardhat.config.cjs",
"deploy:sepolia": "hardhat run scripts/deploy.cjs --network sepolia --config hardhat.config.cjs",
"deploy:mock": "hardhat run scripts/deploy-mock-certificate.cjs --network sepolia --config hardhat.config.cjs",
"node": "hardhat node --config hardhat.config.cjs",
"test": "hardhat test --config hardhat.config.cjs"
```

#### **XÓA các devDependencies blockchain:**
```json
// XÓA những dependencies này trong "devDependencies":
"@nomicfoundation/hardhat-toolbox": "^6.1.0",
"hardhat": "^2.22.0"
```

> **Lưu ý:** GIỮ LẠI `viem`, `wagmi`, `@tanstack/react-query` vì frontend cần để tương tác với blockchain.

### 3.3. Cleanup node_modules

```bash
# Tại Web3-Elearning-Platform-Frontend
npm install
```

---

## 🔗 Bước 4: Kết Nối Frontend với Contracts

### 4.1. Deploy contracts

Từ `Web3-Elearning-Platform-Contracts`:

```bash
# Deploy to Sepolia
npm run deploy:sepolia
```

Sau khi deploy, bạn sẽ nhận được **contract addresses**. Ví dụ:
```
ElearningPlatform deployed to: 0x1234567890123456789012345678901234567890
MockCertificateNFT deployed to: 0x0987654321098765432109876543210987654321
```

### 4.2. Cập nhật contract addresses vào Frontend

Trong `Web3-Elearning-Platform-Frontend`, tạo/cập nhật file cấu hình contract:

**Cách 1: Sử dụng biến môi trường (.env)**

```env
VITE_ELEARNING_CONTRACT_ADDRESS=0x1234567890123456789012345678901234567890
VITE_CERTIFICATE_NFT_ADDRESS=0x0987654321098765432109876543210987654321
VITE_NETWORK_ID=11155111
```

**Cách 2: File config (src/config/contracts.ts)**

```typescript
export const CONTRACTS = {
  sepolia: {
    elearningPlatform: '0x1234567890123456789012345678901234567890',
    certificateNFT: '0x0987654321098765432109876543210987654321',
  },
  // Thêm các network khác nếu cần
};
```

### 4.3. Copy ABI files

Sau khi compile contracts, copy ABI files từ blockchain project sang frontend:

```bash
# Copy từ Web3-Elearning-Platform-Contracts
# Đến Web3-Elearning-Platform-Frontend/src/abi/

# Ví dụ:
cp artifacts/contracts/ElearningPlatform.sol/ElearningPlatform.json ../Web3-Elearning-Platform-Frontend/src/abi/
cp artifacts/contracts/MockCertificateNFT.sol/MockCertificateNFT.json ../Web3-Elearning-Platform-Frontend/src/abi/
```

---

## 📂 Cấu Trúc Cuối Cùng

```
d:\
├── Web3-Elearning-Platform-Frontend/
│   ├── src/
│   │   ├── abi/                          # Contract ABIs (copy từ blockchain project)
│   │   ├── components/
│   │   ├── config/
│   │   │   └── contracts.ts              # Contract addresses
│   │   └── ...
│   ├── public/
│   ├── .env                               # Frontend env vars
│   ├── package.json                       # Chỉ frontend dependencies
│   ├── vite.config.ts
│   └── ...
│
└── Web3-Elearning-Platform-Contracts/
    ├── contracts/
    │   ├── ElearningPlatform.sol
    │   └── MockCertificateNFT.sol
    ├── scripts/
    │   ├── deploy.cjs
    │   └── deploy-mock-certificate.cjs
    ├── test/                              # (tạo sau nếu cần)
    ├── artifacts/                         # (auto-generated)
    ├── cache/                             # (auto-generated)
    ├── .env                               # Blockchain env vars
    ├── hardhat.config.js
    ├── package.json                       # Chỉ blockchain dependencies
    └── README.md
```

---

## ✅ Checklist Hoàn Thành

Sau khi làm theo hướng dẫn, kiểm tra:

### Blockchain Project
- [ ] Đã tạo folder `Web3-Elearning-Platform-Contracts`
- [ ] Di chuyển contracts/, scripts/, hardhat.config
- [ ] Tạo package.json riêng
- [ ] `npm install` thành công
- [ ] `npm run compile` thành công
- [ ] Deploy contracts thành công

### Frontend Project
- [ ] Xóa files blockchain (contracts/, scripts/, hardhat.config)
- [ ] Cleanup package.json (xóa hardhat scripts + dependencies)
- [ ] `npm install` thành công
- [ ] Copy ABI files vào src/abi/
- [ ] Cập nhật contract addresses
- [ ] `npm run dev` chạy thành công

---

## 🚀 Workflow Làm Việc Mới

### Khi thay đổi Smart Contracts:

1. Sửa code trong `Web3-Elearning-Platform-Contracts/contracts/`
2. Compile: `npm run compile`
3. Test: `npm test`
4. Deploy: `npm run deploy:sepolia`
5. Copy ABI mới sang frontend
6. Cập nhật contract address (nếu deploy mới)

### Khi phát triển Frontend:

1. Làm việc trong `Web3-Elearning-Platform-Frontend/`
2. Import ABI từ `src/abi/`
3. Sử dụng contract addresses từ config
4. Tương tác qua `wagmi` và `viem`

---

## 💡 Tips

1. **Git riêng biệt**: Tạo 2 repos riêng cho 2 projects
2. **Deploy độc lập**: Frontend lên Vercel, contracts có thể verify trên Etherscan
3. **Environment variables**: Mỗi project có .env riêng
4. **ABI sync**: Có thể dùng script để tự động copy ABI sau mỗi lần compile

---

## 🆘 Troubleshooting

**Q: Frontend không connect được với contract?**
- Kiểm tra contract address có đúng không
- Kiểm tra network ID (Sepolia = 11155111)
- Kiểm tra ABI đã được copy chưa

**Q: Hardhat compile lỗi sau khi tách?**
- Chạy `npm install` lại trong blockchain project
- Kiểm tra hardhat.config đã di chuyển đúng chưa

**Q: Frontend build lỗi sau khi xóa hardhat?**
- Chạy `npm install` để cleanup dependencies
- Kiểm tra package.json đã xóa hết hardhat scripts chưa
