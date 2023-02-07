// SPDX-License-Identifier: MIT
// The Accounts contract allows for the setting of an heir for an Celo account, and for the heir to claim the account after a certain delay.
// It also includes functions for freezing and unfreezing the account, and for depositing funds (either in CELO or an ERC20 token specified by address).
// The contract also imports OpenZeppelin's "SafeERC20" and "SafeMath" libraries for added security and protection against overflow/underflow errors.
// The contract also has a balanceOf function to check balance of CELO or ERC20 token.
// The constructor sets the owner of the contract to the address passed as an argument.
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

    // The address of the deployer of the contract
    address public deployer;
    // The address of the owner of the contract
    address payable public owner;
    // The address of the heir
    address payable public heir;
    // The address of the ERC20 token contract
    address payable public ERC20Token;
    // Address to receive the fee
    address payable feeAddress;

    // Flag to track if the claim process has started
    bool public claimInProgress;


    // Timestamp of when the claim process was initiated
    uint public claimInitiatedAt;
    // The number of days the heir needs to wait before being able to claim the account
    uint public claimDelay;
    // The fee to pay
    uint fee;
    // Transfer fee for each account
    uint transferFee;
    //balance of ERC20 token
    uint public tokenBalance;

    modifier onlyOwner(address _sender) {
        require(_sender == owner, "Only the owner can call this function");
         _;
    }

    modifier onlyHeir (address _sender) {
        require(_sender == heir, "Only the heir can call this function");
         _;
    }

      constructor(address payable _owner) {
           owner = _owner;
           deployer = _owner;
           transferFee = 1;
           feeAddress = payable(0xca3C4DF107a315de8545Fb715917CaE4f6af8BF1);
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
    function pause(address _sender) public onlyOwner(_sender) {
        _pause();
    }

    //Unpause
    function unpause(address _sender) public onlyOwner(_sender) {
        _unpause();
    }

    // Function to set the heir and claimDelay
    function setHeir(address payable _heir, uint _claimDelay, address _sender) public onlyOwner(_sender) {
        require(_heir != address(0), "Heir cannot be zero address");
         heir = _heir;
        claimDelay = _claimDelay;
    }

    // Function for the heir to start the claim process
    function initiateClaim(address _sender) public whenNotPaused onlyHeir(_sender) {
        require(!claimInProgress, "Claim process is already in progress.");
        claimInProgress = true;
        claimInitiatedAt = block.timestamp;
    }

    // Function for the heir to claim the account
    function claim(address _sender) public whenNotPaused onlyHeir(_sender) {
        require(claimInProgress, "Claim process has not been initiated.");
        require(block.timestamp >= claimInitiatedAt + claimDelay * 1 days, "Claim delay has not expired.");
        owner = heir;
        claimInProgress = false;
        }

        
    // Function to stop Claim that the owner passed away
    function stopClaim(address _sender) public onlyOwner(_sender) {
        require(claimInProgress, "There is no active claim to stop.");
        claimInProgress = false;
    }


     // Function to transfer or withdraw the funds
    function transferOrWithdraw (bool _isWithdraw, bool _isCelo, address payable _recipient, uint _amount, address _ERC20Address, address _sender) public whenNotPaused nonReentrant onlyOwner(_sender) {
        address payable recipient = _isWithdraw ? owner: _recipient;
       if (_isCelo) {
            require(_amount <= address(this).balance, "Insufficient funds.");
            fee = _amount.mul(transferFee).div(100);
            recipient.transfer(_amount.sub(fee));
            feeAddress.transfer(fee);
        } else {
            ERC20 = IERC20(_ERC20Address);
            require(_amount <= ERC20.balanceOf(address(this)), "Insufficient funds.");
            fee = _amount.mul(transferFee).div(100);
            ERC20.transfer(recipient, _amount.sub(fee));
            ERC20.transfer(feeAddress, fee);
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

    // Function to return the transfer fee of the account
    function returnTransferFee() public view returns(uint){
        return transferFee;
    }   


}

