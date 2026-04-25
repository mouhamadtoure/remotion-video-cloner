import React from "react";
import { Player } from "@remotion/player";
import { RemotionRoot } from "./Root";

// Page de preview Vercel — permet de visualiser la vidéo en ligne
// Accessible sur : https://ton-projet.vercel.app

export const PreviewPage: React.FC = () => {
  return (
    <div
      style={{
        minHeight: "100vh",
        backgroundColor: "#0a0a0a",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        fontFamily: "Inter, system-ui, sans-serif",
        padding: "40px 20px",
        gap: 24,
      }}
    >
      {/* Header */}
      <div style={{ textAlign: "center", marginBottom: 8 }}>
        <h1
          style={{
            color: "#ffffff",
            fontSize: 28,
            fontWeight: 700,
            margin: 0,
            letterSpacing: "-0.5px",
          }}
        >
          🎬 Remotion Preview
        </h1>
        <p style={{ color: "#666", fontSize: 14, margin: "8px 0 0" }}>
          video-cloner — aperçu en ligne
        </p>
      </div>

      {/* Player */}
      <div
        style={{
          borderRadius: 16,
          overflow: "hidden",
          boxShadow: "0 0 80px rgba(99,102,241,0.3)",
          border: "1px solid rgba(255,255,255,0.08)",
        }}
      >
        <Player
          component={RemotionRoot as React.ComponentType<unknown>}
          durationInFrames={300}
          fps={30}
          compositionWidth={1280}
          compositionHeight={720}
          style={{ width: "min(900px, 90vw)" }}
          controls
          loop
          autoPlay={false}
          clickToPlay
        />
      </div>

      {/* Instructions */}
      <div
        style={{
          color: "#555",
          fontSize: 13,
          textAlign: "center",
          maxWidth: 500,
          lineHeight: 1.6,
        }}
      >
        <p>
          Ce Player affiche ta composition Remotion. Pour le rendu final :{" "}
          <code
            style={{
              background: "#1a1a1a",
              padding: "2px 8px",
              borderRadius: 4,
              color: "#a78bfa",
            }}
          >
            npm run render
          </code>
        </p>
      </div>
    </div>
  );
};
