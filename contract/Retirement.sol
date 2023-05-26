// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RetirementAccount.sol";

// Factory contract for creating Retirement Wallet contracts
contract RetirementWalletFactory {

    // Accounts array
    Accounts[] public retirementArray;

    // Heir event 
    event BeneficiarySet(uint indexed retirementindex, address beneficiary);
    //Event to freeze
    event AccountPause(uint indexed retirementindex, address pauseAccount);
    //Event to unfreeze
    event AccountUnpause(uint indexed retirementindex, address unpauseAccount);
    //Event create contract
    event CreateAccount(address retirement, address owner);

 
    function createRetirementWallet() public returns(address) {
        Accounts retirement = new Accounts(payable(msg.sender));    
        retirementArray.push(retirement);
        emit CreateAccount(address(retirement), msg.sender);
        return address(retirement);
    }

   // Function to set the beneficiary and the time to withdraw all the money
    function retirementSetBeneficiary(uint256 _retirementindex, address payable _beneficiary, uint _delay, uint _amount, address _ERC20Address) public {
        retirementArray[_retirementindex].setBeneficiary(_beneficiary, _delay, _amount, _ERC20Address);
        emit BeneficiarySet(_retirementindex, _beneficiary);
    }


    // Function to pause the account
    function retirementPause(uint256 _retirementindex) public {
        retirementArray[_retirementindex].pause();
        emit AccountPause(_retirementindex, msg.sender);
   }

    // Function to unfreeze the account
    function retirementUnpause(uint256 _retirementindex) public {
        retirementArray[_retirementindex].unpause();
        emit AccountUnpause(_retirementindex, msg.sender);
    }


    // Function to transfer or withdraw Celo or ERC20
    function retirementTransferOrWithdraw(uint256 _retirementindex, bool _isWithdraw, bool _isCelo, address payable _recipient, uint _amount, address _ERC20Address) public payable {
        retirementArray[_retirementindex].transferOrWithdraw(_isWithdraw, _isCelo, _recipient, _amount, _ERC20Address);
    }

    // View to return the RetirementWallet
    function getRetirementWalletById(uint256 _retirementindex) public view returns(address) {
        return address(retirementArray[_retirementindex]);
    }

    // View to return the balance
    function getBalance(uint256 _retirementindex, bool _isCelo, address _ERC20Address) public view returns(uint) {
        return retirementArray[_retirementindex].balanceOf(_isCelo, _ERC20Address);
    }

    // View to return the owner
    function getOwner(uint256 _retirementindex) public view returns(address){
        return retirementArray[_retirementindex].returnOwner();
    }

    // View to return the beneficiary
     function getBeneficiary(uint256 _retirementindex) public view returns(address){
        return retirementArray[_retirementindex].returnBeneficiary();
    }

    // Function to return the delay of the account   
    function getDelay(uint256 _retirementindex) public view returns(uint){
        return retirementArray[_retirementindex].returnDelay();
    }


    // Function to return the timestamp when initiate the delay
    function getInitiateAt(uint256 _retirementindex) public view returns(uint){
        return retirementArray[_retirementindex].returnInitiateAt();
    }   

    // Function to return the withdraw limit for each token
    function getAmount(uint256 _retirementindex, address _ERC20Address) public view returns (uint) {
    return retirementArray[_retirementindex].getWithdrawLimit(_ERC20Address);
    }

    // Function to return the transfer fee of the account
    function getTransferFee(uint _retirementindex) public view returns(uint){
        return retirementArray[_retirementindex].returnTransferFee();
    }  

    // Return the owner
    function owners(address _owner) public view returns (uint256[] memory) {
    uint256[] memory resultArray = new uint256[](retirementArray.length);
    uint256 index = 0;
    for (uint256 i = 0; i < retirementArray.length; i++) {
        if (retirementArray[i].returnOwner() == _owner) {
            resultArray[index] = i;
            index++;
        }
    }
    return resultArray;
    }

    // Return the beneficiary
    function beneficiary(address _beneficiary) public view returns (uint256[] memory) {
    uint256[] memory resultArray = new uint256[](retirementArray.length);
    uint256 index = 0;
    for (uint256 i = 0; i < retirementArray.length; i++) {
        if (retirementArray[i].returnBeneficiary() == _beneficiary) {
            resultArray[index] = i;
            index++;
        }
    }
    return resultArray;
    } 


}

