import { useInput } from 'ink';

export interface KeyboardNavCallbacks {
  onUp?: () => void;
  onDown?: () => void;
  onEnter?: () => void;
  onQuit?: () => void;
  onRefresh?: () => void;
}

export function useKeyboardNav(callbacks: KeyboardNavCallbacks) {
  useInput((input, key) => {
    if (key.upArrow && callbacks.onUp) {
      callbacks.onUp();
    }

    if (key.downArrow && callbacks.onDown) {
      callbacks.onDown();
    }

    if (key.return && callbacks.onEnter) {
      callbacks.onEnter();
    }

    if ((input === 'q' || input === 'Q') && callbacks.onQuit) {
      callbacks.onQuit();
    }

    if ((input === 'r' || input === 'R') && callbacks.onRefresh) {
      callbacks.onRefresh();
    }
  });
}
