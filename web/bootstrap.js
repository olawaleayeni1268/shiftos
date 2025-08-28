// web/bootstrap.js — start Flutter + show readable errors
(function () {
  const loading = document.getElementById('app-loading');
  const errEl = document.getElementById('app-error');

  function showError(err) {
    try { console.error('ShiftOS web bootstrap error:', err); } catch (_) {}
    if (loading) loading.style.display = 'none';
    if (errEl) {
      errEl.style.display = 'block';
      const msg = (err && (err.message || String(err))) || 'Unknown error';
      errEl.textContent = 'Failed to start: ' + msg;
    }
  }

  window.addEventListener('error', (e) => showError(e.error || e.message || 'Script error'));
  window.addEventListener('unhandledrejection', (e) => showError(e.reason || e));

  function start() {
    try {
      if (!(window._flutter && _flutter.loader && typeof _flutter.loader.loadEntrypoint === 'function')) {
        showError('flutter.js missing or loader unavailable.');
        return;
      }
      _flutter.loader
        .loadEntrypoint({})
        .then((engine) => engine.initializeEngine())
        .then((app) => {
          if (loading) loading.remove();
          return app.runApp();
        })
        .catch(showError);
    } catch (e) {
      showError(e);
    }
  }

  start();
})();
