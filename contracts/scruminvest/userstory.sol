pragma solidity ^0.4.24;
import "./project.sol";
import '../admin/ExternalStorage.sol';
import "../tokens/token.sol";
contract userstory {

    address External_Storage_addr;
    struct Story_Bakers {
        //address baker;
        uint baked_sum;
        uint accept_work; // timestamp

    }

    struct UserStory {
                          uint project_ID;
                          uint User_story_number;
                          //address project_token;
                          bytes32 DFS_Hash;
                          byte8 DFS_type;
                          uint Story_Amount_ANG; // number of ANG payed by bakers
                          uint Story_Amount_Tokens; //number of tokens gives from team
                          uint256 start_date; // timestamp,
                          uint duration; // timedelta,
                          uint sum_raised;
                          uint sum_accepted;
                          uint256 Ask_end_from_project; // datetime when team say they finish work
                          // bool  project_signin; //  several team members?
                          uint256 finished; // datetime acceptwance from bakers
                          // bool project_accept;  // TODO tx transaction of acceptance
                          mapping (address => Story_Bakers) bakers;  //# several users who baked story
                          address[] bakers_list; // several users


                        }

    mapping (address => UserStory) public UserStories ; // AKA projectID


    event Newuserstory (uint ProjectID, uint Userstorynumber, bytes32 DFSHash, uint StoryAmountANG, uint StoryAmounttoken, uint256 Startdate, uint duration);

    function start_user_story (uint ProjectID, uint Userstorynumber, bytes32 DFSHash, byte8 DFStype,                                  uint StoryAmountANG,
                                uint StoryAmounttoken, uint256 Startdate, uint duration)
                                public OnlyOwner(msg.sender) returns (address){
        //todo check transfer sum to escrow
        // what address of escrow?
        //get token addr
        ExternalStorage ES = ExternalStorage(External_Storage_addr);
        Projectaddr =ES.getAddressValue("scruminvest/project");
        Projectcurrent =  Project(Projectaddr);
        Projecttoken = Projectcurrent.ProjectsList(ProjectID);
        reqiure((ERC20(Project_token).balanceOf(this) = StoryAmounttoken) ||
                (Projects[Project_token] .project_owner_address = msg.sender)) ;
            address UserStoryAddr = keccak256(ProjectID, Userstorynumber);
            UserStories[UserStoryAddr].project_ID = project_ID;
            UserStories[UserStoryAddr].User_story_number = Userstorynumber;
            UserStories[UserStoryAddr].duration = duration;
            UserStories[UserStoryAddr].DFS_Hash = DFSHash;
            UserStories[UserStoryAddr].DFS_type= DFStype;
            UserStories[UserStoryAddr].Story_Amount_ANG = StoryAmountANG;
            UserStories[UserStoryAddr].start_date = Startdate;
            UserStories[UserStoryAddr].duration = duration;
            emit  Newuserstory (ProjectID,  Userstorynumber, DFSHash,  StoryAmountANG,
                StoryAmounttoken, Startdate, Deadline);
            return UserStoryAddr;
    }

   // function add_user_story_comment () public { }

    event   succesful_invest(address UserStoryAddr, address baker, uint baked_sum, byte32 message);
    event unsuccesful_invest(address UserStoryAddr, address baker, uint baked_sum, byte32 message);


    function invest(address UserStoryAddr, uint bakedsumANG) public payable {
        // sign_in_user_story_from_investors
        //sign_in_user_story_from_user(UserStoryID:int128)
        // investors signup userstory when negotiations finished
        // investors  send ANG to userstory if agree

        if ((UserStories[UserStoryAddr].sum_raised + bakedsumANG) <
            UserStories[UserStoryAddr].Story_Amount_ANG) {
                if (UserStories[UserStoryAddr].bakers[msg.sender].baked_sum = 0) {
                    UserStories[UserStoryAddr].bakers_list.push(msg.sender);
                }
                UserStories[UserStoryAddr].bakers[msg.sender].baked_sum += bakedsumANG;
                UserStories[UserStoryAddr].sum_raised += bakedsumANG;
                emit succesful_invest(UserStoryAddr, msg.sender, bakedsumANG, "Thank you!");
        }
        else { // if sended sum overloads story's budget, don't accept this
            emit unsuccesful_invest(UserStoryAddr, msg.sender, bakedsumANG, "Your sum overloads budget");
            revert();
        }



    }



    function finish_userstory_from_team(address UserStoryAddr, uint ProjectID) public returns (uint){

        ExternalStorage ES = ExternalStorage(External_Storage_addr);
        Projectaddr =ES.getAddressValue("scruminvest/project");
        Projectcurrent =  Project(Projectaddr);
        Projecttoken = Projectcurrent.ProjectsList(ProjectID);
        reqiure((Projects[Projecttoken].project_owner_address = msg.sender)) ;
                timestamp = now;
                UserStories[UserStoryAddr].finished = now;
        return timestamp;
        //
        // todo: in withdraw module check require check that userstory finished

    }

    function accept_work_from_bakers (address UserStoryAddr, bool acceptance) public {

        reqiure (UserStories[UserStoryAddr].bakers[msg.sender].baked_sum > 0); // only investor can do it
            if (acceptance) {
                UserStories[UserStoryAddr].sum_accepted +=
                                UserStories[UserStoryAddr].bakers[msg.sender].baked_sum;
                UserStories[UserStoryAddr].bakers[msg.sender].accept_work = now;
            }
            if (UserStories[UserStoryAddr].sum_accepted > UserStories[UserStoryAddr].sum_rased /2){
                // all fine, 50%+ invastors accepted works results,
                // sends ANG to team
                ExternalStorage ES = ExternalStorage(External_Storage_addr);
                Projectaddr =ES.getAddressValue("scruminvest/project");
                Projectcurrent =  Project(Projectaddr);
                Projecttoken = Projectcurrent.ProjectsList(ProjectID);
                ANGTokenAddrr = ES.getAddressValue("ANGtoken");
                Token(ANGTokenAddrr).transfer(address(this), Projects[Projecttoken].project_owner_address,UserStories[UserStoryAddr].sum_raised );
                // address sender,address receiver, uint256 amount, bytes data

                //distribution of tokens
                uint pricetoken1000 = 1000 * UserStories[UserStoryAddr].Story_Amount_Tokens /
                                    UserStories[UserStoryAddr].Story_Amount_ANG;
                for (uint baker = 0;  baker < UserStories[UserStoryAddr].bakers_list.lenght();
                        baker++) {
                    bakeraddr = UserStories[UserStoryAddr].bakers_list[baker];
                    summTokens =   UserStories[UserStoryAddr].bakers[bakeraddr].baked_sum *
                                pricetoken1000 / 1000 ;


                    //todo  bakeraddr.send(summTokens);
                    Token(Projecttoken).transfer(address(this), bakeraddr, summTokens);

                }
            // todo gas compensation for transactions to last investor in ANG
            }
    }


    function token_refunds (address UserStoryAddr, address Projectaddr) {

        ExternalStorage ES = ExternalStorage(External_Storage_addr);
        Projectaddr =ES.getAddressValue("scruminvest/project");
        Projectcurrent =  Project(Projectaddr);
        Projecttoken = Projectcurrent.ProjectsList(ProjectID);
        ANGTokenAddrr = ES.getAddressValue("ANGtoken");

        // Returns their token to team
        Token(Projecttoken).transfer(address(this), Projects[Projecttoken].project_owner_address,UserStories[UserStoryAddr].Story_Amount_Tokens);

         //returns ANG to investors

         for (uint baker = 0;  baker < UserStories[UserStoryAddr].bakers_list.lenght();
                        baker++) {

                    Token(ANGTokenAddrr).transfer(address(this), UserStories[UserStoryAddr].bakers_list[baker], UserStories[UserStoryAddr].bakers[bakeraddr].baked_sum);

                }

    }


    event User_story_aborted_by_team (address UserStoryAddr, address Projecttoken, string why  );
    function abort_by_team (address UserStoryAddr, address Project_token, bool abortfromteam, string why )  public OnlyOwner { //it is close to accept_work_from_bakers, but vise versa

            if (abortfromteam) {
                token_refunds ( UserStoryAddr, Project_token );
                emit User_story_aborted_by_team (UserStoryAddr, Projecttoken, why);
                // returns token to team
            }

    }

    event User_story_aborted_by_bakers (address UserStoryAddr, address Projecttoken, string why  );

    function abort_by_bakers (address UserStoryAddr, address Project_token, bool abortfrombakers, string why) public{

        reqiure ((UserStories[UserStoryAddr].bakers[msg.sender].baked_sum > 0) || ( now > UserStories[UserStoryAddr].start_date + UserStories[UserStoryAddr].duration + 60 days));
        // 1. only investor can do it
        // 2. after 60 days past promised finish of userstory

            if (abortfrombakers) {
                token_refunds ( UserStoryAddr, Project_token );
                emit User_story_aborted_by_bakers (UserStoryAddr, Projecttoken, why);
                // returns token to team
            }

    }

    function _setExternalstorageaddr(address Externalstorageaddr ) public onlyAdmins {
        External_Storage_addr = Externalstorageaddr;


    }

    function _init() public onlyAdmins {

        ExternalStorage ES = ExternalStorage(External_Storage_addr);
        Projectaddr =ES.setAddressValue("scruminvest/userstory", address(this));

    }
}
