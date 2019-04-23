import Mousetrap from "mousetrap-ts";

import { IInstrument } from "../audio/audio";

class Keyboard {
  keyboard: Mousetrap = new Mousetrap(window.document.body);
  instrument: IInstrument;
  notesOn: boolean[] = [];

  playNote(midiNote: number): boolean {
    if (!this.notesOn[midiNote]) {
      this.instrument.playNote(midiNote);
      this.notesOn[midiNote] = true;
    }
    return false;
  }

  stopNote(midiNote: number): boolean {
    this.instrument.stopNote(midiNote);
    this.notesOn[midiNote] = false;
    return false;
  }

  enable(instrument: IInstrument) {
    this.instrument = instrument;

    this.keyboard.bind("z", () => this.playNote(45), "keydown");
    this.keyboard.bind("z", () => this.stopNote(45), "keyup");
    this.keyboard.bind("x", () => this.playNote(46), "keydown");
    this.keyboard.bind("x", () => this.stopNote(46), "keyup");
    this.keyboard.bind("c", () => this.playNote(47), "keydown");
    this.keyboard.bind("c", () => this.stopNote(47), "keyup");
    this.keyboard.bind("v", () => this.playNote(48), "keydown"); // C3
    this.keyboard.bind("v", () => this.stopNote(48), "keyup");
    this.keyboard.bind("b", () => this.playNote(49), "keydown");
    this.keyboard.bind("b", () => this.stopNote(49), "keyup");
    this.keyboard.bind("n", () => this.playNote(50), "keydown");
    this.keyboard.bind("n", () => this.stopNote(50), "keyup");
    this.keyboard.bind("m", () => this.playNote(51), "keydown");
    this.keyboard.bind("m", () => this.stopNote(51), "keyup");
    this.keyboard.bind(",", () => this.playNote(52), "keydown");
    this.keyboard.bind(",", () => this.stopNote(52), "keyup");
    this.keyboard.bind(".", () => this.playNote(53), "keydown");
    this.keyboard.bind(".", () => this.stopNote(53), "keyup");
    this.keyboard.bind("/", () => this.playNote(54), "keydown");
    this.keyboard.bind("/", () => this.stopNote(54), "keyup");
    this.keyboard.bind("a", () => this.playNote(55), "keydown");
    this.keyboard.bind("a", () => this.stopNote(55), "keyup");
    this.keyboard.bind("s", () => this.playNote(56), "keydown");
    this.keyboard.bind("s", () => this.stopNote(56), "keyup");
    this.keyboard.bind("d", () => this.playNote(57), "keydown");
    this.keyboard.bind("d", () => this.stopNote(57), "keyup");
    this.keyboard.bind("f", () => this.playNote(58), "keydown");
    this.keyboard.bind("f", () => this.stopNote(58), "keyup");
    this.keyboard.bind("g", () => this.playNote(59), "keydown");
    this.keyboard.bind("g", () => this.stopNote(59), "keyup");
    this.keyboard.bind("h", () => this.playNote(60), "keydown"); // C4, middle C
    this.keyboard.bind("h", () => this.stopNote(60), "keyup");
    this.keyboard.bind("j", () => this.playNote(61), "keydown");
    this.keyboard.bind("j", () => this.stopNote(61), "keyup");
    this.keyboard.bind("k", () => this.playNote(62), "keydown");
    this.keyboard.bind("k", () => this.stopNote(62), "keyup");
    this.keyboard.bind("l", () => this.playNote(63), "keydown");
    this.keyboard.bind("l", () => this.stopNote(63), "keyup");
    this.keyboard.bind(";", () => this.playNote(64), "keydown");
    this.keyboard.bind(";", () => this.stopNote(64), "keyup");
    this.keyboard.bind("'", () => this.playNote(65), "keydown");
    this.keyboard.bind("'", () => this.stopNote(65), "keyup");
    this.keyboard.bind("q", () => this.playNote(66), "keydown");
    this.keyboard.bind("q", () => this.stopNote(66), "keyup");
    this.keyboard.bind("w", () => this.playNote(67), "keydown");
    this.keyboard.bind("w", () => this.stopNote(67), "keyup");
    this.keyboard.bind("e", () => this.playNote(68), "keydown");
    this.keyboard.bind("e", () => this.stopNote(68), "keyup");
    this.keyboard.bind("r", () => this.playNote(69), "keydown");
    this.keyboard.bind("r", () => this.stopNote(69), "keyup");
    this.keyboard.bind("t", () => this.playNote(70), "keydown");
    this.keyboard.bind("t", () => this.stopNote(70), "keyup");
    this.keyboard.bind("y", () => this.playNote(71), "keydown");
    this.keyboard.bind("y", () => this.stopNote(71), "keyup");
    this.keyboard.bind("u", () => this.playNote(72), "keydown"); // C5
    this.keyboard.bind("u", () => this.stopNote(72), "keyup");
    this.keyboard.bind("i", () => this.playNote(73), "keydown");
    this.keyboard.bind("i", () => this.stopNote(73), "keyup");
    this.keyboard.bind("o", () => this.playNote(74), "keydown");
    this.keyboard.bind("o", () => this.stopNote(74), "keyup");
    this.keyboard.bind("p", () => this.playNote(75), "keydown");
    this.keyboard.bind("p", () => this.stopNote(75), "keyup");
    this.keyboard.bind("[", () => this.playNote(76), "keydown");
    this.keyboard.bind("[", () => this.stopNote(76), "keyup");
    this.keyboard.bind("]", () => this.playNote(77), "keydown");
    this.keyboard.bind("]", () => this.stopNote(77), "keyup");
    this.keyboard.bind("\\", () => this.playNote(78), "keydown");
    this.keyboard.bind("\\", () => this.stopNote(78), "keyup");
  }

  disable() {
    this.instrument = null;
    this.keyboard.reset();
  }
}

export { Keyboard };
