// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

import "./TTOD.sol";
// Factory contract for creating TTOD contracts
contract TTODFactory {

    TTOD[] public ttodArray;
  
    function createTTOD() public returns(address) {
       TTOD ttod = new TTOD(msg.sender);    
       ttodArray.push(ttod);
       return address(ttod);
    }

    // Function to set the heir and claimDelay
    function factorysetHeir(uint256 _ttodindex, address _heir, uint _claimDelay) public {

        ttodArray[_ttodindex].setHeir(_heir, _claimDelay, msg.sender);
        }
// Function for the heir to start the claim process
    function factoryinitiateClaim(uint256 _ttodindex) public {
        ttodArray[_ttodindex].initiateClaim(msg.sender);
    }

    // Function for the heir to claim the account
    function factoryclaim(uint256 _ttodindex) public  {
        ttodArray[_ttodindex].claim(msg.sender);
        }

    function factorywithdraw(uint256 _ttodindex) public payable {
        ttodArray[_ttodindex].withdraw(msg.sender);
    }

    function factorystopClaim(uint256 _ttodindex) public {
        ttodArray[_ttodindex].stopClaim(msg.sender);
    }

    function factoryreturnOwner(uint256 _ttodindex) public view returns(address){
        return ttodArray[_ttodindex].returnOwner();
    }

}

