import Vue from 'vue';
import BootstrapVue from 'bootstrap-vue';
import VueFlashMessage from 'vue-flash-message';
import axios from 'axios';
import { library } from '@fortawesome/fontawesome-svg-core';
import { fas } from '@fortawesome/free-solid-svg-icons';
import { far } from '@fortawesome/free-regular-svg-icons';
import { fab } from '@fortawesome/free-brands-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
// Import local files
// import socket from "./socket"

window.jQuery = window.$ = require('jquery');

Vue.config.productionTip = false;

const token = document.head.querySelector('meta[name="csrf-token"]');
if (token) {
  axios.defaults.headers.common['X-CSRF-TOKEN'] = token.content;
}

library.add(fab, fas, far);
Vue.component('fa-icon', FontAwesomeIcon);
Vue.use(BootstrapVue);
Vue.use(VueFlashMessage, { createShortcuts: false });

new Vue({
  el: '#app'
});
