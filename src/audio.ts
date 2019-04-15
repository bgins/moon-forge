import {
  IOscillatorNode,
  IGainNode,
  IBiquadFilterNode
} from "standardized-audio-context";

interface IInstrument {
  playNote: (midiNote: number) => void;
  stopNote: (midiNote: number) => void;
}

interface INote {
  oscillator: IOscillatorNode;
  ampGainNode: IGainNode;
  ampEnv: any;
  filterNode: IBiquadFilterNode;
  filterEnv: any;
  filterFreqGainNode: IGainNode;
}

interface IEnvelopeOptions {
  mode: string;
  attack: number;
  decay: number;
  sustain: number;
  release: number;
}

export { IEnvelopeOptions, IInstrument, INote };
