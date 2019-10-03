import LiveSocket from 'phoenix_live_view';
import { Socket } from 'phoenix';
import hooks from './hooks';

// Import local files
// import socket from "./socket"

window.jQuery = window.$ = require('jquery');

const liveSocket = new LiveSocket('/live', Socket, { hooks });
liveSocket.connect();
