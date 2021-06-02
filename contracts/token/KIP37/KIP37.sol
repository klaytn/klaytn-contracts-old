// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

import "./IKIP37.sol";
import "./IKIP37MetadataURI.sol";
import "./IKIP37Receiver.sol";
import "./IERC1155Receiver.sol";
import "../../GSN/Context.sol";
import "../../introspection/KIP13.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

/**
 *
 * @dev Implementation of the basic standard multi-token.
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 */
contract KIP37 is Context, KIP13, IKIP37, IKIP37MetadataURI {
    using SafeMath for uint256;
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Mapping from token ID to the total supply of the token
    mapping(uint256 => uint256) private _totalSupply;

    // Used as the URI for all token types by relying on ID substition, e.g. https://token-cdn-domain/{id}.json
    string internal _uri;

    /*
     *     bytes4(keccak256('balanceOf(address,uint256)')) == 0x00fdd58e
     *     bytes4(keccak256('balanceOfBatch(address[],uint256[])')) == 0x4e1273f4
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,uint256,bytes)')) == 0xf242432a
     *     bytes4(keccak256('safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)')) == 0x2eb2c2d6
     *     bytes4(keccak256('totalSupply(uint256)')) == 0xbd85b039
     *
     *     => 0x00fdd58e ^ 0x4e1273f4 ^ 0xa22cb465 ^
     *        0xe985e9c5 ^ 0xf242432a ^ 0x2eb2c2d6 ^ 0xbd85b039 == 0x6433ca1f
     */
    bytes4 private constant _INTERFACE_ID_KIP37 = 0x6433ca1f;

    /*
     *     bytes4(keccak256('uri(uint256)')) == 0x0e89341c
     */
    bytes4 private constant _INTERFACE_ID_KIP37_METADATA_URI = 0x0e89341c;

    bytes4 private constant _INTERFACE_ID_KIP37_TOKEN_RECEIVER = 0x7cc2d017;

    bytes4 private constant _INTERFACE_ID_ERC1155_TOKEN_RECEIVER = 0x4e2312e0;

    // Equals to `bytes4(keccak256("onKIP37Received(address,address,uint256,uint256,bytes)"))`
    // which can be also obtained as `IKIP37Receiver(0).onKIP37Received.selector`
    bytes4 private constant _KIP37_RECEIVED = 0xe78b3325;

    // Equals to `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
    // which can be also obtained as `IERC1155Receiver(0).onERC1155Received.selector`
    bytes4 private constant _ERC1155_RECEIVED = 0xf23a6e61;

    // Equals to `bytes4(keccak256("onKIP37BatchReceived(address,address,uint256[],uint256[],bytes)"))`
    // which can be also obtained as `IKIP37Receiver(0).onKIP37BatchReceived.selector`
    bytes4 private constant _KIP37_BATCH_RECEIVED = 0x9b49e332;

    // Equals to `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
    // which can be also obtained as `IERC1155Receiver(0).onERC1155BatchReceived.selector`
    bytes4 private constant _ERC1155_BATCH_RECEIVED = 0xbc197c81;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri) public {
        _setURI(uri);

        // register the supported interfaces to conform to KIP37 via KIP13
        _registerInterface(_INTERFACE_ID_KIP37);

        // register the supported interfaces to conform to KIP37MetadataURI via KIP13
        _registerInterface(_INTERFACE_ID_KIP37_METADATA_URI);
    }

    /**
     * @dev See {IKIP37MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substituion mechanism
     * http://kips.klaytn.com/KIPs/kip-37#metadata
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) external view returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IKIP37-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id)
        public
        view
        returns (uint256)
    {
        require(
            account != address(0),
            "KIP37: balance query for the zero address"
        );
        return _balances[id][account];
    }

    /**
     * @dev See {IKIP37-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        returns (uint256[] memory)
    {
        require(
            accounts.length == ids.length,
            "KIP37: accounts and ids length mismatch"
        );

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            require(
                accounts[i] != address(0),
                "KIP37: batch balance query for the zero address"
            );
            batchBalances[i] = _balances[ids[i]][accounts[i]];
        }

        return batchBalances;
    }

    /**
     * @dev See {IKIP37-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public {
        require(
            _msgSender() != operator,
            "KIP37: setting approval status for self"
        );

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IKIP37-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator)
        public
        view
        returns (bool)
    {
        return _operatorApprovals[account][operator];
    }

    function totalSupply(uint256 _tokenId) public view returns (uint256) {
        return _totalSupply[_tokenId];
    }

    /**
     * @dev See {IKIP37-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public {
        require(to != address(0), "KIP37: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "KIP37: caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            from,
            to,
            _asSingletonArray(id),
            _asSingletonArray(amount),
            data
        );

        _balances[id][from] = _balances[id][from].sub(
            amount,
            "KIP37: insufficient balance for transfer"
        );
        _balances[id][to] = _balances[id][to].add(amount);

        emit TransferSingle(operator, from, to, id, amount);

        require(
            _doSafeTransferAcceptanceCheck(
                operator,
                from,
                to,
                id,
                amount,
                data
            ),
            "KIP37: transfer to non KIP37Receiver implementer"
        );
    }

    /**
     * @dev See {IKIP37-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public {
        require(
            ids.length == amounts.length,
            "KIP37: ids and amounts length mismatch"
        );
        require(to != address(0), "KIP37: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "KIP37: transfer caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            _balances[id][from] = _balances[id][from].sub(
                amount,
                "KIP37: insufficient balance for transfer"
            );
            _balances[id][to] = _balances[id][to].add(amount);
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        require(
            _doSafeBatchTransferAcceptanceCheck(
                operator,
                from,
                to,
                ids,
                amounts,
                data
            ),
            "KIP37: batch transfer to non KIP37Receiver implementer"
        );
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substituion mechanism
     * http://kips.klaytn.com/KIPs/kip-37#metadata.
     *
     * By this mechanism, any occurence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `account`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IKIP37Receiver-onKIP37Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal {
        require(account != address(0), "KIP37: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            address(0),
            account,
            _asSingletonArray(id),
            _asSingletonArray(amount),
            data
        );

        _balances[id][account] = _balances[id][account].add(amount);
        _totalSupply[id] = _totalSupply[id].add(amount);
        emit TransferSingle(operator, address(0), account, id, amount);

        require(
            _doSafeTransferAcceptanceCheck(
                operator,
                address(0),
                account,
                id,
                amount,
                data
            ),
            "KIP37: transfer to non KIP37Receiver implementer"
        );
    }

    /**
     * @dev Batch-operations version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IKIP37Receiver-onKIP37BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal {
        require(to != address(0), "KIP37: mint to the zero address");
        require(
            ids.length == amounts.length,
            "KIP37: ids and amounts length mismatch"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] = amounts[i].add(_balances[ids[i]][to]);
            _totalSupply[ids[i]] = amounts[i].add(_totalSupply[ids[i]]);
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        require(
            _doSafeBatchTransferAcceptanceCheck(
                operator,
                address(0),
                to,
                ids,
                amounts,
                data
            ),
            "KIP37: batch transfer to non KIP37Receiver implementer"
        );
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `account`
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address account,
        uint256 id,
        uint256 amount
    ) internal {
        require(account != address(0), "KIP37: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            account,
            address(0),
            _asSingletonArray(id),
            _asSingletonArray(amount),
            ""
        );

        _balances[id][account] = _balances[id][account].sub(
            amount,
            "KIP37: burn amount exceeds balance"
        );

        _totalSupply[id] = _totalSupply[id].sub(
            amount,
            "KIP37: burn amount exceeds total supply"
        );

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    /**
     * @dev Batch-operations version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal {
        require(account != address(0), "KIP37: burn from the zero address");
        require(
            ids.length == amounts.length,
            "KIP37: ids and amounts length mismatch"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][account] = _balances[ids[i]][account].sub(
                amounts[i],
                "KIP37: burn amount exceeds balance"
            );

            _totalSupply[ids[i]] = _totalSupply[ids[i]].sub(
                amounts[i],
                "KIP37: burn amount exceeds total supply"
            );
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private returns (bool) {
        bool success;
        bytes memory returndata;

        if (!to.isContract()) {
            return true;
        }

        (success, returndata) = to.call(
            abi.encodeWithSelector(
                _ERC1155_RECEIVED,
                operator,
                from,
                id,
                amount,
                data
            )
        );
        if (
            returndata.length != 0 &&
            abi.decode(returndata, (bytes4)) == _ERC1155_RECEIVED
        ) {
            return true;
        }

        (success, returndata) = to.call(
            abi.encodeWithSelector(
                _KIP37_RECEIVED,
                operator,
                from,
                id,
                amount,
                data
            )
        );
        if (
            returndata.length != 0 &&
            abi.decode(returndata, (bytes4)) == _KIP37_RECEIVED
        ) {
            return true;
        }

        return false;
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private returns (bool) {
        bool success;
        bytes memory returndata;

        if (!to.isContract()) {
            return true;
        }

        (success, returndata) = to.call(
            abi.encodeWithSelector(
                _ERC1155_BATCH_RECEIVED,
                operator,
                from,
                ids,
                amounts,
                data
            )
        );
        if (
            returndata.length != 0 &&
            abi.decode(returndata, (bytes4)) == _ERC1155_BATCH_RECEIVED
        ) {
            return true;
        }

        (success, returndata) = to.call(
            abi.encodeWithSelector(
                _KIP37_BATCH_RECEIVED,
                operator,
                from,
                ids,
                amounts,
                data
            )
        );
        if (
            returndata.length != 0 &&
            abi.decode(returndata, (bytes4)) == _KIP37_BATCH_RECEIVED
        ) {
            return true;
        }

        return false;
    }

    function _asSingletonArray(uint256 element)
        private
        pure
        returns (uint256[] memory)
    {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}
