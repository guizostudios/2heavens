// SPDX-License-Identifier: MIT
// The Accounts contract allows for the setting of an heir for an Celo account, and for the heir to claim the account after a certain delay.
// It also includes functions for freezing and unfreezing the account, and for depositing funds (either in CELO or an ERC20 token specified by address).
// The contract also imports OpenZeppelin's "SafeERC20" and "SafeMath" libraries for added security and protection against overflow/underflow errors.
// The contract also includes event emitters for freezing and unfreezing and also has a mutex to prevent reentrancy attack.
// The contract also has a balanceOf function to check balance of CELO or ERC20 token.
// The constructor sets the owner of the contract to the address passed as an argument.

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


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
    //balance of ERC20 token
    uint public tokenBalance;
    // Freeze account
    bool public frozen = false;
    //Event to unfreeze
    event Unfreeze(address unfreezeBy);
    //Event to freeze
    event Freeze(address freezeBy);


      constructor(address payable _owner) {
           owner = _owner;
           deployer = _owner;
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
        claimInProgress = false;
        }

        
    // Function to stop Claim that the owner passed away
    function stopClaim(address _sender) public {
        require(_sender == owner, "Only the owner can stop a claim.");
        require(claimInProgress, "There is no active claim to stop.");
        claimInProgress = false;
    }


    // Function to freeze the account
    function freeze(address _sender) public {
        require(_sender == owner, "Only the owner can freeze the account.");
        frozen = true;
        emit Freeze(_sender);
    }

    // Function to unfreeze the account
    function unfreeze(address _sender) public {
        require(_sender == owner, "Only the owner can unfreeze the account.");
        frozen = false;
        emit Unfreeze(_sender);
    }

   // Function to approve the deposit
    function approve(uint _amount,  address _ERC20Address, address payable _contract) public payable {
        require(_amount > 0, "Cannot deposit 0 or less.");
        IERC20 token_ = IERC20(_ERC20Address);
        token_.approve(_contract, _amount);
   
    }


   // Function to return the deposit approval
    function allowance ( address _ERC20Address, address payable _from, address payable _contract) public  view returns (uint256) {
        IERC20 token_ = IERC20(_ERC20Address);
        return token_.allowance(  _from, _contract);
    }

    // Function to make deposit
    function deposit(uint _amount,  address payable _from, address _ERC20Address, address payable _contract) public payable {
        require(_amount > 0, "Cannot deposit 0 or less.");
        IERC20 token_ = IERC20(_ERC20Address);
        require(token_.balanceOf(_from) >= _amount, "Insufficient balance");
        token_.transferFrom(_from, _contract, _amount);
    }


    // Function to withdraw the funds
    function withdraw(bool _isCelo, uint _amount, address _ERC20Address, address _sender, address payable _feeAddress, uint _transferFee) public payable {
        require(_sender == owner, "Only the owner can withdraw funds.");
        require(!frozen, "Account is frozen, cannot withdraw funds.");
        if (_isCelo) {
            require(address(this).balance > 0, "There are no funds to withdraw.");
            require(_amount <= address(this).balance, "Insufficient funds.");
            require(!mutex, "The function is already in execution.");
            mutex = true;
            fee = _amount.mul(_transferFee).div(100);
            owner.transfer(_amount.sub(fee));
            _feeAddress.transfer(fee);
            mutex = false;
         } else {

        ERC20 = IERC20(_ERC20Address);
        require(ERC20.balanceOf(address(this)) > 0, "There are no funds to withdraw.");
        require(_amount <= ERC20.balanceOf(address(this)), "Insufficient funds.");
        require(!mutex, "The function is already in execution.");
        mutex = true;
        fee = _amount.mul(_transferFee).div(100);
        ERC20.transfer(owner, _amount.sub(fee));
        ERC20.transfer(_feeAddress, fee);
        mutex = false;
         }
    }

    // Function to transfer the funds
    function transferFunds(bool _isCelo, address payable _recipient, uint _amount, address _ERC20Address, address _sender, address payable _feeAddress, uint _transferFee) public payable {
        require(_sender == owner, "Only the owner can transfer funds.");
        require(!frozen, "Account is frozen, cannot withdraw funds.");
       if (_isCelo) {
            require(_amount <= address(this).balance, "Insufficient funds.");
            require(!mutex, "The function is already in execution.");
            mutex = true;
            fee = _amount.mul(_transferFee).div(100);
            _recipient.transfer(_amount.sub(fee));
            _feeAddress.transfer(fee);
            mutex = false;
        } else {
            ERC20 = IERC20(_ERC20Address);
            require(_amount <= ERC20.balanceOf(address(this)), "Insufficient funds.");
            require(!mutex, "The function is already in execution.");
            mutex = true;
            fee = _amount.mul(_transferFee).div(100);
            ERC20.transfer(_recipient, _amount.sub(fee));
            ERC20.transfer(_feeAddress, fee);
            mutex = false;
        }
    }

    // Function for the balance of the account
    function balanceOf(bool _isCelo, address _ERC20Address) public view returns(uint) {
    if (_isCelo) {
        return address(this).balance;
    } else {
        return IERC20(_ERC20Address).balanceOf(address(this));
           }
    }

    // Function to return the owner of the account
    function returnOwner() public view returns(address){
        return owner;
    }

     // Function to return the heir of the account   
    function returnHeir() public view returns(address){
        return heir;
    }
    
    // Function to return the deployer of the account
    function returnDeployer() public view returns(address){
        return deployer;
    }


}

