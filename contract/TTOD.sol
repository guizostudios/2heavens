// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./HeirAccount.sol";


// Factory contract for creating TTOD contracts
contract TTODFactory {

    // Accounts array
    Accounts[] public ttodArray;
    // Heir event
    event HeirSet(uint indexed ttodindex, address heir);
    // Claim event
    event ClaimInitiated(uint indexed ttodindex, address heir);
    // Account claimed event
    event AccountClaimed(uint indexed ttodindex, address newOwner);
    // Account stop claim event
    event AccountStopClaim(uint indexed ttodindex, address owner);
    //Event to pause
    event AccountPause(uint indexed ttodindex, address pauseAccount);
    //Event to unpause
    event AccountUnpause(uint indexed ttodindex, address unpauseAccount);
    //Event create contract
    event CreateAccount(address ttod, address owner);

 
    function createTTODWallet() public returns(address) {
       Accounts ttod = new Accounts(payable(msg.sender));    
       ttodArray.push(ttod);
       emit CreateAccount(address(ttod), msg.sender);
       return address(ttod);
    }

    // Function to set the heir and claimDelay
    function ttodSetHeir(uint256 _ttodindex, address payable _heir, uint _claimDelay) public {
        ttodArray[_ttodindex].setHeir(_heir, _claimDelay, msg.sender);
        emit HeirSet(_ttodindex, _heir);
        }
    // Function for the heir to start the claim process
    function ttodInitiateClaim(uint256 _ttodindex) public {
        ttodArray[_ttodindex].initiateClaim(msg.sender);
        emit ClaimInitiated(_ttodindex, msg.sender);
    }

    // Function for the heir to claim the account
    function ttodClaim(uint256 _ttodindex) public  {
        ttodArray[_ttodindex].claim(msg.sender);
        emit AccountClaimed(_ttodindex, msg.sender);
        }

    // Function to cancel the claim of account
    function ttodStopClaim(uint256 _ttodindex) public {
        ttodArray[_ttodindex].stopClaim(msg.sender);
        emit AccountStopClaim(_ttodindex, msg.sender);
    }

    // Function to pause the account
    function ttodPause(uint256 _ttodindex) public {
        ttodArray[_ttodindex].pause(msg.sender);
        emit AccountPause(_ttodindex, msg.sender);
    }

    // Function to unpause the account
    function ttodUnpause(uint256 _ttodindex) public {
        ttodArray[_ttodindex].unpause(msg.sender);
        emit AccountUnpause(_ttodindex, msg.sender);
    }


    // Function to transfer or withdraw Celo or ERC20
    function ttodTransferOrWithdraw(uint256 _ttodindex, bool _isWithdraw, bool _isCelo, address payable _recipient, uint _amount, address _ERC20Address) public payable {
        ttodArray[_ttodindex].transferOrWithdraw(_isWithdraw, _isCelo, _recipient, _amount, _ERC20Address, msg.sender);
    }

    // View to return the TTOD Wallet
    function getTtodWalletById(uint256 _ttodindex) public view returns(address) {
        return address(ttodArray[_ttodindex]);
    }

    // View to return the balance
    function getTtoBalance(uint256 _ttodindex, bool _isCelo, address _ERC20Address) public view returns(uint) {
        return ttodArray[_ttodindex].balanceOf(_isCelo, _ERC20Address);
    }

    // View to return the owner
    function getTtoOwner(uint256 _ttodindex) public view returns(address){
        return ttodArray[_ttodindex].returnOwner();
    }

    // View to return the heir  
     function getTtoHeir(uint256 _ttodindex) public view returns(address){
        return ttodArray[_ttodindex].returnHeir();
    }

    // View to return the deployer
    function getTtoDeployer(uint256 _ttodindex) public view returns(address){
        return ttodArray[_ttodindex].returnDeployer();
    }

    // Function to return the transfer fee of the account
    function getTtoTransferFee(uint _ttodindex) public view returns(uint){
        return ttodArray[_ttodindex].returnTransferFee();
    }   

    // Return the deployer
    function deployers(address _deployer) public view returns (uint256[] memory) {
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
    function owners(address _owner) public view returns (uint256[] memory) {
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
    function heirs(address _heir) public view returns (uint256[] memory) {
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

