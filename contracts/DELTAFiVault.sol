// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

abstract contract Reader {
    address constant POSITION_PRECOMPILE_ADDRESS =
        0x0000000000000000000000000000000000000800;
    address constant SPOT_BALANCE_PRECOMPILE_ADDRESS =
        0x0000000000000000000000000000000000000801;
    address constant WITHDRAWABLE_PRECOMPILE_ADDRESS =
        0x0000000000000000000000000000000000000803;
    address constant MARK_PX_PRECOMPILE_ADDRESS =
        0x0000000000000000000000000000000000000806;
    address constant TOKEN_INFO_PRECOMPILE_ADDRESS =
        0x000000000000000000000000000000000000080C;

    struct Position {
        int64 szi;
        uint64 entryNtl;
        int64 isolatedRawUsd;
        uint32 leverage;
        bool isIsolated;
    }

    struct SpotBalance {
        uint64 total;
        uint64 hold;
        uint64 entryNtl;
    }

    struct Withdrawable {
        uint64 withdrawable;
    }

    struct TokenInfo {
        string name;
        uint64[] spots;
        uint64 deployerTradingFeeShare;
        address deployer;
        address evmContract;
        uint8 szDecimals;
        uint8 weiDecimals;
        int8 evmExtraWeiDecimals;
    }

    function _position(
        address user,
        uint16 perp
    ) internal view returns (Position memory) {
        bool success;
        bytes memory result;
        (success, result) = POSITION_PRECOMPILE_ADDRESS.staticcall(
            abi.encode(user, perp)
        );
        require(success, "Position precompile call failed");
        return abi.decode(result, (Position));
    }

    function _spotBalance(
        address user,
        uint64 token
    ) internal view returns (SpotBalance memory) {
        bool success;
        bytes memory result;
        (success, result) = SPOT_BALANCE_PRECOMPILE_ADDRESS.staticcall(
            abi.encode(user, token)
        );
        require(success, "SpotBalance precompile call failed");
        return abi.decode(result, (SpotBalance));
    }

    function _withdrawable(
        address user
    ) internal view returns (Withdrawable memory) {
        bool success;
        bytes memory result;
        (success, result) = WITHDRAWABLE_PRECOMPILE_ADDRESS.staticcall(
            abi.encode(user)
        );
        require(success, "Withdrawable precompile call failed");
        return abi.decode(result, (Withdrawable));
    }

    function _markPx(uint32 index) internal view returns (uint64) {
        bool success;
        bytes memory result;
        (success, result) = MARK_PX_PRECOMPILE_ADDRESS.staticcall(
            abi.encode(index)
        );
        require(success, "MarkPx precompile call failed");
        return abi.decode(result, (uint64));
    }

    function _tokenInfo(uint32 token) internal view returns (TokenInfo memory) {
        bool success;
        bytes memory result;
        (success, result) = TOKEN_INFO_PRECOMPILE_ADDRESS.staticcall(
            abi.encode(token)
        );
        require(success, "TokenInfo precompile call failed");
        return abi.decode(result, (TokenInfo));
    }
}

interface ICoreWriter {
    function sendRawAction(bytes calldata data) external;
}

abstract contract Writer {
    ICoreWriter public constant coreWriter =
        ICoreWriter(0x3333333333333333333333333333333333333333);

    function _encode(
        uint24 actionId,
        bytes memory payload
    ) internal pure returns (bytes memory) {
        bytes1 version = bytes1(uint8(1));
        bytes3 aid = bytes3(actionId);
        return abi.encodePacked(version, aid, payload);
    }

    function _sendSpot(
        address destination,
        uint64 token,
        uint64 _wei
    ) internal {
        bytes memory payload = abi.encode(destination, token, _wei);
        coreWriter.sendRawAction(_encode(6, payload));
    }

    function _sendUsdClassTransfer(uint64 ntl, bool toPerp) internal {
        bytes memory payload = abi.encode(ntl, toPerp);
        coreWriter.sendRawAction(_encode(7, payload));
    }

    function _addApiWallet(address wallet, string memory name) internal {
        bytes memory payload = abi.encode(wallet, name);
        coreWriter.sendRawAction(_encode(9, payload));
    }
}

