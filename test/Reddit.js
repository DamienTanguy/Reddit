const { expect, assert } = require("chai");

describe("Reddit", function () {

  let contract;
  let allPost;
  let user1, user2, user3;

  before(async function(){
    const redditContract = await ethers.getContractFactory("Reddit");
    contract = await redditContract.deploy();
    //console.log(contract.address);
  });

  it('should deploy the contract', async function(){
    const redditContract = await ethers.getContractFactory("Reddit");
    [user1, user2, user3] = await ethers.getSigners();
    const err = null;
    try {
      const redditContractDeployement = await redditContract.deploy();
    }
    catch(error){
      err = error;
    }
    assert.equal(err, null, 'The contract is not deployed');
  });

  it('at first, no post is created', async function(){
      allPost = await contract.getAllPost();
      expect(allPost.length).to.equal(0);
  });

  it('After creating a post by the user1, the length of allPost should be 1', async function(){
      await contract.createPost('test post 1');
      allPost = await contract.getAllPost();
      //console.log('user1' + user1.address);
      expect(allPost.length).to.equal(1);
      expect(allPost[0].post).to.equal('test post 1');
  });

  it('At first there is no response for the post1, the length of the response for the post1 should be 0', async function(){
    let responsePost1 = await contract.getResponseOfaPost(0);
    expect(responsePost1.length).to.equal(0);
  });

  it('The user2 creates a response for the post1, the length of the response for the post1 should be 1', async function(){
    await contract.connect(user2).createResponse(0,'test response post 1');
    let responsePost1 = await contract.getResponseOfaPost(0);
    expect(responsePost1.length).to.equal(1);
  });

  it('The length of post for the user1 should return 1', async function(){
    let getAllPostFromUser1 = await contract.connect(user1).getAllPostFromUser(user1.address);
    expect(getAllPostFromUser1.length).to.equal(1);
  });

  it('The length of post for the user2 should return 0', async function(){
    let getAllPostFromUser2 = await contract.connect(user1).getAllPostFromUser(user2.address);
    expect(getAllPostFromUser2.length).to.equal(0);  
  });


  it('The user1 should not be able to vote for his own post (post1)', async function(){
    await expect(contract.connect(user1).VoteUp(0)).to.be.reverted;
  });

  it('The user2 should be able to vote UP for the post1 and the votes value should return 1', async function(){
    await expect(contract.connect(user2).VoteUp(0)).not.to.be.reverted;
    allPost = await contract.getAllPost();
    expect(allPost[0].votes).to.equal(1);
  });

  it('The user2 should not be able to vote 2 times for a post', async function(){
    await expect(contract.connect(user2).VoteDown(0)).to.be.reverted;
  });

  it('The user3 should be able to vote DOWN for the post1 and the votes value should return 0', async function(){
    await expect(contract.connect(user3).VoteDown(0)).not.to.be.reverted;
    allPost = await contract.getAllPost();
    expect(allPost[0].votes).to.equal(0);
  });

});