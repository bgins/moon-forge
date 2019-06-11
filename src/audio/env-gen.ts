import { IAudioContext, IAudioParam } from "standardized-audio-context";

class Envelope {
  settings: IEnvelopeOptions = {
    initialLevel: 0.0001,
    attackTime: 0,
    attackFinalLevel: 1,
    decayTime: 0,
    sustainLevel: 1,
    releaseTime: 0,
    endValue: 0.0001
  };
  audioContext: IAudioContext;
  targetParam: IAudioParam;
  gateOpen: Boolean = false;
  gateOpenAt: number;
  startDecayAt: number;
  startSustainAt: number;
  gateClosedAt: number;
  valueAtGateClose: number;
  endAt: number;

  /*
   * Construct a new instance of Envelope
   */
  constructor(audioContext: IAudioContext, settings: IEnvelopeOptions) {
    this.audioContext = audioContext;

    this.settings.attackTime = settings.attackTime;
    this.settings.decayTime = settings.decayTime;
    this.settings.sustainLevel = settings.sustainLevel;
    this.settings.releaseTime = settings.releaseTime;

    if (settings.initialLevel) this.settings.initialLevel = settings.initialLevel;
    if (settings.attackFinalLevel) this.settings.attackFinalLevel = settings.attackFinalLevel;
    if (settings.endValue) this.settings.endValue = settings.endValue;
  }

  connect(targetParam: IAudioParam): void {
    this.targetParam = targetParam;
  }

  /*
   * Start the envelope by scheduling attack, decay, and sustain phases.
   */
  openGate(gateOpenAt: number): void {
    this.gateOpenAt = gateOpenAt;
    this.startDecayAt = gateOpenAt + this.settings.attackTime;
    this.startSustainAt = this.startDecayAt + this.settings.decayTime;

    this.targetParam.setValueAtTime(this.settings.initialLevel, gateOpenAt);
    this.targetParam.linearRampToValueAtTime(this.settings.attackFinalLevel, this.startDecayAt);
    this.targetParam.exponentialRampToValueAtTime(this.settings.sustainLevel, this.startSustainAt);

    this.gateOpen = true;
    this.endAt = Infinity;
  }

  /*
   * Close the envelope by scheduling the release phase.
   * We capture valueAtGateClose here because we may need it for a retrigger during the release phase.
   * See §1.6.2 of the spec for the formulas used to compute valueAtGateClose.
   * When available, cancelAndHoldAtTime may simplify some of this.
   */
  closeGate(gateClosedAt: number): void {
    this.gateClosedAt = gateClosedAt;
    this.endAt = gateClosedAt + this.settings.releaseTime;

    // valueAtGateClose should be calculated a bit into the future to account for the delay before we hold
    // and ramp down, but this is not done here yet
    if (this.gateOpen) {
      if (gateClosedAt < this.startDecayAt) {
        this.valueAtGateClose =
          this.settings.initialLevel +
          (this.settings.attackFinalLevel - this.settings.initialLevel) *
            ((gateClosedAt - this.gateOpenAt) / this.settings.attackTime);
      } else if (gateClosedAt >= this.startDecayAt && gateClosedAt < this.startSustainAt) {
        this.valueAtGateClose =
          this.settings.attackFinalLevel *
          Math.pow(
            this.settings.sustainLevel / this.settings.attackFinalLevel,
            (gateClosedAt - this.startDecayAt) / this.settings.decayTime
          );
      } else {
        this.valueAtGateClose = this.settings.sustainLevel;
      }

      // this.targetParam.cancelAndHoldAtTime(gateClosedAt);
      this.targetParam.cancelScheduledValues(gateClosedAt);
      this.targetParam.setValueAtTime(this.valueAtGateClose, gateClosedAt);
      this.targetParam.exponentialRampToValueAtTime(this.settings.endValue, this.endAt);
      this.gateOpen = false;
    }
  }

