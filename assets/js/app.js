import LiveSocket from 'phoenix_live_view';
import { Socket } from 'phoenix';

// Import local files
// import socket from "./socket"

window.jQuery = window.$ = require('jquery');

const liveSocket = new LiveSocket('/live', Socket);
liveSocket.connect();
