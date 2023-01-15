// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./JointAccount.sol";

// Factory contract for creating Joint Wallet contracts
contract JointWalletFactory {

    // Accounts array
    Accounts[] public jointArray;
 
    function createJointWallet() public returns(address) {
       Accounts joint = new Accounts(payable(msg.sender));    
       jointArray.push(joint);
       return address(joint);
    }

   // Function to set the beneficiary and the time to withdraw all the money
    function jointSetBeneficiary(uint256 _jointindex, address payable _beneficiary, uint _sender) public {
        jointArray[_jointindex].setBeneficiary(_beneficiary, _delay, msg.sender);
    }

    // Function to set the amount that the beneficiary can withdraw
    function jointSetAmount(uint256 _jointindex, uint _amount, address _ERC20Address) public {
    require(jointArray[_jointindex].returnOwner() == msg.sender, "Only the owner can set the withdrawal limit.");
    jointArray[_jointindex].setWithdrawLimit(_amount, _ERC20Address);
}


    // Function to freeze the account
    function jointFreeze(uint256 _jointindex) public {
        jointArray[_jointindex].freeze(msg.sender);
   }

    // Function to unfreeze the account
    function jointUnfreeze(uint256 _jointindex) public {
        jointArray[_jointindex].unfreeze(msg.sender);
    }

    function approve(uint256 _jointindex, uint _amount, address _ERC20Address, address payable _contract) public payable {
        jointArray[_jointindex].approve(_amount, _ERC20Address, _contract);
    }

    function allowance ( uint256 _jointindex, address _ERC20Address, address payable _from, address payable _contract) public  view returns (uint256) {
        return jointArray[_jointindex].allowance( _ERC20Address, _from, _contract);
    }

    // Function to make deposit
    function jointDeposit(uint256 _jointindex, uint _amount, address payable _from, address _ERC20Address, address payable _contract) public payable {
        jointArray[_jointindex].deposit(/*_isCelo, */_amount, _from, _ERC20Address, _contract);
    }

    // Function to withdraw Celo or ERC20
    function jointWithdraw(uint256 _jointindex, bool _isCelo, uint _amount,  address _ERC20Address, address payable _feeAddress, uint _transferFee) public payable {
        jointArray[_jointindex].withdraw(_isCelo, _amount, _ERC20Address, msg.sender, _feeAddress, _transferFee);
    }

    // Function to transfer Celo or ERC20
    function jointTransferFunds(uint256 _jointindex, bool _isCelo, address payable _recipient, uint _amount, address _ERC20Address, address payable _feeAddress, uint _transferFee) public payable {
        jointArray[_jointindex].transferFunds(_isCelo, _recipient, _amount, _ERC20Address, msg.sender, _feeAddress, _transferFee);
    }

    // View to return the balance
    function jointBalance(uint256 _ttodindex, bool _isCelo, address _ERC20Address) public view returns(uint) {
        return jointArray[_ttodindex].balanceOf(_isCelo, _ERC20Address);
    }

    // View to return the owner
    function jointReturnOwner(uint256 _jointindex) public view returns(address){
        return jointArray[_jointindex].returnOwner();
    }

    // View to return the beneficiary
     function jointReturnBeneficiary(uint256 _jointindex) public view returns(address){
        return jointArray[_jointindex].returnBeneficiary();
    }

    // Function to return the delay of the account   
    function jointReturnDelay(uint256 _jointindex) public view returns(uint){
        return jointArray[_jointindex].returnDelay();
    }


    // Function to return the timestamp when initiate the delay
    function jointReturnInitiateAt(uint256 _jointindex) public view returns(uint){
        return jointArray[_jointindex].returnInitiateAt();
    }   

    // Return the owner
    function findOwner(address _owner) public view returns (uint256[] memory) {
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
    function findBeneficiary(address _beneficiary) public view returns (uint256[] memory) {
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


    // Function to return the withdraw limit for each token
    function jointGetAmount(uint256 _jointindex, address _ERC20Address) public view returns (uint) {
    return jointArray[_jointindex].getWithdrawLimit(_ERC20Address);
    }


}

