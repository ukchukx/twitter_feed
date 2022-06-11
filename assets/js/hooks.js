import { 
  getCreateList,
  addToCreateList,
  removeFromCreateList, 
  addToWaitList, 
  removeFromWaitList, 
  getWaitList
} from './storage';

const hooks = {};


const loadNextTweet = () => {
  const items = getWaitList();

  if (!items.length) return;
  
  const tweetId = items.shift();
  createTweet(tweetId);
  removeFromWaitList(tweetId);
};

const canCreateNow = () => getCreateList().length < 5;

const createTweet = (tweetId) => {
  console.info('Inflating tweet', tweetId);
  addToCreateList(tweetId);
  twttr.widgets
    .createTweet(tweetId, document.getElementById(`tweet-${tweetId}`))
    .then((el) => {
        const e = document.getElementById(`pre-tweet-${tweetId}`);
        
        if (el && e) {
          e.remove();
          removeFromCreateList(tweetId);
          loadNextTweet();
        }
    });
};

hooks.CreateTweet = {
  mounted() {
    if (canCreateNow()) {
      createTweet(this.el.dataset.tweetId);
    } else {
      addToWaitList(this.el.dataset.tweetId);
    }
  },
  destroyed() {
    removeFromWaitList(this.el.dataset.tweetId);
    removeFromCreateList(this.el.dataset.tweetId);
  }
}

export default hooks;
