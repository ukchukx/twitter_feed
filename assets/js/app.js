import LiveSocket from 'phoenix_live_view';
import { Socket } from 'phoenix';
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

const liveSocket = new LiveSocket('/live', Socket, { hooks });
liveSocket.connect();
