/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: {
          light: '#8ECAE6',
          DEFAULT: '#1565C0',
          dark: '#0D47A1',
        },
        background: {
          light: 'var(--bg-light)',
          cream: 'var(--bg-cream)',
          white: 'var(--bg-white)',
          gray: 'var(--bg-gray)',
        },
        text: {
          primary: 'var(--text-primary)',
          secondary: 'var(--text-secondary)',
          light: 'var(--text-light)',
        },
        button: {
          lightblue: '#8ECAE6'
        }
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
