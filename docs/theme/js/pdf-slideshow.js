(() => {
  "use strict";

  const PDFJS_VERSION = "6.1.200";
  const PDFJS_URL =
    `https://unpkg.com/pdfjs-dist@${PDFJS_VERSION}/build/pdf.min.mjs`;
  const PDFJS_WORKER_URL =
    `https://unpkg.com/pdfjs-dist@${PDFJS_VERSION}/build/pdf.worker.min.mjs`;
  const MIN_ZOOM = 0.5;
  const MAX_ZOOM = 3;
  const ZOOM_STEP = 0.25;

  let pdfJsPromise = null;

  function loadPdfJs() {
    if (!pdfJsPromise) {
      pdfJsPromise = import(PDFJS_URL).then((pdfjs) => {
        pdfjs.GlobalWorkerOptions.workerSrc = PDFJS_WORKER_URL;
        return pdfjs;
      });
    }
    return pdfJsPromise;
  }

  function initializeViewer(dialog) {
    const trigger = document.querySelector(
      `[data-pdf-dialog="${CSS.escape(dialog.id)}"]`,
    );
    const canvas = dialog.querySelector("[data-pdf-canvas]");
    const stage = dialog.querySelector("[data-pdf-stage]");
    const message = dialog.querySelector("[data-pdf-message]");
    const status = dialog.querySelector("[data-pdf-status]");
    const previous = dialog.querySelector("[data-pdf-previous]");
    const next = dialog.querySelector("[data-pdf-next]");
    const zoomOut = dialog.querySelector("[data-pdf-zoom-out]");
    const zoomReset = dialog.querySelector("[data-pdf-zoom-reset]");
    const zoomIn = dialog.querySelector("[data-pdf-zoom-in]");
    const close = dialog.querySelector("[data-pdf-close]");

    const context = canvas?.getContext("2d");

    if (
      !trigger ||
      !canvas ||
      !context ||
      !stage ||
      !message ||
      !status ||
      !previous ||
      !next ||
      !zoomOut ||
      !zoomReset ||
      !zoomIn ||
      !close
    ) {
      return;
    }

    const state = {
      pdf: null,
      loading: null,
      page: 1,
      pages: Number(dialog.dataset.pdfPages) || 1,
      zoom: 1,
      renderTask: null,
      renderGeneration: 0,
      resizeTimer: null,
    };

    function updateControls() {
      previous.disabled = !state.pdf || state.page <= 1;
      next.disabled = !state.pdf || state.page >= state.pages;
      zoomOut.disabled = !state.pdf || state.zoom <= MIN_ZOOM;
      zoomIn.disabled = !state.pdf || state.zoom >= MAX_ZOOM;
      zoomReset.disabled = !state.pdf || state.zoom === 1;
      zoomReset.textContent = `${Math.round(state.zoom * 100)}%`;
      status.textContent = `Page ${state.page} of ${state.pages}`;
    }

    function showMessage(text) {
      message.textContent = text;
      message.hidden = false;
      canvas.style.display = "none";
    }

    async function renderPage() {
      if (!state.pdf) return;

      const generation = ++state.renderGeneration;
      if (state.renderTask) {
        state.renderTask.cancel();
        state.renderTask = null;
      }

      const page = await state.pdf.getPage(state.page);
      if (generation !== state.renderGeneration) return;

      const baseViewport = page.getViewport({ scale: 1 });
      const availableWidth = Math.max(160, stage.clientWidth - 32);
      const availableHeight = Math.max(90, stage.clientHeight - 32);
      const fitScale = Math.min(
        availableWidth / baseViewport.width,
        availableHeight / baseViewport.height,
      );
      const viewport = page.getViewport({ scale: fitScale * state.zoom });
      const outputScale = Math.min(window.devicePixelRatio || 1, 2);

      canvas.width = Math.floor(viewport.width * outputScale);
      canvas.height = Math.floor(viewport.height * outputScale);
      canvas.style.width = `${Math.floor(viewport.width)}px`;
      canvas.style.height = `${Math.floor(viewport.height)}px`;
      canvas.setAttribute(
        "aria-label",
        `${dialog.dataset.pdfTitle}, page ${state.page} of ${state.pages}`,
      );

      const renderTask = page.render({
        canvasContext: context,
        viewport,
        transform:
          outputScale === 1
            ? null
            : [outputScale, 0, 0, outputScale, 0, 0],
      });
      state.renderTask = renderTask;

      try {
        await renderTask.promise;
        if (generation !== state.renderGeneration) return;
        message.hidden = true;
        canvas.style.display = "block";
      } catch (error) {
        if (error?.name !== "RenderingCancelledException") {
          throw error;
        }
      } finally {
        if (state.renderTask === renderTask) {
          state.renderTask = null;
        }
      }
    }

    async function ensureLoaded() {
      if (state.pdf) {
        await renderPage();
        return;
      }
      if (state.loading) {
        await state.loading;
        return;
      }

      showMessage("Loading slideshow…");
      updateControls();
      state.loading = (async () => {
        const pdfjs = await loadPdfJs();
        const loadingTask = pdfjs.getDocument({ url: dialog.dataset.pdfSrc });
        state.pdf = await loadingTask.promise;
        state.pages = state.pdf.numPages;
        state.page = Math.min(state.page, state.pages);
        updateControls();
        await renderPage();
      })();

      try {
        await state.loading;
      } catch (error) {
        console.error("Unable to load PDF slideshow", error);
        showMessage("The slideshow preview could not be loaded. Open the PDF instead.");
      } finally {
        state.loading = null;
      }
    }

    async function setPage(page) {
      if (!state.pdf) return;
      state.page = Math.max(1, Math.min(page, state.pages));
      updateControls();
      await renderPage();
    }

    async function setZoom(zoom) {
      if (!state.pdf) return;
      state.zoom = Math.max(MIN_ZOOM, Math.min(zoom, MAX_ZOOM));
      updateControls();
      await renderPage();
    }

    trigger.addEventListener("click", async (event) => {
      if (
        event.button !== 0 ||
        event.metaKey ||
        event.ctrlKey ||
        event.shiftKey ||
        event.altKey
      ) {
        return;
      }
      event.preventDefault();
      dialog.showModal();
      close.focus();
      await ensureLoaded();
    });

    close.addEventListener("click", () => dialog.close());
    dialog.addEventListener("click", (event) => {
      if (event.target === dialog) dialog.close();
    });
    previous.addEventListener("click", () => setPage(state.page - 1));
    next.addEventListener("click", () => setPage(state.page + 1));
    zoomOut.addEventListener("click", () => setZoom(state.zoom - ZOOM_STEP));
    zoomReset.addEventListener("click", () => setZoom(1));
    zoomIn.addEventListener("click", () => setZoom(state.zoom + ZOOM_STEP));

    dialog.addEventListener("keydown", (event) => {
      if (event.key === "ArrowLeft") {
        event.preventDefault();
        setPage(state.page - 1);
      } else if (event.key === "ArrowRight") {
        event.preventDefault();
        setPage(state.page + 1);
      } else if (event.key === "Home") {
        event.preventDefault();
        setPage(1);
      } else if (event.key === "End") {
        event.preventDefault();
        setPage(state.pages);
      }
    });

    window.addEventListener("resize", () => {
      if (!dialog.open || !state.pdf) return;
      window.clearTimeout(state.resizeTimer);
      state.resizeTimer = window.setTimeout(renderPage, 120);
    });

    updateControls();
  }

  document
    .querySelectorAll("[data-pdf-slideshow]")
    .forEach(initializeViewer);
})();
