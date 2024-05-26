// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Declare Smart Contract CredentialVerification
contract CredentialVerification {
    // Defines a struct to hold details about a student's credential
    struct Credential {
        uint256 studentId;
        string studentName;
        string institution;
        string qualification;
        string dateIssued;
        string additionalData;
        bytes32 signature; // A cryptographic signature to verify the authenticity of the data
    }

    // A public mapping to store credentials for each student by their student ID
    mapping(uint256 => Credential) public credentials;

    // A mapping to track which addresses are authorized as employers
    mapping(address => bool) public isEmployer;

    mapping(uint256 => address) public studentAddresses; // Mapping from studentId to Ethereum address

    // A nested mapping to manage permissions, where each student ID maps to another mapping
    // that tracks which employer addresses have been granted permission to view their credentials
    mapping(uint256 => mapping(address => bool)) public permissions;

    // Events to notify the blockchain about certain actions
    event VerificationResult(address employer, bool isVerified, string message);
    event PermissionRequested(uint256 studentId, address employer);
    event PermissionGranted(uint256 studentId, address employer);
    event PermissionDenied(uint256 studentId, address employer);

    // A modifier to restrict function access to only those addresses registered as employers
    modifier onlyEmployer() {
        require(isEmployer[msg.sender], "Caller is not an authorised employer");
        _; // Continue execution of the function if the check passes
    }

    // Public function to add an employer's address to the mapping of authorized employers
    function addEmployer(address employer) public {
        require(!isEmployer[employer], "Employer already authorized.");
        isEmployer[employer] = true;
    }


    // Function for employers to request permission to access a student's credentials
    function requestPermission(uint256 studentId) public onlyEmployer {
        require(credentials[studentId].studentId != 0, "Student ID is not registered.");
        require(studentAddresses[studentId] != address(0), "No Ethereum address registered for this student.");
        emit PermissionRequested(studentId, msg.sender);
    }

    // Function for granting an employer permission to access a student's credentials
    function grantPermission(uint256 studentId, address employer) public {
        require(msg.sender == studentAddresses[studentId], "Only the student can grant permission");
        require(isEmployer[employer], "Employer is not authorized");
        permissions[studentId][employer] = true;
        emit PermissionGranted(studentId, employer);
    }

    // Function to deny or revoke an employer's permission to access a student's credentials
    function denyPermission(uint256 studentId, address employer) public {
        require(msg.sender == studentAddresses[studentId], "Only the student can deny permission");
        require(isEmployer[employer], "Employer is not authorized");
        permissions[studentId][employer] = false;
        emit PermissionDenied(studentId, employer);
    }

    // Function to read and return a student's credentials data if the employer has permission
    function readCredential(uint256 studentId) public view onlyEmployer returns (string memory) {
        require(permissions[studentId][msg.sender], "Permission not granted by the student");
        Credential memory cred = credentials[studentId];
        return generateVerificationMessage(cred);
    }

    // Function to verify the integrity of the credentials using the stored cryptographic signature
    function verifyCredentials(uint256 studentId, bytes32 credentialHash) public view onlyEmployer returns (bool) {
        require(permissions[studentId][msg.sender], "Employer does not have permission to verify this student's credentials");
        Credential memory cred = credentials[studentId];
        return (cred.signature == credentialHash);
    }

    // Function to register or record new credentials for a student
    function registerCredential(uint256 studentId, string memory studentName, string memory institution, string memory qualification, string memory dateIssued, string memory additionalData, bytes32 signature, address studentAddress) public {
    // Ensure that the student ID and address are not already registered to prevent overwriting
    require(credentials[studentId].studentId == 0, "Credentials already registered for this student ID.");
    require(studentAddresses[studentId] == address(0), "Address already registered for this student ID.");

    credentials[studentId] = Credential(studentId, studentName, institution, qualification, dateIssued, additionalData, signature);
    studentAddresses[studentId] = studentAddress;
}

    // Private function to generate a formatted string message displaying a credential's details
    function generateVerificationMessage(Credential memory credential) private pure returns (string memory) {
        return string(abi.encodePacked(
            "Name: ", credential.studentName,
            ", Institution: ", credential.institution,
            ", Qualification: ", credential.qualification,
            ", Date Issued: ", credential.dateIssued
        ));
    }
}
