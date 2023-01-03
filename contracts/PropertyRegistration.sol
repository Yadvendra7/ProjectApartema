// SPDX-License-Identifier: GPL-3.0


   
   //@custom:dev-run-script contracts/PropertyRegistration.sol

pragma solidity 0.8.7;



contract apartmentRegistration{
    struct apartmentDetails{
        string state;
        string district;
        string region;
        uint256 surveyNumber;
        address payable CurrentOwner;
        uint marketValue;
        bool isAvailable;
        address requester;
        reqStatus requestStatus;

    }
    

    //request status
    enum reqStatus {Default,pending,reject,approved}



    //profile of a client
    struct profiles{
        uint[] assetList;   
        }

 
    mapping(uint => apartmentDetails) apartment;
    address owner;
    mapping(string => address) superAdmin;
    mapping(address => profiles) profile;
    
    //contract owner
    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    //adding reggion admins
    function addSuperAdmin(address _superAdmin,string memory _region ) onlyOwner public {
        superAdmin[_region]=_superAdmin;
    }
    //Registration of apartment details.
    function Registration(string memory _state,string memory _district,
        string memory _region,uint256 _surveyNumber,
        address payable _OwnerAddress,uint _marketValue,uint id
        ) public returns(bool) {
        require(superAdmin[_region] == msg.sender || owner == msg.sender);
        apartment[id].state = _state;
        apartment[id].district = _district;
        apartment[id].region = _region;
        apartment[id].surveyNumber = _surveyNumber;
        apartment[id].CurrentOwner = _OwnerAddress;
        apartment[id].marketValue = _marketValue;
        profile[_OwnerAddress].assetList.push(id);
        return true;
    }
    //to view details of apartment for the owner
    function apartmentInfoOwner(uint id) public view returns(string memory,string memory,string memory,uint256,bool,address,reqStatus){
        return(apartment[id].state,apartment[id].district,apartment[id].region,apartment[id].surveyNumber,apartment[id].isAvailable,apartment[id].requester,apartment[id].requestStatus);
    }
        //to view details of apartment for the buyer
        function apartmentInfoUser(uint id) public view returns(address,uint,bool,address,reqStatus){
        return(apartment[id].CurrentOwner,apartment[id].marketValue,apartment[id].isAvailable,apartment[id].requester,apartment[id].requestStatus);
    }

    // to compute id for an apartment.
    

    //push a request to the apartment owner
    function requstToLandOwner(uint id) public {
        require(apartment[id].isAvailable);
        apartment[id].requester=msg.sender;
        apartment[id].isAvailable=false;
        apartment[id].requestStatus = reqStatus.pending; //changes the status to pending.
    }
    //will show assets of the function caller 
    function viewAssets()public view returns(uint[] memory){
        return (profile[msg.sender].assetList);
    }
    //viewing request for the apartments
    function viewRequest(uint property)public view returns(address){
        return(apartment[property].requester);
    }
    //processing request for the apartment by accepting or rejecting
    function processRequest(uint property,reqStatus status)public {
        require(apartment[property].CurrentOwner == msg.sender);
        apartment[property].requestStatus=status;
        if(status == reqStatus.reject){
            apartment[property].requester = address(0);
            apartment[property].requestStatus = reqStatus.Default;
        }
    }
    //availing apartment for sale.
    function makeAvailable(uint property)public{
        require(apartment[property].CurrentOwner == msg.sender);
        apartment[property].isAvailable=true;
    } 
    //buying the approved property
    function buyProperty(uint property)public payable{
        require(apartment[property].requestStatus == reqStatus.approved);
        require(msg.value >= (apartment[property].marketValue+((apartment[property].marketValue)/10)));
        apartment[property].CurrentOwner.transfer(apartment[property].marketValue);
       
        apartment[property].CurrentOwner=payable(msg.sender);
        apartment[property].isAvailable=false;
        apartment[property].requester = address(0);
        apartment[property].requestStatus = reqStatus.Default;
        profile[msg.sender].assetList.push(property); //adds the property to the asset list of the new owner.
        
    }
    
    
    function findId(uint id,address user)public view returns(uint){
        uint i;
        for(i=0;i<profile[user].assetList.length;i++){
            if(profile[user].assetList[i] == id)
                return i;
        }
        return i;
    }
}