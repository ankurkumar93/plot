// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract PlotContract {
    uint plotCount = 0;
    uint ownerCount = 0;

    mapping(uint => mapping (string => string)) plots;
    mapping(uint => Plot) public Plots;
    mapping(uint => Owner) public Owners;

    struct Plot {
        uint plotId;
        uint price;
        bool onSale;
        uint ownerId;
    }   

    event PlotSold(
        uint PlotId
    );

    event PlotOnSale(
        uint PlotId
    );

    struct Owner {
        uint id;
        uint balance;
        address ownerAddress;
    }

    function addOwner() public {
        ownerCount ++;
        Owners[ownerCount] = Owner(ownerCount, 50000, msg.sender);
    }

    function addPlot(uint _ownerId, uint _price) public {
        require(Owners[_ownerId].id > 0, "Owner with that id doesnt exist");
        plotCount ++;
        Plot storage p = Plots[plotCount];
        p.plotId = plotCount;
        p.price = _price;
        p.onSale = true;
        p.ownerId = _ownerId;
    }

    function buyPlot(uint _plotId, uint _newOwnerId, uint _price) public payable {
        require(Plots[_plotId].plotId > 0, "Plot with that id doesnt exist");
        require(Plots[_plotId].ownerId != _newOwnerId, "Owner can not buy a plot");
        require(Owners[_newOwnerId].id > 0, "User with that id doesnt exist");
        require(Owners[_newOwnerId].balance > _price, "Buyer doesnt have enough funds");
        require(_price >= Plots[_plotId].price, "Offered price should be greater than plot value");
        require(Plots[_plotId].onSale, "Plot is sold");
        Plot storage p = Plots[_plotId];
        Owners[Plots[_plotId].ownerId].balance += _price;
        p.ownerId = _newOwnerId;
        Owners[_newOwnerId].balance -= _price;
        p.onSale = false;
        emit PlotSold(_plotId);
    }

    function sellPlot(uint _ownerId, uint _plotId, uint _price) public {
        require(_ownerId != Plots[_plotId].ownerId, "Only an owner can list plot on sale");
        Plots[_plotId].onSale = true;
        Plots[_plotId].price = _price;
        emit PlotOnSale(_plotId);
    }    
}
