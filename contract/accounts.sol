// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/49c0e4370d0cc50ea6090709e3835a3091e33ee2/contracts/token/ERC20/utils/SafeERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/49c0e4370d0cc50ea6090709e3835a3091e33ee2/contracts/utils/math/SafeMath.sol";

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
    // The fee to pay
    uint fee;
    // The address of the ERC20 token contract
    address payable public ERC20Token;
    // IERC20
    IERC20 public ERC20;
    //SafeMath for overflow and underflow protection
    using SafeMath for uint;
    // Reentrancy protection 
    bool public mutex = false;

      constructor(address payable _owner) {
           owner = _owner;
           deployer = msg.sender;
    }

    // Function to set the heir and claimDelay
    function setHeir(address payable _heir, uint _claimDelay, address _sender) public {
        require(owner == _sender, "Only the owner can set the heir.");
        require(!mutex, "The function is already in execution.");
        mutex = true;
         heir = _heir;
        claimDelay = _claimDelay;
        mutex = false;
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

    function withdraw(uint _amount, address _sender, address payable _feeAddress, uint _transferFee) public payable {
        require(_sender == owner, "Only the owner can withdraw funds.");
        require(address(this).balance > 0, "There are no funds to withdraw.");
        require(_amount <= address(this).balance, "Insufficient funds.");
        require(!mutex, "The function is already in execution.");
        mutex = true;
        fee = _amount.mul(_transferFee).div(100);
        owner.transfer(_amount.sub(fee));
        _feeAddress.transfer(fee);
        mutex = false;
    }

    function withdrawERC20(uint _amount, address _ERC20Address, address _sender, address payable _feeAddress, uint _transferFee) public payable {
        require(_sender == owner, "Only the owner can withdraw funds.");
        ERC20 = IERC20(_ERC20Address);
        require(ERC20.balanceOf(address(this)) > 0, "There are no funds to withdraw.");
        require(_amount <= ERC20.balanceOf(address(this)), "Insufficient funds.");
        require(!mutex, "The function is already in execution.");
        mutex = true;
        fee = _amount.mul(_transferFee).div(100);
        ERC20.transfer(owner, _amount.sub(fee));
        _feeAddress.transfer(fee);
        mutex = false;
    }

    function transferFunds(address payable _recipient, uint _amount, address _sender, address payable _feeAddress, uint _transferFee) public payable {
        require(_sender == owner, "Only the owner can transfer funds.");
        require(_amount <= address(this).balance, "Insufficient funds.");
        require(!mutex, "The function is already in execution.");
        mutex = true;
        fee = _amount.mul(_transferFee).div(100);
        _recipient.transfer(_amount.sub(fee));
        _feeAddress.transfer(fee);
        mutex = false;
}

    function transferERC20Funds(address payable _recipient, uint _amount, address _ERC20Address, address _sender, address payable _feeAddress, uint _transferFee) public payable {
        require(_sender == owner, "Only the owner can transfer funds.");
        ERC20 = IERC20(_ERC20Address);
        require(_amount <= ERC20.balanceOf(address(this)), "Insufficient funds.");
        require(!mutex, "The function is already in execution.");
        mutex = true;
        fee = _amount.mul(_transferFee).div(100);
        ERC20.transfer(_recipient, _amount.sub(fee));
        _feeAddress.transfer(fee);
        mutex = false;
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

