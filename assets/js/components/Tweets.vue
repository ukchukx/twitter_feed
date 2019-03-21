<template>
  <!-- eslint-disable -->
  <div>
    <i v-if="loading" class="fas fa-spinner fa-spin"></i>
    <ul class="list-group pull-down mb-3">
      <tweet v-for="tweet in tweets" :tweet="tweet" :key="tweet" />
    </ul>
  </div>
</template>
<script>
import axios from 'axios';
import Tweet from './Tweet';

export default {
  name: 'Tweets',
  components: {
    Tweet
  },
  props: {
    friend: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      tweets: [],
      loading: false
    };
  },
  mounted() {
    this.loading = true;

    axios
      .get(`/tweets/${this.friend.id}`)
      .then(({ data: { data: { tweets } } }) => {
        this.loading = false;
        this.tweets = tweets;
      })
      .catch(() => {
        this.loading = false;
      });
  }
};
</script>
