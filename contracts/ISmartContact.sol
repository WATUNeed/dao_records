// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISmartContact {

    function createPoint(
        uint32 point
    ) external;

    function joinEmployee(
        uint256 per_record,
        address employee
    ) external;

    function recordExists(
        uint32 point,
        address employee,
        address client,
        uint128 timestamp
    ) public view returns (bool exists);

    function createRecord(
        address client,
        address employee,
        uint32 point,
        uint128 timestamp,
        uint32 service
    ) external payable;
}
