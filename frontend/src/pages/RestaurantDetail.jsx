import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";

function statusLabel(status) {
  if (status === "operational") return "Operational";
  if (status === "warning") return "Stand by";
  if (status === "problem") return "Stopped";

  return status;
}

const deviceStatusColor = (status) => {
  switch (status) {
    case "operational":
      return "#42f08d";
    case "failing":
      return "#ef5151";
    case "offline":
      return "#e07f11"; 
    case "maintenance":
      return "#f5c542";
    default:
      return "#333";
  }
};

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

function formatIso(iso) {
  if (!iso) return "-";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return iso;
  return d.toLocaleString();
}

export default function RestaurantDetail() {
  const { id } = useParams();
  const [restaurant, setRestaurant] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    let cancelled = false;

    const load = () => {
      fetch(`/api/v1/restaurants/${id}`, { headers: { Accept: "application/json" } })
        .then(async (res) => {
          if (!res.ok) throw new Error(`HTTP ${res.status}`);
          return res.json();
        })
        .then((data) => {
          if (cancelled) return;
          setRestaurant(data);
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
  }, [id]);

  return (
    <div style={{ padding: 20, maxWidth: 1000, margin: "0 auto" }}>
      <p>
        <Link to="/">← Volver</Link>
      </p>

      {loading && <p>Cargando...</p>}
      {error && <p style={{ color: "crimson" }}>Error: {error}</p>}

      {!loading && !error && restaurant && (
        <>
          <h1 style={{ marginBottom: 6 }}>{restaurant.name}</h1>
          <p style={{ marginTop: 0, color: "#FFFF" }}>
            Ciudad: <strong>{restaurant.city}</strong> | Estado general:{" "}
            <span style={statusStyle(restaurant.status)}>{statusLabel(restaurant.status)}</span>
          </p>

          <h2 style={{ marginTop: 24 }}>Dispositivos</h2>

          <table width="100%" cellPadding="10" style={{ borderCollapse: "collapse" }}>
            <thead>
              <tr style={{ textAlign: "left", borderBottom: "1px solid #ddd" }}>
                <th>Identifier</th>
                <th>Tipo</th>
                <th>Estado</th>
                <th>Último reporte</th>
                <th>Última mantención</th>
              </tr>
            </thead>
            <tbody>
              {(restaurant.devices || []).map((d) => (
                <tr key={d.id} style={{ borderBottom: "1px solid #f0f0f0" }}>
                  <td>{d.identifier}</td>
                  <td>{d.kind}</td>
                  <td>
                    <strong style={{ color: deviceStatusColor(d.status) }}>
                      {d.status}
                    </strong>
                  </td>
                  <td>
                    {d.last_report ? (
                      <>
                        {formatIso(d.last_report.reported_at)} ({d.last_report.reported_status})
                      </>
                    ) : (
                      "-"
                    )}
                  </td>
                  <td>
                    {d.last_maintenance ? (
                      <>
                        <strong>{d.last_maintenance.action}</strong>
                        {d.last_maintenance.notes ? ` — ${d.last_maintenance.notes}` : ""}
                      </>
                    ) : (
                      "-"
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </>
      )}
    </div>
  );
}