// SPDX-License-Identifier: MIT

/// @title Lazy721 - A Lazy Minting ERC721 Contract
/// @author [Your Name]
/// @notice This contract provides a basic implementation of an ERC721 token with lazy minting capabilities.
/// @dev Utilizes OpenZeppelin's ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Pausable, Ownable, and ERC721Burnable.

pragma solidity ^0.8.25;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721Pausable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

/// @dev Using OpenZeppelin's Wizard configuration:
/// https://wizard.openzeppelin.com/

contract Lazy721 is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Pausable,
    Ownable,
    ERC721Burnable
{
    using Strings for string;
    /// @notice The next available token ID for minting.
    uint256 private _nextTokenId;

    /// @notice The maximum number of tokens that can be minted (token cap).
    uint256 private _tokenCap;

    /// @notice The base URI for token metadata.
    string private _uri;

    /// @notice Errors
    ///
    error Lazy721__TokenIdDoesntExist();
    error Lazy721__TokenCapExceeded();
    error Lazy721__QuantityMustBeGreaterThanCero();
    error InvalidERC721Receiver();

    /**
     * @notice Initializes the Lazy721 contract.
     * @param name The name of the ERC721 token.
     * @param symbol The symbol of the ERC721 token.
     * @param tokenCap The maximum number of tokens that can be minted.
     * @param uri The base URI for token metadata.
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 tokenCap,
        string memory uri
    ) ERC721(name, symbol) Ownable(msg.sender) {
        // Sanity Checks
        require(bytes(name).length > 0, "Name cannot be empty");
        require(bytes(symbol).length > 0, "Symbol cannot be empty");
        require(
            bytes(symbol).length <= 5,
            "Symbol should not exceed 5 characters"
        ); // Typical standard for symbols (e.g., ETH, BTC)
        require(tokenCap > 0, "Token cap must be greater than zero");
        require(bytes(uri).length > 0, "URI cannot be empty");
        require(_validateURI(uri), "Invalid URI");

        _tokenCap = tokenCap;
        _uri = uri;
    }

    /**
     * @notice Returns the base URI for token metadata.
     * @return The base URI string.
     */
    function _baseURI() internal view override returns (string memory) {
        return _uri;
    }

    /**
     * @notice Pauses the contract, restricting certain functions.
     * @dev Only callable by the contract owner.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @notice Unpauses the contract, enabling previously restricted functions.
     * @dev Only callable by the contract owner.
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @notice Safely mints a new token to the specified address.
     * @param to The address to receive the newly minted token.
     * @dev Only callable by the contract owner. Reverts if the token cap is exceeded.
     */
    function safeMint(address to) public onlyOwner {
        if (_nextTokenId >= _tokenCap) revert Lazy721__TokenCapExceeded();
        if (!isCapableERC721Receiver(to)) revert InvalidERC721Receiver();
        uint256 tokenId = _nextTokenId++;
        string memory uri = tokenURI(tokenId);
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    /**
     * @notice Updates the token ownership and authorization mappings.
     * @param to The new owner's address.
     * @param tokenId The ID of the token being updated.
     * @param auth The authorized operator.
     * @return The updated owner's address.
     * @dev Internal override for ERC721, ERC721Enumerable, and ERC721Pausable.
     */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    /**
     * @notice Increases the balance of the specified account.
     * @param account The account's address.
     * @param value The amount to increase the balance by.
     * @dev Internal override for ERC721 and ERC721Enumerable.
     */
    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    /**
     * @notice Returns the URI for the specified token's metadata.
     * @param tokenId The ID of the token.
     * @return The metadata URI string.
     * @dev Reverts if the token ID does not exist.
     */
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        if (tokenId > _nextTokenId) revert Lazy721__TokenIdDoesntExist();
        return
            string(
                abi.encodePacked(_baseURI(), Strings.toString(tokenId), ".json")
            );
    }

    /**
     * @notice Checks if the contract supports the specified interface.
     * @param interfaceId The interface ID to check for.
     * @return True if the interface is supported, false otherwise.
     * @dev Override for ERC721, ERC721Enumerable, and ERC721URIStorage.
     */
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function getTokensOwnedByUser(
        address _owner
    ) public view returns (uint256[] memory) {
        uint256 balance = balanceOf(_owner); // Get the number of tokens owned by the user
        uint256[] memory tokens = new uint256[](balance); // Create an array to store token IDs

        for (uint256 i = 0; i < balance; i++) {
            tokens[i] = tokenOfOwnerByIndex(_owner, i); // Get the token ID at the current index
        }

        return tokens;
    }

    function _validateURI(
        string memory uriResource
    ) internal pure returns (bool) {
        // Convert string to bytes to access length
        bytes memory uriBytes = bytes(uriResource);

        // Basic validation example
        if (
            uriBytes.length == 0 || // Now accessing length through bytes
            (!_startsWith(uriResource, "ipfs://"))
        ) {
            return false;
        }
        // Add more complex validation logic as needed
        return true;
    }

    function _startsWith(
        string memory _str,
        string memory _prefix
    ) internal pure returns (bool) {
        // Convert strings to bytes to access lengths
        bytes memory strBytes = bytes(_str);
        bytes memory prefixBytes = bytes(_prefix);

        // Simple startswith implementation
        if (strBytes.length < prefixBytes.length) {
            return false;
        }
        for (uint256 i = 0; i < prefixBytes.length; i++) {
            if (strBytes[i] != prefixBytes[i]) {
                return false;
            }
        }
        return true;
    }

    function isCapableERC721Receiver(address _to) public returns (bool) {
        // If the address is not a contract, assume it's an EOA and can receive
        if (_to.code.length == 0) return true;

        // Check if contract implements ERC721 Holder interface
        try ERC721Holder(_to).onERC721Received(
            address(this), // operator
            address(this), // from
            0,              // tokenId
            ""              // data
        ) returns (bytes4 retval) {
            // Verify the return value matches the ERC721 Holder interface
            return retval == ERC721Holder.onERC721Received.selector;
        } catch {
            // If the function call fails for any reason, assume it's not a capable receiver
            return false;
        }
    }
}
