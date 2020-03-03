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
        int fakeCount;              //count of reported news as fake 
        int realCount;              //count of reported news as real 
        int fakeWeight;             //percentage of news reported as fake
        int realWeight;             //percentage of news reported as real
        bool mlRating;              //mlRating of the news as true or false
        bool result;                //Overall Authenticity of the news based on fakeWeight,realWeight and mlRating, result is true if mlRating is true and realWeight is greater than fakeWeight
        address[] voters;           //address of voters who have voted for current article
    }
    
    struct Users {
        address userAddress;
        string name;
        string emailID;
        string joinDate;
        int authScore;
        string[] newsList;          //titles of news published
        string[] authenticNewsList; //titles of news published by this author which are proven authentic
        string[] fakeNewsList;      //titles of news published by this author which are proven authentic
        int authenticCount;         //count of news which are correctly verified
        int unauthenticCount; 
        bool isBlocked;
    }
    
    News[] public news;
    Users[] public users;
    
    function createArticle(string memory title, string memory sub_title,string memory author,string memory date,
        string memory newsContent,string[] memory sourcesList,
        string[] memory tags)
            public{
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

    function createUser(string memory name,string memory emailID,
    	string memory joinDate)
            public{
                Users memory currentUser;
                    currentUser.userAddress=msg.sender;
                    currentUser.name=name;
                    currentUser.emailID=emailID;
                    currentUser.authScore=5;
                    currentUser.joinDate=joinDate;
                    currentUser.authenticCount=0;
                    currentUser.unauthenticCount=0;
                    currentUser.isBlocked=false;
                users.push(currentUser);
    }

    //takes in title of the news and vote decision and updates the votecount of that news appropriately
    function vote(string memory title,bool val) public{
        //search for the specific news title for which the voting has to be done
        uint i;
        for(i=0;i<news.length;i++){
            if(keccak256(abi.encodePacked(news[i].title))==keccak256(abi.encodePacked(title))){
                require(msg.sender!=news[i].journalistAddress);
                uint j=0;
                for(j;j<news[i].voters.length;j++)
                {
                    require(msg.sender!=voters[j]);
                }
                if (val==true){
                    news[i].realCount++;
                    news[i].voters.push(msg.sender);
                 }
                else{
                    news[i].fakeCount++;
                    news[i].voters.push(msg.sender);
                }
                break;
            }
        }
    }
    
    //takes in an article title along with votecount and ml input and decides authenticity of the article
    function articleAuthenticity(string memory title,bool mlRating,int fakeCount,int realCount) public{
        require(fakeCount+realCount>=10);
        uint positiveWeightage = (realCount/(fakeCount+realCount))*100;
        uint negativeWeightage = 100-positiveWeightage;
        bool finalResult;
        if(mlRating==true && positiveWeightage>negativeWeightage){
            finalResult=true;
        }
        else{
            finalResult=false;
        }
        for(i=0;i<news.length;i++){
            if(keccak256(abi.encodePacked(news[i].title))==keccak256(abi.encodePacked(title))){
               news[i].result=finalResult;
               news[i].realWeight=positiveWeightage;
               news[i].fakeWeight=negativeWeightage;
               alterUserCredits(i);
               break;
            }
        }
    }
    
    //for a news whose authenticity has been verified alter the publishers credit
    function alterUserCredits(uint i) public{
        uint j=0;
        uint finalAuthScore;
        address journalistAddress=news[i].journalistAddress;
        if(news[i].result==true)
        {
            finalAuthScore=1;
        }
        else
        {
            finalAuthScore=-1;
        }
        for(j;j<users.length;j++){
            if(keccak256(abi.encodePacked(journalistAddress))==keccak256(abi.encodePacked(users[j].userAddress)))
            {
                string newsTitle=news[i].title;
                uint authCount,unauthCount;
                users[i].authScore+=finalAuthScore;
                users[i].newsList.push(newsTitle);
                if(news[i].result==true)
                {
                    users[i].authenticNewsList.push(newsTitle);
                    authCount = users[i].authenticCount++;
                }
                else
                {
                    users[i].fakeNewsList.push(newsTitle);
                    unauthCount = users[i].unauthenticCount++;
                }
                if(authCount<unauthCount)
                {
                    uint percentageAuth = (authCount/(authCount+unauthCount))*100;
                    if(percentageAuth<20)
                    {
                        users[i].isBlocked=true;
                    }
                }
                break;
            }
        }
    }
}
