# 🏫 Ostad Student Result Management System – DevOps Practice

Hello students!

This project contains the **UI and backend** for a student result management system. Your task is to **set up the backend services (MongoDB, Redis, Mongo Express)**, configure the environment, run seeding, and deploy the backend using PM2.

---

## 1️⃣ Frontend Instructions

**Folder:** `frontend` (React + Tailwind)

1. Install dependencies:

```bash
npm install
```

2. Start development server:

```bash
npm run dev
```

- Runs on port `5173` by default.
- Ensure environment variable is set:

```env
VITE_API_BASE_URL=http://localhost:5050
```

3. Build production version:

```bash
npm run build
```

---

## 2️⃣ Backend Instructions

**Folder:** `server`

1. Environment variables `.env`:

```env
PORT=5050
MONGO_URL=mongodb://ostad:ostad@localhost:27017
REDIS_URL=redis://localhost:6379
DB_NAME=Ostad-DB
CACHE_TTL=600
```

2. Run server with PM2:

```bash
pm2 start server.js --name "ostad-backend"
```

3. Stop / restart server with PM2:

```bash
pm2 stop ostad-backend
pm2 restart ostad-backend
pm2 logs ostad-backend
```

---

## 3️⃣ Database & Caching Services

You need to **set up MongoDB, Redis, and Mongo Express**. Recommended using Docker Compose:

```yaml

      MONGO_INITDB_ROOT_USERNAME: ostad
      MONGO_INITDB_ROOT_PASSWORD: ostad
      MONGO_INITDB_DATABASE: Ostad-DB
    ports:
      - "27017:27017"
  mongo-express:
    environment:
      ME_CONFIG_MONGODB_ADMINUSERNAME: ostad
      ME_CONFIG_MONGODB_ADMINPASSWORD: ostad
      ME_CONFIG_MONGODB_SERVER: mongo
      ME_CONFIG_BASICAUTH_USERNAME: admin
      ME_CONFIG_BASICAUTH_PASSWORD: admin
    ports:
      - "8081:8081"

  redis:
    image: redis:7.0
    ports:
      - "6379:6379"
```

- **Mongo Express Web UI:** [http://localhost:8081](http://localhost:8081)

  - Web login: `admin / admin`
  - Mongo login: `ostad / ostad`

- **Redis:** `localhost:6379`

---

## 4️⃣ Seeding Data

To populate **students and results**:

```bash
node seed.js
```

- Seeds **20,000 students** and **results** in batches.
- Make sure MongoDB is running before seeding.
- After seeding, verify in **Mongo Express**.

---

## 5️⃣ Useful Backend Endpoints

| Endpoint       | Method | Description                  |
| -------------- | ------ | ---------------------------- |
| `/getStudents` | GET    | List all registered students |
| `/addStudent`  | POST   | Add new student              |
| `/result/:id`  | GET    | Fetch result by student ID   |

---

## 6️⃣ Notes for Students

- Frontend calls backend via **`VITE_API_BASE_URL=http://localhost:5050`**
- Backend caching is handled with Redis (`CACHE_TTL=600`)
- Use **PM2** to keep backend running in production
- MongoDB and Redis can be **Dockerized** or installed locally
- Mongo Express is optional but useful for verifying data

---

## 7️⃣ Recommended Commands

| Task                                       | Command                                      |
| ------------------------------------------ | -------------------------------------------- |
| Start frontend                             | `npm run dev`                                |
| Build frontend                             | `npm run build`                              |
| Install backend deps                       | `npm install`                                |
| Run backend via PM2                        | `pm2 start server.js --name "ostad-backend"` |
| Seed database                              | `node seed.js`                               |
| Stop backend                               | `pm2 stop ostad-backend`                     |
| View backend logs                          | `pm2 logs ostad-backend`                     |
| Start services (Mongo/Redis/Mongo Express) | `docker-compose up -d`                       |

---

This README is **ready for DevOps students** to practice: **environment configuration, Docker setup, seeding, PM2 process management, and running the full stack**.
