import { BrowserRouter, Routes, Route } from "react-router-dom";
import RestaurantsList from "./pages/RestaurantsList";
import RestaurantDetail from "./pages/RestaurantDetail";

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<RestaurantsList />} />
        <Route path="/restaurants/:id" element={<RestaurantDetail />} />
      </Routes>
    </BrowserRouter>
  );
}