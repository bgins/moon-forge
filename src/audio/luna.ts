import { Envelope, IEnvelopeOptions } from './env-gen';
import {
  AudioContext,
  IAudioContext,
  IGainNode,
  IOscillatorOptions,
  IBiquadFilterOptions,
  IGainOptions,
  IBiquadFilterNode,
  IDynamicsCompressorNode
} from 'standardized-audio-context';

import { IInstrument, INote } from './audio';

class Luna implements IInstrument {
  audioContext: IAudioContext;
  masterGainNode: IGainNode<IAudioContext>;
  bottomFilter: IBiquadFilterNode<IAudioContext>;
  topFilter: IBiquadFilterNode<IAudioContext>;
  limiter: IDynamicsCompressorNode<IAudioContext>;
  notes: INote[] = [];
  oscillatorOptions: IOscillatorOptions;
  ampGainOptions: IGainOptions;
  ampEnvOptions: IEnvelopeOptions;
  filterOptions: IBiquadFilterOptions;
  filterEnvOptions: IEnvelopeOptions;
  masterGainOptions: IGainOptions;
  divisions: number;
  baseFrequency: number;
  baseMidiNote: number;

  /*
   * Construct a new instance of Luna from flags and defaults
   */
  constructor(flags: any) {
    console.log('New Luna', flags);
    this.oscillatorOptions = {
      type: flags.oscillator,
      detune: 0,
      frequency: 261.625,
      channelCount: 2,
      channelCountMode: 'max',
      channelInterpretation: 'speakers'
    };
    this.ampGainOptions = {
      gain: 0.001,
      channelCount: 2,
      channelCountMode: 'max',
      channelInterpretation: 'speakers'
    };
    this.ampEnvOptions = {
      attackTime: flags.ampEnvAttack,
      decayTime: flags.ampEnvDecay,
      sustainLevel: flags.ampEnvSustain,
      releaseTime: flags.ampEnvRelease
    };
    this.filterOptions = {
      type: flags.filter,
      frequency: flags.filterFreq,
      Q: flags.filterQ,
      detune: 0,
      gain: 0,
      channelCount: 2,
      channelCountMode: 'max',
      channelInterpretation: 'speakers'
    };
    this.filterEnvOptions = {
      attackTime: flags.filterEnvAttack,
      decayTime: flags.filterEnvDecay,
      sustainLevel: flags.filterEnvSustain,
      releaseTime: flags.filterEnvRelease
    };
    this.masterGainOptions = {
      gain: flags.gain,
      channelCount: 2,
      channelCountMode: 'max',
      channelInterpretation: 'speakers'
    };
    this.divisions = flags.tuning.divisions;
    this.baseFrequency = flags.tuning.baseFrequency;
    this.baseMidiNote = flags.tuning.baseMidiNote;

    this.audioContext = new AudioContext();

    // all notes play through the master gain
    // the user controls a range from 0 to 1, but they actually get less
    this.masterGainNode = this.audioContext.createGain();
    this.masterGainNode.gain.setValueAtTime(
      this.masterGainOptions.gain / 10,
      this.audioContext.currentTime
    );

    // roll of low frequencies that might be dangerous
    this.bottomFilter = this.audioContext.createBiquadFilter();
    this.bottomFilter.type = 'highpass';
    this.bottomFilter.frequency.setValueAtTime(
      60,
      this.audioContext.currentTime
    );

    // roll off things that cannot be heard
    this.topFilter = this.audioContext.createBiquadFilter();
    this.topFilter.type = 'lowpass';
    this.topFilter.frequency.setValueAtTime(
      18000,
      this.audioContext.currentTime
    );

    // limit fast transients that would otherwise clip
    this.limiter = this.audioContext.createDynamicsCompressor();
    this.limiter.ratio.setValueAtTime(20, this.audioContext.currentTime);
    this.limiter.knee.setValueAtTime(0.0, this.audioContext.currentTime);
    this.limiter.threshold.setValueAtTime(0.0, this.audioContext.currentTime);
    this.limiter.attack.setValueAtTime(0.001, this.audioContext.currentTime);
    this.limiter.release.setValueAtTime(0.2, this.audioContext.currentTime);

    this.masterGainNode.connect(this.topFilter);
    this.topFilter.connect(this.bottomFilter);
    this.bottomFilter.connect(this.limiter);
    this.limiter.connect(this.audioContext.destination);
  }

  updateAudioParam(param: any): void {
    switch (param.name) {
      case 'oscillatorType':
        this.oscillatorOptions.type = param.val;
        break;
      case 'ampEnvAttack':
        this.ampEnvOptions.attackTime = param.val;
        break;
      case 'ampEnvDecay':
        this.ampEnvOptions.decayTime = param.val;
        break;
      case 'ampEnvSustain':
        this.ampEnvOptions.sustainLevel = param.val;
        break;
      case 'ampEnvRelease':
        this.ampEnvOptions.releaseTime = param.val;
        break;
      case 'filterType':
        this.filterOptions.type = param.val;
        break;
      case 'filterFreq':
        this.filterOptions.frequency = param.val;
        break;
      case 'filterQ':
        this.filterOptions.Q = param.val;
        break;
      case 'filterEnvAttack':
        this.filterEnvOptions.attackTime = param.val;
        break;
      case 'filterEnvDecay':
        this.filterEnvOptions.decayTime = param.val;
        break;
      case 'filterEnvSustain':
        this.filterEnvOptions.sustainLevel = param.val;
        break;
      case 'filterEnvRelease':
        this.filterEnvOptions.releaseTime = param.val;
        break;
      case 'masterGain':
        this.updateMasterGain(param.val);
        break;
      case 'divisions':
        this.divisions = param.val;
        break;
      case 'baseFrequency':
        this.baseFrequency = param.val;
        break;
      case 'baseMidiNote':
        this.baseMidiNote = param.val;
        break;
      default:
        console.log('unknown parameter adjustment');
    }
  }

