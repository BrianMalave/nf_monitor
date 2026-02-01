import { useEffect, useState } from "react";
import { Link } from "react-router-dom";

function statusLabel(status) {
  if (status === "operational") return "Operational";
  if (status === "warning") return "Stand by";
  if (status === "problem") return "Stopped";
  return status;
}

function statusStyle(status) {
  const base = {
    padding: "2px 8px",
    borderRadius: 999,
    fontWeight: 700,
    fontSize: 12,
    display: "inline-block",
    // border: "1px solid #ddd",
  };

  if (status === "operational") return { ...base, background: "#42f08d" };
  if (status === "warning") return { ...base, background: "#e07f11" };
  if (status === "problem") return { ...base, background: "#ef5151" };
  return base;
}

const detailButtonStyle = {
  padding: "6px 12px",
  borderRadius: 6,
  backgroundColor: "#1f2937",
  color: "#fff",
  textDecoration: "none",
  fontSize: 13,
  fontWeight: 600,
  transition: "background-color 0.2s ease",
};

export default function RestaurantsList() {
  const [restaurants, setRestaurants] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

useEffect(() => {
  let cancelled = false;

  const load = () => {
    fetch("/api/v1/restaurants", { headers: { Accept: "application/json" } })
      .then(async (res) => {
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        return res.json();
      })
      .then((data) => {
        if (cancelled) return;
        setRestaurants(Array.isArray(data) ? data : [data]);
        setError("");
      })
      .catch((e) => {
        if (cancelled) return;
        setError(e.message);
      })
      .finally(() => {
        if (cancelled) return;
        setLoading(false);
      });
  };

  load();
  const timer = setInterval(load, 5000);

  return () => {
    cancelled = true;
    clearInterval(timer);
  };
}, []);

  return (
    <div style={{ padding: 20, maxWidth: 1000, margin: "0 auto" }}>
      <h1 style={{ marginBottom: 6 }}>Niufoods Monitor</h1>
      <p style={{ marginTop: 0, color: "#FFFF" }}>
        Lista de restaurantes y su estado general.
      </p>

      {loading && <p>Cargando...</p>}
      {error && <p style={{ color: "crimson" }}>Error: {error}</p>}

      {!loading && !error && (
        <table width="100%" cellPadding="10" style={{ borderCollapse: "collapse" }}>
          <thead>
            <tr style={{ textAlign: "left", borderBottom: "1px solid #ddd" }}>
              <th>Restaurante</th>
              <th>Ciudad</th>
              <th>Estado</th>
              <th>Dispositivos</th>
            </tr>
          </thead>
          <tbody>
            {restaurants.map((r) => (
              <tr key={r.id} style={{ borderBottom: "1px solid #f0f0f0" }}>
                <td>
                  <span>{r.name}</span>
                </td>
                <td>{r.city}</td>
                <td>
                  <span style={statusStyle(r.status)}>{statusLabel(r.status)}</span>
                </td>
                <td>{r.devices_count}</td>
                <td>
                  <Link
                    to={`/restaurants/${r.id}`}
                    style={detailButtonStyle}
                    onMouseEnter={(e) => (e.target.style.backgroundColor = "#28384e")}
                    onMouseLeave={(e) => (e.target.style.backgroundColor = "#2d3e62")}
                  >
                    Detalle
                  </Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}