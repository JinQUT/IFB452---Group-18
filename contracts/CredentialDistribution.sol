// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DistributeCredentials {
    // contract owner address, universities/educational institutions
    address public issuer;

    // struct to define the structure of the distribute credentials contract
    struct CredentialsData {
        address issuer;
        string studentName;
        string degree; 
        string degreeCompletionDate;
    }
    
    // mapping to store credential contract information
    mapping (uint256 => CredentialsData) public credentials;

    // Counter to keep track of the total number of credentials issued
    uint256 public credentialsCount;

    // event triggered when a new credential is distributed
    event CredentialsIssued(uint256 credentialID, address issuer, string studentName, string degree, string completionDate);

    // contract constructor dont need one?
    constructor() {
        issuer = msg.sender;
    }

    // restrict acess to only the university
    modifier onlyIssuer(){
        require(msg.sender == issuer, "Only the university issuer can execute this");
        _;
    }

    // issue credential function
    function issueCredential(string memory studentName, string memory degree, string memory degreeCompletionDate) public onlyIssuer {
        credentialsCount++;   
        // store credential
        credentials[credentialsCount] = CredentialsData(issuer, studentName, degree, degreeCompletionDate);
        emit CredentialsIssued(credentialsCount, issuer, studentName, degree, degreeCompletionDate);
    }

}