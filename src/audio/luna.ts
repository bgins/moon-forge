import { Envelope, IEnvelopeSettings } from "./env-gen";
import {
  AudioContext,
  IAudioContext,
  IGainNode,
  IOscillatorOptions,
  IBiquadFilterOptions,
  IGainOptions,
  IBiquadFilterNode,
  IDynamicsCompressorNode
} from "standardized-audio-context";

import { IInstrument, INote } from "./audio";

class Luna implements IInstrument {
  audioContext: IAudioContext;
  masterGainNode: IGainNode;
  bottomFilter: IBiquadFilterNode;
  topFilter: IBiquadFilterNode;
  limiter: IDynamicsCompressorNode;
  notes: INote[] = [];
  oscillatorOptions: IOscillatorOptions;
  ampGainOptions: IGainOptions;
  ampEnvOptions: IEnvelopeSettings;
  filterOptions: IBiquadFilterOptions;
  filterEnvOptions: IEnvelopeSettings;
  masterGainOptions: IGainOptions;
  edo: number;
  baseFrequency: number;
  baseMidiNote: number;

  // give flags a type when the options are stable
  constructor(flags: any) {
    this.oscillatorOptions = {
      type: flags.oscillator,
      detune: 0,
      frequency: 261.625,
      channelCount: 2,
      channelCountMode: "max",
      channelInterpretation: "speakers"
    };
    this.ampGainOptions = {
      gain: 0.001,
      channelCount: 2,
      channelCountMode: "max",
      channelInterpretation: "speakers"
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
      channelCountMode: "max",
      channelInterpretation: "speakers"
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
      channelCountMode: "max",
      channelInterpretation: "speakers"
    };
    this.edo = +flags.temperamentInput;
    this.baseFrequency = +flags.baseFrequencyInput;
    this.baseMidiNote = +flags.baseMidiNoteInput;

    this.audioContext = new AudioContext();

    this.masterGainNode = this.audioContext.createGain();
    this.masterGainNode.gain.setValueAtTime(this.masterGainOptions.gain / 5, this.audioContext.currentTime);

    this.bottomFilter = this.audioContext.createBiquadFilter();
    this.bottomFilter.type = "highpass";
    this.bottomFilter.frequency.setValueAtTime(60, this.audioContext.currentTime);

    this.topFilter = this.audioContext.createBiquadFilter();
    this.topFilter.type = "lowpass";
    this.topFilter.frequency.setValueAtTime(18000, this.audioContext.currentTime);

    this.limiter = this.audioContext.createDynamicsCompressor();
    this.limiter.ratio.setValueAtTime(20, this.audioContext.currentTime);
    this.limiter.knee.setValueAtTime(0.0, this.audioContext.currentTime);
    this.limiter.threshold.setValueAtTime(0.0, this.audioContext.currentTime);
    this.limiter.attack.setValueAtTime(0.005, this.audioContext.currentTime);
    this.limiter.release.setValueAtTime(0.1, this.audioContext.currentTime);

    this.masterGainNode.connect(this.topFilter);
    this.topFilter.connect(this.bottomFilter);
    this.bottomFilter.connect(this.limiter);
    this.limiter.connect(this.audioContext.destination);
  }

  updateMasterGain(gain: number): void {
    this.masterGainNode.gain.setValueAtTime(gain / 5, this.audioContext.currentTime);
  }

  playNote(midiNote: number): void {
    if (this.notes[midiNote] && this.audioContext.currentTime < this.notes[midiNote].ampEnv.getEndTime()) {
      this.notes[midiNote].oscillator.stop(this.audioContext.currentTime + 1000);

      this.notes[midiNote].oscillator.type = this.oscillatorOptions.type;
      this.notes[midiNote].filterNode.type = this.filterOptions.type;
      this.notes[midiNote].filterNode.Q.setValueAtTime(this.filterOptions.Q, this.audioContext.currentTime);
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
        sustainLevel: this.filterEnvOptions.sustainLevel * this.filterOptions.frequency,
        releaseTime: this.filterEnvOptions.releaseTime,
        endValue: 60
      });
    } else {
      this.notes[midiNote] = null;
      // let freq = 261.625565 * 2 ** ((midiNote - 60) / 12);
      let freq = this.baseFrequency * 2 ** ((midiNote - this.baseMidiNote) / this.edo);
      console.log(freq);

      let oscillator = this.audioContext.createOscillator();
      oscillator.type = this.oscillatorOptions.type;
      oscillator.frequency.setValueAtTime(freq, this.audioContext.currentTime);

      const ampGainNode = this.audioContext.createGain();
      ampGainNode.gain.setValueAtTime(this.ampGainOptions.gain, this.audioContext.currentTime);

      const ampEnv = new Envelope(this.audioContext, {
        attackTime: this.ampEnvOptions.attackTime,
        decayTime: this.ampEnvOptions.decayTime,
        sustainLevel: this.ampEnvOptions.sustainLevel,
        releaseTime: this.ampEnvOptions.releaseTime
      });
      ampEnv.connect(ampGainNode.gain);

      const filterNode = this.audioContext.createBiquadFilter();
      filterNode.type = this.filterOptions.type;
      filterNode.Q.setValueAtTime(this.filterOptions.Q, this.audioContext.currentTime);
      filterNode.frequency.setValueAtTime(this.filterOptions.frequency, this.audioContext.currentTime);

      const filterEnv = new Envelope(this.audioContext, {
        attackTime: this.filterEnvOptions.attackTime,
        attackFinalLevel: this.filterOptions.frequency,
        decayTime: this.filterEnvOptions.decayTime,
        sustainLevel: this.filterEnvOptions.sustainLevel * this.filterOptions.frequency,
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
