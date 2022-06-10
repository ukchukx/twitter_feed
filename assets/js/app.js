import LiveSocket from 'phoenix_live_view';
import { Socket } from 'phoenix';
import hooks from './hooks';

// Import local files
// import socket from "./socket"

window.jQuery = window.$ = require('jquery');
window.addEventListener('beforeunload', function (event) {
    if (event.currentTarget.location.pathname.includes('/friend/')) {
        localStorage.removeItem('creating');
        localStorage.removeItem('waiting');
    }
});

const liveSocket = new LiveSocket('/live', Socket, { hooks });
liveSocket.connect();