  /*
   * Retrigger the envelope.
   * Calculate the currentValue for the current envelope phase.
   * See §1.6.2 of the spec for the formulas used to compute currentValue.
   * Retriggers after the envelope has completed probably do not happen often,
   * but something better should happen in the case where they do.
   */
  retrigger(retriggerAt: number, newSettings: IEnvelopeOptions): void {
    // currentValue should be calculated a bit into the future to account for the delay before we
    // reschedule, but this is not done here yet
    if (this.gateOpen) {
      if (retriggerAt < this.startDecayAt) {
        console.log("retrigger in attack phase");
      } else if (retriggerAt >= this.startDecayAt && retriggerAt < this.startSustainAt) {
        console.log("retrigger in decay phase");

        const currentValue =
          this.settings.attackFinalLevel *
          Math.pow(
            this.settings.sustainLevel / this.settings.attackFinalLevel,
            (retriggerAt - this.startDecayAt) / this.settings.decayTime
          );

        this.reschedule(retriggerAt, currentValue, newSettings);
      } else {
        console.log("retrigger in sustain phase");
        this.reschedule(retriggerAt, this.settings.sustainLevel, newSettings);
      }
    } else {
      if (retriggerAt > this.gateClosedAt && retriggerAt <= this.gateClosedAt + this.settings.releaseTime) {
        console.log("retrigger in release phase");

        const currentValue =
          this.valueAtGateClose *
          Math.pow(
            this.settings.endValue / this.valueAtGateClose,
            (retriggerAt - this.gateClosedAt) / this.settings.releaseTime
          );

        this.reschedule(retriggerAt, currentValue, newSettings);
        this.gateOpen = true;
        this.endAt = Infinity;
      } else {
        console.log("retrigger after envelope completed");
      }
    }
  }

  /*
   * Reschedule after a retrigger.
   * This and retrigger may be simpler when cancelAndHoldAtTime is available.
   * We calculate the time when the attack would have started to get the right ramps.
   */
  private reschedule(retriggerAt: number, currentValue: number, newSettings: IEnvelopeOptions): void {
    console.log("rescheduling");

    // this.targetParam.cancelAndHoldAtTime(retriggerAt);
    this.targetParam.cancelScheduledValues(retriggerAt);
    this.targetParam.setValueAtTime(currentValue, retriggerAt);

    this.settings = newSettings;
    if (!newSettings.initialLevel) this.settings.initialLevel = 0.0001;
    if (!newSettings.attackFinalLevel) this.settings.attackFinalLevel = 1;
    if (!newSettings.endValue) this.settings.endValue = 0.0001;

    // compute would-have-been start time given the current value and the new attack time
    const attackWouldHaveStartedAt =
      retriggerAt -
      ((this.settings.attackTime * (currentValue - this.settings.initialLevel)) / this.settings.attackFinalLevel -
        this.settings.initialLevel);

    // reschedule with updated settings
    this.startDecayAt = attackWouldHaveStartedAt + this.settings.attackTime;
    this.startSustainAt = this.startDecayAt + this.settings.decayTime;
    this.targetParam.linearRampToValueAtTime(this.settings.attackFinalLevel, this.startDecayAt);
    this.targetParam.exponentialRampToValueAtTime(this.settings.sustainLevel, this.startSustainAt);

    this.gateOpenAt = attackWouldHaveStartedAt;
  }

  getEndTime(): number {
    return this.endAt;
  }
}

/*
 * More options may be added in the future.
 */
interface IEnvelopeOptions {
  initialLevel?: number;
  // delayTime: number;
  attackTime: number;
  attackFinalLevel?: number;
  // holdTime: number;
  decayTime: number;
  sustainLevel: number;
  releaseTime: number;
  endValue?: number;
  // attackCurveType?: string;
  // decayCurveType?: string;
  // releaseCurveType?: string;
  // velocityScaling: number;
}

export { Envelope, IEnvelopeOptions };
