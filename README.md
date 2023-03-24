# 2heavens - A Decentralized Retirement Management
We help users invest in their future retirement plans by providing two different services: a B2C service that enables users to set up retirement accounts for their children, and a B2B service that provides a private retirement plan for companies.

The B2B service is designed for companies and enables them to create rules through smart contracts for employee retention. This service is tailored to help companies incentivize their employees to stay with the company for a longer period, which can be particularly important for startups or growing companies where employee retention is critical.

Our approach is decentralized, which means that the user holds the power. The investments are kept in a smart contract that has customizable rules chosen by the owner. Only the owner has the right to access the funds or delegate access to other individuals.


## Features

Our smart contract is designed to manage the funds of an account. It allows the owner of the contract to set a beneficiary and a delay time before the beneficiary can withdraw all the funds. The contract also has the ability to set a withdraw limit for specific ERC20 tokens and has reentrancy protection. Additionally, the contract includes functions to freeze and unfreeze the account, approve and check deposit approvals, make a deposit, and withdraw funds. Overall, this smart contract provides a secure and efficient way to manage funds and control access to them.

## Security

Our smart contracts are built with security in mind and use the OpenZeppelin "SafeERC20" and "SafeMath" libraries for added security and protection against overflow/underflow errors. Additionally, our contracts include event emitters for freezing and unfreezing and also have a mutex to prevent reentrancy attacks. 

The smart contract was audited by Immunebytes as you can see on the report https://drive.google.com/file/d/1lQA2nDCd1yQ-0BPyEgiU0au8m5EMWmu6/view


## How to Use
To use 2heavens, you will need to connect to the Celo blockchain using a wallet such as MetaMask. From there, you can interact with the smart contracts to manage your crypto assets and set up retirement plans.

## Conclusion
We are making the process of retirement easier and more efficient for everyone.

 
