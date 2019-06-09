import { IOscillatorNode, IGainNode, IBiquadFilterNode } from "standardized-audio-context";
import { Envelope } from "./env-gen";

interface IInstrument {
  playNote: (midiNote: number) => void;
  stopNote: (midiNote: number) => void;
}

interface INote {
  oscillator: IOscillatorNode;
  ampGainNode: IGainNode;
  ampEnv: Envelope;
  filterNode: IBiquadFilterNode;
  filterEnv: Envelope;
}

export { IInstrument, INote };
