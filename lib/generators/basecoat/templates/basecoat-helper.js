// Re-initialize basecoat-css components after Turbo navigation
document.addEventListener('turbo:load', () => {
  document.dispatchEvent(new Event('DOMContentLoaded', { bubbles: true, cancelable: false }))
})

// View transitions for turbo frame navigation
addEventListener("turbo:before-frame-render", (event) => {
    if (document.startViewTransition) {
        const originalRender = event.detail.render
        event.detail.render = async (currentElement, newElement) => {
            const transition = document.startViewTransition(() => originalRender(currentElement, newElement))
            await transition.finished
        }
    }
})

// Dark mode toggle
const apply = dark => {
    document.documentElement.classList.toggle('dark', dark);
    try { localStorage.setItem('themeMode', dark ? 'dark' : 'light'); } catch (_) {}
};

// Apply theme on initial load (runs immediately to prevent flash)
try {
    const stored = localStorage.getItem('themeMode');
    if (stored ? stored === 'dark'
        : matchMedia('(prefers-color-scheme: dark)').matches) {
        document.documentElement.classList.add('dark');
    }
} catch (_) {}

// Set up theme toggle event listener
document.addEventListener('basecoat:theme', (event) => {
    const mode = event.detail?.mode;
    apply(mode === 'dark' ? true
        : mode === 'light' ? false
            : !document.documentElement.classList.contains('dark'));
})