interface IPriceOracle {
    function getTokenPrice(uint64 token) external view returns (uint256 price);
}

/// @title DELTAFiVault
/// @notice ERC-4626 vault on HyperEVM that bridges to HyperCore L1 for spot+perp positions.
contract DELTAFiVault is
    Reader,
    Writer,
    ERC4626,
    Ownable,
    Pausable,
    ReentrancyGuard
{
    using Math for uint256;
    using SafeERC20 for IERC20;

    // Core bridge address
    address public constant hypeBridge =
        0x2222222222222222222222222222222222222222; // HYPE
    address public bridge;

    // Spot and perp id
    uint64 public constant usdcSpotId = 0;
    uint64 public assetSpotId;
    uint64 public hedgeSpotId;
    uint16 public hedgePerpId;

    // Spot and perp decimals
    uint8 public constant usdcWeiDecimals = 8;
    uint8 public assetWeiDecimals;
    uint8 public hedgeWeiDecimals;
    uint8 public hedgeSzDecimals;

    // Oracle address
    IPriceOracle public priceOracle;

    // Minimum deposit amount
    uint256 public minDeposit;

    // Portfolio manager
    address public portfolioManager;

    // Authorized participants
    mapping(address => bool) public authorizedParticipant;

    // Pending
    mapping(address account => uint256 amount) public pendings;

    // Fee
    mapping(address account => uint256 amount) public finalizeFees;

    uint256 public redemptionFeePpm; // parts per million (1e6) per year
    uint256 public finalizeFee;
    uint256 public mgmtFeePpm;
    uint256 public lastFeeAccrual;
    address public feeReceiver;

    // Events
    event SetMinDeposit(uint256 previous, uint256 current);
    event SetPortfolioManager(
        address indexed previous,
        address indexed current
    );
    event SetAuthorizedParticipant(
        address indexed participant,
        bool authorized
    );
    event SetRedemptionFeePpm(uint256 previous, uint256 current);
    event SetFinalizeFee(uint256 previous, uint256 current);
    event SetMgmtFeePpm(uint256 previous, uint256 current);
    event SetFeeReceiver(address previous, address current);
    event FeesAccrued(uint256 timestamp, uint256 feeAmount);
    event Finalize(address indexed account, uint256 amount);

    /// @notice Initializes the vault with asset, hedge, and oracle configuration.
    constructor(
        IERC20 _asset,
        string memory _name,
        string memory _symbol,
        uint64 _assetSpotId,
        uint64 _hedgeSpotId,
        uint16 _hedgePerpId,
        IPriceOracle _priceOracle
    ) ERC4626(_asset) ERC20(_name, _symbol) Ownable(msg.sender) {
        bridge = address(
            uint160(0x2000000000000000000000000000000000000000) + _assetSpotId
        );
        assetSpotId = _assetSpotId;
        hedgeSpotId = _hedgeSpotId;
        hedgePerpId = _hedgePerpId;

        TokenInfo memory assetTokenInfo = _tokenInfo(uint32(_assetSpotId));
        TokenInfo memory hedgeTokenInfo = _tokenInfo(uint32(_hedgeSpotId));

        require(assetTokenInfo.evmContract == address(_asset), "Invalid asset");

        assetWeiDecimals = assetTokenInfo.weiDecimals;
        hedgeWeiDecimals = hedgeTokenInfo.weiDecimals;
        hedgeSzDecimals = hedgeTokenInfo.szDecimals;

        priceOracle = _priceOracle;

        finalizeFee = 0.00002 ether;
        lastFeeAccrual = block.timestamp;

        // _mint(address(this), 1); // to avoid zero-supply edge-case
    }

    receive() external payable {}

    // ----------------------------
    // Modifier
    // ----------------------------

    /// @notice Restrict to portfolio manager
    modifier onlyPortfolioManager() {
        require(
            msg.sender == portfolioManager,
            "Caller is not portfolio manager"
        );
        _;
    }

    /// @notice Restrict to authorized participants
    modifier onlyAuthorizedParticipant() {
        require(authorizedParticipant[msg.sender], "Caller is not authorized");
        _;
    }

    // ----------------------------
    // Asset valuation
    // ----------------------------

    /// @notice Returns the total value of spot holdings denominated in the vault's asset token.
    function totalSpotAssets() public view returns (uint256) {
        SpotBalance memory spAsset = _spotBalance(address(this), assetSpotId);
        SpotBalance memory spUsdc = _spotBalance(address(this), usdcSpotId);
        SpotBalance memory spHedge = _spotBalance(address(this), hedgeSpotId);

        uint64 price = _markPx(hedgePerpId);
        uint256 priceAsset = uint256(priceOracle.getTokenPrice(assetSpotId));
        uint256 priceUSDC = uint256(priceOracle.getTokenPrice(usdcSpotId));

        uint8 assetDecimals = ERC20(asset()).decimals();

        // 1) asset spot
        uint256 spotAssetValue = (spAsset.total * 10 ** assetDecimals) /
            10 ** assetWeiDecimals;
        // 2) usdc spot -> asset units
        uint256 spotUsdcValue = (((spUsdc.total * priceAsset) / priceUSDC) *
            10 ** assetDecimals) / 10 ** usdcWeiDecimals;
        // 3) hedge spot -> asset units
        uint256 spotHedgeValue = (
            ((((spHedge.total * price * priceAsset) / priceUSDC) *
                10 ** assetDecimals) / 10 ** hedgeWeiDecimals)
        ) / 10 ** (6 - hedgeSzDecimals);

        return spotAssetValue + spotUsdcValue + spotHedgeValue;
    }

    /// @notice Returns the total value of perp-side holdings denominated in the vault's asset token.
    function totalPerpAssets() public view returns (uint256) {
        Withdrawable memory wd = _withdrawable(address(this));
        Position memory pos = _position(address(this), hedgePerpId);

        uint64 price = _markPx(hedgePerpId);
        uint256 priceAsset = uint256(priceOracle.getTokenPrice(assetSpotId));
        uint256 priceUSDC = uint256(priceOracle.getTokenPrice(usdcSpotId));

        uint8 assetDecimals = ERC20(asset()).decimals();

        // 1) usdc spot -> asset units
        uint256 perpAssetValue = (((wd.withdrawable * priceAsset) / priceUSDC) *
            10 ** assetDecimals) / 10 ** 6;
        require(int256(pos.szi) <= 0, "No active perp long position");
        // 2) usdc perp -> asset units
        uint256 perpHedgeValue = ((((uint256(-int256(pos.szi)) * price) *
            priceAsset) / priceUSDC) * 10 ** assetDecimals) /
            pos.leverage /
            10 ** 6;

        return perpAssetValue + perpHedgeValue;
    }

    /// @notice Combined spot + perp asset value used by ERC-4626 share pricing.
    function totalAssets() public view override returns (uint256) {
        return totalSpotAssets() + totalPerpAssets();
    }

    // ----------------------------
    // Operations
    // ----------------------------

    /// @notice Deposit assets and bridge them to L1. Restricted to authorized participants.
    function deposit(
        uint256 assets,
        address receiver
    )
        public
        override
        onlyAuthorizedParticipant
        whenNotPaused
        nonReentrant
        returns (uint256)
    {
        uint256 shares = super.deposit(assets, receiver);
        _l1Deposit(assets);
        return shares;
    }

    /// @notice Mint shares by depositing the corresponding assets to L1.
    function mint(
        uint256 shares,
        address receiver
    )
        public
        override
        onlyAuthorizedParticipant
        whenNotPaused
        nonReentrant
        returns (uint256)
    {
        uint256 assets = super.mint(shares, receiver);
        _l1Deposit(assets);
        return assets;
    }

    function _l1Deposit(uint256 assets) internal {
        require(assets >= minDeposit, "Deposit below minimum");

        // bridging
        SafeERC20.safeTransfer(IERC20(asset()), bridge, assets);
    }

    /// @notice Withdraw assets from L1 spot balance, queuing them for EVM finalization.
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    )
        public
        override
        onlyAuthorizedParticipant
        whenNotPaused
        nonReentrant
        returns (uint256)
    {
        uint256 shares = super.withdraw(assets, receiver, owner);
        uint256 net = _l1Withdraw(bridge, assets);
        pendings[receiver] += net;
        finalizeFees[receiver] += finalizeFee;
        return shares;
    }

    /// @notice Redeem shares, queuing the underlying assets for EVM finalization.
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    )
        public
        override
        onlyAuthorizedParticipant
        whenNotPaused
        nonReentrant
        returns (uint256)
    {
        uint256 assets = super.redeem(shares, receiver, owner);
        uint256 net = _l1Withdraw(bridge, assets);
        pendings[receiver] += net;
        finalizeFees[receiver] += finalizeFee;
        return assets;
    }

    /// @notice Withdraw assets and send directly to an L1 address (no EVM finalization).
    function withdrawToL1(
        uint256 assets,
        address receiver,
        address owner
    )
        external
        onlyAuthorizedParticipant
        whenNotPaused
        nonReentrant
        returns (uint256)
    {
        uint256 shares = super.withdraw(assets, receiver, owner);
        _l1Withdraw(receiver, assets);
        return shares;
    }

    /// @notice Redeem shares and send the underlying assets directly to an L1 address.
    function redeemToL1(
        uint256 shares,
        address receiver,
        address owner
    )
        public
        onlyAuthorizedParticipant
        whenNotPaused
        nonReentrant
        returns (uint256)
    {
        uint256 assets = super.redeem(shares, receiver, owner);
        _l1Withdraw(receiver, assets);
        return assets;
    }

    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal override {
        if (caller != owner) {
            _spendAllowance(owner, caller, shares);
        }

        _burn(owner, shares);
        // SafeERC20.safeTransfer(IERC20(asset()), receiver, assets);

        emit Withdraw(caller, receiver, owner, assets, shares);
    }

    function _l1Withdraw(
        address to,
        uint256 assets
    ) internal returns (uint256 net) {
        SpotBalance memory spAsset = _spotBalance(address(this), assetSpotId);

        // bridging
        {
            uint8 assetDecimals = ERC20(asset()).decimals();
            net = (assets * (1e6 - redemptionFeePpm)) / 1e6;
            uint256 normalizedNet = (net * 10 ** assetWeiDecimals) /
                10 ** assetDecimals;
            require(
                spAsset.total >= normalizedNet,
                "Insufficient spot balance"
            );

            // send net assets to bridge
            _sendSpot(to, assetSpotId, uint64(normalizedNet));
        }
    }

    /// @notice Finalize a pending withdrawal by bridging assets from L1 to the user on EVM.
    function finalizeEVM(
        address account
    ) external payable whenNotPaused nonReentrant returns (uint256 amount) {
        require(msg.value == finalizeFees[account], "Invalid finalize fee");

        amount = pendings[account];
        // delete pendings[account];
        pendings[account] = 0;

        // forward HYPE fee to L1 bridge
        (bool success, ) = hypeBridge.call{value: msg.value}("");
        require(success, "Bridge failed");
        finalizeFees[account] = 0;

        SafeERC20.safeTransfer(IERC20(asset()), account, amount);

        emit Finalize(account, amount);
    }

    // ----------------------------
    // Fee
    // ----------------------------

    /// @notice Trigger management fee accrual, minting shares to the fee receiver.
    function accrueFees() public {
        _accrueFees();
    }

    function _accrueFees() internal {
        require(feeReceiver != address(0), "Invalid feeReceiver");

        uint256 ts = block.timestamp;
        uint256 dt = ts - lastFeeAccrual;
        if (dt == 0 || mgmtFeePpm == 0) {
            lastFeeAccrual = ts;
            return;
        }
        uint256 fee = (totalSupply() * mgmtFeePpm * dt) / (1e6 * 365 days);
        if (fee > 0) {
            _mint(feeReceiver, fee);
            emit FeesAccrued(ts, fee);
        }
        lastFeeAccrual = ts;
    }

    // ----------------------------
    // Portfolio manager controls
    // ----------------------------

    /// @notice Transfer USD between spot and perp accounts on L1. Portfolio manager only.
    function sendUsdClassTransfer(
        uint64 amount,
        bool spotToPerp
    ) external onlyPortfolioManager whenNotPaused nonReentrant {
        _sendUsdClassTransfer(amount, spotToPerp);
    }

    // ----------------------------
    // Admin controls
    // ----------------------------

    /// @notice Withdraw ERC-20 tokens or native HYPE from the contract buffer. Owner only.
    function bufWithdraw(
        address token,
        address account,
        uint256 amount
    ) external onlyOwner whenNotPaused nonReentrant {
        require(account != address(0), "Invalid recipient");
        if (token == address(0)) {
            // withdraw HYPE
            (bool success, ) = account.call{value: amount}("");
            require(success, "Withdraw failed");
        } else {
            // withdraw ERC20 token
            SafeERC20.safeTransfer(IERC20(token), account, amount);
        }
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice Register an API wallet on L1 for automated trading.
    function addApiWallet(
        address wallet,
        string memory name
    ) external onlyOwner whenNotPaused {
        _addApiWallet(wallet, name);
    }

    /// @notice Set the portfolio manager
    function setPortfolioManager(
        address _portfolioManager
    ) external onlyOwner whenNotPaused {
        require(_portfolioManager != address(0), "Invalid portfolioManager");
        address prev = portfolioManager;
        portfolioManager = _portfolioManager;
        emit SetPortfolioManager(prev, portfolioManager);
    }

    /// @notice Grant or revoke participant access
    function setAuthorizedParticipant(
        address participant,
        bool authorized
    ) external onlyOwner whenNotPaused {
        require(participant != address(0), "Invalid authorizedParticipant");
        authorizedParticipant[participant] = authorized;
        emit SetAuthorizedParticipant(participant, authorized);
    }

    function setMinDeposit(
        uint256 _minDeposit
    ) external onlyOwner whenNotPaused {
        uint256 prev = minDeposit;
        minDeposit = _minDeposit;
        emit SetMinDeposit(prev, _minDeposit);
    }

    function setRedemptionFeePpm(
        uint256 _ppm
    ) external onlyOwner whenNotPaused {
        require(_ppm <= 1e6, "Ppm must be <= 1e6");
        uint256 prev = redemptionFeePpm;
        redemptionFeePpm = _ppm;
        emit SetRedemptionFeePpm(prev, _ppm);
    }

    function setFinalizeFee(uint256 _fee) external onlyOwner whenNotPaused {
        uint256 prev = finalizeFee;
        finalizeFee = _fee;
        emit SetFinalizeFee(prev, _fee);
    }

    function setMgmtFeePpm(uint256 _ppm) external onlyOwner whenNotPaused {
        require(_ppm <= 1e6, "Ppm must be <= 1e6");
        uint256 prev = mgmtFeePpm;
        mgmtFeePpm = _ppm;
        emit SetMgmtFeePpm(prev, _ppm);
    }

    function setFeeReceiver(
        address _receiver
    ) external onlyOwner whenNotPaused {
        require(_receiver != address(0), "Invalid feeReceiver");
        address prev = feeReceiver;
        feeReceiver = _receiver;
        emit SetFeeReceiver(prev, _receiver);
    }
}
