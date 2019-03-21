<template>
  <!-- eslint-disable -->
  <div>
    <i v-if="loading" class="fas fa-spinner fa-spin"></i>
    <ul v-if="tweets.length" class="list-group pull-down mb-3">
      <tweet
        v-for="tweet in tweets"
        :tweet="tweet"
        @read="markTweet(tweet)"
        :key="tweet" />
    </ul>
    <h4 v-else-if="!loading">No new tweets</h4>
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
  },
  methods: {
    markTweet(tweet) {
      axios
        .post('/last-tweet', { tweet, friend: this.friend.id })
        .then(() => {
          this.tweets = this.tweets.filter(t => t > tweet);
        });
    }
  }
};
</script>
