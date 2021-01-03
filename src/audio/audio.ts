import { IOscillatorNode, IGainNode, IBiquadFilterNode, IAudioContext } from 'standardized-audio-context';
import { Envelope } from './env-gen';

interface IInstrument {
  playNote: (midiNote: number) => void;
  stopNote: (midiNote: number) => void;
  stopAllNotes: () => void;
}

interface INote {
  oscillator: IOscillatorNode<IAudioContext>;
  ampGainNode: IGainNode<IAudioContext>;
  ampEnv: Envelope;
  filterNode: IBiquadFilterNode<IAudioContext>;
  filterEnv: Envelope;
}

export { IInstrument, INote };
