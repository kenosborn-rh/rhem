const weatherBtn = document.getElementById("weatherBtn");
const backBtn = document.getElementById("backBtn");
const mapView = document.getElementById("map-view");
const weatherView = document.getElementById("weather-view");
const weatherContainer = document.getElementById("weather-container");

weatherBtn.addEventListener("click", async () => {
  mapView.classList.add("hidden");
  weatherView.classList.remove("hidden");

  const response = await fetch("weather.html");
  const content = await response.text();
  weatherContainer.innerHTML = content;
});

backBtn.addEventListener("click", () => {
  weatherView.classList.add("hidden");
  mapView.classList.remove("hidden");
});
