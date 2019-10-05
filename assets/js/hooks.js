const hooks = {};

hooks.CreateTweet = {
  mounted() {
    twttr.widgets
      .createTweet(this.el.dataset.tweetId, this.el)
      .then((el) => {
         const e = document.getElementById(`pre-tweet-${this.el.dataset.tweetId}`);
         if (el && e) e.remove();
      });
  }
}

export default hooks;
