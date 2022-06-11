const createList = 'creating';
const waitList = 'waiting';

const currentFriendId = () => location.pathname.replace('/friend/', '');

const getList = (list) => {
  const friendId = currentFriendId();
  const data = JSON.parse(localStorage.getItem(list) || '{}')[friendId] || {};
  return (data[list] || []).filter((x) => !!x);
};

const saveList = (list, items) => {
  const friendId = currentFriendId();
  const data = JSON.parse(localStorage.getItem(list) || '{}');
  const friendData = data[friendId] || {};
  data[friendId] = { ...friendData, [list]: items };
  localStorage.setItem(list, JSON.stringify(data));
};

const deleteList = (list, friendId) => {
  const data = JSON.parse(localStorage.getItem(list) || '{}');
  delete data[friendId];
  localStorage.setItem(list, JSON.stringify(data));
};

const addToList = (list, tweetId) => {
  saveList(list, getList(list).concat([tweetId]));
};

const removeFromList = (list, tweetId) => {
  saveList(list, getList(list).filter((x) => x !== tweetId));
};

const addToCreateList = (tweetId) => addToList(createList, tweetId);

const addToWaitList = (tweetId) => addToList(waitList, tweetId);

const removeFromCreateList = (tweetId) => removeFromList(createList, tweetId);

const removeFromWaitList = (tweetId) => removeFromList(waitList, tweetId);

const getCreateList = () => getList(createList);

const getWaitList = () => getList(waitList);

const deleteLists = (friendId) => {
  deleteList(createList, friendId);
  deleteList(waitList, friendId);
};

export  {
    getCreateList,
    getWaitList,
    addToCreateList,
    removeFromCreateList,
    addToWaitList,
    removeFromWaitList,
    deleteLists
};