// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Reddit {

    struct post {
        uint id;
        address owner;
        string post;
        uint votes;
    }

    struct response {
        uint id;
        address owner;
        string response;
    }

    uint currentIdPost = 0;
    uint currentIdResponse = 0;

    mapping(uint => post) allPost;
    mapping(uint => mapping(uint => response)) allResponse;
    mapping(uint => uint) idResponse;
    //0 -> post1 (mapping allPost)
        //0 => 0 => response1 (mapping allResponse)
        //0 => 1 => response2
        //0 => 2 => response3
    //1 -> post2
        //1 => 0 => response1
    //2 -> post3

    //0 => 3 (to know what is the next reponseId for the post - mapping idResponse)
    //1 => 1
    //2 => 0

    mapping(address => mapping(uint => bool)) hasVoted; //to know if a user has already voted
    //address1 => 0 (post1) => true
    //address2 => 1 (post2) => false
    
    mapping(address => uint) timeStampLastPost;
    //keep 30 seconds betwwen post to avoid spam

    function createPost(string memory _post) external {
        require(timeStampLastPost[msg.sender] < block.timestamp - 30, "It's tooo early to post again");
        require(bytes(_post).length != 0, "Your message is empty");
        post memory thisPost = post(currentIdPost,msg.sender,_post,0);
        allPost[currentIdPost] = thisPost;
        currentIdPost++;
        timeStampLastPost[msg.sender] = block.timestamp;
    }

    function createResponse(uint _postId, string memory _response) external {
        bytes memory getContentPost = bytes(allPost[_postId].post); //content of the post
        require(getContentPost.length != 0, "you can't comment an empty post");
        require(bytes(_response).length != 0, "Your message is empty");
        require(timeStampLastPost[msg.sender] < block.timestamp - 30, "It's tooo early to post again");
        response memory thisResponse = response(currentIdResponse,msg.sender,_response);
        allResponse[_postId][idResponse[_postId]] = thisResponse;
        idResponse[_postId]++;
        currentIdResponse++;
        timeStampLastPost[msg.sender] = block.timestamp;
    }
    
    modifier voteControl(uint _postId, address _voter) {
        require(!hasVoted[_voter][_postId], "You already voted for this post");
        require(allPost[_postId].owner != _voter, "You can't vote for your post");
        bytes memory getContentPost = bytes(allPost[_postId].post); //content of the post
        require(getContentPost.length != 0, "you can't vote for an empty post");
        _;
    }

    function VoteUp(uint _postId) external voteControl(_postId, msg.sender){
        address _voter = msg.sender;
        allPost[_postId].votes++;
        hasVoted[_voter][_postId] = true;
    }

    function VoteDown(uint _postId) external voteControl(_postId, msg.sender){
        address _voter = msg.sender;
        allPost[_postId].votes--;
        hasVoted[_voter][_postId] = true;
    }

    function getAllPost() external view returns(post[] memory) {
        post[] memory everyPost = new post[](currentIdPost);
        for(uint i =0; i < currentIdPost; i++){
            everyPost[i] = allPost[i];
        }
        return everyPost;
    }

    function getAllPostFromUser(address _user) external view returns(post[] memory){
        uint size = 0;
        for(uint i = 0; i < currentIdPost; i++){
           if(allPost[i].owner == _user){
               size++;
           }
        }
        post[] memory everyPost = new post[](size);
        uint j = 0;
        for(uint i = 0; i < currentIdPost; i++){
           if(allPost[i].owner == _user){
               everyPost[j] = allPost[i];
               j++;
           }
        }
        return everyPost;
    }

    function getResponseOfaPost(uint _postId) external view returns(response[] memory){
        uint responseCountForThisPost = 0;
        for(uint i = 0; i < idResponse[_postId]; i++){
           if(bytes(allResponse[_postId][i].response).length != 0 ){
               responseCountForThisPost++;
           }
        }
        response[] memory everyResponse = new response[](responseCountForThisPost);
        uint count = 0;
        for(uint i = 0; i < responseCountForThisPost; i++){
            everyResponse[count] = allResponse[_postId][i];
            count++;
        }
        return everyResponse;
    }

}