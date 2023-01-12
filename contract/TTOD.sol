// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./HeirAccount.sol";

// Factory contract for creating TTOD contracts
contract TTODFactory {

    // Accounts array
    Accounts[] public ttodArray;
    // Mapping for deployer addresses
    mapping(address => uint256[]) public deployerToTTOD;
    // Mapping for owner addresses
    mapping(address => uint256[]) public ownerToTTOD;
    // Mapping for heir addresses
    mapping(address => uint256[]) public heirToTTOD;
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
       uint256 ttodIndex = ttodArray.length - 1;
       deployerToTTOD[msg.sender].push(ttodIndex);
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

    function ttodBalance(uint256 _ttodindex, bool _isCelo, address _ERC20Address) public {
        ttodArray[_ttodindex].balanceOf(_isCelo, _ERC20Address);
    }

    function ttodFreeze(uint256 _ttodindex) public {
        ttodArray[_ttodindex].freeze(msg.sender);
        emit AccountFrozen(msg.sender);
    }

    // Function to unfreeze the account
    function ttodUnfreeze(uint256 _ttodindex) public {
        ttodArray[_ttodindex].unfreeze(msg.sender);
        emit AccountUnFrozen(msg.sender);
    }

    // Function to make deposit
    function ttodDeposit(uint256 _ttodindex, bool _isCelo, address _ERC20Address) public payable {
       ttodArray[_ttodindex].deposit(_isCelo, _ERC20Address);
    }

    function ttodWithdraw(uint256 _ttodindex, bool _isCelo, uint _amount,  address _ERC20Address, address payable _feeAddress, uint _transferFee) public payable {
        ttodArray[_ttodindex].withdraw(_isCelo, _amount, _ERC20Address, msg.sender, _feeAddress, _transferFee);
    }

    function ttodTransferFunds(uint256 _ttodindex, bool _isCelo, address payable _recipient, uint _amount, address _ERC20Address, address payable _feeAddress, uint _transferFee) public payable {
        ttodArray[_ttodindex].transferFunds(_isCelo, _recipient, _amount, _ERC20Address, msg.sender, _feeAddress, _transferFee);
    }

    function ttodStopClaim(uint256 _ttodindex) public {
        ttodArray[_ttodindex].stopClaim(msg.sender);
        emit AccountStopClaim(msg.sender);
    }

    function ttodReturnOwner(uint256 _ttodindex) public view returns(address){
        return ttodArray[_ttodindex].returnOwner();
    }
    
     function ttodReturnHeir(uint256 _ttodindex) public view returns(address){
        return ttodArray[_ttodindex].returnHeir();
    }
    
    function ttodReturnDeployer(uint256 _ttodindex) public view returns(address){
        return ttodArray[_ttodindex].returnDeployer();
    }

    function getTTODsByDeployer(address _deployer) public view returns(uint256[] memory) {
        return deployerToTTOD[_deployer];
    }

    function getTTODsByOwner(address _owner) public view returns(uint256[] memory) {
        return ownerToTTOD[_owner];
    }

    function getTTODsByHeir(address _heir) public view returns(uint256[] memory) {
       return heirToTTOD[_heir];
    }


}

