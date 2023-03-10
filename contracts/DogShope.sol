// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract DogShope {
    enum Breeds {
        GoldenRetriever,
        Bulldog,
        GermanShepherd,
        SiberianHusky,
        BorderCollie,
        Poodle,
        LabradorRetriever
    }
    mapping(Breeds => uint) public costOfOwnership;
    address public shopOwner;

    struct Dog {
        string name;
        Breeds breed;
    }
    mapping(address => Dog) ownerOf;

    constructor() {
        shopOwner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == shopOwner, "Only oiwner can sale the shop!");
        _;
    }

    function setOwner(address newOwner) public onlyOwner {
        shopOwner = newOwner;
    }

    function getBreedValueByKey(string memory breed) internal pure returns (Breeds) {
        if (keccak256(abi.encodePacked(breed)) == keccak256("GoldenRetriever")) return Breeds.GoldenRetriever;
        if (keccak256(abi.encodePacked(breed)) == keccak256("Bulldog")) return Breeds.Bulldog;
        if (keccak256(abi.encodePacked(breed)) == keccak256("GermanShepherd")) return Breeds.GermanShepherd;
        if (keccak256(abi.encodePacked(breed)) == keccak256("SiberianHusky")) return Breeds.SiberianHusky;
        if (keccak256(abi.encodePacked(breed)) == keccak256("BorderCollie")) return Breeds.BorderCollie;
        if (keccak256(abi.encodePacked(breed)) == keccak256("Poodle")) return Breeds.Poodle;
        if (keccak256(abi.encodePacked(breed)) == keccak256("LabradorRetriever")) return Breeds.LabradorRetriever;
        revert("Breed is not available in the shop!");
    }

    function setCost(string memory breed, uint price) external {
        assert(shopOwner == msg.sender);
        costOfOwnership[getBreedValueByKey(breed)] = price;
    }

    function ownADog(string memory name, string memory breed) public payable {
        require(costOfOwnership[getBreedValueByKey(breed)] <= msg.value, "Need to pay more to own a dog!");
        bool sent = payable(address(this)).send(msg.value);
        if (sent == false) {
            revert("failure while sending eth");
        }
        ownerOf[msg.sender] = Dog(name, getBreedValueByKey(breed));
    }

    function getBreedByOwner(address owner) external view returns (Dog memory) {
        return ownerOf[owner];
    }
}
