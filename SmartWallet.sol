// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SmartWallet {
    mapping(address => uint256) private _balances;
    address private _owner;
    uint256 private _percente;
    uint256 private _gain;

    //// constructor qui permettra de prelever % de frais ///
    constructor(address owner_, uint8 percente_) {
        require(percente_ < 1000, "SmartWallet: percentage fees too high");
        _owner = owner_;
        _percente = percente_;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function deposit() public payable {
        _balances[msg.sender] += msg.value;
    }

    // Exerice 1:
    // Implementer une fonction withdrawAmount pour permettre à un utilisateur
    // de récupérer un certain amount de ses fonds

    /////////// les fonctions withdraw //////////

    function withdrawAmount(uint256 amount) public {
        uint256 fee = (amount * _percente) / 100; // calcule le montant des "fees" (frais)
        _balances[msg.sender] -= fee;
        _balances[msg.sender] -= amount; // décremente la balance du "amount" (valeur voulant etre retiré)
        amount -= fee; // décremente le amount (valeur voulant etre retiré) des "fees" (frais)
        _balances[_owner] += fee; // envoye des fees (frais) vers le _owner
        _gain += fee; // increment le solde du owners de x fees
        payable(msg.sender).transfer(amount); // transfere vers msg.sender(celui qui a envoye a linitial)
    }

    function withdraw() public {
        require(
            _balances[msg.sender] > 0,
            "SmartWallet: can not withdraw 0 ether"
        );
        uint256 amount = _balances[msg.sender]; // recupere le amount total
        uint256 fee = (amount * _percente) / 100; // calcule le montant des "fees" (frais)
        _balances[msg.sender] -= fee; // décremente les "fees "de la balance
        amount -= fee; // décremente le amount (valeur voulant etre retiré) des "fees" (frais)
        _balances[_owner] += fee; // envoye des fees (frais) vers le _owner
        _gain += fee; // increment le solde du owners de x fees
        _balances[msg.sender] = 0; // met la balance à 0
        payable(msg.sender).transfer(amount); // transfere vers msg.sender(celui qui a envoye a linitial)
    }

    function withdrawGain() public {
        require(msg.sender == _owner, "Only owner can withdraw gain");
        payable(msg.sender).transfer(_balances[msg.sender]);
    }

    // Exercice 2:
    // Implementer une fonction transfer pour permettre à un utilisateur d'envoyer
    // des fonds à un autre utilisateur de notre SmartWallet
    // ATTENTION on effectue pas un vrai transfer d'ETHER,
    // un transfer n'est qu'une ecriture comptable dans un registre

    function transfer(address account, uint256 amount) public {
        _balances[msg.sender] -= amount;
        _balances[account] += amount;
    }

    // function qui permet de changer le % de fees
    function setPercentage(uint256 percente_) public {
        require(
            msg.sender == _owner,
            "SmartWallet: Only _owner can change this function"
        );
        _percente = percente_;
    }

    /// function qui permet de lire le total de fees générer par owner
    function seeGains() public view returns (uint256) {
        return _gain;
    }

    // fonction qui permet de lire le montant des fees
    function seeFees() public view returns (uint256) {
        return _percente;
    }

    function total() public view returns (uint256) {
        return address(this).balance;
    }
}