  updateMasterGain(gain: number): void {
    this.masterGainNode.gain.setValueAtTime(
      gain / 10,
      this.audioContext.currentTime
    );
  }

  /*
   * Play a new note or retrigger a note that is still playing.
   * Retriggers occur based on the end time provided by the notes' amplitude envelope.
   */
  playNote(midiNote: number): void {
    if (
      this.notes[midiNote] &&
      this.audioContext.currentTime < this.notes[midiNote].ampEnv.getEndTime()
    ) {
      // reschedule the stop far into the future, longer than any note can be held
      // this.notes[midiNote].oscillator.stop(Number.MAX_VALUE);
      this.notes[midiNote].oscillator.stop(
        this.audioContext.currentTime + 10000
      );

      // update settings to take effect on retrigger
      this.notes[midiNote].oscillator.type = this.oscillatorOptions.type;
      this.notes[midiNote].filterNode.type = this.filterOptions.type;
      this.notes[midiNote].filterNode.Q.setValueAtTime(
        this.filterOptions.Q,
        this.audioContext.currentTime
      );
      this.notes[midiNote].filterNode.frequency.setValueAtTime(
        this.filterOptions.frequency,
        this.audioContext.currentTime
      );

      this.notes[midiNote].ampEnv.retrigger(this.audioContext.currentTime, {
        attackTime: this.ampEnvOptions.attackTime,
        decayTime: this.ampEnvOptions.decayTime,
        sustainLevel: this.ampEnvOptions.sustainLevel,
        releaseTime: this.ampEnvOptions.releaseTime
      });
      this.notes[midiNote].filterEnv.retrigger(this.audioContext.currentTime, {
        attackTime: this.filterEnvOptions.attackTime,
        attackFinalLevel: this.filterOptions.frequency,
        decayTime: this.filterEnvOptions.decayTime,
        sustainLevel:
          this.filterEnvOptions.sustainLevel * this.filterOptions.frequency,
        releaseTime: this.filterEnvOptions.releaseTime,
        endValue: 60
      });
    } else {
      // clear out old note entry if it exists
      this.notes[midiNote] = null;

      // conventionally: [freq = 261.625565 * 2 ** ((midiNote - 60) / 12);]
      // but we allow for arbitrary divisions of the octave here
      const freq =
        this.baseFrequency * 2 ** ((midiNote - this.baseMidiNote) / this.divisions);
      console.log(freq);

      const oscillator = this.audioContext.createOscillator();
      oscillator.type = this.oscillatorOptions.type;
      oscillator.frequency.setValueAtTime(freq, this.audioContext.currentTime);

      const ampGainNode = this.audioContext.createGain();
      ampGainNode.gain.setValueAtTime(
        this.ampGainOptions.gain,
        this.audioContext.currentTime
      );

      const ampEnv = new Envelope(this.audioContext, {
        attackTime: this.ampEnvOptions.attackTime,
        decayTime: this.ampEnvOptions.decayTime,
        sustainLevel: this.ampEnvOptions.sustainLevel,
        releaseTime: this.ampEnvOptions.releaseTime
      });
      ampEnv.connect(ampGainNode.gain);

      const filterNode = this.audioContext.createBiquadFilter();
      filterNode.type = this.filterOptions.type;
      filterNode.Q.setValueAtTime(
        this.filterOptions.Q,
        this.audioContext.currentTime
      );
      filterNode.frequency.setValueAtTime(
        this.filterOptions.frequency,
        this.audioContext.currentTime
      );

      const filterEnv = new Envelope(this.audioContext, {
        attackTime: this.filterEnvOptions.attackTime,
        attackFinalLevel: this.filterOptions.frequency,
        decayTime: this.filterEnvOptions.decayTime,
        sustainLevel:
          this.filterEnvOptions.sustainLevel * this.filterOptions.frequency,
        releaseTime: this.filterEnvOptions.releaseTime,
        endValue: 60
      });
      filterEnv.connect(filterNode.frequency);

      oscillator.connect(ampGainNode);
      ampGainNode.connect(filterNode);
      filterNode.connect(this.masterGainNode);

      const now = this.audioContext.currentTime;
      ampEnv.openGate(now);
      filterEnv.openGate(now);
      oscillator.start(now);

      const note: INote = {
        oscillator: oscillator,
        ampGainNode: ampGainNode,
        ampEnv: ampEnv,
        filterNode: filterNode,
        filterEnv: filterEnv
      };
      this.notes[midiNote] = note;
    }
  }

  /*
   * Stop a note.
   * The note is not cleared out here because its release time still needs to play out
   * and we may receive a retrigger from the user.
   */
  stopNote(midiNote: number): void {
    const oscillator = this.notes[midiNote].oscillator;
    const ampEnv = this.notes[midiNote].ampEnv;
    const filterEnv = this.notes[midiNote].filterEnv;

    const now = this.audioContext.currentTime;
    ampEnv.closeGate(now);
    filterEnv.closeGate(now);

    const stopAt = ampEnv.getEndTime();
    oscillator.stop(stopAt);
  }
}

export { Luna };
