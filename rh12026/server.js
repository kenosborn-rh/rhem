import express from "express";
import cors from "cors";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
app.use(cors());

const PORT = process.env.PORT || 8081;
const DRONE_ID = process.env.DRONE_ID || "PZ-042";
const ROUTE_NAME = process.env.ROUTE_NAME || "Pepperoni Run";
const START_ETA_SEC = parseInt(process.env.START_ETA_SEC || "300", 10);
const BOOT_EPOCH = Date.now();

// serve static UI
app.use(express.static(path.join(__dirname, "public"), { etag: false, cacheControl: false }));

// health/readiness (nice for RHEM)
app.get("/healthz", (_req, res) => res.status(200).send("ok"));
app.get("/readyz", (_req, res) => res.status(200).send("ready"));

// simple telemetry simulator
app.get("/status", (_req, res) => {
  const uptimeSec = Math.floor((Date.now() - BOOT_EPOCH) / 1000);
  const loop = 90;                           // 90s “lap”
  const phase = (uptimeSec % loop) / loop;   // 0..1

  const speedMs = 8 + Math.round(5 * Math.sin(phase * 2 * Math.PI));  // 3..13 m/s
  const altitudeM = 40 + Math.round(6 * Math.cos(phase * 2 * Math.PI));
  const headingDeg = Math.floor((phase * 360) % 360);
  const batteryPct = Math.max(10, 100 - Math.floor(uptimeSec / 6));    // drains ~1%/6s
  const etaSec = Math.max(0, START_ETA_SEC - uptimeSec % START_ETA_SEC);

  res.json({
    droneId: DRONE_ID,
    route: ROUTE_NAME,
    telemetry: {
      speed_mps: speedMs,
      altitude_m: altitudeM,
      heading_deg: headingDeg,
      battery_pct: batteryPct,
      eta_sec: etaSec
    },
    ts: new Date().toISOString()
  });
});

// fallback to index.html for root
app.get("/", (_req, res) => {
  res.sendFile(path.join(__dirname, "public", "index.html"));
});

app.listen(PORT, () => {
  console.log(`DroneCam listening on :${PORT}`);
});
