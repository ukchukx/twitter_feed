import { LiveSocket } from 'phoenix_live_view';
import { Socket } from 'phoenix';
import topbar from 'topbar';
import hooks from './hooks';
import { deleteLists } from './storage';

// Import local files
// import socket from "./socket"

window.jQuery = window.$ = require('jquery');
window.addEventListener('beforeunload', function (event) {
    if (event.currentTarget.location.pathname.includes('/friend/')) {
        deleteLists(event.currentTarget.location.pathname.replace('/friend/', ''));
    }
});
let _csrf_token = document.querySelector("meta[name='csrf-token']").getAttribute("content");

topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"});
window.addEventListener("phx:page-loading-start", info => topbar.show());
window.addEventListener("phx:page-loading-stop", info => topbar.hide());

const liveSocket = new LiveSocket('/live', Socket, { hooks, params: { _csrf_token } });
liveSocket.connect();
window.liveSocket = liveSocket;