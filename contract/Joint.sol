// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./JointAccount.sol";

// Factory contract for creating Joint Wallet contracts
contract JointWalletFactory {

    // Accounts array
    Accounts[] public jointArray;

    // Heir event 
    event BeneficiarySet(uint indexed jointindex, address beneficiary);
    //Event to freeze
    event AccountPause(uint indexed jointindex, address pauseAccount);
    //Event to unfreeze
    event AccountUnpause(uint indexed jointindex, address unpauseAccount);
    //Event create contract
    event CreateAccount(address joint, address owner);

 
    function createJointWallet() public returns(address) {
        Accounts joint = new Accounts(payable(msg.sender));    
        jointArray.push(joint);
        emit CreateAccount(address(joint), msg.sender);
        return address(joint);
    }

   // Function to set the beneficiary and the time to withdraw all the money
    function jointSetBeneficiary(uint256 _jointindex, address payable _beneficiary, uint _delay, uint _amount, address _ERC20Address) public {
        jointArray[_jointindex].setBeneficiary(_beneficiary, _delay, _amount, _ERC20Address);
        emit BeneficiarySet(_jointindex, _beneficiary);
    }


    // Function to pause the account
    function jointPause(uint256 _jointindex) public {
        jointArray[_jointindex].pause();
        emit AccountPause(_jointindex, msg.sender);
   }

    // Function to unfreeze the account
    function jointUnpause(uint256 _jointindex) public {
        jointArray[_jointindex].unpause();
        emit AccountUnpause(_jointindex, msg.sender);
    }


    // Function to transfer or withdraw Celo or ERC20
    function jointTransferOrWithdraw(uint256 _jointindex, bool _isWithdraw, bool _isCelo, address payable _recipient, uint _amount, address _ERC20Address) public payable {
        jointArray[_jointindex].transferOrWithdraw(_isWithdraw, _isCelo, _recipient, _amount, _ERC20Address);
    }

    // View to return the JointWallet
    function getJointWalletById(uint256 _jointindex) public view returns(address) {
        return address(jointArray[_jointindex]);
    }

    // View to return the balance
    function getBalance(uint256 _jointindex, bool _isCelo, address _ERC20Address) public view returns(uint) {
        return jointArray[_jointindex].balanceOf(_isCelo, _ERC20Address);
    }

    // View to return the owner
    function getOwner(uint256 _jointindex) public view returns(address){
        return jointArray[_jointindex].returnOwner();
    }

    // View to return the beneficiary
     function getBeneficiary(uint256 _jointindex) public view returns(address){
        return jointArray[_jointindex].returnBeneficiary();
    }

    // Function to return the delay of the account   
    function getDelay(uint256 _jointindex) public view returns(uint){
        return jointArray[_jointindex].returnDelay();
    }


    // Function to return the timestamp when initiate the delay
    function getInitiateAt(uint256 _jointindex) public view returns(uint){
        return jointArray[_jointindex].returnInitiateAt();
    }   

    // Function to return the withdraw limit for each token
    function getAmount(uint256 _jointindex, address _ERC20Address) public view returns (uint) {
    return jointArray[_jointindex].getWithdrawLimit(_ERC20Address);
    }

    // Function to return the transfer fee of the account
    function getTransferFee(uint _ttodindex) public view returns(uint){
        return jointArray[_ttodindex].returnTransferFee();
    }  

    // Return the owner
    function owners(address _owner) public view returns (uint256[] memory) {
    uint256[] memory resultArray = new uint256[](jointArray.length);
    uint256 index = 0;
    for (uint256 i = 0; i < jointArray.length; i++) {
        if (jointArray[i].returnOwner() == _owner) {
            resultArray[index] = i;
            index++;
        }
    }
    return resultArray;
    }

    // Return the beneficiary
    function beneficiary(address _beneficiary) public view returns (uint256[] memory) {
    uint256[] memory resultArray = new uint256[](jointArray.length);
    uint256 index = 0;
    for (uint256 i = 0; i < jointArray.length; i++) {
        if (jointArray[i].returnBeneficiary() == _beneficiary) {
            resultArray[index] = i;
            index++;
        }
    }
    return resultArray;
    } 


}

