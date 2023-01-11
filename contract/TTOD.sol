// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./accounts.sol";

// Factory contract for creating TTOD contracts
contract TTODFactory {

    // Accounts array
    Accounts[] public ttodArray;
 
    function createTTOD() public returns(address) {
       Accounts ttod = new Accounts(payable(msg.sender));    
       ttodArray.push(ttod);
       return address(ttod);
    }

    // Function to set the heir and claimDelay
    function ttodSetHeir(uint256 _ttodindex, address payable _heir, uint _claimDelay) public {

        ttodArray[_ttodindex].setHeir(_heir, _claimDelay, msg.sender);
        }
// Function for the heir to start the claim process
    function ttodInitiateClaim(uint256 _ttodindex) public {
        ttodArray[_ttodindex].initiateClaim(msg.sender);
    }

    // Function for the heir to claim the account
    function ttodClaim(uint256 _ttodindex) public  {
        ttodArray[_ttodindex].claim(msg.sender);
        }

    function ttodWithdraw(uint256 _ttodindex, uint _amount) public payable {
        ttodArray[_ttodindex].withdraw(_amount, msg.sender);
    }

    function ttodStopClaim(uint256 _ttodindex) public {
        ttodArray[_ttodindex].stopClaim(msg.sender);
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

}

