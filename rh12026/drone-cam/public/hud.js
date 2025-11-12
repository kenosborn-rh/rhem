const $ = (id) => document.getElementById(id);

async function tick(){
  try{
    const res = await fetch("/status", {cache:"no-store"});
    const data = await res.json();

    $("droneId").textContent = `Drone: ${data.droneId}`;
    $("route").textContent   = `Route: ${data.route}`;
    $("speed").textContent   = `Speed: ${data.telemetry.speed_mps} m/s`;
    $("alt").textContent     = `Alt: ${data.telemetry.altitude_m} m`;
    $("heading").textContent = `Heading: ${data.telemetry.heading_deg}°`;
    $("battery").textContent = `Battery: ${data.telemetry.battery_pct}%`;
    $("eta").textContent     = `ETA: ${fmt(data.telemetry.eta_sec)}`;
    $("ts").textContent      = new Date(data.ts).toLocaleTimeString();

    $("battery").classList.toggle("low", data.telemetry.battery_pct <= 20);
    $("eta").classList.toggle("soon", data.telemetry.eta_sec <= 30);
  }catch(e){
    $("ts").textContent = "— (no signal)";
  }
}

function fmt(sec){
  const m = Math.floor(sec/60), s = Math.floor(sec%60);
  return `${String(m).padStart(2,"0")}:${String(s).padStart(2,"0")}`;
}

setInterval(tick, 1000);
tick();
