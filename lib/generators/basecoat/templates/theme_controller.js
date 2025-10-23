import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Apply theme on initial load (runs immediately to prevent flash)
    this.applyStoredTheme()
  }

  toggle() {
    const isDark = !document.documentElement.classList.contains('dark')
    this.apply(isDark)
  }

  apply(dark) {
    document.documentElement.classList.toggle('dark', dark)
    try {
      localStorage.setItem('themeMode', dark ? 'dark' : 'light')
    } catch (_) {}
  }

  applyStoredTheme() {
    try {
      const stored = localStorage.getItem('themeMode')
      if (stored ? stored === 'dark' : matchMedia('(prefers-color-scheme: dark)').matches) {
        document.documentElement.classList.add('dark')
      }
    } catch (_) {}
  }
}
