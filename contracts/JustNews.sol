pragma solidity >=0.4.22 <0.7.0;
pragma experimental ABIEncoderV2;

contract JustNews {
    
    struct News {
        address journalistAddress;
        string title;
        string sub_title;
        string author;
        string date;
        string newsContent;
        string[] sourcesList;
        string[] tags;
        int fakeCount;
        int realCount;
        bool mlRating;
        bool result;
    }
    
    struct Users {
        string name;
        string emailID;
        int authScore;
        string[] newsList; //will contain titles of news published
        string joinDate;
        string[] authenticNewsList; //will contain the titles of news published by this author which are proven authentic
        string[] fakeNewsList;
        int authenticCount; //contains a count of news which are correctly verified;
        int unauthenticCount; 
        bool isBlocked;
    }
    
    
    address public journalist;
    News[] public news;
    Users[] public users;
    address[] public voters;
    
    //restrict voting for the publisher and viewers who have already cast the vote
    modifier restrictedVoting(){
        require(msg.sender!=journalist);
        uint i=0;
        for(i;i<voters.length;i++)
        {
            require(msg.sender!=voters[i]);
        }
        _;
    }
    
    //Creates an article by initializing the address of journalist and news content 
    function createArticle(string memory title, string memory sub_title,string memory author,string memory date,
        string memory newsContent,string[] memory sourcesList,
        string[] memory tags)
            public{
                journalist = msg.sender;
                News memory currentNews = News({
                    journalistAddress:msg.sender,
                    title:title,
                    sub_title:sub_title,
                    author:author,
                    date:date,
                    newsContent:newsContent,
                    sourcesList:sourcesList,
                    tags:tags,
                    fakeCount:0,
                    realCount:0,
                    mlRating:false,
                    result:false
                });
                news.push(currentNews);
    }

    //Creates an user by initializing respective details  
    function createUser(string memory name,string memory emailID,
    	string memory joinDate)
            public{
                Users memory currentUser;
                    currentUser.name=name;
                    currentUser.emailID=emailID;
                    currentUser.authScore=0;
                    currentUser.joinDate=joinDate;
                    currentUser.authenticCount=0;
                    currentUser.unauthenticCount=0;
                    currentUser.isBlocked=false;
                users.push(currentUser);
    }

    //takes in title of the news and vote decision and updates the votecount of that news appropriately
    function vote(string memory title,bool val) public restrictedVoting{
        //search for the specific news title for which the voting has to be done
        uint i;
        for(i=0;i<news.length;i++){
            if(keccak256(abi.encodePacked(news[i].title))==keccak256(abi.encodePacked(title))){
                if (val==true){
                    news[i].realCount++;
                }
                else{
                    news[i].fakeCount++;
                }
            }
        }
        voters.push(msg.sender);
    }
}
