import Vue from 'vue';
import axios from 'axios';
// Import local files
// import socket from "./socket"
import Tweets from './components/Tweets';

window.jQuery = window.$ = require('jquery');

Vue.config.productionTip = false;

const token = document.head.querySelector('meta[name="csrf-token"]');
if (token) {
  axios.defaults.headers.common['X-CSRF-TOKEN'] = token.content;
}

Vue.component(Tweets.name, Tweets);

new Vue({
  el: '#app'
});
