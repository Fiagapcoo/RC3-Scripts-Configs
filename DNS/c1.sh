#!/bin/sh
#!/bin/bash

echo -n "Enter T (must be between 1-4): "
read T
echo -n "Enter Group number (must be between 1-6): "
read G

echo "T: $T"
echo "G: $G"


check_user_input(){
case $T in
    ''|*[!0-9]*) 
        echo "Error: Please enter valid numbers."
        exit 1
        ;;
esac

case $G in
    ''|*[!0-9]*) 
        echo "Error: Please enter valid numbers."
        exit 1
        ;;
esac

# Check if numbers are in valid range (T: 1-4, G: 1-6)
if [ "$T" -lt 1 ] || [ "$T" -gt 4 ] || [ "$G" -lt 1 ] || [ "$G" -gt 6 ]; then
    echo "Error: T must be between 1 and 4, and G must be between 1 and 6."
    exit 1
fi


echo "Input validation successful."
}


WebServer_Config() {
    mkdir -p /var/www/webserver.rc3-${T}${G}.test
    echo "
<!DOCTYPE html>
<html lang=\"pt\">
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>Informações do Grupo</title>
</head>
<body>
    <h1>Informações sobre os elementos do grupo</h1>
    <p>Nome do Grupo: Grupo RC3-${T}${G}</p>
    <ul>
        <li>Membro 1: Nome e detalhes</li>
        <li>Membro 2: Nome e detalhes</li>
        <li>Membro 3: Nome e detalhes</li>
        <!-- Adicione outros membros aqui -->
    </ul>
</body>
</html>
" > /var/www/webserver.rc3-${T}${G}.test/index.html

}


