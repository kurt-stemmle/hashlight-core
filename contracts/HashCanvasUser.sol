// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.17;

import "./lib/IERC721.sol";
import "./lib/IERC721Receiver.sol";
import "./lib/IERC721Metadata.sol";

import "./lib/Strings.sol";
import "./lib/ERC165.sol";

contract HashCanvasUser is ERC165, IERC721, IERC721Metadata {
    event CanvasChange();

    using Strings for uint256;

    string private _name;
    string private _symbol;
    bool public isMinted = false;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    address public owner;

    string public creatorName;
    string public creatorURL;
    string public description;

    address public parentContractAddress;

    bytes32[128] public bitMap;

    uint256 public audioPaletteId;
    uint256 public springPaletteId;
    uint256 public summerPaletteId;
    uint256 public fallPaletteId;
    uint256 public winterPaletteId;
    uint256 public christmasPaletteId;

    address public audioPaletteRepoAddress;
    address public colorPaletteRepoAddress;

    constructor(
        string memory name_,
        string memory symbol_,
        address owner_,
        address parent,
        address audioRepo,
        address colorRepo
    ) {
        _name = name_;
        _symbol = symbol_;
        owner = owner_;
        parentContractAddress = parent;
        audioPaletteRepoAddress = audioRepo;
        colorPaletteRepoAddress = colorRepo;
    }

    function getPaletteId() public view returns (uint256) {
        uint256 thisYear = block.timestamp % 31556926;

        if (thisYear > 30585600) {
            return christmasPaletteId;
        } else if (thisYear > 22809600) {
            return springPaletteId;
        } else if (thisYear < 13305600) {
            return summerPaletteId;
        } else if (thisYear < 6739200) {
            return fallPaletteId;
        } else {
            return winterPaletteId;
        }
    }

    function setSummerPalette(uint256 index) public {
        require(msg.sender == owner);
        summerPaletteId = index;
    }

    function setWinterPalette(uint256 index) public {
        require(msg.sender == owner);
        winterPaletteId = index;
    }

    function setChristmasPalette(uint256 index) public {
        require(msg.sender == owner);
        christmasPaletteId = index;
    }

    function setFallPalette(uint256 index) public {
        require(msg.sender == owner);
        fallPaletteId = index;
    }

    function setSpringPalette(uint256 index) public {
        require(msg.sender == owner);
        springPaletteId = index;
    }

    function setOwner(address to) public {
        require(msg.sender == owner);
        owner = to;
    }

    function setCreatorName(string memory name_) public {
        require(msg.sender == owner);
        require(!isMinted);
        creatorName = name_;
    }

    function setDescription(string memory newDescription) public {
        require(msg.sender == owner);
        require(!isMinted);
        description = newDescription;
    }

    function setCreatorURL(string memory newURL) public {
        require(!isMinted);
        require(msg.sender == owner);
        creatorURL = newURL;
    }

    function MintTo(address to) public {
        require(msg.sender == owner);
        require(!isMinted);
        _safeMint(to, 1);
        isMinted = true;
    }

    function getMap() public view returns (bytes32[128] memory) {
        return bitMap;
    }

    function setAudioPaletteId(uint256 id) public {
        require(msg.sender == owner);
        require(!isMinted);
        audioPaletteId = id;
    }

    function setMany(uint256[] memory indexes, bytes32[] memory update) public {
        require(!isMinted, "NFT is minted");
        require(msg.sender == owner);
        require(update.length == 15);
        require(indexes.length == 15);
        bitMap[indexes[0]] = update[0];
        bitMap[indexes[1]] = update[1];
        bitMap[indexes[2]] = update[2];
        bitMap[indexes[3]] = update[3];
        bitMap[indexes[4]] = update[4];
        bitMap[indexes[5]] = update[5];
        bitMap[indexes[6]] = update[6];
        bitMap[indexes[7]] = update[7];
        bitMap[indexes[8]] = update[8];
        bitMap[indexes[9]] = update[9];
        bitMap[indexes[10]] = update[10];
        bitMap[indexes[11]] = update[11];
        bitMap[indexes[12]] = update[12];
        bitMap[indexes[13]] = update[13];
        bitMap[indexes[14]] = update[14];
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner_)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            owner_ != address(0),
            "ERC721: address zero is not a valid owner"
        );
        return _balances[owner_];
    }

    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        address tokenOwner = _owners[tokenId];
        require(tokenOwner != address(0), "ERC721: invalid token ID");
        return tokenOwner;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function setNFTName(string memory newName) public {
        require(!isMinted, "NFT is minted");
        require(msg.sender == owner);
        _name = newName;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function setNFTSymbol(string memory newSym) public {
        require(!isMinted, "NFT is minted");
        require(msg.sender == owner);
        _symbol = newSym;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        _requireMinted(tokenId);
        string memory add = Strings.toHexString(
            uint256(uint160(address(this))),
            20
        );
        return string.concat("https://www.hashlight.org/metadata/", add);
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address tokeOwner = HashCanvasUser.ownerOf(tokenId);
        require(to != tokeOwner, "ERC721: approval to current owner");

        require(
            msg.sender == tokeOwner || isApprovedForAll(tokeOwner, msg.sender),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address tokeOwner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[tokeOwner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: caller is not token owner nor approved"
        );

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: caller is not token owner nor approved"
        );
        _safeTransfer(from, to, tokenId, data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        address tokeOwner = HashCanvasUser.ownerOf(tokenId);
        return (spender == tokeOwner ||
            isApprovedForAll(tokeOwner, spender) ||
            getApproved(tokenId) == spender);
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(
            HashCanvasUser.ownerOf(tokenId) == from,
            "ERC721: transfer from incorrect owner"
        );
        require(to != address(0), "ERC721: transfer to the zero address");

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(HashCanvasUser.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address tokeOwner,
        address operator,
        bool approved
    ) internal virtual {
        require(tokeOwner != operator, "ERC721: approve to caller");
        _operatorApprovals[tokeOwner][operator] = approved;
        emit ApprovalForAll(tokeOwner, operator, approved);
    }

    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.code.length > 0) {
            try
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}
