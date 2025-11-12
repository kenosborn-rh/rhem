const video = document.getElementById("droneVideo");
const banner = document.getElementById("delivery-banner");
const marker = document.getElementById("delivery-marker");
const flash = document.getElementById("target-flash");

let altitude = 75;
let speed = 45;
let battery = 87;

// Smoothly descending altitude as flight progresses
function updateHUD() {
  if (altitude > 15) altitude -= Math.random() * 1.5; // gentle descent
  speed = 40 + Math.random() * 5;
  battery -= 0.05;

  document.getElementById("hud-altitude").textContent = `Altitude: ${altitude.toFixed(1)} m`;
  document.getElementById("hud-speed").textContent = `Speed: ${speed.toFixed(1)} km/h`;
  document.getElementById("hud-battery").textContent = `Battery: ${battery.toFixed(1)} %`;
}

let hudInterval;
video.addEventListener("play", () => {
  hudInterval = setInterval(updateHUD, 1000);
});

video.addEventListener("ended", () => {
  clearInterval(hudInterval);

  // 🟡 Landing zone identified
  banner.style.background = "rgba(255, 255, 0, 0.85)";
  banner.style.borderColor = "rgba(200, 150, 0, 0.9)";
  banner.style.color = "#222";
  banner.textContent = "🟡 Landing Zone Identified — Initiating Drop Sequence";

  // 🎯 Flash effect before marker appears
  flash.style.visibility = "visible";
  flash.style.animation = "flash 0.8s ease-out";

  setTimeout(() => {
    flash.style.visibility = "hidden";
    flash.style.animation = "none";

    marker.style.visibility = "visible";
    marker.style.opacity = 1;
  }, 800);

  // ✅ Delivery complete
  setTimeout(() => {
    banner.style.background = "rgba(0, 255, 0, 0.85)";
    banner.style.borderColor = "rgba(0, 200, 0, 0.9)";
    banner.style.color = "#111";
    banner.textContent = "✅ Delivery Commencing — Bon Appetit!";

    // Fade out marker gracefully
    setTimeout(() => {
      marker.style.animation = "fadeOut 2s forwards";
    }, 3000);
  }, 3500);
});

