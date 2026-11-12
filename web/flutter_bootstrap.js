{{flutter_js}}
{{flutter_build_config}}

// Starts the app, then removes the HTML splash from web/index.html.
_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    document.getElementById("splash")?.remove();
  },
});
