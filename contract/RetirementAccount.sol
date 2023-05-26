// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Accounts is Pausable, ReentrancyGuard {
    // IERC20
    IERC20 public ERC20;
    //SafeMath for overflow and underflow protection
    using SafeMath for uint;

    // The address of the owner of the contract
    address payable public owner;
    // The address of the beneficiary
    address payable public beneficiary;
     // The address of the ERC20 token contract
    address payable public ERC20Token;
    // Address to receive the fee
    address payable feeAddress;

    // Timestamp of when the delay started
    uint public InitiatedAt;
    // The number of days the beneficiary needs to wait before being able to withdraw all the money
    uint public delay;
    // The fee to pay
    uint fee;
    // Transfer fee for each account
    uint transferFee;
    //balance of ERC20 token
    uint public tokenBalance;
 
    // Mapping for the specified ERC20 token to the provided amount
    mapping (address => uint) public withdrawLimit;

    // Modifier only owner
    modifier onlyOwner() {
        require(owner == msg.sender, "Only the owner can call this function");
         _;
    }

    // Modifier owner or beneficiary
    modifier requireBeneficiaryOrOwner() {
        require(beneficiary == msg.sender || msg.sender == owner, "Only the owner or the beneficiary can call this function");
         _;
    }

      constructor(address payable _owner) {

        require(_owner != address(0), "Owner address cannot be zero address"); 
        owner = _owner;
        transferFee = 1;
        feeAddress =  payable(0xca3C4DF107a315de8545Fb715917CaE4f6af8BF1);
    }


    //Fallback function
    fallback () external payable {
        emit Deposit(address(this), msg.sender, msg.value);
    } 

    //Receive function
    receive () external payable {
        emit Deposit(address(this), msg.sender, msg.value);
    }

    // Deposit event
    event Deposit(address indexed contractAddress, address indexed from, uint amount);

    //Pause
    function pause() public onlyOwner {
        _pause();
    }

    //Unpause
    function unpause() public onlyOwner {
        _unpause();
    }  

    // Function to set the beneficiary and the time to withdraw all the money
    function setBeneficiary(address payable _beneficiary, uint _delay,  uint _amount, address _ERC20Address) public onlyOwner {
        require(_beneficiary != address(0), "Beneficiary cannot be zero address");
        require(_ERC20Address != address(0), "ERC20 address cannot be zero address");
        beneficiary = _beneficiary;
        delay = _delay;
        InitiatedAt = block.timestamp;
        withdrawLimit[_ERC20Address] = _amount;
    }



    // Function to transfer the funds
    function transferOrWithdraw(bool _isWithdraw, bool _isCelo, address payable _recipient, uint _amount, address _ERC20Address) public whenNotPaused nonReentrant requireBeneficiaryOrOwner {
        require(_amount != 0, "Amount cannot be zero");
        if (msg.sender == beneficiary) {
            require(_amount <= withdrawLimit[_ERC20Address] || (InitiatedAt + delay) < block.timestamp , "The withdrawal amount exceeds the limit or delay has not passed yet.");
        }
        address payable recipient = _isWithdraw ? owner: _recipient;
       if (_isCelo) {
            require(_amount <= address(this).balance, "Insufficient funds.");
            fee = _amount.mul(transferFee).div(100);
            recipient.transfer(_amount.sub(fee));
            feeAddress.transfer(fee);
            withdrawLimit[_ERC20Address] -= _amount;
         } else {
            require(_ERC20Address != address(0), "ERC20 address cannot be zero address");
            ERC20 = IERC20(_ERC20Address);
            require(_amount <= ERC20.balanceOf(address(this)), "Insufficient funds.");
            fee = _amount.mul(transferFee).div(100);
            ERC20.transfer(recipient, _amount.sub(fee));
            ERC20.transfer(feeAddress, fee);
            withdrawLimit[_ERC20Address] -= _amount;
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

    // Function to return the transfer fee of the account
    function returnTransferFee() public view returns(uint){
        return transferFee;
    }   
 
}


