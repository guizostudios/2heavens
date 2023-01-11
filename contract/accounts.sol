// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Accounts {
    // The address of the deployer of the contract
    address public deployer;
    // The address of the owner of the contract
    address payable public owner;
    // The address of the heir
    address payable public heir;
    // Flag to track if the claim process has started
    bool public claimInProgress;
    // Timestamp of when the claim process was initiated
    uint public claimInitiatedAt;
    // The number of days the heir needs to wait before being able to claim the account
    uint public claimDelay;

      constructor(address payable _owner) {
           owner = _owner;
           deployer = msg.sender;
    }

    // Function to set the heir and claimDelay
    function setHeir(address payable _heir, uint _claimDelay, address _sender) public {
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

    function withdraw(uint _amount, address _sender) public payable {
        require(_sender == owner, "Only the owner can withdraw funds.");
        require(address(this).balance > 0, "There are no funds to withdraw.");
        require(_amount <= address(this).balance, "Insufficient funds.");
        owner.transfer(_amount);
    }

    function transferFunds(address payable _recipient, uint _amount, address _sender) public payable {
    require(_sender == owner, "Only the owner can transfer funds.");
    require(_amount <= address(this).balance, "Insufficient funds.");
    _recipient.transfer(_amount);
}


    function stopClaim(address _sender) public {
        require(_sender == owner, "Only the owner can stop a claim.");
        require(claimInProgress, "There is no active claim to stop.");
        claimInProgress = false;
    }

    function returnOwner() public view returns(address){
        return owner;
    }

    
    function returnHeir() public view returns(address){
        return heir;
    }

    
    function returnDeployer() public view returns(address){
        return deployer;
    }

}


// cEUR, cReal and cUSD
// fallback
// fee
//map
// search contract by owner or heir 
//hook
//Reentrancy protection
//Overflow and underflow protection
//It does not have any mechanism to freeze account or prevent malicious actors from withdrawing funds.
//heir add heir...validate the contract owner at that time