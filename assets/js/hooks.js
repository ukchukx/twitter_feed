const hooks = {};

const createList = 'creating';
const waitList = 'waiting';

const getList = (list) => (localStorage.getItem(list) || '').split(',').filter((x) => !!x);
const saveList = (list, items) => localStorage.setItem(list, items || []);

const addToList = (list, tweetId) => {
  saveList(list, getList(list).concat([tweetId]));
};
const removeFromList = (list, tweetId) => {
  saveList(list, getList(list).filter((x) => x !== tweetId));
};
const loadNextTweet = () => {
  const items = getList(waitList);
  if (!items.length) return;

  createTweet(items.shift());
  saveList(waitList, items);
};


const currentlyCreating = () => getList(createList);

const canCreateNow = () => currentlyCreating().length < 5;

const createTweet = (tweetId) => {
  console.info('Creating', tweetId);
  addToList(createList, tweetId);
  twttr.widgets
    .createTweet(tweetId, document.getElementById(`tweet-${tweetId}`))
    .then((el) => {
        const e = document.getElementById(`pre-tweet-${tweetId}`);
        if (el && e) {
          e.remove();
          removeFromList(createList, tweetId);
          loadNextTweet();
        }
    });
};

hooks.CreateTweet = {
  mounted() {
    if (canCreateNow()) {
      createTweet(this.el.dataset.tweetId);
    } else {
      addToList(waitList, this.el.dataset.tweetId);
    }
  },
  destroyed() {
    removeFromList(waitList, this.el.dataset.tweetId);
    removeFromList(createList, this.el.dataset.tweetId);
  }
}

export default hooks;
