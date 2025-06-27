# IPv4 Quiz Game 🎮

[![Flutter](https://img.shields.io/badge/Flutter-3.13.8-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

Um jogo educativo para testar conhecimentos sobre endereçamento IPv4, sub-redes e máscaras de rede, desenvolvido em Flutter.

![App Screenshot](screenshots/app_demo.gif) (adicione suas imagens numa pasta screenshots)

## 📌 Funcionalidades

- *Sistema de Autenticação*:
  - Login e registro de usuários
  - Modo visitante
  - Gerenciamento de sessão com Provider

- *Quizzes por Nível*:
  - ✅ Fácil (Máscaras /8, /16, /24) - Timer: 30s, 3 vidas
  - ⚠️ Médio (Sub-redes variadas) - Timer: 20s, 3 vidas
  - 💀 Difícil (Super-redes e agregação) - Timer: 10s, 3 vidas

- *Perfil do Usuário*:
  - Visualização de estatísticas
  - Edição de dados cadastrais
  - Histórico de pontuações

- *Ranking Global*:
  - Top 5 jogadores por nível
  - Comparação com seu desempenho

## 🛠️ Tecnologias Utilizadas

| Tecnologia         | Descrição                           |
|--------------------|-----------------------------------|
| Flutter 3.13       | Framework cross-platform           |
| Provider           | Gerenciamento de estado            |
| SQFlite            | Banco de dados local SQLite        |
| Dart 3.1           | Linguagem de programação           |

## 🚀 Como Executar

1. *Pré-requisitos*:
   - Flutter SDK (versão 3.13.8 ou superior)
   - Dispositivo/Emulador configurado

2. *Instalação*:
   ```bash
   git clone https://github.com/seu-usuario/ipv4-quiz-game.git
   cd ipv4-quiz-game
   flutter pub get