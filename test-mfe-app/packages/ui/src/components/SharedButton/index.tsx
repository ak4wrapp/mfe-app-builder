import React from "react";
export const SharedButton = ({ text }: { text: string }) => (
  <button
    style={{
      padding: "10px 20px",
      background: "#0070f3",
      color: "white",
      border: "none",
      borderRadius: 6,
      cursor: "pointer",
    }}
  >
    {text}
  </button>
);
