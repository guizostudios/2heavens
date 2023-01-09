// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

contract TTOD {
    // The address of the owner of the contract
    address public owner;
    // The address of the heir
    address public heir;
    // Flag to track if the claim process has started
    bool public claimInProgress;
    // Timestamp of when the claim process was initiated
    uint public claimInitiatedAt;
    // The number of days the heir needs to wait before being able to claim the account
    uint public claimDelay;

      constructor(address _owner) public {
           owner = _owner;
    }

    // Function to set the heir and claimDelay
    function setHeir(address _heir, uint _claimDelay, address _sender) public {
        require(owner == _sender, "Only the owner can set the heir.");
        heir = _heir;
        claimDelay = _claimDelay;
    }

    // Function for the heir to start the claim process
    function initiateClaim(address _sender) public {
        require(heir == _sender, "Only the heir can initiate the claim process.");
        require(!claimInProgress, "Claim process is already in progress.");
        claimInProgress = true;
        claimInitiatedAt = block.timestamp;
    }

    // Function for the heir to claim the account
    function claim(address _sender) public  {
        require(heir == _sender, "Only the heir can claim the account.");
        require(claimInProgress, "Claim process has not been initiated.");
        require(block.timestamp >= claimInitiatedAt + claimDelay * 1 days, "Claim delay has not expired.");
        owner = heir;
        }

    function withdraw(address _sender) public payable {
        require(_sender == owner, "Only the owner can withdraw funds.");
        require(address(this).balance > 0, "There are no funds to withdraw.");
        msg.sender.transfer(address(this).balance);
    }

    function stopClaim(address _sender) public {
        require(_sender == owner, "Only the owner can stop a claim.");
        require(claimInProgress, "There is no active claim to stop.");
        claimInProgress = false;
    }

    function returnOwner() public view returns(address){
        return owner;
    }

}



//  amount and token to withdraw
// cEUR, cReal and cUSD
// verify no funds because there are more than one token
// fallback
// fee
//map
//return owner and heir
// search contract by owner or heir 
//hook