// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRecord {

    function createPoint(uint point) external;

    function getPoint(uint point, address employee) public view returns (address, uint);

    function createRecord(address client, address employee, uint point, uint datetime) external;

    function recordExistsToday(address client) external view returns (bool);

    function paid(address employee, uint amount) external;
}
