import Mousetrap from 'mousetrap-ts';

import { IInstrument } from '../audio/audio';

class Keyboard {
  keyboard: Mousetrap = new Mousetrap(window.document.body);
  instrument: IInstrument;
  notesOn: boolean[] = [];

  playNote(midiNote: number): boolean {
    if (!this.notesOn[midiNote]) {
      console.log('keyboard note on: ' + midiNote);
      this.instrument.playNote(midiNote);
      this.notesOn[midiNote] = true;
    }
    return false;
  }

  stopNote(midiNote: number): boolean {
    console.log('keyboard note off: ' + midiNote);
    this.instrument.stopNote(midiNote);
    this.notesOn[midiNote] = false;
    return false;
  }

  enable(instrument: IInstrument) {
    this.instrument = instrument;

    this.keyboard.bind('z', () => this.playNote(33), 'keydown');
    this.keyboard.bind('z', () => this.stopNote(33), 'keyup');
    this.keyboard.bind('x', () => this.playNote(34), 'keydown');
    this.keyboard.bind('x', () => this.stopNote(34), 'keyup');
    this.keyboard.bind('c', () => this.playNote(35), 'keydown');
    this.keyboard.bind('c', () => this.stopNote(35), 'keyup');
    this.keyboard.bind('v', () => this.playNote(36), 'keydown'); // C2
    this.keyboard.bind('v', () => this.stopNote(36), 'keyup');
    this.keyboard.bind('b', () => this.playNote(37), 'keydown');
    this.keyboard.bind('b', () => this.stopNote(37), 'keyup');
    this.keyboard.bind('n', () => this.playNote(38), 'keydown');
    this.keyboard.bind('n', () => this.stopNote(38), 'keyup');
    this.keyboard.bind('m', () => this.playNote(39), 'keydown');
    this.keyboard.bind('m', () => this.stopNote(39), 'keyup');
    this.keyboard.bind(',', () => this.playNote(40), 'keydown');
    this.keyboard.bind(',', () => this.stopNote(40), 'keyup');
    this.keyboard.bind('.', () => this.playNote(41), 'keydown');
    this.keyboard.bind('.', () => this.stopNote(41), 'keyup');
    this.keyboard.bind('/', () => this.playNote(42), 'keydown');
    this.keyboard.bind('/', () => this.stopNote(42), 'keyup');
    this.keyboard.bind('a', () => this.playNote(43), 'keydown');
    this.keyboard.bind('a', () => this.stopNote(43), 'keyup');
    this.keyboard.bind('s', () => this.playNote(44), 'keydown');
    this.keyboard.bind('s', () => this.stopNote(44), 'keyup');
    this.keyboard.bind('d', () => this.playNote(45), 'keydown');
    this.keyboard.bind('d', () => this.stopNote(45), 'keyup');
    this.keyboard.bind('f', () => this.playNote(46), 'keydown');
    this.keyboard.bind('f', () => this.stopNote(46), 'keyup');
    this.keyboard.bind('g', () => this.playNote(47), 'keydown');
    this.keyboard.bind('g', () => this.stopNote(47), 'keyup');
    this.keyboard.bind('h', () => this.playNote(48), 'keydown'); // C3
    this.keyboard.bind('h', () => this.stopNote(48), 'keyup');
    this.keyboard.bind('j', () => this.playNote(49), 'keydown');
    this.keyboard.bind('j', () => this.stopNote(49), 'keyup');
    this.keyboard.bind('k', () => this.playNote(50), 'keydown');
    this.keyboard.bind('k', () => this.stopNote(50), 'keyup');
    this.keyboard.bind('l', () => this.playNote(51), 'keydown');
    this.keyboard.bind('l', () => this.stopNote(51), 'keyup');
    this.keyboard.bind(';', () => this.playNote(52), 'keydown');
    this.keyboard.bind(';', () => this.stopNote(52), 'keyup');
    this.keyboard.bind("'", () => this.playNote(53), 'keydown');
    this.keyboard.bind("'", () => this.stopNote(53), 'keyup');
    this.keyboard.bind('q', () => this.playNote(54), 'keydown');
    this.keyboard.bind('q', () => this.stopNote(54), 'keyup');
    this.keyboard.bind('w', () => this.playNote(55), 'keydown');
    this.keyboard.bind('w', () => this.stopNote(55), 'keyup');
    this.keyboard.bind('e', () => this.playNote(56), 'keydown');
    this.keyboard.bind('e', () => this.stopNote(56), 'keyup');
    this.keyboard.bind('r', () => this.playNote(57), 'keydown');
    this.keyboard.bind('r', () => this.stopNote(57), 'keyup');
    this.keyboard.bind('t', () => this.playNote(58), 'keydown');
    this.keyboard.bind('t', () => this.stopNote(58), 'keyup');
    this.keyboard.bind('y', () => this.playNote(59), 'keydown');
    this.keyboard.bind('y', () => this.stopNote(59), 'keyup');
    this.keyboard.bind('u', () => this.playNote(60), 'keydown'); // C4, middle C
    this.keyboard.bind('u', () => this.stopNote(60), 'keyup');
    this.keyboard.bind('i', () => this.playNote(61), 'keydown');
    this.keyboard.bind('i', () => this.stopNote(61), 'keyup');
    this.keyboard.bind('o', () => this.playNote(62), 'keydown');
    this.keyboard.bind('o', () => this.stopNote(62), 'keyup');
    this.keyboard.bind('p', () => this.playNote(63), 'keydown');
    this.keyboard.bind('p', () => this.stopNote(63), 'keyup');
    this.keyboard.bind('[', () => this.playNote(64), 'keydown');
    this.keyboard.bind('[', () => this.stopNote(64), 'keyup');
    this.keyboard.bind(']', () => this.playNote(65), 'keydown');
    this.keyboard.bind(']', () => this.stopNote(65), 'keyup');
    this.keyboard.bind('1', () => this.playNote(66), 'keydown');
    this.keyboard.bind('1', () => this.stopNote(66), 'keyup');
    this.keyboard.bind('2', () => this.playNote(67), 'keydown');
    this.keyboard.bind('2', () => this.stopNote(67), 'keyup');
    this.keyboard.bind('3', () => this.playNote(68), 'keydown');
    this.keyboard.bind('3', () => this.stopNote(68), 'keyup');
    this.keyboard.bind('4', () => this.playNote(69), 'keydown');
    this.keyboard.bind('4', () => this.stopNote(69), 'keyup');
    this.keyboard.bind('5', () => this.playNote(70), 'keydown');
    this.keyboard.bind('5', () => this.stopNote(70), 'keyup');
    this.keyboard.bind('6', () => this.playNote(71), 'keydown');
    this.keyboard.bind('6', () => this.stopNote(71), 'keyup');
    this.keyboard.bind('7', () => this.playNote(72), 'keydown'); // C5
    this.keyboard.bind('7', () => this.stopNote(72), 'keyup');
    this.keyboard.bind('8', () => this.playNote(73), 'keydown');
    this.keyboard.bind('8', () => this.stopNote(73), 'keyup');
    this.keyboard.bind('9', () => this.playNote(74), 'keydown');
    this.keyboard.bind('9', () => this.stopNote(74), 'keyup');
    this.keyboard.bind('0', () => this.playNote(75), 'keydown');
    this.keyboard.bind('0', () => this.stopNote(75), 'keyup');
    this.keyboard.bind('-', () => this.playNote(76), 'keydown');
    this.keyboard.bind('-', () => this.stopNote(76), 'keyup');
    this.keyboard.bind('=', () => this.playNote(77), 'keydown');
    this.keyboard.bind('=', () => this.stopNote(77), 'keyup');
  }

  disable() {
    this.instrument = null;
    this.keyboard.reset();
  }
}

export { Keyboard };
