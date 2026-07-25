(() => {
  "use strict";

  function copyText(text) {
    if (navigator.clipboard?.writeText) {
      return navigator.clipboard.writeText(text);
    }

    const textarea = document.createElement("textarea");
    textarea.value = text;
    textarea.setAttribute("readonly", "");
    textarea.style.position = "fixed";
    textarea.style.opacity = "0";
    document.body.appendChild(textarea);
    textarea.select();

    try {
      document.execCommand("copy");
    } finally {
      textarea.remove();
    }

    return Promise.resolve();
  }

  document.querySelectorAll("[data-palette-copy]").forEach((button) => {
    const palette = button.closest(".palette-swatch");
    const status = palette?.querySelector(".palette-swatch__status");
    const copyValue = palette?.dataset.copy;
    let restoreTimeout = null;

    if (!status || !copyValue) return;

    button.addEventListener("click", async () => {
      if (restoreTimeout !== null) {
        window.clearTimeout(restoreTimeout);
        restoreTimeout = null;
      }

      try {
        await copyText(copyValue);
        button.dataset.copied = "true";
        status.textContent = "Copied";
        restoreTimeout = window.setTimeout(() => {
          delete button.dataset.copied;
          status.textContent = "";
          restoreTimeout = null;
        }, 1200);
      } catch {
        delete button.dataset.copied;
        status.textContent = "";
      }
    });
  });
})();
