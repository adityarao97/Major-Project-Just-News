pragma solidity >=0.4.22 <0.7.0;
pragma experimental ABIEncoderV2;

contract JustNews {

    struct News {
        string articleID;
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
        bool result;                //Overall Authenticity of the news based on fakeWeight,
                                    //realWeight and mlRating, result is true if mlRating is true and realWeight is greater than fakeWeight
        address[] voters;           //address of voters who have voted for current article
    }

    struct User {
        address userAddress;
        string name;
        string emailID;
        string joinDate;
        int authScore;              //credit given to journalist based on the authenticity test default credit assigned is 5
        string[] newsList;          //titles of news published
        string[] authenticNewsList; //titles of news published by this author which are proven authentic
        string[] fakeNewsList;      //titles of news published by this author which are proven fake
        int authenticCount;         //count of news which are correctly verified
        int unauthenticCount;       //count of news which are incorrectly verified
        bool isBlocked;             //returns true and blocks a user if it has less than 30% of authentically verified news
    }

    News[] public news;
    User[] public users;

    function createArticle(string memory title, string memory sub_title,string memory author,string memory date,
        string memory newsContent,string[] memory sourcesList,
        string[] memory tags)
            public{
                News memory currentNews;
                    currentNews.articleID = bytes32ToString(bytes32(news.length));
                    currentNews.journalistAddress = msg.sender;
                    currentNews.title = title;
                    currentNews.sub_title = sub_title;
                    currentNews.author = author;
                    currentNews.date = date;
                    currentNews.newsContent = newsContent;
                    currentNews.sourcesList = sourcesList;
                    currentNews.tags = tags;
                    currentNews.fakeCount = 0;
                    currentNews.realCount = 0;
                    currentNews.mlRating = true;
                    currentNews.result = true;
                news.push(currentNews);
    }

    function createUser(string memory name,string memory emailID,
    	string memory joinDate)
            public{
                User memory currentUser;
                    currentUser.userAddress = msg.sender;
                    currentUser.name = name;
                    currentUser.emailID = emailID;
                    currentUser.joinDate = joinDate;
                    currentUser.authScore = 5;
                    currentUser.authenticCount = 0;
                    currentUser.unauthenticCount = 0;
                    currentUser.isBlocked = false;
                users.push(currentUser);
    }

    //takes in title of the news and vote decision and updates the votecount of that news appropriately
    function vote(string memory title,bool val) public{
        //search for the specific news title for which the voting has to be done
        uint i;
        for(i = 0;i<news.length;i++){
            if(keccak256(abi.encodePacked(news[i].title))==keccak256(abi.encodePacked(title))){
                require(msg.sender != news[i].journalistAddress);     //voter should not be the author of the news
                uint j = 0;
                for(;j<news[i].voters.length;j++)
                {
                    require(msg.sender != news[i].voters[j]);                 //voter should not be repetitive
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
    function articleAuthenticity(string memory title) public{
        uint i = 0;
        for(;i<news.length;i++){
            if(keccak256(abi.encodePacked(news[i].title)) == keccak256(abi.encodePacked(title))){
                int realCount = news[i].realCount;
                int fakeCount = news[i].fakeCount;
                require(realCount+fakeCount >= 10);
                int positiveWeightage = (realCount/(fakeCount + realCount)) * 100;
                int negativeWeightage = (fakeCount/(fakeCount + realCount)) * 100;
                int mlContrib = (news[i].mlRating == true)?40:0;
                bool finalResult;

                int finalScore = mlContrib + positiveWeightage;

                if(finalScore>50){
                    finalResult = true;
                }
                else{
                    finalResult = false;
                }
               news[i].result = finalResult;
               news[i].realWeight = positiveWeightage;
               news[i].fakeWeight = negativeWeightage;
               alterUserCredits(i);
               break;
            }
        }
    }

    function getAllUsers() public view returns(User[]){
        return users;
    }

    function getAllArticles() public view returns(News[]){
        return news;
    }

    function getArticleByID(string ID) public view returns(News){
        uint i = 0;
        for(i;i<news.length;i++){
            if(stringsEqual(news[i].articleID,ID)){
                return news[i];
                break;
            }
        }
    }

    //for a news whose authenticity has been verified and result decided alter the publishers credit
    function alterUserCredits(uint i) public{
        uint j = 0;
        int finalAuthScore;
        address journalistAddress = news[i].journalistAddress;
        if(news[i].result==true)
        {
            finalAuthScore = 1;
        }
        else
        {
            finalAuthScore = -1;
        }
        for(;j<users.length;j++){
            if(keccak256(abi.encodePacked(journalistAddress))==keccak256(abi.encodePacked(users[j].userAddress)))
            {
                string memory newsTitle = news[i].title;
                int authCount;
                int unauthCount;
                users[j].authScore += finalAuthScore;
                users[j].newsList.push(newsTitle);
                if(news[i].result==true)
                {
                    users[j].authenticNewsList.push(newsTitle);
                    authCount = users[j].authenticCount++;
                }
                else
                {
                    users[j].fakeNewsList.push(newsTitle);
                    unauthCount = users[j].unauthenticCount++;
                }
                if(users[j].newsList.length>3 && authCount<unauthCount)
                {
                    int percentageAuth = (authCount/(authCount+unauthCount))*100;
                    if(percentageAuth<20)
                    {
                        users[j].isBlocked = true;
                    }
                }
                break;
            }
        }
    }

    function stringsEqual(string storage _a, string memory _b) internal returns (bool) {
        bytes storage a = bytes(_a); bytes memory b = bytes(_b);
        if (a.length != b.length) return false; // @todo unroll this loop
        for (uint i = 0; i < a.length; i ++)
            if (a[i] != b[i])
                return false;
        return true;
    }

    function bytes32ToString (bytes32 data) public returns (string) {
    bytes memory bytesString = new bytes(32);
    for (uint j = 0; j < 32; j++) {
        byte char = byte(bytes32(uint(data) * 2 ** (8 * j)));
        if (char != 0) {
            bytesString[j] = char;
        }
    }
    return string(bytesString);
}

}
