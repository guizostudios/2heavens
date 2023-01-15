// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract Accounts {
    // The address of the owner of the contract
    address payable public owner;
    // The address of the beneficiary
    address payable public beneficiary;
    // Timestamp of when the delay started
    uint public InitiatedAt;
    // The number of days the beneficiary needs to wait before being able to withdraw all the money
    uint public delay;
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
    // Mapping for the specified ERC20 token to the provided amount
    mapping (address => uint) public withdrawLimit;



      constructor(address payable _owner) {
           owner = _owner;
    }

    // Function to set the beneficiary and the time to withdraw all the money
    function setBeneficiary(address payable _beneficiary, uint _delay, address _sender) public {
        require(owner == _sender, "Only the owner can set the beneficiary.");
        require(!mutex, "The function is already in execution.");
        mutex = true;
        beneficiary = _beneficiary;
        delay = _delay;
        mutex = false;
        InitiatedAt = block.timestamp;
    }


    // Function to set the amount that the beneficiary can withdraw
    function setWithdrawLimit(address _sender, uint _amount, address _ERC20Address) public {
    require(_sender == owner, "Only the owner can set the withdrawal limit.");
    withdrawLimit[_ERC20Address] = _amount;
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

    function approve(uint _amount, address _ERC20Address, address payable _contract) public payable {
        require(_amount > 0, "Cannot deposit 0 or less.");
        IERC20 token_ = IERC20(_ERC20Address);
        token_.approve(_contract, _amount);
   
    }

  
    function allowance ( address _ERC20Address, address payable _from, address payable _contract) public  view returns (uint256) {
        IERC20 token_ = IERC20(_ERC20Address);
        return token_.allowance(_from, _contract);
    }


    function deposit(uint _amount, address payable _from, address _ERC20Address, address payable _contract) public payable {
        // require(_amount > 0, "Cannot deposit 0 or less.");
        IERC20 token_ = IERC20(_ERC20Address);
        // token_.approve(_contract, _amount);
        require(token_.balanceOf(_from) >= _amount, "Insufficient balance");
        // require(token_.allowance(_from, _contract) >= _amount, "Allowance not granted yet");
        // delay added to ensure approve function has been mined
        //require(timing.sleep(10 seconds),"sleep failed");
        token_.transferFrom(_from, _contract, _amount);
    }

     se for beneficiary ver limite para cada moeda. Fazer para o transfer
    verificar amountWithdraw por que ele é declaro em cima e pode dar erro pois nao é passado no array
    retirar o valor do amountWithdraw
    // Function to withdraw the funds
    function withdraw(bool _isCelo, uint _amount, address _ERC20Address, address _sender, address payable _feeAddress, uint _transferFee) public payable {
        require(_sender == owner || _sender == beneficiary, "Only the owner or the beneficiary can withdraw funds.");
        if (_sender == beneficiary) {
            require(_amount <= amountWithdraw || (InitiatedAt + delay) < now, "The withdrawal amount exceeds the limit or delay has not passed yet.");
        }
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
        require(_sender == owner || _sender == beneficiary, "Only the owner or the beneficiary can withdraw funds.");
        if (_sender == beneficiary) {
            require(_amount <= amountWithdraw || (InitiatedAt + delay) < now, "The withdrawal amount exceeds the limit or delay has not passed yet.");
        }
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

     // Function to return the beneficiary of the account   
    function returnBeneficiary() public view returns(address){
        return beneficiary;
    }

    // Function to return the withdraw limit for each token
    function getWithdrawLimit(address _ERC20Address) public view returns (uint) {
    return withdrawLimit[_ERC20Address];
    }

    // Function to return the delay of the account   
    function returnDelay() public view returns(uint){
        return delay;
    }


    // Function to return the timestamp when initiate the delay
    function returnInitiateAt() public view returns(uint){
        return InitiatedAt;
    }   
 
}

