const hooks = {};

hooks.CreateTweet = {
  mounted() {
    twttr.widgets
    .createTweet(this.el.dataset.tweetId, this.el)
    .then(() => {
      this.el.firstElementChild.remove();
    });
  }
}

export default hooks;
