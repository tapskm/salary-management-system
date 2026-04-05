/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/views/**/*.{html,erb}",
    "./app/javascript/**/*.{js,jsx,ts,tsx}",
    "./app/helpers/**/*.rb",
    "./app/assets/stylesheets/**/*.css"
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
