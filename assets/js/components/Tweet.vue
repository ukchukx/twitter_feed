<template>
  <!-- eslint-disable -->
  <li class="list-group-item">
    <vue-tweet :id="tweet">
      <i class="fas fa-spinner fa-spin"></i>
    </vue-tweet>
    <button @click="mark()" class="btn btn-sm btn-primary btn-icon-split">
      <span class="icon text-white-50">
        <i class="fas fa-check"></i>
      </span>
      <span class="text">
        Mark as read
      </span>
    </button>
  </li>
</template>
<script>
import { Tweet } from 'vue-tweet-embed';

export default {
  name: 'Tweet',
  components: {
    'vue-tweet': Tweet
  },
  props: {
    tweet: {
      type: String,
      required: true
    }
  },
  methods: {
    mark() {
      this.$emit('read', this.tweet);
    }
  }
};
</script>
<style>
.list-group-item {
  border: none;
  padding: none;
}
</style>
