document.addEventListener("DOMContentLoaded", () => {
  const viewWeather = document.getElementById("view-weather");
  const back = document.getElementById("back-to-map");

  if (viewWeather) {
    viewWeather.onclick = () => location.href = "weather.html";
  }

  if (back) {
    back.onclick = () => location.href = "/";
  }
});
