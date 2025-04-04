const targetTextEl = document.getElementById('target-text');
const inputEl = document.getElementById('user-input');
const scoreEl = document.getElementById('score');
const feedbackEl = document.getElementById('feedback');
const safeImg = document.getElementById('safe-img');
const progressBar = document.getElementById('progress-bar');
const resetBtn = document.getElementById('reset-btn');

const typeSound = document.getElementById('type-sound');
const successSound = document.getElementById('success-sound');
const failSound = document.getElementById('fail-sound');

let currentString = '';
let score = 0;
let isMuted = false;
let gameOver = false;
const requiredScore = 5;

function generateRandomString(length = 6) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  let str = '';
  for (let i = 0; i < length; i++) {
    str += chars[Math.floor(Math.random() * chars.length)];
  }
  return str;
}

function newChallenge() {
  if (score >= requiredScore) return;
  currentString = generateRandomString();
  targetTextEl.textContent = `> ${currentString}`;
  inputEl.value = '';
  feedbackEl.textContent = '';
  inputEl.focus();
}

function playSound(sound) {
  if (!isMuted) {
    sound.currentTime = 0;
    sound.play();
  }
}

function updateProgressBar() {
  const percent = (score / requiredScore) * 100;
  progressBar.style.width = `${percent}%`;
}

inputEl.addEventListener('input', () => {
  if (gameOver) return;

  const value = inputEl.value.trim();
  playSound(typeSound);

  if (value.length === currentString.length) {
    if (value === currentString) {
      score++;
      scoreEl.textContent = score;
      updateProgressBar();
      feedbackEl.textContent = 'ACCESS GRANTED';
      feedbackEl.style.color = '#00ff00';
      playSound(successSound);

      if (score >= requiredScore) {
        safeImg.src = 'safe-open.png';
        feedbackEl.textContent = 'SAFE OPENED – GAME OVER';
        gameOver = true;
        resetBtn.style.display = 'inline-block';
        inputEl.disabled = true;
      } else {
        setTimeout(newChallenge, 800);
      }
    } else {
      feedbackEl.textContent = 'ACCESS DENIED';
      feedbackEl.style.color = 'red';
      playSound(failSound);
      setTimeout(() => {
        inputEl.value = '';
        feedbackEl.textContent = '';
      }, 1000);
    }
  }
});

function toggleMute() {
  isMuted = !isMuted;
}

let volumeLevel = 1.0;

function adjustVolume() {
  volumeLevel = volumeLevel === 1.0 ? 0.5 : volumeLevel === 0.5 ? 0.2 : 1.0;
  [typeSound, successSound, failSound].forEach(snd => snd.volume = volumeLevel);
  alert(`Volume set to ${Math.round(volumeLevel * 100)}%`);
}

function resetGame() {
  score = 0;
  gameOver = false;
  isMuted = false;
  scoreEl.textContent = 0;
  inputEl.disabled = false;
  inputEl.value = '';
  safeImg.src = 'safe-closed.png';
  feedbackEl.textContent = '';
  progressBar.style.width = '0%';
  resetBtn.style.display = 'none';
  newChallenge();
}

newChallenge();
