$(document).ready(function () {
    $('.load_ponies').on('click', function () {
        var self = $(this);
        if (self.data("start")) {
            BrowserPonies.stop();
            self.data("start", false);
        } else {
            self.data("start", true);
            BrowserPonies.start();
        }
    });
    (function (cfg) {
        BrowserPonies.setBaseUrl(cfg.baseurl);
        BrowserPonies.loadConfig(BrowserPoniesBaseConfig);
        BrowserPonies.loadConfig(cfg);
    })({
        "baseurl": "https://panzi.github.io/Browser-Ponies/",
        "fadeDuration": 500,
        "volume": 1,
        "fps": 25,
        "speed": 3,
        "audioEnabled": false,
        "showFps": false,
        "showLoadProgress": true,
        "speakProbability": 0.1,
        "spawn": {
            "ahuizotl": Math.floor(Math.random() * 4) + 1,
            "allie way": Math.floor(Math.random() * 4) + 1,
            "applejack": Math.floor(Math.random() * 4) + 1,
            "fluttershy": Math.floor(Math.random() * 4) + 1,
            "pinkie pie": Math.floor(Math.random() * 4) + 1,
            "rainbow dash": Math.floor(Math.random() * 4) + 1,
            "rarity": Math.floor(Math.random() * 4) + 1,
            "twilight sparkle": Math.floor(Math.random() * 4) + 1,
            "zecora": Math.floor(Math.random() * 4) + 1,
        },
        "spawnRandom": Math.floor(Math.random() * 9) + 1,
        "autostart": false
    });
});
