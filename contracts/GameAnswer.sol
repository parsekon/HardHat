// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// 1. Ведущий сохраняет вопрос и ответ на него
// 2. Указывается сумма, которую получит ответивший правильно
// 3. Если правильно ответили несколько человек, то выигрыш делится
// 4. Каждый участник должен отправить на контракт ставку в размере выигрыша и свой ответ
// 5. В определённый момент ведущий может остановить приём ответов (но не раньше дедлайна)
// 6. После окончания приёма ответов все участники раскрываются (показывают ответы)
// 7. Ведущий раскрывает правильный ответ и всем, кто ответил правильно, выплачивается выигрыш

contract Game {

  address public owner;
  // вопрос
  string public question;
  // ответ закодированный bytes32
  bytes32 public answer;
  // массив адресов игроков
  address[] players;
  // массив победителей
  address[] public winners;
  // размер ставки eth
  uint public bet;
  // дедлайн для отправки ответа
  uint immutable answerDeadLine;
  // дедлайн для раскрытия ответа 
  uint immutable revealAnswerDeadLine;
  // ответы игроков
  mapping (address => bytes32) answers;
  // раскрытые ответы
  mapping(address => string) openAnswers;
  // раскрытый ответ
  string public revealedAnswer;
  // ответ раскрыт true/false
  bool revealed;
  // сумма ставок
  uint allSumm;
  // hash answer = hash(answer, msg.sender, secret_phrase)
  
  event NewAnswer(address indexed _player, bytes32 _hashedAnswer);
  event PlayerAnswer(address indexed _player, string _openAnswer);
  event CorrectAnswer(string _answer);
  event TransferFailed(address indexed _winner, uint _summ);
  
  // в конструктор задается вопрос строка, ответ в закодированном виде bytes32
  // время на прием ответов, время на раскрытие ответов
  constructor(string memory _question, bytes32 _answer, uint _bet, uint _duration, uint _revealDuration) {
    owner = msg.sender;
    question = _question;
    answer = _answer;
    bet = _bet;
    // начало игры ----> дедлайн для отправки ответа (в виде хэша) ---> дедлайн для раскрытия своего ответа
    // ----> ведущий показывает правильный ответ
    answerDeadLine = block.timestamp + _duration;
    // answerDeadLine <= revealPlayerAnswer <= revealAnswerDeadLine
    // revealAnswer >= revealAnswerDeadLine
    revealAnswerDeadLine = answerDeadLine + _revealDuration;
  }  

  modifier onlyOwner() {
    require(msg.sender == owner, "Not an owner!");
    _;
  }

  // сравнение строк(ответов с правильным)/ тк в solidity нельзя сравнивать строки напрямую, их необходимо преобразовывать в bytes32
  function compareStrings(string memory _str1, string memory _str2) internal pure returns(bool) {
    return keccak256(bytes(_str1)) == keccak256(bytes(_str2));
  }

  // проверка ответов
  function checkAnswers() external onlyOwner {
    require(revealed, "Not revealed");
    uint countWinners;
    for(uint i = 0; i < players.length; i++) {
      if(compareStrings(openAnswers[players[i]], revealedAnswer)) {
        winners.push(players[i]);
      }
    }
    countWinners = winners.length;
    if (countWinners > 0) {
      uint prize = allSumm / countWinners;
      for(uint i = 0; i < winners.length; i++) {
        (bool success, ) = winners[i].call{value: prize}("");
        if(!success) {
          emit TransferFailed(winners[i], prize);
        }
      }
    }
  }
  
  // раскрытие правильного ответа организатором
  function revealAnswer(string calldata _answer, string calldata _secretPhrase) external onlyOwner {
    require(revealAnswerDeadLine <= block.timestamp, "Too early");
    require(!revealed, "Already revealed");
    bytes32 _hash = keccak256(abi.encode(_answer, msg.sender, _secretPhrase));
    require (_hash == answer, "Incorrect answer!");
    revealedAnswer = _toLower(_answer);
    revealed = true;
    emit CorrectAnswer(revealedAnswer);
  }

  // раскрытие ответов игроков 
  // _secretPhrase - при кодировании ответа, чтобы другие игроки не смогли раскрыть, ответ кодируется с помощью дополнительной секретной фразы
  // ее необходимо также использовать при раскрытии ответа
  function revealAnswerPlayer(string calldata _answer, string calldata _secretPhrase) external {
    require(compareStrings(openAnswers[msg.sender], ""), "answer revealed...");
    require(block.timestamp >= answerDeadLine, "too early");
    require(block.timestamp <= revealAnswerDeadLine, "Too late");
    // сверяем ответ записанный ранее с вскрываемым ответом
    // для этого изначально считаем hash хэшированный ответ
    bytes32 _hashAnswer = keccak256(abi.encode(_answer, msg.sender, _secretPhrase));
    require (_hashAnswer == answers[msg.sender], "Incorrect answer!");

    openAnswers[msg.sender] = _toLower(_answer);
    players.push(msg.sender); // ??? почему игрок добавляется в массив игроков только после раскрытия ответа?
    emit PlayerAnswer(msg.sender, _toLower(_answer));
  }
  
  // прием ответов и ставок
  function giveAnswer(bytes32 _answer) external payable {
    require(msg.value == bet, 'wrong bet!');
    require(answers[msg.sender] == bytes32(0), "already given answer!");
    require(answerDeadLine >= block.timestamp, "Too late");
    answers[msg.sender] = _answer;
    allSumm += bet;
    emit NewAnswer(msg.sender, _answer);
  }

  function _toLower(string memory str) internal pure returns (string memory) {
    bytes memory bStr = bytes(str);
    bytes memory bLower = new bytes(bStr.length);
    for (uint i = 0; i < bStr.length; i++) {
        // Uppercase character...
        if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
            // So we add 32 to make it lowercase
            bLower[i] = bytes1(uint8(bStr[i]) + 32);
        } else {
            bLower[i] = bStr[i];
        }
    }
    return string(bLower);
  }
}

// вспомогательный контракт для изначального хэширования ответов
contract AnswerToHash {
  
}