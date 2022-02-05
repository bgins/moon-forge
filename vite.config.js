import elmPlugin from "vite-plugin-elm"

export default {
  plugins: [elmPlugin()],
  build: {
    outDir: "dist",
    target: "es2020"
  }
}
