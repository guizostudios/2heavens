// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./HeirAccount.sol";

// Factory contract for creating TTOD contracts
contract TTODFactory {

    // Accounts array
    Accounts[] public ttodArray;
    // Heir event
    event HeirSet(address heir);
    // Claim event
    event ClaimInitiated(address heir);
    // Account claimed event
    event AccountClaimed(address newOwner);
    // Account stop claim event
    event AccountStopClaim(address Owner);
    //Event to freeze
    event AccountFrozen(address frozenAccount);
    //Event to unfreeze
    event AccountUnFrozen(address unFrozenAccount);

 
    function createTTOD() public returns(address) {
       Accounts ttod = new Accounts(payable(msg.sender));    
       ttodArray.push(ttod);
       return address(ttod);
    }

    // Function to set the heir and claimDelay
    function ttodSetHeir(uint256 _ttodindex, address payable _heir, uint _claimDelay) public {
        ttodArray[_ttodindex].setHeir(_heir, _claimDelay, msg.sender);
        emit HeirSet(_heir);
        }
    // Function for the heir to start the claim process
    function ttodInitiateClaim(uint256 _ttodindex) public {
        ttodArray[_ttodindex].initiateClaim(msg.sender);
        emit ClaimInitiated(msg.sender);
    }

    // Function for the heir to claim the account
    function ttodClaim(uint256 _ttodindex) public  {
        ttodArray[_ttodindex].claim(msg.sender);
        emit AccountClaimed(msg.sender);
        }

    // Function to cancel the claim of account
    function ttodStopClaim(uint256 _ttodindex) public {
        ttodArray[_ttodindex].stopClaim(msg.sender);
        emit AccountStopClaim(msg.sender);
    }

    // Function to freeze the account
    function ttodFreeze(uint256 _ttodindex) public {
        ttodArray[_ttodindex].freeze(msg.sender);
        emit AccountFrozen(msg.sender);
    }

    // Function to unfreeze the account
    function ttodUnfreeze(uint256 _ttodindex) public {
        ttodArray[_ttodindex].unfreeze(msg.sender);
        emit AccountUnFrozen(msg.sender);
    }

   // Function to approve the deposit
    function approve(uint256 _ttodindex, uint _amount, address _ERC20Address, address payable _contract) public payable {
        ttodArray[_ttodindex].approve(_amount, _ERC20Address, _contract);
    }

   // Function to return the deposit approval
    function allowance ( uint256 _ttodindex,  address _ERC20Address, address payable _from, address payable _contract) public  view returns (uint256) {
        return ttodArray[_ttodindex].allowance( _ERC20Address, _from, _contract);
    }

    // Function to make deposit
    function ttodDeposit(uint256 _ttodindex, uint _amount, address payable _from, address _ERC20Address, address payable _contract) public payable {
        ttodArray[_ttodindex].deposit(/*_isCelo, */_amount, _from, _ERC20Address, _contract);
    }

    // Function to withdraw Celo or ERC20
    function ttodWithdraw(uint256 _ttodindex, bool _isCelo, uint _amount,  address _ERC20Address, address payable _feeAddress, uint _transferFee) public payable {
        ttodArray[_ttodindex].withdraw(_isCelo, _amount, _ERC20Address, msg.sender, _feeAddress, _transferFee);
    }

    // Function to transfer Celo or ERC20
    function ttodTransferFunds(uint256 _ttodindex, bool _isCelo, address payable _recipient, uint _amount, address _ERC20Address, address payable _feeAddress, uint _transferFee) public payable {
        ttodArray[_ttodindex].transferFunds(_isCelo, _recipient, _amount, _ERC20Address, msg.sender, _feeAddress, _transferFee);
    }

    // View to return the balance
    function ttodBalance(uint256 _ttodindex, bool _isCelo, address _ERC20Address) public view returns(uint) {
        return ttodArray[_ttodindex].balanceOf(_isCelo, _ERC20Address);
    }

    // View to return the owner
    function ttodReturnOwner(uint256 _ttodindex) public view returns(address){
        return ttodArray[_ttodindex].returnOwner();
    }

    // View to return the heir  
     function ttodReturnHeir(uint256 _ttodindex) public view returns(address){
        return ttodArray[_ttodindex].returnHeir();
    }

    // View to return the deployer
    function ttodReturnDeployer(uint256 _ttodindex) public view returns(address){
        return ttodArray[_ttodindex].returnDeployer();
    }

    // Return the deployer
    function findDeployer(address _deployer) public view returns (uint256[] memory) {
    uint256[] memory resultArray = new uint256[](ttodArray.length);
    uint256 index = 0;
    for (uint256 i = 0; i < ttodArray.length; i++) {
        if (ttodArray[i].returnDeployer() == _deployer) {
            resultArray[index] = i;
            index++;
        }
    }
    return resultArray;
    }

    // Return the owner
    function findOwner(address _owner) public view returns (uint256[] memory) {
    uint256[] memory resultArray = new uint256[](ttodArray.length);
    uint256 index = 0;
    for (uint256 i = 0; i < ttodArray.length; i++) {
        if (ttodArray[i].returnOwner() == _owner) {
            resultArray[index] = i;
            index++;
        }
    }
    return resultArray;
    }

    // Return the heir
    function findHeir(address _heir) public view returns (uint256[] memory) {
    uint256[] memory resultArray = new uint256[](ttodArray.length);
    uint256 index = 0;
    for (uint256 i = 0; i < ttodArray.length; i++) {
        if (ttodArray[i].returnHeir() == _heir) {
            resultArray[index] = i;
            index++;
        }
    }
    return resultArray;
    }
 
}