App_Setup() {



    mkdir -p /var/www/app.rc3-${T}${G}.test
cat << 'EOF' > /var/www/app.rc3-${T}${G}.test/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tic Tac Toe</title>
    <style>
        :root {
            --primary-color: #2c3e50;
            --secondary-color: #3498db;
            --accent-color: #e74c3c;
            --background-color: #ecf0f1;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Arial', sans-serif;
        }

        body {
            background-color: var(--background-color);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 2rem;
        }

        .container {
            display: flex;
            gap: 2rem;
            max-width: 1200px;
            width: 100%;
            justify-content: center;
            flex-wrap: wrap;
        }

        .game-section {
            flex: 1;
            min-width: 300px;
            max-width: 500px;
        }

        .leaderboard-section {
            flex: 1;
            min-width: 300px;
            max-width: 400px;
        }

        h1 {
            color: var(--primary-color);
            margin-bottom: 2rem;
            text-align: center;
        }

        .status {
            margin-bottom: 1rem;
            padding: 1rem;
            text-align: center;
            font-size: 1.2rem;
            color: var(--primary-color);
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .board {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
            margin-bottom: 1rem;
            background: var(--primary-color);
            padding: 10px;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        .cell {
            aspect-ratio: 1;
            background: white;
            border: none;
            border-radius: 8px;
            font-size: 2rem;
            font-weight: bold;
            color: var(--primary-color);
            cursor: pointer;
            transition: transform 0.2s, background-color 0.2s;
        }

        .cell:hover {
            background-color: #f8f9fa;
            transform: scale(1.02);
        }

        .cell.x {
            color: var(--secondary-color);
        }

        .cell.o {
            color: var(--accent-color);
        }

        .controls {
            display: flex;
            gap: 1rem;
            margin-bottom: 2rem;
        }

        button {
            padding: 0.8rem 1.5rem;
            border: none;
            border-radius: 8px;
            background-color: var(--secondary-color);
            color: white;
            font-size: 1rem;
            cursor: pointer;
            transition: transform 0.2s, background-color 0.2s;
            flex: 1;
        }

        button:hover {
            background-color: #2980b9;
            transform: translateY(-2px);
        }

        .leaderboard {
            background: white;
            padding: 1.5rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        .leaderboard h2 {
            color: var(--primary-color);
            margin-bottom: 1rem;
            text-align: center;
        }

        .leaderboard-list {
            list-style: none;
        }

        .leaderboard-item {
            display: flex;
            justify-content: space-between;
            padding: 0.8rem;
            border-bottom: 1px solid #eee;
        }

        .leaderboard-item:last-child {
            border-bottom: none;
        }

        .player-name {
            font-weight: bold;
            color: var(--primary-color);
        }

        .score {
            color: var(--secondary-color);
            font-weight: bold;
        }

        @media (max-width: 768px) {
            .container {
                flex-direction: column;
                align-items: center;
            }

            .game-section, .leaderboard-section {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <h1>Tic Tac Toe</h1>
    <div class="container">
        <div class="game-section">
            <div class="status" id="status">Player X's turn</div>
            <div class="board" id="board">
                <button class="cell" data-cell></button>
                <button class="cell" data-cell></button>
                <button class="cell" data-cell></button>
                <button class="cell" data-cell></button>
                <button class="cell" data-cell></button>
                <button class="cell" data-cell></button>
                <button class="cell" data-cell></button>
                <button class="cell" data-cell></button>
                <button class="cell" data-cell></button>
            </div>
            <div class="controls">
                <button id="restartBtn">Restart Game</button>
                <button id="resetScoresBtn">Reset Scores</button>
            </div>
        </div>
        <div class="leaderboard-section">
            <div class="leaderboard">
                <h2>Leaderboard</h2>
                <ul class="leaderboard-list" id="leaderboard">
                    <li class="leaderboard-item">
                        <span class="player-name">Player X</span>
                        <span class="score">0</span>
                    </li>
                    <li class="leaderboard-item">
                        <span class="player-name">Player O</span>
                        <span class="score">0</span>
                    </li>
                </ul>
            </div>
        </div>
    </div>

    <script>
        class TicTacToe {
            constructor() {
                this.board = document.getElementById('board');
                this.cells = document.querySelectorAll('[data-cell]');
                this.status = document.getElementById('status');
                this.restartBtn = document.getElementById('restartBtn');
                this.resetScoresBtn = document.getElementById('resetScoresBtn');
                this.leaderboard = document.getElementById('leaderboard');
                
                this.currentPlayer = 'X';
                this.gameActive = true;
                this.scores = {
                    X: 0,
                    O: 0
                };

                this.winningCombinations = [
                    [0, 1, 2], [3, 4, 5], [6, 7, 8],
                    [0, 3, 6], [1, 4, 7], [2, 5, 8],
                    [0, 4, 8], [2, 4, 6]
                ];

                this.initGame();
            }

            initGame() {
                this.cells.forEach(cell => {
                    cell.addEventListener('click', () => this.handleCellClick(cell));
                    cell.classList.remove('x', 'o');
                    cell.textContent = '';
                });

                this.restartBtn.addEventListener('click', () => this.restartGame());
                this.resetScoresBtn.addEventListener('click', () => this.resetScores());
                
                this.loadScores();
                this.updateStatus();
            }

            handleCellClick(cell) {
                if (!cell.textContent && this.gameActive) {
                    cell.textContent = this.currentPlayer;
                    cell.classList.add(this.currentPlayer.toLowerCase());
                    
                    if (this.checkWin()) {
                        this.handleWin();
                    } else if (this.checkDraw()) {
                        this.handleDraw();
                    } else {
                        this.currentPlayer = this.currentPlayer === 'X' ? 'O' : 'X';
                        this.updateStatus();
                    }
                }
            }

            checkWin() {
                return this.winningCombinations.some(combination => {
                    return combination.every(index => {
                        return this.cells[index].textContent === this.currentPlayer;
                    });
                });
            }

            checkDraw() {
                return [...this.cells].every(cell => cell.textContent);
            }

            handleWin() {
                this.gameActive = false;
                this.scores[this.currentPlayer]++;
                this.saveScores();
                this.updateLeaderboard();
                this.status.textContent = `Player ${this.currentPlayer} wins!`;
            }

            handleDraw() {
                this.gameActive = false;
                this.status.textContent = "It's a draw!";
            }

            restartGame() {
                this.gameActive = true;
                this.currentPlayer = 'X';
                this.cells.forEach(cell => {
                    cell.textContent = '';
                    cell.classList.remove('x', 'o');
                });
                this.updateStatus();
            }

            resetScores() {
                this.scores = { X: 0, O: 0 };
                this.saveScores();
                this.updateLeaderboard();
                this.restartGame();
            }

            updateStatus() {
                this.status.textContent = `Player ${this.currentPlayer}'s turn`;
            }

            updateLeaderboard() {
                this.leaderboard.innerHTML = `
                    <li class="leaderboard-item">
                        <span class="player-name">Player X</span>
                        <span class="score">${this.scores.X}</span>
                    </li>
                    <li class="leaderboard-item">
                        <span class="player-name">Player O</span>
                        <span class="score">${this.scores.O}</span>
                    </li>
                `;
            }

            saveScores() {
                localStorage.setItem('tictactoeScores', JSON.stringify(this.scores));
            }

            loadScores() {
                const savedScores = localStorage.getItem('tictactoeScores');
                if (savedScores) {
                    this.scores = JSON.parse(savedScores);
                    this.updateLeaderboard();
                }
            }
        }

        // Initialize the game
        const game = new TicTacToe();
    </script>
</body>
</html>
EOF

}

apk add --no-cache nginx
check_user_input || { echo "Input validation failed"; exit 1; }
App_Setup || { echo "app setup failed"; exit 1; }
WebServer_Config || { echo "WebServer setup failed"; exit 1; }

sed -i '/http {/a \
    server { \
        listen 80; \
        server_name webserver.rc3-'${T}${G}'.test; \
        root /var/www/webserver.rc3-'${T}${G}'.test; \
        index index.html; \
        location / { \
            try_files \$uri \$uri/ =404; \
        } \
    } \
    server { \
        listen 80; \
        server_name app.rc3-'${T}${G}'.test; \
        root /var/www/app.rc3-'${T}${G}'.test; \
        index index.html; \
        location / { \
            try_files \$uri \$uri/ =404; \
        } \
    }' /etc/nginx/nginx.conf


rc-service nginx restart || nginx -s reload